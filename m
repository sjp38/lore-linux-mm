Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 5CA2A6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 11:59:32 -0400 (EDT)
Message-ID: <4F96CDE1.5000909@redhat.com>
Date: Tue, 24 Apr 2012 11:59:29 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
Content-Type: multipart/mixed;
 boundary="------------030403060505070205030302"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

This is a multi-part message in MIME format.
--------------030403060505070205030302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

While moving tasks between cpusets we noticed some strange behavior.  
Specifically if the nodes of the destination
cpuset are a subset of the nodes of the source cpuset do_migrate_pages() 
will move pages that are already on a node
in the destination cpuset.  The reason for this is do_migrate_pages() 
does not check whether each node in the source
nodemask is in the destination nodemask before calling 
migrate_to_node().  If we simply do this check and skip them
when the source is in the destination moving we wont move nodes that 
dont need to be moved.

Adding a little debug printk to migrate_to_node():

Without this change migrating tasks from a cpuset containing nodes 0-7 
to a cpuset containing nodes 3-4, we migrate
from ALL the nodes even if they are in the both the source and 
destination nodesets:

   Migrating 7 to 4
   Migrating 6 to 3
   Migrating 5 to 4
   Migrating 4 to 3
   Migrating 1 to 4
   Migrating 3 to 4
   Migrating 0 to 3
   Migrating 2 to 3


With this change we only migrate from nodes that are not in the 
destination nodesets:

   Migrating 7 to 4
   Migrating 6 to 3
   Migrating 5 to 4
   Migrating 2 to 3
   Migrating 1 to 4
   Migrating 0 to 3

This version of the patch will only skips migrating from nodes that are 
not in the destination
nodesets if the number of nodes in the source and destination nodesets 
are not equal.  This
preserves the intended behavior that Christoph pointed out yet aviods 
the costly overhead
of migrating them when its not necessary.


Here is timings of migrating from nodes 0-7 to 1 & 3 with and without 
the patch:

BEFORE PATCH -- Move times: 59, 140, 651 seconds
============

Moving 14 tasks from nodes (0-7) to nodes (1,3)
numad(8780) do_migrate_pages (mm=0xffff88081d414400 
from_nodes=0xffff880818c81d28 to_nodes=0xffff880818c81ce8 flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x7 dest=0x3 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x6 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x5 dest=0x3 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x4 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x2 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x1 dest=0x3 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d414400 source=0x0 dest=0x1 
flags=0x4)
(Above moves repeated for each of the 14 tasks...)
PID 8890 moved to node(s) 1,3 in 59.2 seconds


Moving 20 tasks from nodes (0-7) to nodes (1,4-5)
numad(8780) do_migrate_pages (mm=0xffff88081d88c700 
from_nodes=0xffff880818c81d28 to_nodes=0xffff880818c81ce8 flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x7 dest=0x4 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x6 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x3 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x2 dest=0x5 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x1 dest=0x4 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d88c700 source=0x0 dest=0x1 
flags=0x4)
(Above moves repeated for each of the 20 tasks...)
PID 8962 moved to node(s) 1,4-5 in 139.88 seconds


Moving 26 tasks from nodes (0-7) to nodes (1-3,5)
numad(8780) do_migrate_pages (mm=0xffff88081d5bc740 
from_nodes=0xffff880818c81d28 to_nodes=0xffff880818c81ce8 flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x7 dest=0x5 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x6 dest=0x3 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x5 dest=0x2 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x3 dest=0x5 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x2 dest=0x3 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x1 dest=0x2 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x0 dest=0x1 
flags=0x4)
numad(8780) migrate_to_node (mm=0xffff88081d5bc740 source=0x4 dest=0x1 
flags=0x4)
(Above moves repeated for each of the 26 tasks...)
PID 9058 moved to node(s) 1-3,5 in 651.45 seconds



AFTER PATCH -- Move times: 42, 56, 93 seconds
===========

Moving 14 tasks from nodes (0-7) to nodes (5,7)
numad(33209) do_migrate_pages (mm=0xffff88101d5ff140 
from_nodes=0xffff88101e7b5d28 to_nodes=0xffff88101e7b5ce8 flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x6 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x4 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x3 dest=0x7 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x2 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x1 dest=0x7 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d5ff140 source=0x0 dest=0x5 
flags=0x4)
(Above moves repeated for each of the 14 tasks...)
PID 33221 moved to node(s) 5,7 in 41.67 seconds


Moving 20 tasks from nodes (0-7) to nodes (1,3,5)
numad(33209) do_migrate_pages (mm=0xffff88101d6c37c0 
from_nodes=0xffff88101e7b5d28 to_nodes=0xffff88101e7b5ce8 flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d6c37c0 source=0x7 dest=0x3 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d6c37c0 source=0x6 dest=0x1 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d6c37c0 source=0x4 dest=0x3 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d6c37c0 source=0x2 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d6c37c0 source=0x0 dest=0x1 
flags=0x4)
(Above moves repeated for each of the 20 tasks...)
PID 33289 moved to node(s) 1,3,5 in 56.3 seconds


Moving 26 tasks from nodes (0-7) to nodes (1,3,5,7)
numad(33209) do_migrate_pages (mm=0xffff88101d924400 
from_nodes=0xffff88101e7b5d28 to_nodes=0xffff88101e7b5ce8 flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d924400 source=0x6 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d924400 source=0x4 dest=0x1 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d924400 source=0x2 dest=0x5 
flags=0x4)
numad(33209) migrate_to_node (mm=0xffff88101d924400 source=0x0 dest=0x1 
flags=0x4)
(Above moves repeated for each of the 26 tasks...)
PID 33372 moved to node(s) 1,3,5,7 in 92.67 seconds


Signed-off-by: Larry Woodman<lwoodman@redhat.com>



--------------030403060505070205030302
Content-Type: text/plain;
 name="upstream-do_migrate_pages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="upstream-do_migrate_pages.patch"

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 47296fe..6c189fa 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1012,6 +1012,16 @@ int do_migrate_pages(struct mm_struct *mm,
 		int dest = 0;
 
 		for_each_node_mask(s, tmp) {
+
+			/* IFF there is an equal number of source and
+			 * destination nodes, maintain relative node distance
+			 * even when source and destination nodes overlap.
+			 * However, when the node weight is unequal, never move
+			 * memory out of any destination nodes */
+			if ((nodes_weight(*from_nodes) != nodes_weight(*to_nodes)) && 
+						(node_isset(s, *to_nodes)))
+				continue;
+
 			d = node_remap(s, *from_nodes, *to_nodes);
 			if (s == d)
 				continue;

--------------030403060505070205030302--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
