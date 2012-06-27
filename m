Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 978FF6B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:13:13 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 12:13:12 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2E9363C604A0
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:36:33 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RGaHsG33489064
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:36:17 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RM78X5031924
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:07:09 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Date: Thu, 28 Jun 2012 00:36:07 +0800
Message-Id: <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
are allocated by slab or bootmem allocator. Also, the descriptors
might have been allocated and initialized during the hotplug path.
However, the memory chunk allocated in current implementation wouldn't
be put into the available pool if that has been allocated. The situation
will lead to memory leak.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/sparse.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 781fa04..a803599 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -75,6 +75,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
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
@@ -102,6 +118,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	mem_section[root] = section;
 out:
 	spin_unlock(&index_init_lock);
+	if (ret)
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
