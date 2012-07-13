Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D7F186B0062
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 21:56:43 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.boulder.ibm.com>;
	Thu, 12 Jul 2012 19:56:43 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 80EA719D804F
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 01:56:38 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6D1udV5264214
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 19:56:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6D1ucMb014910
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 19:56:39 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] mm/sparse: remove index_init_lock
Date: Fri, 13 Jul 2012 10:01:22 +0800
Message-Id: <1342144882-16856-3-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1342144882-16856-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1342144882-16856-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

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

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
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
