Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFC3CC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:47:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6109120825
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 03:47:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="A7b3B9MI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6109120825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DADF76B000C; Thu,  6 Jun 2019 23:47:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D386B6B000E; Thu,  6 Jun 2019 23:47:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8216B0266; Thu,  6 Jun 2019 23:47:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 904896B000C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 23:47:36 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id h12so337469otn.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 20:47:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=bZvuY/i6GNCDoB9S/9ycfjQg/GlXUjYF/GtxOCf0uXU=;
        b=UmExPAKauKrxSf9xy8ZcouYT+c2FWmE46ALFJBcdZ3jtzKbSCYyR1poHgigQlGBSrd
         g2uqZvrBxrzFN2tWX2G4EuGrb//6vuoT2wXwOwUzxpcAniLTvoztJEIg5EZGnENS+Nje
         Wp8FBNPpgL1rb7/28t5CAB8Gn0FYIriu0gXDGogB4dElY2IpFkDQLkzssf6HVVw583of
         ekxJfz5erwBBcrxD/Ks8pR397VtOAnOJ/0bcPqDevYp2+q3LELdiz0Rj7KcnIQqVky1F
         Y6zjwBQc2Y3Fq9MlLjBiuuDl0hPwEQucK27dwdujLCtcjygPC2Sbn03Vd1B8ygCf2/ys
         IZTQ==
X-Gm-Message-State: APjAAAWTxlwZyITb7RB1AsiXMyGLgqDvAgPBzFv07mNuIMpnigPg8Q3W
	+c1V+c3jvxx9P008eIFgu54b32mMnZn2vmB3zxvBxuW2ZjznrGkWPbdso2QypvnVOqVp4xChLQN
	gFvz8BQXRX3dw2tQt4I4UUuBWhyXuMBLsO8VtuRTbj1M4J7zfqhVk+9pddj9TInJbjw==
X-Received: by 2002:a9d:be9:: with SMTP id 96mr17085914oth.49.1559879256205;
        Thu, 06 Jun 2019 20:47:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/M0tUI2jRLkIxSnFeOmjewqS9XbZ023kyaHy3sDGPvAUOc/M7UMlWD0BZDsfbVoKLBJw6
X-Received: by 2002:a9d:be9:: with SMTP id 96mr17085885oth.49.1559879255507;
        Thu, 06 Jun 2019 20:47:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559879255; cv=none;
        d=google.com; s=arc-20160816;
        b=e2OQ5sxHG15r87fwTpJPLJSH49hwYFFv1HbqSHgdsWdTNSYAdVJNnV5TV+Sp4bf8Fm
         9lrdSPcspJR4Edd8FEpWNzG33h8AOGJRGFesHOXfS25nrgEfS93g+ZQv5d0c8avoJtSL
         k7P6ECDbd8yFd5Ypy+VN8yV7bG0BNzP6BkKPFDBz3MXPTu1Km+NiQuWxQX7R6ndPuf5d
         xNKvAvGh2iosqA7d8ps+GfOkacPgdwwMN2IioZnPa1xUyVxun5CkkgI/nXfXIoMptpcE
         bDeaMebsOJRvxRC1l8UYc5O1WE4Fjf+LJKEGwiRuTnmrj9XU69RX7x/hyYj/5zVDEQcx
         RDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=bZvuY/i6GNCDoB9S/9ycfjQg/GlXUjYF/GtxOCf0uXU=;
        b=w5aVzSDYYBETbrv2NVuNctY3Yo0ZJoOLdsatxYPexUILlsC2szwhgFTlfgZPg6sLfn
         0kwQ+4NM9ehLgMGU4KsGvu00l337juOmwkqDBtIFmniiqwv8VjyaPf58UDhnQi9iuRc8
         1OrjaThHYkoDrToI1o6lZo2M9MLR7bTMNKsXwFoTOgK60ZXj9mBm53TDhYIHgPnYVKzx
         0UAkdgdC03U1JG7p+CzveJvkwNZqejmjLBqHj0p1UYJdOE5cSN/g6Msee7jioVXc8MrS
         MG8JxF80HEbvCiuQ03Uszf3OGOYCEL97EAZGeqixAResC5HhtLU84u5b6F4Y15UgfMbH
         J8uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A7b3B9MI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s8si632802oig.219.2019.06.06.20.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 20:47:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A7b3B9MI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9de530000>; Thu, 06 Jun 2019 20:47:32 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 20:47:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 20:47:34 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 03:47:28 +0000
Subject: Re: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-12-jgg@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <3edc47bd-e8f6-0e65-5844-d16901890637@nvidia.com>
Date: Thu, 6 Jun 2019 20:47:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-12-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559879252; bh=bZvuY/i6GNCDoB9S/9ycfjQg/GlXUjYF/GtxOCf0uXU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=A7b3B9MIZYE2j+v3mXjKis5leb/eVo7kaz4HeWlw96qB4oJdGtB86PLsdX70nI9ax
	 x3/wFcbHrGloJGNYAG+xmMO+ti4FMUCxIPFMH+21XCi150Jn6NaUYQx0kq04Bf6jKj
	 LkktxvYAUlD5Ove8fENnNtyaieAVfZiEKInsVhqpxtqRzXZAStQjBmX1EmXNW9wVD0
	 qRd9vtBuVuOZRuz1WMqrpCwQNfKp37kqYjYZ8hbRrh6CM+QdjaHZLXTSzrJBYQvPb/
	 tMZ+XTvLFuSez92di1HCFzs1bE/CVkNOISup9kLBndzsy8o/zyKWeRc6duPhudgnyM
	 tfNzpFVVgkGIg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> hmm_release() is called exactly once per hmm. ops->release() cannot
> accidentally trigger any action that would recurse back onto
> hmm->mirrors_sem.
> 
> This fixes a use after-free race of the form:
> 
>        CPU0                                   CPU1
>                                            hmm_release()
>                                              up_write(&hmm->mirrors_sem);
>  hmm_mirror_unregister(mirror)
>   down_write(&hmm->mirrors_sem);
>   up_write(&hmm->mirrors_sem);
>   kfree(mirror)
>                                              mirror->ops->release(mirror)
> 
> The only user we have today for ops->release is an empty function, so this
> is unambiguously safe.
> 
> As a consequence of plugging this race drivers are not allowed to
> register/unregister mirrors from within a release op.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  mm/hmm.c | 28 +++++++++-------------------
>  1 file changed, 9 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 709d138dd49027..3a45dd3d778248 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -136,26 +136,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  	WARN_ON(!list_empty(&hmm->ranges));
>  	mutex_unlock(&hmm->lock);
>  
> -	down_write(&hmm->mirrors_sem);
> -	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
> -					  list);
> -	while (mirror) {
> -		list_del_init(&mirror->list);
> -		if (mirror->ops->release) {
> -			/*
> -			 * Drop mirrors_sem so the release callback can wait
> -			 * on any pending work that might itself trigger a
> -			 * mmu_notifier callback and thus would deadlock with
> -			 * us.
> -			 */
> -			up_write(&hmm->mirrors_sem);
> +	down_read(&hmm->mirrors_sem);

This is cleaner and simpler, but I suspect it is leading to the deadlock
that Ralph Campbell is seeing in his driver testing. (And in general, holding
a lock during a driver callback usually leads to deadlocks.)

Ralph, is this the one? It's the only place in this patchset where I can
see a lock around a callback to driver code, that wasn't there before. So
I'm pretty sure it is the one...


thanks,
-- 
John Hubbard
NVIDIA

