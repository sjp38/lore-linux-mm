Message-ID: <3D376567.4040307@us.ibm.com>
Date: Thu, 18 Jul 2002 18:03:35 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: [patch] Useless locking in mm/numa.c
Content-Type: multipart/mixed;
 boundary="------------020700060601010906070601"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, linux-mm@kvack.org, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020700060601010906070601
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

There is a lock that is apparently protecting nothing.  The node_lock spinlock 
in mm/numa.c is protecting read-only accesses to pgdat_list.  Here is a patch 
to get rid of it.

Cheers!

-Matt

--------------020700060601010906070601
Content-Type: text/plain;
 name="node_lock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="node_lock.patch"

--- linux-2.5.26-vanilla/mm/numa.c	Tue Jul 16 16:49:30 2002
+++ linux-2.5.26-vanilla/mm/numa.c.fixed	Thu Jul 18 17:59:35 2002
@@ -44,15 +44,11 @@
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
-static spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
-
 void show_free_areas_node(pg_data_t *pgdat)
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(&node_lock, flags);
 	show_free_areas_core(pgdat);
-	spin_unlock_irqrestore(&node_lock, flags);
 }
 
 /*
@@ -106,11 +102,9 @@
 #ifdef CONFIG_NUMA
 	temp = NODE_DATA(numa_node_id());
 #else
-	spin_lock_irqsave(&node_lock, flags);
 	if (!next) next = pgdat_list;
 	temp = next;
 	next = next->node_next;
-	spin_unlock_irqrestore(&node_lock, flags);
 #endif
 	start = temp;
 	while (temp) {

--------------020700060601010906070601--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
