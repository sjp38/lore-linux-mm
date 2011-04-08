Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1F0708D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 04:44:14 -0400 (EDT)
Date: Fri, 8 Apr 2011 16:44:09 +0800 (CST)
From: bill <bill_carson@126.com>
Message-ID: <114cbfb0.1855c.12f34486272.Coremail.bill_carson@126.com>
Subject: Query about __unmap_hugepage_range
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hey, MM developers:)

I don't know if this posting is proper at here, so sorry for disturbing if it does. 

for normal 4K page: in unmap_page_range 
1: tlb_start_vma(tlb, vma); <------ call  flush_cache_range to invalidate icache if vma is VM_EXEC
2: clear pagetable mapping
3: tlb_end_vma(tlb, vma); <-------- call flush_tlb_range to invalidate unmapped vma tlb entry

for hugepage: in __unmap_hugepage_range
1: clear pagetable mapping
 2: call flush_tlb_range(vma, start, end); to invalidate unmapped vma tlb entry

I really don't understand about two things:
A: why there is no  flush_cache_range for hugepage when we do the unmapping?
B: How does kernel take care of such case for both normal 4K page and hugepage:
    a: mmap a page with PROT_EXEC at location p;
    b: copy bunch instruction into p ,call cacheflush to make ICACHE see the new instruction; 
    c: run instruction at location p, then unmap it;
    d: mmap a new page with MAP_FIXED/PROT_EXEC at location p, and run unexpected instruction at p;
        there is a great chance we got the same page at step_a;
        user space should see a clean icache, not a stale one;
     
I am really puzzled for a long time.
I am porting hugepage for ARM ,and one testcase in libhugetlbfs called icache-hygiene failed, test rationale is described  in above B.

Any tips/advice would be truly appreciated.
Thanks

        

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
