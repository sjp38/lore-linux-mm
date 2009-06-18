Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D605A6B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 08:14:32 -0400 (EDT)
Date: Thu, 18 Jun 2009 20:14:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
Message-ID: <20090618121430.GA6746@localhost>
References: <20090615031253.530308256@intel.com> <28c262360906150609gd736bf7p7a57de1b81cedd97@mail.gmail.com> <20090615152612.GA11700@localhost> <20090616090308.bac3b1f7.minchan.kim@barrios-desktop> <20090616134944.GB7524@localhost> <20090617092826.56730a10.minchan.kim@barrios-desktop> <20090617072319.GA5841@localhost> <28c262360906170644w65c08a8y2d2805fb08045804@mail.gmail.com> <20090617135543.GA8079@localhost> <28c262360906170703h3363b68dp74471358f647921e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906170703h3363b68dp74471358f647921e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 10:03:37PM +0800, Minchan Kim wrote:
> On Wed, Jun 17, 2009 at 10:55 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > On Wed, Jun 17, 2009 at 09:44:39PM +0800, Minchan Kim wrote:
> >> It is private mail for my question.
> >> I don't want to make noise in LKML.
> >> And I don't want to disturb your progress to merge HWPoison.
> >>
> >> > Because this race window is small enough:
> >> >
> >> > A  A  A  A TestSetPageHWPoison(p);
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  lock_page(page);
> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  try_to_unmap(page, TTU_MIGRATION|...);
> >> > A  A  A  A lock_page_nosync(p);
> >> >
> >> > such small race windows can be found all over the kernel, it's just
> >> > insane to try to fix any of them.
> >>
> >> I don't know there are intentional small race windows in kernel until you said.
> >> I thought kernel code is perfect so it wouldn't allow race window
> >> although it is very small. But you pointed out. Until now, My thought
> >> is wrong.
> >>
> >> Do you know else small race windows by intention ?
> >> If you know it, tell me, please. It can expand my sight. :)
> >
> > The memory failure code does not aim to rescue 100% page corruptions.
> > That's unreasonable goal - the kernel pages, slab pages (including the
> > big dcache/icache) are almost impossible to isolate.
> >
> > Comparing to the big slab pools, the migration and other race windows are
> > really too small to care about :)
> 
> Also, If you will mention this contents as annotation, I will add my
> review sign.

Good suggestion. Here is a patch for comment updates.

> Thanks for kind reply for my boring discussion.

Boring? Not at all :)

Thanks,
Fengguang

---
 mm/memory-failure.c |   76 +++++++++++++++++++++++++-----------------
 1 file changed, 47 insertions(+), 29 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -1,4 +1,8 @@
 /*
+ * linux/mm/memory-failure.c
+ *
+ * High level machine check handler.
+ *
  * Copyright (C) 2008, 2009 Intel Corporation
  * Authors: Andi Kleen, Fengguang Wu
  *
@@ -6,29 +10,36 @@
  * the GNU General Public License ("GPL") version 2 only as published by the
  * Free Software Foundation.
  *
- * High level machine check handler. Handles pages reported by the
- * hardware as being corrupted usually due to a 2bit ECC memory or cache
- * failure.
- *
- * This focuses on pages detected as corrupted in the background.
- * When the current CPU tries to consume corruption the currently
- * running process can just be killed directly instead. This implies
- * that if the error cannot be handled for some reason it's safe to
- * just ignore it because no corruption has been consumed yet. Instead
- * when that happens another machine check will happen.
- *
- * Handles page cache pages in various states.	The tricky part
- * here is that we can access any page asynchronous to other VM
- * users, because memory failures could happen anytime and anywhere,
- * possibly violating some of their assumptions. This is why this code
- * has to be extremely careful. Generally it tries to use normal locking
- * rules, as in get the standard locks, even if that means the
- * error handling takes potentially a long time.
- *
- * The operation to map back from RMAP chains to processes has to walk
- * the complete process list and has non linear complexity with the number
- * mappings. In short it can be quite slow. But since memory corruptions
- * are rare we hope to get away with this.
+ * Pages are reported by the hardware as being corrupted usually due to a
+ * 2bit ECC memory or cache failure. Machine check can either be raised when
+ * corruption is found in background memory scrubbing, or when someone tries to
+ * consume the corruption. This code focuses on the former case.  If it cannot
+ * handle the error for some reason it's safe to just ignore it because no
+ * corruption has been consumed yet. Instead when that happens another (deadly)
+ * machine check will happen.
+ *
+ * The tricky part here is that we can access any page asynchronous to other VM
+ * users, because memory failures could happen anytime and anywhere, possibly
+ * violating some of their assumptions. This is why this code has to be
+ * extremely careful. Generally it tries to use normal locking rules, as in get
+ * the standard locks, even if that means the error handling takes potentially
+ * a long time.
+ *
+ * We don't aim to rescue 100% corruptions. That's unreasonable goal - the
+ * kernel text and slab pages (including the big dcache/icache) are almost
+ * impossible to isolate. We also try to keep the code clean by ignoring the
+ * other thousands of small corruption windows.
+ *
+ * When the corrupted page data is not recoverable, the tasks mapped the page
+ * have to be killed. We offer two kill options:
+ * - early kill with SIGBUS.BUS_MCEERR_AO (optional)
+ * - late  kill with SIGBUS.BUS_MCEERR_AR (mandatory)
+ * A task will be early killed as soon as corruption is found in its virtual
+ * address space, if it has called prctl(PR_MEMORY_FAILURE_EARLY_KILL, 1, ...);
+ * Any task will be late killed when it tries to access its corrupted virtual
+ * address. The early kill option offers KVM or other apps with large caches an
+ * opportunity to isolate the corrupted page from its internal cache, so as to
+ * avoid being late killed.
  */
 
 /*
@@ -275,6 +286,12 @@ static void collect_procs_file(struct pa
 
 		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
 				      pgoff)
+			/*
+			 * Send early kill signal to tasks whose vma covers
+			 * the page but not necessarily mapped it in its pte.
+			 * Applications who requested early kill normally want
+			 * to be informed of such data corruptions.
+			 */
 			if (vma->vm_mm == tsk->mm)
 				add_to_kill(tsk, page, vma, to_kill, tkc);
 	}
@@ -284,6 +301,12 @@ static void collect_procs_file(struct pa
 
 /*
  * Collect the processes who have the corrupted page mapped to kill.
+ *
+ * The operation to map back from RMAP chains to processes has to walk
+ * the complete process list and has non linear complexity with the number
+ * mappings. In short it can be quite slow. But since memory corruptions
+ * are rare and only tasks flagged PF_EARLY_KILL will be searched, we hope to
+ * get away with this.
  */
 static void collect_procs(struct page *page, struct list_head *tokill)
 {
@@ -439,7 +462,7 @@ static int me_pagecache_dirty(struct pag
  * Dirty swap cache page is tricky to handle. The page could live both in page
  * cache and swap cache(ie. page is freshly swapped in). So it could be
  * referenced concurrently by 2 types of PTEs:
- * normal PTEs and swap PTEs. We try to handle them consistently by calling u
+ * normal PTEs and swap PTEs. We try to handle them consistently by calling
  * try_to_unmap(TTU_IGNORE_HWPOISON) to convert the normal PTEs to swap PTEs,
  * and then
  *      - clear dirty bit to prevent IO
@@ -647,11 +670,6 @@ static void hwpoison_user_mappings(struc
 	 * mapped.  This has to be done before try_to_unmap,
 	 * because ttu takes the rmap data structures down.
 	 *
-	 * This also has the side effect to propagate the dirty
-	 * bit from PTEs into the struct page. This is needed
-	 * to actually decide if something needs to be killed
-	 * or errored, or if it's ok to just drop the page.
-	 *
 	 * Error handling: We ignore errors here because
 	 * there's nothing that can be done.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
