Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D623D6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:49:24 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QXf2g-0003yY-1I
	for linux-mm@kvack.org; Fri, 17 Jun 2011 19:49:22 +0000
Subject: [PATCH] mm, memory-failure: Fix spinlock vs mutex order
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1308335557.12801.24.camel@laptop>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>
	 <20110615161827.GA11769@tassilo.jf.intel.com>
	 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
	 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
	 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
	 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com>
	 <1308255972.17300.450.camel@schen9-DESK>
	 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com>
	 <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
	 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com>
	 <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
	 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
	 <1308310080.2355.19.camel@twins>
	 <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
	 <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
	 <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com>
	 <1308334688.12801.19.camel@laptop>  <1308335557.12801.24.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Jun 2011 21:53:05 +0200
Message-ID: <1308340385.12801.101.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 2011-06-17 at 20:32 +0200, Peter Zijlstra wrote:
> Aside from the THP thing there's a user in memory-failure.c, which looks
> to be broken as it is because its calling things under tasklist_lock
> which isn't preemptible, but it looks like we can simply swap the
> tasklist_lock vs page_lock_anon_vma.
> 

I thought about maybe using rcu, but then thought the thing is probably
wanting to exclude new tasks as it wants to kill all mm users.

---
Subject: mm, memory-failure: Fix spinlock vs mutex order

We cannot take a mutex while holding a spinlock, so flip the order as
its documented to be random.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory-failure.c |   21 ++++++---------------
 mm/rmap.c           |    5 ++---
 2 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index eac0ba5..740c4f5 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -391,10 +391,11 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct anon_vma *av;
 
-	read_lock(&tasklist_lock);
 	av = page_lock_anon_vma(page);
 	if (av == NULL)	/* Not actually mapped anymore */
-		goto out;
+		return;
+
+	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
 
@@ -408,9 +409,8 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 				add_to_kill(tsk, page, vma, to_kill, tkc);
 		}
 	}
-	page_unlock_anon_vma(av);
-out:
 	read_unlock(&tasklist_lock);
+	page_unlock_anon_vma(av);
 }
 
 /*
@@ -424,17 +424,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct prio_tree_iter iter;
 	struct address_space *mapping = page->mapping;
 
-	/*
-	 * A note on the locking order between the two locks.
-	 * We don't rely on this particular order.
-	 * If you have some other code that needs a different order
-	 * feel free to switch them around. Or add a reverse link
-	 * from mm_struct to task_struct, then this could be all
-	 * done without taking tasklist_lock and looping over all tasks.
-	 */
-
-	read_lock(&tasklist_lock);
 	mutex_lock(&mapping->i_mmap_mutex);
+	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
@@ -454,8 +445,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 				add_to_kill(tsk, page, vma, to_kill, tkc);
 		}
 	}
-	mutex_unlock(&mapping->i_mmap_mutex);
 	read_unlock(&tasklist_lock);
+	mutex_unlock(&mapping->i_mmap_mutex);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 0eb463e..5e51855 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -38,9 +38,8 @@
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within inode_wb_list_lock in __sync_single_inode)
  *
- * (code doesn't rely on that order so it could be switched around)
- * ->tasklist_lock
- *   anon_vma->mutex      (memory_failure, collect_procs_anon)
+ * anon_vma->mutex,mapping->i_mutex      (memory_failure, collect_procs_anon)
+ *   ->tasklist_lock
  *     pte map lock
  */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
