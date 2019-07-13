Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27CA4C73C66
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 19:39:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA35620850
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 19:39:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="n0KFTozv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA35620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24AB66B0003; Sat, 13 Jul 2019 15:39:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FD1D8E0003; Sat, 13 Jul 2019 15:39:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EC8E8E0002; Sat, 13 Jul 2019 15:39:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC7766B0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 15:39:20 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 8so2500011pgl.3
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 12:39:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=4rwRS7GM+nAGTGCY3bn6psvJVMqQf5Gz5RaBpQRnLL8=;
        b=Hsa7lfZWKLNQXTIjvS5A8A60DwA0OGzzob2ckCvn3FC1946xl5VNVrO5AHc1bT+pGd
         8okCzJT8Yu6TNh52vuxfgUq6rHW2hzm27dWgzbcbXp/vxUFpfT7z5wOaEh5l1rC2oxyz
         FW4mvqlhlSsr6vj3PBJercverDdKykxUWr86dRCmDi852UmrAWOMH0k2c9ii6rtyYAyB
         rFM8GnwKUNaFUkaPC6dxmftJ94WIo2rVpWrjXCJubhIUJcCeXjIRQMNmqt2GCKzTa7e7
         o2bi7wXnqP+jvatkLgQNr3k9NOXEega6NYKzbMQqC9UiQqScp7TIYIbAY4GbWbyfLKez
         dO8A==
X-Gm-Message-State: APjAAAW12fP/oWNUwyr2Sz3CWoYWtCpaYGAZPFzi1mli6NFx9MtW6r0n
	g9Y0DhFvgcxAizWFxm3qfTepfinFsmzeztuws0xYfHrchgIhs/A5SS6hftQe0XfF8QmgVhcpAIt
	rhyXtBraQPFBNQ148YzV04LUp71fo0ZU09AIMhz4llwkGjbI2sK595I3ltgRpA8IJew==
X-Received: by 2002:a17:902:70cc:: with SMTP id l12mr19318707plt.87.1563046760279;
        Sat, 13 Jul 2019 12:39:20 -0700 (PDT)
X-Received: by 2002:a17:902:70cc:: with SMTP id l12mr19318656plt.87.1563046759424;
        Sat, 13 Jul 2019 12:39:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563046759; cv=none;
        d=google.com; s=arc-20160816;
        b=HD+pnGBZ68weAymp6lowdN27NWmFXY1hfOYI10uhP7FcIronPtWNEKpsymt8A5+2jl
         EqLXAeYYXBmRqhzFM3GYGC1hNvOkYBvVDyTziZPlPMAZV/FA4OrWU7CsG2avupseJV+d
         xOcDdLxgv4NSC0OL1jVspfPoZUs6BiNORgABeb1Qy00RG0pR6IxvsapMymoT2Sl4hHCT
         kf+YewH+09M5qIAeDiyYfBJUiCVgpX+qhHw+kn4CDZo+TNADZDVFOjXxCZ+it5TpLTbu
         aiR8kf7CxkdKxHXo+4mjPTv2kwGlhjKLVlhlqkHjcBKxAAp3HJb2RcuKgRetP4qv7d/A
         m9ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=4rwRS7GM+nAGTGCY3bn6psvJVMqQf5Gz5RaBpQRnLL8=;
        b=N4wBU2KhlHrlgSsuaDrkuKpoFVHkFjQoYKOhiziKifwPVDFwpQePR3LCNpnPE3ehSF
         jIrZRv7poUjIaJLSXw0eBDe307KeIhunE9vc3ampvz0DBp+VpuTseaMn5tT8NzwMzaGw
         8d403p9dFfLDT4QiiOXxIpv5hJTKa1GNTaDNRv8+pERj9DEnmFC9mCBlkTLEkuEg5o1V
         GGxFztx0GNrEbJYADB/CYmcW0dUoAgtOb2GXucLbkZaXjEEuXSEfvtb31dEokJfoq4IT
         GND3jWQ2t07YV87z28KRwMbTK5nUM/6foYctSAzFAdM2R3H9o65KLseZqhBamQE1FU3M
         gCQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=n0KFTozv;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13sor6624559pgr.87.2019.07.13.12.39.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Jul 2019 12:39:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=n0KFTozv;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=4rwRS7GM+nAGTGCY3bn6psvJVMqQf5Gz5RaBpQRnLL8=;
        b=n0KFTozv9CtnAVuGyX9D6NNG61GDCR6T64sYf9upTmnmAdBFsnDEUe1t04Bu/LT2D+
         bqBxtGoXwlL1gRCO7WG9Ry/284/rMlUsnYIrhM2DGa+J+n8e/x6f6zHA4id9QtkHa0lh
         yUECAj3rN/6p1EB2mV2pFisblC3mqlEQjqMnDIujn/DWYMn1r1/cFrH44limBhWtA471
         7Ivil9qXvMi9HM/BXy38rCzLWP4HvU3WnGlPrgV9sfbyNU5xKXnzdknElbXLdolGGYg7
         PDlDb+DUR0wgpZ8zpQE63IgFYMKyfyV09ZDJLsq+hVRQu169Lp9V4242fwagSZfrMEY1
         Paow==
X-Google-Smtp-Source: APXvYqxOrGaeCkdz67qh5Pd8o/OBYvz4gK7V7SeQ+uf99qRLAi4vYDlYPDSLlTDG/ZmBLF3HPE9yUQ==
X-Received: by 2002:a63:6686:: with SMTP id a128mr11260150pgc.361.1563046758563;
        Sat, 13 Jul 2019 12:39:18 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id k6sm11697073pfi.12.2019.07.13.12.39.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 13 Jul 2019 12:39:17 -0700 (PDT)
Date: Sat, 13 Jul 2019 12:39:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com, 
    akpm@linux-foundation.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
In-Reply-To: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.DEB.2.21.1907131230280.246128@chino.kir.corp.google.com>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jul 2019, Yang Shi wrote:

> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:
> 
> WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
> Modules linked in: loop dax_pmem dax_pmem_core
> ip_tables x_tables xfs virtio_net net_failover virtio_blk failover
> ata_generic virtio_pci virtio_ring virtio libata
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
> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
> __GFP_NOFAIL set all the time due to commit
> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> with fault injection").
> 

It only clears __GFP_DIRECT_RECLAIM provisionally to see if the allocation 
would immediately succeed before falling back to the elements in the 
mempool.  If that fails, and the mempool is empty, mempool_alloc() 
attempts the allocation with __GFP_DIRECT_RECLAIM.  So for the problem 
described here, I think what we really want is this:

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -386,7 +386,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
 	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
 
-	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
+	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO|__GFP_NOFAIL);
 
 repeat_alloc:
 
But bio_alloc_bioset() plays with gfp_mask itself: are we sure that it 
isn't the one clearing __GFP_DIRECT_RECLAIM itself before falling back to 
saved_gfp?

In other words do we also want this?

diff --git a/block/bio.c b/block/bio.c
--- a/block/bio.c
+++ b/block/bio.c
@@ -462,16 +462,16 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, unsigned int nr_iovecs,
 		 * We solve this, and guarantee forward progress, with a rescuer
 		 * workqueue per bio_set. If we go to allocate and there are
 		 * bios on current->bio_list, we first try the allocation
-		 * without __GFP_DIRECT_RECLAIM; if that fails, we punt those
-		 * bios we would be blocking to the rescuer workqueue before
-		 * we retry with the original gfp_flags.
+		 * without __GFP_DIRECT_RECLAIM or __GFP_NOFAIL; if that fails,
+		 * we punt those bios we would be blocking to the rescuer
+		 * workqueue before we retry with the original gfp_flags.
 		 */
-
 		if (current->bio_list &&
 		    (!bio_list_empty(&current->bio_list[0]) ||
 		     !bio_list_empty(&current->bio_list[1])) &&
 		    bs->rescue_workqueue)
-			gfp_mask &= ~__GFP_DIRECT_RECLAIM;
+			gfp_mask &= ~(__GFP_DIRECT_RECLAIM |
+				      __GFP_NOFAIL);
 
 		p = mempool_alloc(&bs->bio_pool, gfp_mask);
 		if (!p && gfp_mask != saved_gfp) {

