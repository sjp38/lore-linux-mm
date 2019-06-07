Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D399EC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A115208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RnlfJ4dm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A115208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D22176B0270; Fri,  7 Jun 2019 17:37:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD2146B0271; Fri,  7 Jun 2019 17:37:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC1196B0272; Fri,  7 Jun 2019 17:37:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C21F6B0270
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 17:37:11 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b75so3324675ywh.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 14:37:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=y2l4fZUHEu5jTe1akMwM/C9NdR8qPwwFFoigSM6h8EI=;
        b=J06LRz8LpgBKeLfPAbl7vUMXi3dNbLhOxvSEYQ3uCwnsn/21Fg/Iq7OfK4oTmE2WhD
         ysUb9OktI8WzBvPxfwMIyRnf57Y4guYynqSa6+qSaE62GSfjCl4PF49o64CVF662RFQB
         lXcS3WJEeTXzb+6JvEmCUIizubybndr3unEB5cKJMPt/0Qbg7c0FAa3VkhEb+3B8+h2a
         UpS2SVd3pLpy9Su45SHr2cDWW+zrM4XJXmTjQny8YFZOAkT+yPlt/Ii4fcGHX2UzEv8n
         sXYrBh9pZLMCLf9+KNHFZ3LhQHgiNM2imj/Ddo/8Rp8V3Rqxb8l4LNnQUMKgIJtxKhBq
         xPCQ==
X-Gm-Message-State: APjAAAVIJ2fDU34km5oT5LQZo6sax3DeetAt/fpBVLFh5bCTT25QWSnV
	gBzd6WGIlWTDY0HGJnQFt6jRXAFRXuV39D6YEJni/zxahRq5KJOJvT0pbxZQNIm8/IJY1HZjDR5
	5qjaEJNTWyhTxyuKsGWj4Fmeqj+7h90ztln91qcYPM4ejM032GgmnnbyTHUAH21dNTA==
X-Received: by 2002:a81:57d6:: with SMTP id l205mr942498ywb.323.1559943431336;
        Fri, 07 Jun 2019 14:37:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw86wILaD9nJFnbRIKyT5ntv+5FB3Qtulq6Jn9mBog3TrpPrAYc7qPLb746/wrzQD9Rnwvd
X-Received: by 2002:a81:57d6:: with SMTP id l205mr942469ywb.323.1559943430565;
        Fri, 07 Jun 2019 14:37:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559943430; cv=none;
        d=google.com; s=arc-20160816;
        b=qt836aeP2gNYv1cuvKqpDp3nOCMYDkWzBJuAr3yEpS1Djy/566X0Bvvl7nCHkUczXd
         RDZSutwfTPD3TWG1jX7ov7KLSKCGDBAGx2ugQaBZvSup4bxvi+QXR41WWVT6bqgRMXjE
         Xxf+TWm/Xx3EAXiFYTDUug6bx08DwZdNHe9hrvQSTnxvK31CvW19+egtaVC62C9Itvkw
         jDdpurR6wKyHYiMrRhrQoWDMWGElVa3VlPh2FQL2cYqx2ZSb3BTonol0km4csjmfMQou
         Uh9bjXD/d3G3MW8aGOS3kHEX6C2XzlL5TG91QmC19AYnLiaXEunYW83eIuMekuOKAkuN
         3P/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=y2l4fZUHEu5jTe1akMwM/C9NdR8qPwwFFoigSM6h8EI=;
        b=FFxsytQG8sr1BTJOcG/RyYgKg1VvlQ8+vXpM2DoqJ0andyqiN57qRO8q1JDtLo7d0O
         nVsjK50StTa2WGMuonCLLDuv9XMq86s15jchulGwlpHbFBNsaCrY794/IC9430o+/G/R
         7NBB3UmF5i8aaGn4r+QUVkQpjd3suozlfsP3EPKpRwx+OvAV7FWCa76rie1XaHz7TjZg
         jOBiQKuxWOY0U/Z9GKcQoYnGI4QGPoub3N6uewODMR9pW4GovIRU1NgsUjoCuDMqJIyc
         TmkqcKb+xg7qfM7ovoH6V1SHUZFSII681oPRhLfG4IOK3hCD6spwZ16VYB1Id9lIIrJY
         qzyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RnlfJ4dm;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a15si902555ybl.477.2019.06.07.14.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 14:37:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RnlfJ4dm;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfad8f60000>; Fri, 07 Jun 2019 14:36:54 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 14:37:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 14:37:09 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 21:37:08 +0000
Subject: Re: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-12-jgg@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <61ea869d-43d2-d1e5-dc00-cf5e3e139169@nvidia.com>
Date: Fri, 7 Jun 2019 14:37:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-12-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559943414; bh=y2l4fZUHEu5jTe1akMwM/C9NdR8qPwwFFoigSM6h8EI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=RnlfJ4dm9rb0aajSZnsU9ebXq5RZwM9NQ6DFLnQY6ATII69dnW/Te8wQjfhe7r9vF
	 tEkAQi10ucVG/0ko1HSqhs2P2B2UN6ppGw5i2TEsNNH3cIYD0rIEUXdM2sBPUVPbYA
	 viPeu5qYlbn1t0Ao/MsRAtiG1Rpgnv4uI3LKaiiL8X19btt0dk/ntEdPf48yJPPlMJ
	 5flOt6tYZ+Er1DurblUkrJ564/gbDV6H4BNQmjwQjhJKOMOJdHjzH4kT/FSo2Ri6zb
	 h6Mg6XPkLg6wxI6GhqJUslefH70kHL/cWMQinfvEya8exHGBjsX7pZlMogsYdPzHat
	 nooGWxUI1zOEg==
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
>         CPU0                                   CPU1
>                                             hmm_release()
>                                               up_write(&hmm->mirrors_sem);
>   hmm_mirror_unregister(mirror)
>    down_write(&hmm->mirrors_sem);
>    up_write(&hmm->mirrors_sem);
>    kfree(mirror)
>                                               mirror->ops->release(mirror)
> 
> The only user we have today for ops->release is an empty function, so this
> is unambiguously safe.
> 
> As a consequence of plugging this race drivers are not allowed to
> register/unregister mirrors from within a release op.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

I agree with the analysis above but I'm not sure that release() will
always be an empty function. It might be more efficient to write back
all data migrated to a device "in one pass" instead of relying
on unmap_vmas() calling hmm_start_range_invalidate() per VMA.

I think the bigger issue is potential deadlocks while calling
sync_cpu_device_pagetables() and tasks calling hmm_mirror_unregister():

Say you have three threads:
- Thread A is in try_to_unmap(), either without holding mmap_sem or with
mmap_sem held for read.
- Thread B has some unrelated driver calling hmm_mirror_unregister().
This doesn't require mmap_sem.
- Thread C is about to call migrate_vma().

Thread A                Thread B                 Thread C
try_to_unmap            hmm_mirror_unregister    migrate_vma
----------------------  -----------------------  ----------------------
hmm_invalidate_range_start
down_read(mirrors_sem)
                         down_write(mirrors_sem)
                         // Blocked on A
                                                   device_lock
device_lock
// Blocked on C
                                                   migrate_vma()
                                                   hmm_invalidate_range_s
                                                   down_read(mirrors_sem)
                                                   // Blocked on B
                                                   // Deadlock

Perhaps we should consider using SRCU for walking the mirror->list?

> ---
>   mm/hmm.c | 28 +++++++++-------------------
>   1 file changed, 9 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 709d138dd49027..3a45dd3d778248 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -136,26 +136,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   	WARN_ON(!list_empty(&hmm->ranges));
>   	mutex_unlock(&hmm->lock);
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
> +	list_for_each_entry(mirror, &hmm->mirrors, list) {
> +		/*
> +		 * Note: The driver is not allowed to trigger
> +		 * hmm_mirror_unregister() from this thread.
> +		 */
> +		if (mirror->ops->release)
>   			mirror->ops->release(mirror);
> -			down_write(&hmm->mirrors_sem);
> -		}
> -		mirror = list_first_entry_or_null(&hmm->mirrors,
> -						  struct hmm_mirror, list);
>   	}
> -	up_write(&hmm->mirrors_sem);
> +	up_read(&hmm->mirrors_sem);
>   
>   	hmm_put(hmm);
>   }
> @@ -287,7 +277,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
>   	struct hmm *hmm = mirror->hmm;
>   
>   	down_write(&hmm->mirrors_sem);
> -	list_del_init(&mirror->list);
> +	list_del(&mirror->list);
>   	up_write(&hmm->mirrors_sem);
>   	hmm_put(hmm);
>   	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
> 

