Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 090DD6B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:41:24 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.pok.ibm.com>;
	Sun, 15 Jul 2012 22:41:23 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 95A80C90063
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:41:12 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6G4fCLf4981168
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:41:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GAC5Z0025963
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 06:12:05 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v3 3/3] mm/sparse: remove index_init_lock
Date: Mon, 16 Jul 2012 12:45:57 +0800
Message-Id: <1342413957-3843-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1342413957-3843-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1342413957-3843-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

sparse_index_init uses index_init_lock spinlock to protect root
mem_section assignment. The lock is not necessary anymore because the
function is called only during the boot (during paging init which
is executed only from a single CPU) and from the hotplug code (by
add_memory via arch_add_memory) which uses mem_hotplug_mutex.

The lock has been introduced by 28ae55c9 (sparsemem extreme: hotplug
preparation) and sparse_index_init was used only during boot at that
time.

Later when the hotplug code (and add_memory) was introduced there was
no synchronization so it was possible to online more sections from
the same root probably (though I am not 100% sure about that).
The first synchronization has been added by 6ad696d2 (mm: allow memory
hotplug and hibernation in the same kernel) which has been later
replaced by the mem_hotplug_mutex - 20d6c96b (mem-hotplug: introduce
{un}lock_memory_hotplug()).

Let's remove the lock as it is not needed and it makes the code more
confusing.

[mhocko@suse.cz: changelog]
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/sparse.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 51950de..40b1100 100644
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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
