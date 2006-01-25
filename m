Received: from e34.co.us.ibm.com (e34.boulder.ibm.com [9.17.249.44])
	by pokfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id k0PLbSCP010595
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:29 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0PLb8Ix017777
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0PLZC0Y271724
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 14:35:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0PLawiu010949
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 14:36:58 -0700
Subject: [patch 1/9] mempool - Add page allocator
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
References: <20060125161321.647368000@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 25 Jan 2006 11:39:55 -0800
Message-Id: <1138217995.2092.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

plain text document attachment (critical_mempools)
Add another allocator to the common mempool code: a simple page allocator

This will be used by the next patch in the series to replace duplicate
mempool-backed page allocators in 2 places in the kernel.  It is also very
likely that there will be more users in the future.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

 include/linux/mempool.h |    6 ++++++
 mm/mempool.c            |   17 +++++++++++++++++
 2 files changed, 23 insertions(+)

Index: linux-2.6.16-rc1+critical_mempools/mm/mempool.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/mm/mempool.c
+++ linux-2.6.16-rc1+critical_mempools/mm/mempool.c
@@ -289,3 +289,20 @@ void mempool_free_slab(void *element, vo
 	kmem_cache_free(mem, element);
 }
 EXPORT_SYMBOL(mempool_free_slab);
+
+/*
+ * A simple mempool-backed page allocator
+ */
+void *mempool_alloc_pages(gfp_t gfp_mask, void *pool_data)
+{
+	int order = (int)pool_data;
+	return alloc_pages(gfp_mask, order);
+}
+EXPORT_SYMBOL(mempool_alloc_pages);
+
+void mempool_free_pages(void *element, void *pool_data)
+{
+	int order = (int)pool_data;
+	__free_pages(element, order);
+}
+EXPORT_SYMBOL(mempool_free_pages);
Index: linux-2.6.16-rc1+critical_mempools/include/linux/mempool.h
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/include/linux/mempool.h
+++ linux-2.6.16-rc1+critical_mempools/include/linux/mempool.h
@@ -38,4 +38,10 @@ extern void mempool_free(void *element, 
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data);
 void mempool_free_slab(void *element, void *pool_data);
 
+/*
+ * A mempool_alloc_t and mempool_free_t for a simple page allocator
+ */
+void *mempool_alloc_pages(gfp_t gfp_mask, void *pool_data);
+void mempool_free_pages(void *element, void *pool_data);
+
 #endif /* _LINUX_MEMPOOL_H */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
