Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AA0836B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 14:28:57 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QXdmp-0001DS-6B
	for linux-mm@kvack.org; Fri, 17 Jun 2011 18:28:55 +0000
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1308334688.12801.19.camel@laptop>
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
	 <1308334688.12801.19.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Jun 2011 20:32:37 +0200
Message-ID: <1308335557.12801.24.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 2011-06-17 at 20:18 +0200, Peter Zijlstra wrote:
> On Fri, 2011-06-17 at 11:01 -0700, Linus Torvalds wrote:
> 
> > So I do think that "page_referenced_anon()" should do a trylock, and
> > return "referenced" if the trylock fails. Comments?
> 
> The only problem I can immediately see with that is when a single
> process' anon memory is dominant, then such an allocation will never
> succeed in freeing these pages because the one lock will pin pretty much
> all anon. Then again, there's always a few file pages to drop.
> 
> That said, its rather unlikely, and iirc people were working on removing
> direct reclaim, or at least rely less on it.
> 
> 

something like so I guess, completely untested etc..

Also, there's a page_lock_anon_vma() user in split_huge_page(), which is
used in mm/swap_state.c:add_to_swap(), which is also in the reclaim
path, not quite sure what to do there.

Aside from the THP thing there's a user in memory-failure.c, which looks
to be broken as it is because its calling things under tasklist_lock
which isn't preemptible, but it looks like we can simply swap the
tasklist_lock vs page_lock_anon_vma.

---
 kernel/Makefile |    1 +
 mm/rmap.c       |   39 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/kernel/Makefile b/kernel/Makefile
index 2d64cfc..f6d05de 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -101,6 +101,7 @@ obj-$(CONFIG_RING_BUFFER) += trace/
 obj-$(CONFIG_TRACEPOINTS) += trace/
 obj-$(CONFIG_SMP) += sched_cpupri.o
 obj-$(CONFIG_IRQ_WORK) += irq_work.o
+obj-m += test.o
 
 obj-$(CONFIG_PERF_EVENTS) += events/
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 0eb463e..40cd399 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -400,6 +400,41 @@ out:
 	return anon_vma;
 }
 
+struct anon_vma *page_trylock_anon_vma(struct page *page)
+{
+	struct anon_vma *anon_vma = NULL;
+	struct anon_vma *root_anon_vma;
+	unsigned long anon_mapping;
+
+	rcu_read_lock();
+	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
+	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
+		goto out;
+	if (!page_mapped(page))
+		goto out;
+
+	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	root_anon_vma = ACCESS_ONCE(anon_vma->root);
+	if (!mutex_trylock(&root_anon_vma->mutex)) {
+		anon_vma = NULL;
+		goto out;
+	}
+
+	/*
+	 * If the page is still mapped, then this anon_vma is still
+	 * its anon_vma, and holding the mutex ensures that it will
+	 * not go away, see anon_vma_free().
+	 */
+	if (!page_mapped(page)) {
+		mutex_unlock(&root_anon_vma->mutex);
+		anon_vma = NULL;
+	}
+
+out:
+	rcu_read_unlock();
+	return anon_vma;
+}
+
 /*
  * Similar to page_get_anon_vma() except it locks the anon_vma.
  *
@@ -694,7 +729,7 @@ static int page_referenced_anon(struct page *page,
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_trylock_anon_vma(page);
 	if (!anon_vma)
 		return referenced;
 
@@ -1396,7 +1431,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_trylock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
