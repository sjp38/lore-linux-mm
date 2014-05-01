Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A51466B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 03:34:11 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so245287wib.16
        for <linux-mm@kvack.org>; Thu, 01 May 2014 00:34:10 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
        by mx.google.com with ESMTPS id f10si423850wix.43.2014.05.01.00.34.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 00:34:10 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id hi5so296155wib.2
        for <linux-mm@kvack.org>; Thu, 01 May 2014 00:34:09 -0700 (PDT)
Date: Thu, 1 May 2014 08:34:03 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH V4 6/7] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140501073402.GA30358@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
 <1396018892-6773-7-git-send-email-steve.capper@linaro.org>
 <20140430152047.GF31220@arm.com>
 <20140430153317.GG31220@arm.com>
 <20140430153824.GA7166@linaro.org>
 <20140430172114.GI31220@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430172114.GI31220@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Apr 30, 2014 at 06:21:14PM +0100, Catalin Marinas wrote:
> On Wed, Apr 30, 2014 at 04:38:25PM +0100, Steve Capper wrote:
> > On Wed, Apr 30, 2014 at 04:33:17PM +0100, Catalin Marinas wrote:
> > > On Wed, Apr 30, 2014 at 04:20:47PM +0100, Catalin Marinas wrote:
> > > > On Fri, Mar 28, 2014 at 03:01:31PM +0000, Steve Capper wrote:
> > > > > In order to implement fast_get_user_pages we need to ensure that the
> > > > > page table walker is protected from page table pages being freed from
> > > > > under it.
> > > > > 
> > > > > This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
> > > > > to address spaces with multiple users will be call_rcu_sched freed.
> > > > > Meaning that disabling interrupts will block the free and protect the
> > > > > fast gup page walker.
> > > > > 
> > > > > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > > > 
> > > > While this patch is simple, I'd like to better understand the reason for
> > > > it. Currently HAVE_RCU_TABLE_FREE is enabled for powerpc and sparc while
> > > > __get_user_pages_fast() is supported by a few other architectures that
> > > > don't select HAVE_RCU_TABLE_FREE. So why do we need it for fast gup on
> > > > arm/arm64 while not all the other archs need it?
> > > 
> > > OK, replying to myself. I assume the other architectures that don't need
> > > HAVE_RCU_TABLE_FREE use IPI for TLB shootdown, hence they gup_fast
> > > synchronisation for free.
> > 
> > Yes that is roughly the case.
> > Essentially we want to RCU free the page table backing pages at a
> > later time when we aren't walking on them.
> > 
> > Other arches use IPI, some others have their own RCU logic. I opted to
> > activate some existing logic to reduce code duplication.
> 
> Both powerpc and sparc use tlb_remove_table() via their __pte_free_tlb()
> etc. which implies an IPI for synchronisation if mm_users > 1. For
> gup_fast we may not need it since we use the RCU for protection. Am I
> missing anything?

So my understanding is:

tlb_remove_table will just immediately free any pages where there's a
single user as there's no need to consider a gup walking.

For the case of multiple users we have an mmu_table_batch structure
that holds references to pages that should be freed at a later point.

This batch is contained on a page that is allocated on the fly. If, for
any reason, we can't allocate the batch container we fallback to a slow
path which is to issue an IPI (via tlb_remove_table_one). This IPI will
block on the gup walker. We need this fallback behaviour on ARM/ARM64.

Most of the time we will be able to allocate the batch container, and
we will populate it with references to page table containing pages that
are freed via an RCU scheduler delayed callback to tlb_remove_table_rcu.

In the fast_gup walker, we block tlb_remove_table_rcu from running by
disabling interrupts in the critical path. Technically we could issue
a call to rcu_read_lock_sched instead to block tlb_remove_table_rcu,
but that wouldn't be sufficient to block THP splits; so we opt to
disable interrupts to block both THP and tlb_remove_table_rcu.

Cheers,
-- 
Steve

> 
> -- 
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
