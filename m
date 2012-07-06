Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9127B6B0074
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:09:50 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 21:09:49 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E309C1FF0048
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 03:09:45 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6639jwm294226
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 21:09:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6639iQd032030
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 21:09:45 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm/sparse: remove index_init_lock
Date: Fri,  6 Jul 2012 11:09:38 +0800
Message-Id: <1341544178-7245-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341544178-7245-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dave@linux.vnet.ibm.com, mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Apart from call to sparse_index_init() during boot stage, the function
is mainly used for hotplug case as follows and protected by hotplug
mutex "mem_hotplug_mutex". So we needn't the spinlock in sparse_index_init().

	sparse_index_init
	sparse_add_one_section
	__add_section
	__add_pages
	arch_add_memory
	add_memory

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 8b8edfb..4437c6c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -77,7 +77,6 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 
 static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 {
-	static DEFINE_SPINLOCK(index_init_lock);
 	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
 	struct mem_section *section;
 	int ret = 0;
@@ -88,20 +87,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	section = sparse_index_alloc(nid);
 	if (!section)
 		return -ENOMEM;
-	/*
-	 * This lock keeps two different sections from
-	 * reallocating for the same index
-	 */
-	spin_lock(&index_init_lock);
-
-	if (mem_section[root]) {
-		ret = -EEXIST;
-		goto out;
-	}
 
 	mem_section[root] = section;
-out:
-	spin_unlock(&index_init_lock);
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
