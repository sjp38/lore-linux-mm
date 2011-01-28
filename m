Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A40878D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:36:48 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 41A4A3EE0C1
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:36:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28FEE45DD74
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:36:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED63245DE4D
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:36:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DFCDC1DB803A
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:36:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1E241DB803B
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:36:41 +0900 (JST)
Date: Fri, 28 Jan 2011 17:30:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 4/4] memcg: fix khugepaged should skip busy
 memcg
Message-Id: <20110128173036.9719292c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128172022.8f16e862.nishimura@mxp.nes.nec.co.jp>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122832.34550412.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128172022.8f16e862.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 17:20:22 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +	/*
> > +	 * At collapsing, khugepaged charges HPAGE_SIZE. When it unmap
> > +	 * used ptes, the charge will be decreased.
> > +	 *
> > +	 * This requirement of 'extra charge' at collapsing seems redundant
> > +	 * it's safe way for now. For example, at replacing a chunk of page
> > +	 * to be hugepage, khuepaged skips pte_none() entry, which is not
> > +	 * which is not charged. But we should do charge under spinlocks as
> > +	 * pte_lock, we need precharge. Check status before doing heavy
> > +	 * jobs and give khugepaged chance to retire early.
> > +	 */
> > +	if (mem_cgroup_check_margin(mem) >= HPAGE_SIZE)
> I'm sorry if I misunderstand, shouldn't it be "<" ?

yes. This bug will make khugepaged never work on a memcg and
the system never cause hang ;(

Thank you.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When using khugepaged with small memory cgroup, we see khugepaged
causes soft lockup, or running process under memcg will hang

It's because khugepaged tries to scan all pmd of a process
which is under busy/small memory cgroup and tries to allocate
HUGEPAGE size resource.

This work is done under mmap_sem and can cause memory reclaim
repeatedly. This will easily raise cpu usage of khugepaged and latecy
of scanned process will goes up. Moreover, it seems succesfully
working TransHuge pages may be splitted by this memory reclaim
caused by khugepaged.

This patch adds a hint for khugepaged whether a process is
under a memory cgroup which has sufficient memory. If memcg
seems busy, a process is skipped.

How to test:
  # mount -o cgroup cgroup /cgroup/memory -o memory
  # mkdir /cgroup/memory/A
  # echo 200M (or some small) > /cgroup/memory/A/memory.limit_in_bytes
  # echo 0 > /cgroup/memory/A/tasks
  # make -j 8 kernel

Changelog:
 - fixed condition check bug.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    7 +++++
 mm/huge_memory.c           |   10 +++++++-
 mm/memcontrol.c            |   53 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+), 1 deletion(-)

Index: mmotm-0125/mm/memcontrol.c
===================================================================
--- mmotm-0125.orig/mm/memcontrol.c
+++ mmotm-0125/mm/memcontrol.c
@@ -255,6 +255,9 @@ struct mem_cgroup {
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
 
+	/* For transparent hugepage daemon */
+	unsigned long long recent_failcnt;
+
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -2211,6 +2214,56 @@ void mem_cgroup_split_huge_fixup(struct 
 	tail_pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	move_unlock_page_cgroup(head_pc, &flags);
 }
+
+bool mem_cgroup_worth_try_hugepage_scan(struct mm_struct *mm)
+{
+	struct mem_cgroup *mem;
+	bool ret = true;
+	u64 recent_charge_fail;
+
+	if (mem_cgroup_disabled())
+		return true;
+
+	mem = try_get_mem_cgroup_from_mm(mm);
+
+	if (!mem)
+		return true;
+
+	if (mem_cgroup_is_root(mem))
+		goto out;
+
+	/*
+	 * At collapsing, khugepaged charges HPAGE_SIZE. When it unmap
+	 * used ptes, the charge will be decreased.
+	 *
+	 * This requirement of 'extra charge' at collapsing seems redundant
+	 * it's safe way for now. For example, at replacing a chunk of page
+	 * to be hugepage, khuepaged skips pte_none() entry, which is not
+	 * which is not charged. But we should do charge under spinlocks as
+	 * pte_lock, we need precharge. Check status before doing heavy
+	 * jobs and give khugepaged chance to retire early.
+	 */
+	if (mem_cgroup_check_margin(mem) < HPAGE_SIZE)
+		ret = false;
+
+	 /*
+	  * This is an easy check. If someone other than khugepaged does
+	  * hit limit, khugepaged should avoid more pressure.
+	  */
+	recent_charge_fail = res_counter_read_u64(&mem->res, RES_FAILCNT);
+	if (ret
+	    && mem->recent_failcnt
+            && recent_charge_fail > mem->recent_failcnt) {
+		ret = false;
+	}
+	/* because this thread will fail charge by itself +1.*/
+	if (recent_charge_fail)
+		mem->recent_failcnt = recent_charge_fail + 1;
+out:
+	css_put(&mem->css);
+	return ret;
+}
+
 #endif
 
 /**
Index: mmotm-0125/mm/huge_memory.c
===================================================================
--- mmotm-0125.orig/mm/huge_memory.c
+++ mmotm-0125/mm/huge_memory.c
@@ -2011,8 +2011,10 @@ static unsigned int khugepaged_scan_mm_s
 	down_read(&mm->mmap_sem);
 	if (unlikely(khugepaged_test_exit(mm)))
 		vma = NULL;
-	else
+	else if (mem_cgroup_worth_try_hugepage_scan(mm))
 		vma = find_vma(mm, khugepaged_scan.address);
+	else
+		vma = NULL;
 
 	progress++;
 	for (; vma; vma = vma->vm_next) {
@@ -2024,6 +2026,12 @@ static unsigned int khugepaged_scan_mm_s
 			break;
 		}
 
+		if (unlikely(!mem_cgroup_worth_try_hugepage_scan(mm))) {
+			progress++;
+			vma = NULL; /* try next mm */
+			break;
+		}
+
 		if ((!(vma->vm_flags & VM_HUGEPAGE) &&
 		     !khugepaged_always()) ||
 		    (vma->vm_flags & VM_NOHUGEPAGE)) {
Index: mmotm-0125/include/linux/memcontrol.h
===================================================================
--- mmotm-0125.orig/include/linux/memcontrol.h
+++ mmotm-0125/include/linux/memcontrol.h
@@ -148,6 +148,7 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
+bool mem_cgroup_worth_try_hugepage_scan(struct mm_struct *mm);
 #endif
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
@@ -342,6 +343,12 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 static inline void mem_cgroup_split_huge_fixup(struct page *head,
 						struct page *tail)
 {
+
+}
+
+static inline bool mem_cgroup_worth_try_hugepage_scan(struct mm_struct *mm)
+{
+	return true;
 }
 
 #endif /* CONFIG_CGROUP_MEM_CONT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
