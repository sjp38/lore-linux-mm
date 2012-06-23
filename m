Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 1EA9A6B02C1
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:31 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 23 Jun 2012 11:53:29 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B5F4A6E804D
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:01 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5NFr1gl174620
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5NFr1jk012672
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 12:53:01 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 3/5] mm/sparse: fix possible memory leak
Date: Sat, 23 Jun 2012 23:52:54 +0800
Message-Id: <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
are allocated by slab or bootmem allocator. Also, the descriptors
might have been allocated and initialized by others. However, the
memory chunk allocated in current implementation wouldn't be put
into the available pool if others have allocated memory chunk for
that.

The patch introduces addtional function sparse_index_free() to
deallocate the memory chunk if the root memory section descriptor
has been initialized by others.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index ce50c8b..bae8f2d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -86,6 +86,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 	return section;
 }
 
+static void noinline __init_refok sparse_index_free(struct mem_section *section,
+						    int nid)
+{
+	unsigned long size = SECTIONS_PER_ROOT *
+			     sizeof(struct mem_section);
+
+	if (!section)
+		return;
+
+	if (slab_is_available())
+		kfree(section);
+	else
+		free_bootmem_node(NODE_DATA(nid),
+			virt_to_phys(section), size);
+}
+
 static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 {
 	static DEFINE_SPINLOCK(index_init_lock);
@@ -113,6 +129,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	mem_section[root] = section;
 out:
 	spin_unlock(&index_init_lock);
+	if (ret == -EEXIST)
+		sparse_index_free(section, nid);
+
 	return ret;
 }
 #else /* !SPARSEMEM_EXTREME */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
