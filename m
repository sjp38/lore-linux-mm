Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 758246B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 08:10:07 -0500 (EST)
Message-ID: <4EC264AA.30306@redhat.com>
Date: Tue, 15 Nov 2011 14:10:02 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: [RFC PATCH V2] Enforce RSS+Swap rlimit
References: <4EB3FA89.6090601@redhat.com>
In-Reply-To: <4EB3FA89.6090601@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


Change since V1: rebase on 3.2-rc1

Currently RSS rlimit is not enforced. We can not forbid a process to exceeds
its RSS limit and allow it swap out. That would hurts the performance of all
system, even when memory resources are plentiful.

Therefore, instead of enforcing a limit on rss usage alone, this patch enforces
a limit on rss+swap value. This is similar to memsw limits of cgroup.
If a process rss+swap usage exceeds RLIMIT_RSS max limit, he received a SIGBUS
signal. 

My tests show that code in do_anonymous_page() and __do_fault() indeed prevents
processes to get more memory than the limit and I haven't seen any adverse
effect, but so far, I have no test coverage of the code in do_wp_page(). I'm
not sure how to test it.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/mm.h |    7 +++++++
 mm/memory.c        |   21 +++++++++++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3dc3a8c..3b54ff1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1092,6 +1092,13 @@ static inline unsigned long get_mm_rss(struct mm_struct *mm)
 		get_mm_counter(mm, MM_ANONPAGES);
 }
 
+static inline unsigned long get_mm_memsw(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_ANONPAGES) +
+		get_mm_counter(mm, MM_SWAPENTS);
+}
+
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
 {
 	return max(mm->hiwater_rss, get_mm_rss(mm));
diff --git a/mm/memory.c b/mm/memory.c
index 829d437..b0463c2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2661,8 +2661,14 @@ gotten:
 				dec_mm_counter_fast(mm, MM_FILEPAGES);
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
-		} else
+		} else {
+			if (get_mm_memsw(mm) >=
+			    rlimit_max(RLIMIT_RSS) >> PAGE_SHIFT) {
+				ret |= VM_FAULT_SIGBUS;
+				goto release;
+			}
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2713,6 +2719,7 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
+release:
 	if (new_page)
 		page_cache_release(new_page);
 unlock:
@@ -3073,6 +3080,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t entry;
+	int ret = 0;
 
 	pte_unmap(page_table);
 
@@ -3109,6 +3117,10 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_none(*page_table))
 		goto release;
 
+	if (get_mm_memsw(mm) >=  rlimit_max(RLIMIT_RSS) >> PAGE_SHIFT) {
+		ret = VM_FAULT_SIGBUS;
+		goto release;
+	}
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
@@ -3118,7 +3130,7 @@ setpte:
 	update_mmu_cache(vma, address, page_table);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	return 0;
+	return ret;
 release:
 	mem_cgroup_uncharge_page(page);
 	page_cache_release(page);
@@ -3263,6 +3275,10 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (get_mm_memsw(mm) >=  rlimit_max(RLIMIT_RSS) >> PAGE_SHIFT) {
+			ret = VM_FAULT_SIGBUS;
+			goto unlock;
+		}
 		if (anon) {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
@@ -3287,6 +3303,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			anon = 1; /* no anon but release faulted_page */
 	}
 
+unlock:
 	pte_unmap_unlock(page_table, ptl);
 
 	if (dirty_page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
