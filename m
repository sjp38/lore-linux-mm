Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32850C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C574B208C0
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:07:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C574B208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 278236B0003; Wed, 17 Jul 2019 01:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 202106B0005; Wed, 17 Jul 2019 01:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CA378E0001; Wed, 17 Jul 2019 01:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF4EC6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:07:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so17270722eda.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 22:07:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ampYWH5RSqTTctNXjay93hp+EsZNvTDA3i1RhxumKIc=;
        b=rKNvYVTaaDV9PJQkuPKBIDoIhV5jv88esr+Dw7IA5T68ptoa0fjISd47Q5mO2049mY
         Bih48SD6ZnaXCIdmqe1r4baO2j/j7vcxGJMXWF+GIBKAtV6UXzDNyF8uXX5ykmGCvn18
         V8CVwapoh68RL9RcQZRCQtXrDDM06lKGpzOnGJd+7FIBpTwN8jLflO/RO46sEivCg2J3
         EewuA+vnABkXT4AIR/kOwodbH7tzNzTAsDaMxQsgZvfFZTWLzRQU7CJMBeH2hUGTr/Vt
         h7ZAhPoCoN29e50f1QBoPTTaFZSyRjMo+SEvslI6uiiSjxv24imAm5bS8/kiUYSqhkGH
         UgfQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWxx8CPtzM9dbhNT7IjoEWix4+xers8/xB7SWN3Pz8L75jrAhPx
	rDz6IpHzqXSkzCas0lle5lNSaurYQOC4L0PentGjP5WzKBE0GUQkJsXiewLrKkLTzSr95lpU5jn
	NwTffU2HpjqJx4aNIbIamaNNHRpEE2C3kgXKjUjBxavONoioVn1a+h74mLmtM0iE=
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr11000252ejr.122.1563340034260;
        Tue, 16 Jul 2019 22:07:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmCfO+XQyONThPFgRBPw+kfuy10tvKBCUaASSEUwTJYHkF2mvtO1D4Wf83phc1OuoBRJNt
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr11000194ejr.122.1563340033258;
        Tue, 16 Jul 2019 22:07:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563340033; cv=none;
        d=google.com; s=arc-20160816;
        b=Jb011meSEO2HoOVDQnvbcu4E69vZ81Xr8u1ky6txdpft7JCZ1R1m1Gts7136fznt3c
         VYNuMq/Bnvbmjh50iXlO8AMJHBaTUoWZlXb6wOcRa6K/G1gKyB767hDkWjOnpbYKn5ZT
         CeH3gGRx0ToxKpJ58mqTLZLUKWQ+Q4IWdT7rXo9KdMOOBiW+D3/1Z0ygi5NzjHAIqK4K
         cpAmDxmin+n/dwgpmUUpt16NpP41VFFqRhKK0DH599lgndasHz4fw2/1DBXavma+DWdp
         y7SCOyjQ/10ZNhs4sSOdqx4/xaInZ0Rjh91AbRWIEeHNde2Vj3SZ55lSODo2RSUVcK+8
         VnOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ampYWH5RSqTTctNXjay93hp+EsZNvTDA3i1RhxumKIc=;
        b=yJx9D2dWCAJx8uomRNt74R2m5vXExj+tgGm+qIglhxKV8oY7wm7IoXSoto5LRyfoZu
         eVCtTMclhYfcD5pIXwus2fIUC/giItqHGpKuev9lxD42g8J7IbkVj+HvwR2cdrNt3v/y
         XN/nlhIpb63dEf+Xu6g00eWKX+Q9QEI3bFls23Q4wNojAOe+L/Z3sVN2PAZ80YqXUkXV
         CCQoFQmtZZrS51axkxpEakk6/NzcwnTGR00GE5luw51q4r9+BGKZTqmQ8kjp6UvQv8rR
         OLR5EisizMBhTGcmhg0iQoaHyJkED09q2wplHCr7PpbzmI1nNuODtq9GIvBnDnCBfwDC
         c6Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r21si11962618ejz.133.2019.07.16.22.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 22:07:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 31D91ABCD;
	Wed, 17 Jul 2019 05:07:12 +0000 (UTC)
Date: Wed, 17 Jul 2019 07:07:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: catalin.marinas@arm.com, dvyukov@google.com, rientjes@google.com,
	willy@infradead.org, cai@lca.pw, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Message-ID: <20190717050711.GA16284@dhcp22.suse.cz>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-07-19 01:50:31, Yang Shi wrote:
> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:
> 
> WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
> Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring virtio libata
> CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
> ...
>  kmemleak_alloc+0x4e/0xb0
>  kmem_cache_alloc+0x2a7/0x3e0
>  ? __kmalloc+0x1d6/0x470
>  ? ___might_sleep+0x9c/0x170
>  ? mempool_alloc+0x2b0/0x2b0
>  mempool_alloc_slab+0x2d/0x40
>  mempool_alloc+0x118/0x2b0
>  ? __kasan_check_read+0x11/0x20
>  ? mempool_resize+0x390/0x390
>  ? lock_downgrade+0x3c0/0x3c0
>  bio_alloc_bioset+0x19d/0x350
>  ? __swap_duplicate+0x161/0x240
>  ? bvec_alloc+0x1b0/0x1b0
>  ? do_raw_spin_unlock+0xa8/0x140
>  ? _raw_spin_unlock+0x27/0x40
>  get_swap_bio+0x80/0x230
>  ? __x64_sys_madvise+0x50/0x50
>  ? end_swap_bio_read+0x310/0x310
>  ? __kasan_check_read+0x11/0x20
>  ? check_chain_key+0x24e/0x300
>  ? bdev_write_page+0x55/0x130
>  __swap_writepage+0x5ff/0xb20
> 
> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak has
> __GFP_NOFAIL set all the time due to commit
> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> with fault injection").  But, it doesn't make any sense to have
> __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same time.
> 
> According to the discussion on the mailing list, the commit should be
> reverted for short term solution.  Catalin Marinas would follow up with a better
> solution for longer term.
> 
> The failure rate of kmemleak metadata allocation may increase in some
> circumstances, but this should be expected side effect.
> 
> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Qian Cai <cai@lca.pw>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

I forgot
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/kmemleak.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9dd581d..884a5e3 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -114,7 +114,7 @@
>  /* GFP bitmask for kmemleak internal allocations */
>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN)
>  
>  /* scanning area inside a memory block */
>  struct kmemleak_scan_area {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

