Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EC34C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E3C1206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:18:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E3C1206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E31C06B0006; Mon, 15 Jul 2019 09:18:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE2166B0007; Mon, 15 Jul 2019 09:18:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF9416B0008; Mon, 15 Jul 2019 09:18:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 802216B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:18:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so13570562edx.10
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:18:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IYHZl7XqACbfQgkIvfXTj9QTDPr1mZ5nykvuxTT4n1g=;
        b=c/PmTbQAg/yYlH0uq1bYAF9gLVnG8Wh0+gVsxX4Z4fBrf7YTovhaj54CgcJlO2jKlR
         vhVdc2crCOADM8nRf+yl8aK0CsT1njyYbbtWlBOuA1/WGAVvi7eX8ws025554nYslCFg
         gbD6GzCG94i8QnyV2y0FdbDMXrCestVC5YyQFDhnyAgXjcV7vtkdzV8JbPRbP1lA5VC3
         R/AhmC9v3Dh7qNjlViwB3ZzlDjZQ0w68pArpPWClhrjHUSvUAupGitxUGI8wZaeTSxL2
         r71T8DDnIwF5Dd/Y0KXq/Yx5iynxsLfqM2IZ7pCfF6t9yi2+PuNThNyUBhLRtaaumkxo
         jdXw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVwDYyDwQ4hROT+pZXwW2FV0vLnF1steRgd/bXuCgPN80/oMssi
	8EDGADiOx0QfTzNJCC27wBjKD9wJyfUpYDr3fB9ROUHslhJkhqA3shcPY8fhs9bIiwIIK13cHev
	hP1NsgfywbsauH02KnESosOKkbNNl07YzJxyDbyW7VUyouBWhpZ0sSRz7dI2i+lE=
X-Received: by 2002:a50:8dcb:: with SMTP id s11mr22788121edh.144.1563196738072;
        Mon, 15 Jul 2019 06:18:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcd1ysj4EmPpt+wM8nglceMhzOtN7mds/g0SHxWWxYUOp3xu0R1twjYw4XHsla2fZf1hz3
X-Received: by 2002:a50:8dcb:: with SMTP id s11mr22788056edh.144.1563196737387;
        Mon, 15 Jul 2019 06:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563196737; cv=none;
        d=google.com; s=arc-20160816;
        b=h5upR5IQQE1yclAOJT/wSUZd4EmhNJTiCg43BkxT7v8qpbbB+S8Mfd862V60QEt2mM
         av0G18oKxOO/BVQ+9fNe35fHFYzFVmCHXMJPJyK9AFcb9gGJUiQ2mE8Bf0Rw8Jg0s6Qx
         Ke/nThs4fnYBWx3ZGxQS3/crdCKnr572ysPapmM5sD5FQAvWTf95pFGzvAMgyE8GpKJk
         JKfFolXHW0QeqTDqDtKo3qGWGP7cKBUjTNJ9/cDIHFPAseHK9DS6x9R6le4Et/HMetI9
         C32hYuLwMmSbMN1vvK5dFPHL0sd31TogHw05C8IBeFOB5JqNN60wAtq0bLCNxJwgMShX
         5KJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IYHZl7XqACbfQgkIvfXTj9QTDPr1mZ5nykvuxTT4n1g=;
        b=ob9j2rMcuKzfPs6T1E21tNPLhtfZ6sC7IJRxJgKoEePpfQrRXqsfERXdlSqWGZ6w4R
         NG7rCyIZK/vHhAXycLty7wHrCnK0rlDAyUg1nqOqQl14sjW6Jkq5fLS37T+kSg2Bldro
         r7sD2NyZwh45x7GIG+/eakRC9rAmZWb+fvQQRiqahLDs296UIF5KA5PoPGW52x/gGHoX
         ca2LC7T4DABZRitymQBh+OJT5JOiQUNv7552So0rUtCNwmLmZZf40vFA4s2lItaPg4aR
         hCmvjHHNsiHtDt9bU74ugV/ieyAo1VPUqURVc9qMaMWSyBKYVB7uGFgxvaYDmxXhtTlY
         fvXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj23si9516308ejb.165.2019.07.15.06.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 06:18:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F30B1AFFE;
	Mon, 15 Jul 2019 13:18:56 +0000 (UTC)
Date: Mon, 15 Jul 2019 15:18:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, dvyukov@google.com,
	catalin.marinas@arm.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
Message-ID: <20190715131856.GY29483@dhcp22.suse.cz>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1907131230280.246128@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907131230280.246128@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 13-07-19 12:39:16, David Rientjes wrote:
> On Sat, 13 Jul 2019, Yang Shi wrote:
> 
> > When running ltp's oom test with kmemleak enabled, the below warning was
> > triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> > passed in:
> > 
> > WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
> > Modules linked in: loop dax_pmem dax_pmem_core
> > ip_tables x_tables xfs virtio_net net_failover virtio_blk failover
> > ata_generic virtio_pci virtio_ring virtio libata
> > CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> > RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
> > ...
> >  kmemleak_alloc+0x4e/0xb0
> >  kmem_cache_alloc+0x2a7/0x3e0
> >  ? __kmalloc+0x1d6/0x470
> >  ? ___might_sleep+0x9c/0x170
> >  ? mempool_alloc+0x2b0/0x2b0
> >  mempool_alloc_slab+0x2d/0x40
> >  mempool_alloc+0x118/0x2b0
> >  ? __kasan_check_read+0x11/0x20
> >  ? mempool_resize+0x390/0x390
> >  ? lock_downgrade+0x3c0/0x3c0
> >  bio_alloc_bioset+0x19d/0x350
> >  ? __swap_duplicate+0x161/0x240
> >  ? bvec_alloc+0x1b0/0x1b0
> >  ? do_raw_spin_unlock+0xa8/0x140
> >  ? _raw_spin_unlock+0x27/0x40
> >  get_swap_bio+0x80/0x230
> >  ? __x64_sys_madvise+0x50/0x50
> >  ? end_swap_bio_read+0x310/0x310
> >  ? __kasan_check_read+0x11/0x20
> >  ? check_chain_key+0x24e/0x300
> >  ? bdev_write_page+0x55/0x130
> >  __swap_writepage+0x5ff/0xb20
> > 
> > The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
> > __GFP_NOFAIL set all the time due to commit
> > d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> > with fault injection").
> > 
> 
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
>  	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
>  	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
>  
> -	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
> +	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO|__GFP_NOFAIL);
>  
>  repeat_alloc:

No, I do not think we should make mempool allocator more complex for
something that is an implementation problem the kmemleak.
-- 
Michal Hocko
SUSE Labs

