Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E01AC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F0AD2067C
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 13:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F0AD2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D65E56B0277; Thu,  6 Jun 2019 09:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D16C46B0278; Thu,  6 Jun 2019 09:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2E7D6B0279; Thu,  6 Jun 2019 09:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56B296B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 09:44:04 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id x8so14987lff.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 06:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vm4btAOsyOUR0oYjzNf92pqRfluADuwslifIy4VqXiM=;
        b=lFWHU8qExxmqAJxsFRbBYkLwR2oGApIdzpNqpoF5wwgQ38j8J/G7ioA7LVSFLZOuYI
         Cc5XCOUtdGSOXqW4pmOM/AF9VNw9bV2FsVKJo+YMRMEDJyZza+fXTedZoEXmd2ufQvyn
         8jIDiZqMQesxjJRK11GU8j0HIOjZh93WFW47JoIeNeQsqHDsQCzjttFIfcc5X2XK87cx
         BeOlsBm2k7Ytr9KBijcSIMLL/hDNF37gU+BxnzKm89HaZDrCaGU8RZxnTrMIJYbGc2M5
         vM8GzYm8wqQ5h+7PDXlQvuseW0lqd0ft+Vpl9TUomXenYq2B8+0agar6qZcbDLJN6ULU
         vPVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVtdv8LhKDGMRKaxqqkd532+Iat9hWvOmPgmP/hgMRCU/FA85/o
	QVmG/FWCyPSBH/qE0sFxUG8gTkxUYU2tmj7XxRTzH4+Ernbl3Bpc/wgfJkMJyWnrsxyF5pmZm8B
	DWt1zQW7rW60SuXr7Dqohnv1Czb9iBUlrJMxlAZWMcFfCOAiDpVvThzf2rtqxxE0giA==
X-Received: by 2002:a2e:9284:: with SMTP id d4mr25094466ljh.26.1559828643717;
        Thu, 06 Jun 2019 06:44:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9hUiyfylo5G750/1PbXMSyDzOhJ1DnWZYPPcrVRUTvmBhHqGhSGU4S6WQmenO7YjfsoBn
X-Received: by 2002:a2e:9284:: with SMTP id d4mr25094393ljh.26.1559828642261;
        Thu, 06 Jun 2019 06:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559828642; cv=none;
        d=google.com; s=arc-20160816;
        b=pyR43zFBf8uReO7+GG0kEYnZG7/73KY9yL4vvkUUdDvtVpoX2YHaCpQ3qJnkBtG6FG
         O7M02hlhaq9mPYyNDglezrIV5Y5p264D6XwIzLJgNzHTVIu3QOYZx0Cc0MNBJpclFiH8
         TM4nnSjVhoRK9gohCHPvijXSCYlIk+KbyFpNQjhAP33c4tcOpm42h4PEia1zzyswqb68
         +jwYwMKosl0W60lPntaCziCpFm5OTPkHosgNGUJTF/VBUEavFlvayZh0gDCYQ1Je/Om4
         Xc5mNIg8iIkBweCLy6a/dCY5pyU/jjX5KlwGbrjlXECLQsYne9vf/aJ8NhXwBO0X85br
         y6EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vm4btAOsyOUR0oYjzNf92pqRfluADuwslifIy4VqXiM=;
        b=lcDBWgNQglDpXhIE51TBWFhx4kPOz6NDx8J9VSscKF3oN0H8tLmMs3rJ1Icjfr+IJV
         B5qKL2ktz/NMqp9KsFprz+5Kefj4CVGvbUbALJfKyQhY6n4UwB4SqYl6RNKJHCNLFb1c
         e9FzqIKQB/eNgH+GBRo8RqJ0DpXKcggeYydPtpyw0vSbJ3Xc4ykElXcaV73Wg50dRYBh
         +0Oqn7p1/opPlRMdiDAcF6yXgRXUD3gtjUMESMSLvI7r11ymDc7i8dXCoEiAikDYyOma
         sLzMp25678WlWOYAH6vEuckYp5Da90Yy8kiO3+bXzk7f47b+D83PcIVkdqhgZoypNHYR
         mt/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j24si2161614ljg.57.2019.06.06.06.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 06:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hYsgC-0008Uh-Hh; Thu, 06 Jun 2019 16:43:44 +0300
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>,
 akpm@linux-foundation.org, bfields@redhat.com, chris@chrisdown.name,
 daniel.m.jordan@oracle.com, guro@fb.com, hannes@cmpxchg.org,
 jlayton@kernel.org, laoar.shao@gmail.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-nfs@vger.kernel.org, mgorman@techsingularity.net,
 mhocko@suse.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com,
 yang.shi@linux.alibaba.com
References: <0000000000005a4b99058a97f42e@google.com>
 <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
 <20190606131334.GA24822@fieldses.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
Date: Thu, 6 Jun 2019 16:43:44 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606131334.GA24822@fieldses.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.06.2019 16:13, J. Bruce Fields wrote:
> On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
>> This may be connected with that shrinker unregistering is forgotten on error path.
> 
> I was wondering about that too.  Seems like it would be hard to hit
> reproduceably though: one of the later allocations would have to fail,
> then later you'd have to create another namespace and this time have a
> later module's init fail.

Yes, it's had to bump into this in real life.

AFAIU, syzbot triggers such the problem by using fault-injections
on allocation places should_failslab()->should_fail(). It's possible
to configure a specific slab, so the allocations will fail with
requested probability.
 
> This is the patch I have, which also fixes a (probably less important)
> failure to free the slab cache.
> 
> --b.
> 
> commit 17c869b35dc9
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Jun 5 18:03:52 2019 -0400
> 
>     nfsd: fix cleanup of nfsd_reply_cache_init on failure
>     
>     Make sure everything is cleaned up on failure.
>     
>     Especially important for the shrinker, which will otherwise eventually
>     be freed while still referred to by global data structures.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index ea39497205f0..3dcac164e010 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -157,12 +157,12 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
>  	nn->nfsd_reply_cache_shrinker.seeks = 1;
>  	status = register_shrinker(&nn->nfsd_reply_cache_shrinker);
>  	if (status)
> -		return status;
> +		goto out_nomem;
>  
>  	nn->drc_slab = kmem_cache_create("nfsd_drc",
>  				sizeof(struct svc_cacherep), 0, 0, NULL);
>  	if (!nn->drc_slab)
> -		goto out_nomem;
> +		goto out_shrinker;
>  
>  	nn->drc_hashtbl = kcalloc(hashsize,
>  				sizeof(*nn->drc_hashtbl), GFP_KERNEL);
> @@ -170,7 +170,7 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
>  		nn->drc_hashtbl = vzalloc(array_size(hashsize,
>  						 sizeof(*nn->drc_hashtbl)));
>  		if (!nn->drc_hashtbl)
> -			goto out_nomem;
> +			goto out_slab;
>  	}
>  
>  	for (i = 0; i < hashsize; i++) {
> @@ -180,6 +180,10 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
>  	nn->drc_hashsize = hashsize;
>  
>  	return 0;
> +out_slab:
> +	kmem_cache_destroy(nn->drc_slab);
> +out_shrinker:
> +	unregister_shrinker(&nn->nfsd_reply_cache_shrinker);
>  out_nomem:
>  	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
>  	return -ENOMEM;

Looks OK for me. Feel free to add my reviewed-by if you want.

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

