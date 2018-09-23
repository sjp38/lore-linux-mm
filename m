Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB3EA8E0001
	for <linux-mm@kvack.org>; Sun, 23 Sep 2018 05:23:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a4-v6so107749pfi.16
        for <linux-mm@kvack.org>; Sun, 23 Sep 2018 02:23:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor5921354pls.69.2018.09.23.02.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Sep 2018 02:23:23 -0700 (PDT)
Date: Sun, 23 Sep 2018 19:23:15 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/3] mm: optimise pte dirty/accessed bit setting by
 demand based pte insertion
Message-ID: <20180923192315.13cb4114@roar.ozlabs.ibm.com>
In-Reply-To: <1537519325.19048.0.camel@intel.com>
References: <20180828112034.30875-1-npiggin@gmail.com>
	<20180828112034.30875-4-npiggin@gmail.com>
	<20180905142951.GA15680@roeck-us.net>
	<20180918035337.0727dad0@roar.ozlabs.ibm.com>
	<1537519325.19048.0.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <ley.foon.tan@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ley Foon Tan <lftan@altera.com>, nios2-dev@lists.rocketboards.org

On Fri, 21 Sep 2018 16:42:05 +0800
Ley Foon Tan <ley.foon.tan@intel.com> wrote:

> On Tue, 2018-09-18 at 03:53 +1000, Nicholas Piggin wrote:
> > On Wed, 5 Sep 2018 07:29:51 -0700
> > Guenter Roeck <linux@roeck-us.net> wrote:
> >   
> > > 
> > > Hi,
> > > 
> > > On Tue, Aug 28, 2018 at 09:20:34PM +1000, Nicholas Piggin wrote:  
> > > > 
> > > > Similarly to the previous patch, this tries to optimise
> > > > dirty/accessed
> > > > bits in ptes to avoid access costs of hardware setting them.
> > > >   
> > > This patch results in silent nios2 boot failures, silent meaning
> > > that
> > > the boot stalls.  
> > Okay I just got back to looking at this. The reason for the hang is
> > I think a bug in the nios2 TLB code, but maybe other archs have
> > similar
> > issues.
> > 
> > In case of a missing / !present Linux pte, nios2 installs a TLB entry
> > with no permissions via its fast TLB exception handler (software TLB
> > fill). Then it relies on that causing a TLB permission exception in a
> > slower handler that calls handle_mm_fault to set the Linux pte and
> > flushes the old TLB. Then the fast exception handler will find the
> > new
> > Linux pte.
> > 
> > With this patch, nios2 has a case where handle_mm_fault does not
> > flush
> > the old TLB, which results in the TLB permission exception
> > continually
> > being retried.
> > 
> > What happens now is that fault paths like do_read_fault will install
> > a
> > Linux pte with the young bit clear and return. That will cause nios2
> > to
> > fault again but this time go down the bottom of handle_pte_fault and
> > to
> > the access flags update with the young bit set. The young bit is seen
> > to
> > be different, so that causes ptep_set_access_flags to do a TLB flush
> > and
> > that finally allows the fast TLB handler to fire and pick up the new
> > Linux pte.
> > 
> > With this patch, the young bit is set in the first handle_mm_fault,
> > so
> > the second handle_mm_fault no longer sees the ptes are different and
> > does not flush the TLB. The spurious fault handler also does not
> > flush
> > them unless FAULT_FLAG_WRITE is set.
> > 
> > What nios2 should do is invalidate the TLB in update_mmu_cache. What
> > it
> > *really* should do is install the new TLB entry, I have some patches
> > to
> > make that work in qemu I can submit. But I would like to try getting
> > these dirty/accessed bit optimisation in 4.20, so I will send a
> > simple
> > path to just do the TLB invalidate that could go in Andrew's git
> > tree.
> > 
> > Is that agreeable with the nios2 maintainers?
> > 
> > Thanks,
> > Nick
> >   
> Hi
> 
> Do you have patches to test?

I've been working on some, it has taken longer than I expected, I'll
hopefully have something to send out by tomorrow.

Thanks,
Nick
