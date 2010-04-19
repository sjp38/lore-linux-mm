Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 381B26B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 12:56:21 -0400 (EDT)
Date: Mon, 19 Apr 2010 17:55:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Fix infinite loop in get_futex_key when backed by huge
	pages
Message-ID: <20100419165558.GZ19264@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, r6144 <rainy6144@gmail.com>, linux-kernel@vger.kernel.org, tglx <tglx@linutronix.de>, Andrea Arcangeli <aarcange@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

If a futex key happens to be located within a huge page mapped MAP_PRIVATE,
get_futex_key() can go into an infinite loop waiting for a page->mapping that
will never exist. This was reported and documented in an external bugzilla at

https://bugzilla.redhat.com/show_bug.cgi?id=552257

This patch makes page->mapping a poisoned value that includes
PAGE_MAPPING_ANON mapped MAP_PRIVATE.  This is enough for futex to continue
but because of PAGE_MAPPING_ANON, the poisoned value is not dereferenced
or used by futex. No other part of the VM should be dereferencing the
page->mapping of a hugetlbfs page as its page cache is not on the LRU.

This patch fixes the problem with the test case described in the bugzilla.

This patch if merged to mainline should also be considered for -stable.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Darren Hart <darren@dvhart.com>
---
 include/linux/poison.h |    9 +++++++++
 mm/hugetlb.c           |    5 ++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/poison.h b/include/linux/poison.h
index 2110a81..bab71f3 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -48,6 +48,15 @@
 #define POISON_FREE	0x6b	/* for use-after-free poisoning */
 #define	POISON_END	0xa5	/* end-byte of poisoning */
 
+/********** mm/hugetlb.c **********/
+/*
+ * Private mappings of hugetlb pages use this poisoned value for
+ * page->mapping. The core VM should not be doing anything with this mapping
+ * but futex requires the existance of some page->mapping value even though it
+ * is unused if PAGE_MAPPING_ANON is set.
+ */
+#define HUGETLB_POISON	((void *)(0x00300300 + POISON_POINTER_DELTA + PAGE_MAPPING_ANON))
+
 /********** arch/$ARCH/mm/init.c **********/
 #define POISON_FREE_INITMEM	0xcc
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6034dc9..ffbdfc8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -546,6 +546,7 @@ static void free_huge_page(struct page *page)
 
 	mapping = (struct address_space *) page_private(page);
 	set_page_private(page, 0);
+	page->mapping = NULL;
 	BUG_ON(page_count(page));
 	INIT_LIST_HEAD(&page->lru);
 
@@ -2447,8 +2448,10 @@ retry:
 			spin_lock(&inode->i_lock);
 			inode->i_blocks += blocks_per_huge_page(h);
 			spin_unlock(&inode->i_lock);
-		} else
+		} else {
 			lock_page(page);
+			page->mapping = HUGETLB_POISON;
+		}
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
