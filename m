Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A75DC6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 05:20:26 -0500 (EST)
Received: by wikq8 with SMTP id q8so89029468wik.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 02:20:26 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id s5si836768wjs.1.2015.11.04.02.20.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 02:20:24 -0800 (PST)
Received: by wmff134 with SMTP id f134so106273674wmf.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 02:20:24 -0800 (PST)
Date: Wed, 4 Nov 2015 11:20:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 107111] New: page allocation failure but there seem to be
 free pages
Message-ID: <20151104102023.GF29607@dhcp22.suse.cz>
References: <bug-107111-27@https.bugzilla.kernel.org/>
 <20151103141603.261893b44e0cd6e704921fb6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151103141603.261893b44e0cd6e704921fb6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, john@calva.com, Mel Gorman <mgorman@techsingularity.net>

On Tue 03-11-15 14:16:03, Andrew Morton wrote:
[...]
> > [1188431.177410] apache2: page allocation failure: order:1, mode:0x204020
> 
> An order-1 page, __GFP_COMP|__GFP_HIGH.  ie: GFP_ATOMIC.

__GFP_HIGH doesn't really work well on a small zone like DMA I am
afraid.

[...]
> > [1188431.177521] Node 0 DMA free:7968kB min:40kB low:48kB high:60kB
[...]
> > [1188431.177527] lowmem_reserve[]: 0 1988 1988 1988
[...]
> > [1188431.177555] Node 0 DMA: 44*4kB (UE) 94*8kB (UEM) 76*16kB (UE) 42*32kB
> > (UEM) 22*64kB (UEM) 6*128kB (UE) 3*256kB (UE) 1*512kB (E) 1*1024kB (U) 0*2048kB
> > 0*4096kB = 7968kB
> 
> The DMA zone has lots and lots of higher-order pages available which
> could satisfy this allocation.

min = 10 - 10/2 = 5 # __GFP_HIGH
min = 5 - 5/4 = 4  # ALLOC_HARDER
free_pages = 1992 - ((1<<1) - 1) = 1991
free_cma = 0

1991 <= 4 + 1988

So we do not pass lowmem reserves check here...

[...]
> The kernel could and should have satisfied this order-1 GFP_ATOMIC
> IRQ-context allocation from the DMA zone.  But it did not do so.  Bug.

I am not really sure this is a bug to be honest. It seems that we are
not coping with the non sleeping allocation pressure. I would suggest
increasing min_free_kbytes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
