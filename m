Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1LEPbE6006776
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 09:25:37 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1LEPbOh282162
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 09:25:37 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1LEPaIC019852
	for <linux-mm@kvack.org>; Wed, 21 Feb 2007 09:25:37 -0500
Message-Id: <20070221142534.532912000@linux.vnet.ibm.com>>
References: <20070221142451.193001000@linux.vnet.ibm.com>>
Date: Wed, 21 Feb 2007 19:54:53 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH 2/3][RFC] Containers: Pagecache controller accounting
Content-Disposition: inline; filename=pagecache-controller-acct.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: balbir@in.ibm.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, devel@openvz.org, xemul@sw.ru, menage@google.com, clameter@sgi.com, riel@redhat.com, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

The accounting framework works by adding a container pointer in 
address_space structure.  Each page in pagecache belongs to a 
radix tree within the address_space structure corresponding to the inode.

In order to charge the container for pagecache usage, the corresponding 
address_space is obtained from struct page which holds the container pointer.  
This framework avoids any additional pointers in struct page.

additions and deletions from pagecache are hooked to charge and uncharge 
the corresponding container.

Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
---
 include/linux/fs.h |    4 ++++
 mm/filemap.c       |    8 ++++++++
 2 files changed, 12 insertions(+)

--- linux-2.6.20.orig/include/linux/fs.h
+++ linux-2.6.20/include/linux/fs.h
@@ -447,6 +447,10 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_CONTAINER_PAGECACHE_ACCT
+	struct container *container; 	/* Charge page to the right container
+					   using page->mapping */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
--- linux-2.6.20.orig/mm/filemap.c
+++ linux-2.6.20/mm/filemap.c
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/pagecache_acct.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -117,6 +118,8 @@ void __remove_from_page_cache(struct pag
 	struct address_space *mapping = page->mapping;
 
 	radix_tree_delete(&mapping->page_tree, page->index);
+	/* Uncharge before the mapping is gone */
+	pagecache_acct_uncharge(page);
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
@@ -451,6 +454,11 @@ int add_to_page_cache(struct page *page,
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&mapping->tree_lock);
+		/* Unlock before charge, because we may reclaim this inline */
+		if (!error) {
+			pagecache_acct_init_page_ptr(page);
+			pagecache_acct_charge(page);
+		}
 		radix_tree_preload_end();
 	}
 	return error;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
