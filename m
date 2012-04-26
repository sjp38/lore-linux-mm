Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id BE0536B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 14:11:44 -0400 (EDT)
Message-ID: <4F998FDE.5020104@redhat.com>
Date: Thu, 26 Apr 2012 14:11:42 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: [PATCH -mm V3] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

While running an application that moves tasks from one cpuset to another 
I noticed
that it takes much longer and moves many more pages than expected.  The 
reason
for this is do_migrate_pages() does its best to preserve the relative 
node differential
from the first node of the cpuset because the application may have been 
written with
that in mind.  If memory was interleaved on the nodes of the source 
cpuset by an
application do_migrate_pages() will try its best to maintain that 
interleaving on the
nodes of the destination cpuset.  This means copying the memory from all 
source nodes
to the destination nodes even if the source and destination nodes overlap.

This is a problem for userspace NUMA placement tools.  The amount of 
time spent
doing extra memory moves cancels out some of the NUMA performance 
improvements.
Furthermore, if the number of source and destination nodes are 
different, if is impossible
to maintain the previous interleaving layout anyway.

This patch changes do_migrate_pages() to only preserve the relative 
layout inside the
program if the number of NUMA nodes in the source and destination mask 
are the
same. If the number is different, we do a much more efficient migration 
by not touching
memory that is in an allowed node.

This preserves the old behaviour for programs that want it, while 
allowing a userspace
NUMA placement tool to use the new, faster migration. This improves 
performance in
our tests by up to a factor of 7.


Without this change migrating tasks from a cpuset containing nodes 0-7 
to a cpuset containing
nodes 3-4, we migrate from ALL the nodes even if they are in the both 
the source and destination
nodesets:

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

Yet if we move from a cpuset containing nodes 2,3,4 to a cpuset 
containing 3,4,5 we still
do move everything so that we preserve the desired NUMA offsets:

Migrating 4 to 5
Migrating 3 to 4
Migrating 2 to 3


As far as performance is concerned this simple patch improves the time 
it takes to move
14, 20 and 26 large tasks from a cpuset containing nodes 0-7 to a cpuset 
containing nodes
1 & 3 by up to a factor of 7.  Here are the timings with and without the 
patch:

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

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f563fa3..0a5308d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1012,6 +1012,26 @@ int do_migrate_pages(struct mm_struct *mm,
                 int dest = 0;

                 for_each_node_mask(s, tmp) {
+
+                       /*
+                        * do_migrate_pages() tries to maintain the
+                        * relative node relationship of the pages
+                        * established between threads and memory areas.
+                        *
+                        * However if the number of source nodes is not
+                        * equal to the number of destination nodes we
+                        * can not preserve this node relative relationship.
+                        * In that case, skip copying memory from a node 
that
+                        * is in the destination mask.
+                        *
+                        * Example: [2,3,4] -> [3,4,5] moves everything.
+                        *                 [0-7] - > [3,4,5] moves only 
0,1,2,6,7.
+                        */
+
+                       if ((nodes_weight(*from_nodes) != 
nodes_weight(*to_nodes)) &&
+                                               (node_isset(s, *to_nodes)))
+                               continue;
+
                         d = node_remap(s, *from_nodes, *to_nodes);
                         if (s == d)
                                 continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
