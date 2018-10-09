Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4571F6B000C
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:16:54 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id w193-v6so401614wmf.8
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:16:54 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g69-v6si7357102wmd.156.2018.10.09.00.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 00:16:52 -0700 (PDT)
Date: Tue, 9 Oct 2018 09:16:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm: In the PTE swapout page reclaim case clear the
 accessed bit instead of flushing the TLB
Message-ID: <20181009071637.GF5663@hirez.programming.kicks-ass.net>
References: <1539059570-9043-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539059570-9043-1-git-send-email-amhetre@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: vdumpa@nvidia.com, avanbrunt@nvidia.com, Snikam@nvidia.com, praithatha@nvidia.com, Shaohua Li <shli@kernel.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Tue, Oct 09, 2018 at 10:02:50AM +0530, Ashish Mhetre wrote:
> From: Shaohua Li <shli@kernel.org>
> 
> We use the accessed bit to age a page at page reclaim time,
> and currently we also flush the TLB when doing so.
> 
> But in some workloads TLB flush overhead is very heavy. In my
> simple multithreaded app with a lot of swap to several pcie
> SSDs, removing the tlb flush gives about 20% ~ 30% swapout
> speedup.
> 
> Fortunately just removing the TLB flush is a valid optimization:
> on x86 CPUs, clearing the accessed bit without a TLB flush
> doesn't cause data corruption.
> 
> It could cause incorrect page aging and the (mistaken) reclaim of
> hot pages, but the chance of that should be relatively low.
> 
> So as a performance optimization don't flush the TLB when
> clearing the accessed bit, it will eventually be flushed by
> a context switch or a VM operation anyway. [ In the rare
> event of it not getting flushed for a long time the delay
> shouldn't really matter because there's no real memory
> pressure for swapout to react to. ]

Note that context switches (and here I'm talking about switch_mm(), not
the cheaper switch_to()) do not unconditionally imply a TLB invalidation
these days (on PCID enabled hardware).

So in that regards, the Changelog (and the comment) is a little
misleading.

I don't see anything fundamentally wrong with the patch though; just the
wording.
