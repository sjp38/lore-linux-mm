Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0147F8D0005
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:01:20 -0500 (EST)
Message-Id: <20101126143843.801484792@chello.nl>
Date: Fri, 26 Nov 2010 15:38:43 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/21] mm: Preemptibility -v6
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

This patch-set makes part of the mm a lot more preemptible. It converts
i_mmap_lock and anon_vma->lock to mutexes and makes mmu_gather fully
preemptible.

The main motivation was making mm_take_all_locks() preemptible, since it
appears people are nesting hundreds of spinlocks there.

The side-effects are that can finally make mmu_gather preemptible,
something which lots of people have wanted to do for a long time.

It also gets us anon_vma refcounting, which seems to result in a nice
cleanup of the anon_vma lifetime rules wrt KSM and compaction.

This patch-set is build and boot-tested on x86_64 (a previous version was
also tested on Dave's Niagra2 machines, and I suppose s390 was too when
Martin provided the conversion patch for his arch).

There are no known architectures left unconverted.

Yanmin ran the -v3 posting through the comprehensive Intel test farm
and didn't find any regressions.

( Not included in this posting are the 4 Sparc64 patches that implement
  gup_fast, those can be applied separately after this series gets
  anywhere. )

The full series (including the Sparc64 gup_fast bits) also available in -git
form from (against Linus' tree as of about an hour ago):

  git://git.kernel.org/pub/scm/linux/kernel/git/peterz/linux-2.6-mmu_preempt.git

Linus seems to want this to get some serious review and be pushed through
Andrew (well, anybody but me actually, but since Andrew is mm master...)

Ben, Thomas, Andrew, can I trick you guys into looking at this stuff?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
