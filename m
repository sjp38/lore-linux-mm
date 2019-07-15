Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4EFBC7618A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 504FC20868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 504FC20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD87B6B0003; Sun, 14 Jul 2019 23:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A88E36B0006; Sun, 14 Jul 2019 23:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 950B36B0007; Sun, 14 Jul 2019 23:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8036B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:43:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so9630788pfz.10
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 20:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=c4jn8W8MSwPoAyUKfRXsob5nEN9cj5M9g3s9JoW/oaI=;
        b=HoDT+2jQ1W+WUMjp2aKs167UcnJ2M+83HIVUnfpPCSoMnRWiP3TZOWGK3IEheW5N//
         4eFpTN3iFaPTynmEkyHygwo3bi4tVfmA3WDRPq0xipa7xmX8DDMWFB/T54jNi54gz/K8
         e1+OeoY7CCsMq/llfqZA49u3cTk+zSOILUNYtNFADXWoc+h5jW98sZGVEM5KGbXT8FK8
         sNYMgjxbaep6BBi9Fc/lOsK/gh0xwZ/kGXfxWzrz4P1c5BdBhgzg02uZryfH4ClTeSiZ
         KZfQk6iK/PzGdwOxRTMs17wFP6mCRJ3P+bQKhsaZ7/Cv+34IfpZnTNaPpSRyf3sgbjdx
         o/VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU3HZ753OaUpLUg+7CGLrFHZSYVaDGoxEepCJ4NzOou0i/5gTTD
	e+JiDWQu+VCguwPicdfKTss2wow+aN6vuUks4uhRJL8vPIIQlXm5hQB0ElCOEEZ2f42Yg41Bhal
	0BUgkGEdT78015vF8qby44p5joTk9S8NZQJkKrH/EuVofXjgjww6Clwexf6RKBdg4ig==
X-Received: by 2002:a63:f959:: with SMTP id q25mr24534619pgk.357.1563162221860;
        Sun, 14 Jul 2019 20:43:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl47bDg7+RP3iaXxPUs9qGWX4BU+EsTtpwCBSUP7nRdsNrzFXoLAt7donhSulYxWRsCF/J
X-Received: by 2002:a63:f959:: with SMTP id q25mr24534546pgk.357.1563162220822;
        Sun, 14 Jul 2019 20:43:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563162220; cv=none;
        d=google.com; s=arc-20160816;
        b=XNSfYyLs3TN+zcKsSX+imNjnVgMD+nyb1cD9Od7KAL/Acl524nNTIoLlUHJRn6lqrK
         sB3gIt/8ZtvfWXQP6wj1Kpswb+tP8QumiEEc/IdFVq/s8cnS5NA/VnwdtLRL/s+whHLx
         qDdD43VO2Sq5f7LUSMdbCz4jdJF5App+TgfDGbspmjvRi61XXRav5KDF/YeeSqWYQzQ4
         UrWYEVBqqIraeGhNmBbQUSnRFSLkx7erc4e8dTO2EBWLB4OTeDGZYkj6YtG2twN7fuQ8
         cR05cBjFPrbiI+zMwK4eUQlz91TjrCOhr7B8DfK27UDugm+DXMz9XfjpfX0ezTr2p9zI
         zjdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=c4jn8W8MSwPoAyUKfRXsob5nEN9cj5M9g3s9JoW/oaI=;
        b=alS8qbkd5U2QP3KaXEwxxFDItavW5OEtt2EjZAtv5eMDhPhTMTowwRkYhMsjnwtzXi
         LPpCQaH56Oj2EUgNDCZ1Bw6SlNexdXzG5rMcn3MasyoOC3+TYU/HdE5qtWiJHfv5Ld+T
         Ws8RWzb0uvo2sLDiFlT6O0O8Wi58d9t+jONCUOYAJZ4iMAKvezXUxu7jzQQHFFse9fsI
         4BdJbc9Y/MoB64o0kEN4CwUwaMwrvrjk9KwhZ78VRCgKeZNiByX3vMb8YWWR50pJO0YV
         Lsq/O8ZjFPmJaYPc2m3HiObvsaZJlniOo89UAs8rB20nCjJJAmePhjb72qB//rGTX+LN
         5k5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id b40si14563756plb.426.2019.07.14.20.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 20:43:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TWuGjYt_1563162210;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWuGjYt_1563162210)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 15 Jul 2019 11:43:38 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: David Rientjes <rientjes@google.com>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1907131230280.246128@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <95f03095-3284-996c-83f9-c049aebc49c3@linux.alibaba.com>
Date: Sun, 14 Jul 2019 20:43:27 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907131230280.246128@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/13/19 12:39 PM, David Rientjes wrote:
> On Sat, 13 Jul 2019, Yang Shi wrote:
>
>> When running ltp's oom test with kmemleak enabled, the below warning was
>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>> passed in:
>>
>> WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
>> Modules linked in: loop dax_pmem dax_pmem_core
>> ip_tables x_tables xfs virtio_net net_failover virtio_blk failover
>> ata_generic virtio_pci virtio_ring virtio libata
>> CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
>> RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
>> ...
>>   kmemleak_alloc+0x4e/0xb0
>>   kmem_cache_alloc+0x2a7/0x3e0
>>   ? __kmalloc+0x1d6/0x470
>>   ? ___might_sleep+0x9c/0x170
>>   ? mempool_alloc+0x2b0/0x2b0
>>   mempool_alloc_slab+0x2d/0x40
>>   mempool_alloc+0x118/0x2b0
>>   ? __kasan_check_read+0x11/0x20
>>   ? mempool_resize+0x390/0x390
>>   ? lock_downgrade+0x3c0/0x3c0
>>   bio_alloc_bioset+0x19d/0x350
>>   ? __swap_duplicate+0x161/0x240
>>   ? bvec_alloc+0x1b0/0x1b0
>>   ? do_raw_spin_unlock+0xa8/0x140
>>   ? _raw_spin_unlock+0x27/0x40
>>   get_swap_bio+0x80/0x230
>>   ? __x64_sys_madvise+0x50/0x50
>>   ? end_swap_bio_read+0x310/0x310
>>   ? __kasan_check_read+0x11/0x20
>>   ? check_chain_key+0x24e/0x300
>>   ? bdev_write_page+0x55/0x130
>>   __swap_writepage+0x5ff/0xb20
>>
>> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
>> __GFP_NOFAIL set all the time due to commit
>> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
>> with fault injection").
>>
> It only clears __GFP_DIRECT_RECLAIM provisionally to see if the allocation
> would immediately succeed before falling back to the elements in the
> mempool.  If that fails, and the mempool is empty, mempool_alloc()
> attempts the allocation with __GFP_DIRECT_RECLAIM.  So for the problem
> described here, I think what we really want is this:
>
> diff --git a/mm/mempool.c b/mm/mempool.c
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -386,7 +386,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>   	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
>   	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
>   
> -	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
> +	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO|__GFP_NOFAIL);
>   
>   repeat_alloc:
>   
> But bio_alloc_bioset() plays with gfp_mask itself: are we sure that it
> isn't the one clearing __GFP_DIRECT_RECLAIM itself before falling back to
> saved_gfp?
>
> In other words do we also want this?
>
> diff --git a/block/bio.c b/block/bio.c
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -462,16 +462,16 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
>   		 * We solve this, and guarantee forward progress, with a rescuer
>   		 * workqueue per bio_set. If we go to allocate and there are
>   		 * bios on current->bio_list, we first try the allocation
> -		 * without __GFP_DIRECT_RECLAIM; if that fails, we punt those
> -		 * bios we would be blocking to the rescuer workqueue before
> -		 * we retry with the original gfp_flags.
> +		 * without __GFP_DIRECT_RECLAIM or __GFP_NOFAIL; if that fails,
> +		 * we punt those bios we would be blocking to the rescuer
> +		 * workqueue before we retry with the original gfp_flags.
>   		 */
> -
>   		if (current->bio_list &&
>   		    (!bio_list_empty(&current->bio_list[0]) ||
>   		     !bio_list_empty(&current->bio_list[1])) &&
>   		    bs->rescue_workqueue)
> -			gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> +			gfp_mask &= ~(__GFP_DIRECT_RECLAIM |
> +				      __GFP_NOFAIL);
>   
>   		p = mempool_alloc(&bs->bio_pool, gfp_mask);
>   		if (!p && gfp_mask != saved_gfp) {

I don't think it will make any difference by removing __GFP_NOFAIL 
outside kmemleak. The problem is the commit 
d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist 
with fault injection") makes __GFP_NOFAIL is set for kmemleak always in 
order to turn off fault-injection for kmemleak.

As long as kmemleak is called in ~__GFP_DIRECT_RECLAIM path, the warning 
might be hit.

And since kmemleak is just a debugging tool, so IMHO I don't think this 
is worth fixing, so I came up with the patch to document it.


