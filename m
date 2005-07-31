Message-ID: <42EC2ED6.2070700@yahoo.com.au>
Date: Sun, 31 Jul 2005 11:52:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com>
Content-Type: multipart/mixed;
 boundary="------------060409040509070201000705"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060409040509070201000705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:

> get_user_pages is hard!  I don't know the right answer offhand,
> but thank you for posing a good question.
> 

Detect the racing fault perhaps, and retry until we're sure
that a write fault has gone through?

-- 
SUSE Labs, Novell Inc.


--------------060409040509070201000705
Content-Type: text/plain;
 name="mm-gup-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-gup-fix.patch"

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2005-07-28 19:04:34.000000000 +1000
+++ linux-2.6/include/linux/mm.h	2005-07-31 11:40:24.000000000 +1000
@@ -625,6 +625,7 @@ static inline int page_mapped(struct pag
  * Used to decide whether a process gets delivered SIGBUS or
  * just gets major/minor fault counters bumped up.
  */
+#define VM_FAULT_RACE	(-2)
 #define VM_FAULT_OOM	(-1)
 #define VM_FAULT_SIGBUS	0
 #define VM_FAULT_MINOR	1
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2005-07-28 19:04:37.000000000 +1000
+++ linux-2.6/mm/memory.c	2005-07-31 11:49:35.000000000 +1000
@@ -964,6 +964,14 @@ int get_user_pages(struct task_struct *t
 					return i ? i : -EFAULT;
 				case VM_FAULT_OOM:
 					return i ? i : -ENOMEM;
+				case VM_FAULT_RACE:
+					/*
+					 * Someone else got there first.
+					 * Must retry before we can assume
+					 * that we have actually performed
+					 * the write fault (below).
+					 */
+					continue;
 				default:
 					BUG();
 				}
@@ -1224,6 +1232,7 @@ static int do_wp_page(struct mm_struct *
 	struct page *old_page, *new_page;
 	unsigned long pfn = pte_pfn(pte);
 	pte_t entry;
+	int ret;
 
 	if (unlikely(!pfn_valid(pfn))) {
 		/*
@@ -1280,7 +1289,9 @@ static int do_wp_page(struct mm_struct *
 	 */
 	spin_lock(&mm->page_table_lock);
 	page_table = pte_offset_map(pmd, address);
+	ret = VM_FAULT_RACE;
 	if (likely(pte_same(*page_table, pte))) {
+		ret = VM_FAULT_MINOR;
 		if (PageAnon(old_page))
 			dec_mm_counter(mm, anon_rss);
 		if (PageReserved(old_page))
@@ -1299,7 +1310,7 @@ static int do_wp_page(struct mm_struct *
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	spin_unlock(&mm->page_table_lock);
-	return VM_FAULT_MINOR;
+	return ret;
 
 no_new_page:
 	page_cache_release(old_page);
@@ -1654,7 +1665,7 @@ static int do_swap_page(struct mm_struct
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
 			else
-				ret = VM_FAULT_MINOR;
+				ret = VM_FAULT_RACE;
 			pte_unmap(page_table);
 			spin_unlock(&mm->page_table_lock);
 			goto out;
@@ -1676,7 +1687,7 @@ static int do_swap_page(struct mm_struct
 	spin_lock(&mm->page_table_lock);
 	page_table = pte_offset_map(pmd, address);
 	if (unlikely(!pte_same(*page_table, orig_pte))) {
-		ret = VM_FAULT_MINOR;
+		ret = VM_FAULT_RACE;
 		goto out_nomap;
 	}
 
@@ -1737,6 +1748,7 @@ do_anonymous_page(struct mm_struct *mm, 
 {
 	pte_t entry;
 	struct page * page = ZERO_PAGE(addr);
+	int ret = VM_FAULT_MINOR;
 
 	/* Read-only mapping of ZERO_PAGE. */
 	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
@@ -1760,6 +1772,7 @@ do_anonymous_page(struct mm_struct *mm, 
 			pte_unmap(page_table);
 			page_cache_release(page);
 			spin_unlock(&mm->page_table_lock);
+			ret = VM_FAULT_RACE;
 			goto out;
 		}
 		inc_mm_counter(mm, rss);
@@ -1779,7 +1792,7 @@ do_anonymous_page(struct mm_struct *mm, 
 	lazy_mmu_prot_update(entry);
 	spin_unlock(&mm->page_table_lock);
 out:
-	return VM_FAULT_MINOR;
+	return ret;
 no_mem:
 	return VM_FAULT_OOM;
 }
@@ -1897,6 +1910,7 @@ retry:
 		pte_unmap(page_table);
 		page_cache_release(new_page);
 		spin_unlock(&mm->page_table_lock);
+		ret = VM_FAULT_RACE;
 		goto out;
 	}
 
Index: linux-2.6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/fault.c	2005-07-28 19:03:48.000000000 +1000
+++ linux-2.6/arch/i386/mm/fault.c	2005-07-31 11:47:48.000000000 +1000
@@ -351,6 +351,8 @@ good_area:
 			goto do_sigbus;
 		case VM_FAULT_OOM:
 			goto out_of_memory;
+		case VM_FAULT_RACE:
+			break;
 		default:
 			BUG();
 	}

--------------060409040509070201000705--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
