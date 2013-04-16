Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id EB7886B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 23:38:26 -0400 (EDT)
Subject: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
MIME-Version: 1.0
Message-ID: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn>
From: zhang.yi20@zte.com.cn
Date: Tue, 16 Apr 2013 11:37:45 +0800
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Darren Hart <dvhart@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

Hello,

The futex-keys of processes share futex determined by page-offset, 
mapping-host, and 
mapping-index of the user space address. 
User appications using hugepage for futex may lead to futex-key conflict. 
Assume there 
are two or more futexes in diffrent normal pages of the hugepage, and each 
futex has 
the same offset in its normal page, causing all the futexes have the same 
futex-key. 
In that case, futex may not work well. 

This patch adds the normal page index in the compound page into the offset 
of futex-key. 

Steps to reproduce the bug: 
1. The 1st thread map a file of hugetlbfs, and use the return address as 
the 1st mutex's 
address, and use the return address with PAGE_SIZE added as the 2nd 
mutex's address; 
2. The 1st thread initialize the two mutexes with pshared attribute, and 
lock the two mutexes. 
3. The 1st thread create the 2nd thread, and the 2nd thread block on the 
1st mutex. 
4. The 1st thread create the 3rd thread, and the 3rd thread block on the 
2nd mutex. 
5. The 1st thread unlock the 2nd mutex, the 3rd thread can not take the 
2nd mutex, and 
may block forever. 

Signed-off-by: Zhang Yi <zhang.yi20@zte.com.cn>
Tested-by: Ma Chenggong <ma.chenggong@zte.com.cn>
Reviewed-by: Liu Dong <liu.dong3@zte.com.cn>
Reviewed-by: Cui Yunfeng <cui.yunfeng@zte.com.cn>
Reviewed-by: Lu Zhongjun <lu.zhongjun@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

diff -uprN orig/linux-3.9-rc7/include/linux/mm.h 
new/linux-3.9-rc7/include/linux/mm.h
--- orig/linux-3.9-rc7/include/linux/mm.h       2013-04-15 
00:45:16.000000000 +0000
+++ new/linux-3.9-rc7/include/linux/mm.h        2013-04-16 
11:21:59.573458000 +0000
@@ -502,6 +502,20 @@ static inline void set_compound_order(st
        page[1].lru.prev = (void *)order;
 }
 
+static inline void set_page_compound_index(struct page *page, int index)
+{
+       if (PageHead(page))
+               return;
+       page->index = index;
+}
+
+static inline int get_page_compound_index(struct page *page)
+{
+       if (PageHead(page))
+               return 0;
+       return page->index;
+}
+
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff -uprN orig/linux-3.9-rc7/kernel/futex.c 
new/linux-3.9-rc7/kernel/futex.c
--- orig/linux-3.9-rc7/kernel/futex.c   2013-04-15 00:45:16.000000000 
+0000
+++ new/linux-3.9-rc7/kernel/futex.c    2013-04-16 11:13:30.069887000 
+0000
@@ -239,7 +239,7 @@ get_futex_key(u32 __user *uaddr, int fsh
        unsigned long address = (unsigned long)uaddr;
        struct mm_struct *mm = current->mm;
        struct page *page, *page_head;
-       int err, ro = 0;
+       int err, ro = 0, comp_idx = 0;
 
        /*
         * The futex address must be "naturally" aligned.
@@ -299,6 +299,7 @@ again:
                         * freed from under us.
                         */
                        if (page != page_head) {
+                               comp_idx = get_page_compound_index(page);
                                get_page(page_head);
                                put_page(page);
                        }
@@ -311,6 +312,7 @@ again:
 #else
        page_head = compound_head(page);
        if (page != page_head) {
+               comp_idx = get_page_compound_index(page);
                get_page(page_head);
                put_page(page);
        }
@@ -363,7 +365,8 @@ again:
                key->private.mm = mm;
                key->private.address = address;
        } else {
-               key->both.offset |= FUT_OFF_INODE; /* inode-based key */
+               key->both.offset |= (comp_idx << PAGE_SHIFT)
+                                   | FUT_OFF_INODE; /* inode-based key */
                key->shared.inode = page_head->mapping->host;
                key->shared.pgoff = page_head->index;
        }
diff -uprN orig/linux-3.9-rc7/mm/hugetlb.c new/linux-3.9-rc7/mm/hugetlb.c
--- orig/linux-3.9-rc7/mm/hugetlb.c     2013-04-15 00:45:16.000000000 
+0000
+++ new/linux-3.9-rc7/mm/hugetlb.c      2013-04-16 10:23:02.658531000 
+0000
@@ -667,6 +667,7 @@ static void prep_compound_gigantic_page(
        for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
                __SetPageTail(p);
                set_page_count(p, 0);
+               set_page_compound_index(p, i);
                p->first_page = page;
        }
 }
diff -uprN orig/linux-3.9-rc7/mm/page_alloc.c 
new/linux-3.9-rc7/mm/page_alloc.c
--- orig/linux-3.9-rc7/mm/page_alloc.c  2013-04-15 00:45:16.000000000 
+0000
+++ new/linux-3.9-rc7/mm/page_alloc.c   2013-04-16 10:23:16.452393000 
+0000
@@ -361,6 +361,7 @@ void prep_compound_page(struct page *pag
                struct page *p = page + i;
                __SetPageTail(p);
                set_page_count(p, 0);
+               set_page_compound_index(p, i);
                p->first_page = page;
        }
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
