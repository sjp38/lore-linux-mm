Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D1F18600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 13:45:12 -0500 (EST)
Date: Thu, 7 Jan 2010 10:44:13 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105054536.44bf8002@infradead.org>  <alpine.DEB.2.00.1001050916300.1074@router.home>  <20100105192243.1d6b2213@infradead.org>  <alpine.DEB.2.00.1001071007210.901@router.home>
  <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 2010, Linus Torvalds wrote:
> 
> For example: there's no real reason why we take mmap_sem for writing when 
> extending an existing vma. And while 'brk()' is a very oldfashioned way of 
> doing memory management, it's still quite common. So rather than looking 
> at subtle lockless algorithms, why not look at doing the common cases of 
> an extending brk? Make that one take the mmap_sem for _reading_, and then 
> do the extending of the brk area with a simple cmpxchg or something?

I didn't use cmpxchg, because we actually want to update both 
'current->brk' _and_ the vma->vm_end atomically, so here's a totally 
untested patch that uses the page_table_lock spinlock for it instead (it 
could be a new spinlock, not worth it).

It's also totally untested and might be horribly broken. But you get the 
idea.

We could probably do things like this in regular mmap() too for the 
"extend a mmap" case. brk() is just especially simple.

		Linus

---
 mm/mmap.c |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 79 insertions(+), 10 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ee22989..3d07e5f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -242,23 +242,14 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	return next;
 }
 
-SYSCALL_DEFINE1(brk, unsigned long, brk)
+static long slow_brk(unsigned long brk)
 {
 	unsigned long rlim, retval;
 	unsigned long newbrk, oldbrk;
 	struct mm_struct *mm = current->mm;
-	unsigned long min_brk;
 
 	down_write(&mm->mmap_sem);
 
-#ifdef CONFIG_COMPAT_BRK
-	min_brk = mm->end_code;
-#else
-	min_brk = mm->start_brk;
-#endif
-	if (brk < min_brk)
-		goto out;
-
 	/*
 	 * Check against rlimit here. If this check is done later after the test
 	 * of oldbrk with newbrk then it can escape the test and let the data
@@ -297,6 +288,84 @@ out:
 	return retval;
 }
 
+/*
+ * NOTE NOTE NOTE!
+ *
+ * We do all this speculatively with just the read lock held.
+ * If anything goes wrong, we release the read lock, and punt
+ * to the traditional write-locked version.
+ *
+ * Here "goes wrong" includes:
+ *  - having to unmap the area and actually shrink it
+ *  - the final cmpxchg doesn't succeed
+ *  - the old brk area wasn't a simple anonymous vma
+ *  etc etc
+ */
+static struct vm_area_struct *ok_to_extend_brk(struct mm_struct *mm, unsigned long cur_brk, unsigned long brk)
+{
+	struct vm_area_struct *vma, *nextvma;
+
+	nextvma = find_vma_prev(mm, cur_brk, &vma);
+	if (vma) {
+		/*
+		 * Needs to be an anonymous vma that ends at the current brk,
+		 * and with no following vma that would start before the
+		 * new brk
+		 */
+		if (vma->vm_file || cur_brk != vma->vm_end || (nextvma && brk > nextvma->vm_start))
+			vma = NULL;
+	}
+	return vma;
+}
+
+SYSCALL_DEFINE1(brk, unsigned long, brk)
+{
+	unsigned long cur_brk, min_brk;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+
+	down_read(&mm->mmap_sem);
+	cur_brk = mm->brk;
+#ifdef CONFIG_COMPAT_BRK
+	min_brk = mm->end_code;
+#else
+	min_brk = mm->start_brk;
+#endif
+	if (brk < min_brk)
+		goto out;
+
+	brk = PAGE_ALIGN(brk);
+	cur_brk = PAGE_ALIGN(cur_brk);
+
+	if (brk < cur_brk)
+		goto slow_case;
+	if (brk == cur_brk)
+		goto out;
+
+	vma = ok_to_extend_brk(mm, cur_brk, brk);
+	if (!vma)
+		goto slow_case;
+
+	spin_lock(&mm->page_table_lock);
+	if (vma->vm_end == cur_brk) {
+		vma->vm_end = brk;
+		mm->brk = brk;
+		cur_brk = brk;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	if (cur_brk != brk)
+		goto slow_case;
+
+out:
+	up_read(&mm->mmap_sem);
+	return cur_brk;
+
+slow_case:
+	up_read(&mm->mmap_sem);
+	return slow_brk(brk);
+}
+
 #ifdef DEBUG_MM_RB
 static int browse_rb(struct rb_root *root)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
