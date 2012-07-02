Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 33DD86B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 05:29:38 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 05:29:37 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q629TX9V10289640
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 05:29:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q62F0QOx010539
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 11:00:26 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Date: Mon,  2 Jul 2012 17:28:56 +0800
Message-Id: <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dave@linux.vnet.ibm.com, mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

sparse_index_init() is designed to be safe if two copies of it race.  It
uses "index_init_lock" to ensure that, even in the case of a race, only
one CPU will manage to do:

	mem_section[root] = section;

However, in the case where two copies of sparse_index_init() _do_ race,
the one that loses the race will leak the "section" that
sparse_index_alloc() allocated for it.  This patch fixes that leak.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 781fa04..a6984d9 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -75,6 +75,20 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 	return section;
 }
 
+static inline void __meminit sparse_index_free(struct mem_section *section)
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
+		free_bootmem(virt_to_phys(section), size);
+}
+
 static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 {
 	static DEFINE_SPINLOCK(index_init_lock);
@@ -102,6 +116,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	mem_section[root] = section;
 out:
 	spin_unlock(&index_init_lock);
+	if (ret)
+		sparse_index_free(section);
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
