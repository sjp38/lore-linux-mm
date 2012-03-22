Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7A7366B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:14:25 -0400 (EDT)
Message-ID: <4F6B6BFF.1020701@redhat.com>
Date: Thu, 22 Mar 2012 14:14:23 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if task
 is already on a correct node
Content-Type: multipart/mixed;
 boundary="------------020402010409030303080605"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

This is a multi-part message in MIME format.
--------------020402010409030303080605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

While moving tasks between cpusets I noticed some strange behavior.  Specifically if the nodes of the destination
cpuset are a subset of the nodes of the source cpuset do_migrate_pages() will move pages that are already on a node
in the destination cpuset.  The reason for this is do_migrate_pages() does not check whether each node in the source
nodemask is in the destination nodemask before calling migrate_to_node().  If we simply do this check and skip them
when the source is in the destination moving we wont move nodes that dont need to be moved.
  
Adding a little debug printk to migrate_to_node():

Without this change migrating tasks from a cpuset containing nodes 0-7 to a cpuset containing nodes 3-4, we migrate
from ALL the nodes even if they are in the both the source and destination nodesets:

   Migrating 7 to 4
   Migrating 6 to 3
   Migrating 5 to 4
   Migrating 4 to 3
   Migrating 1 to 4
   Migrating 3 to 4
   Migrating 0 to 3
   Migrating 2 to 3


With this change we only migrate from nodes that are not in the destination nodesets:

   Migrating 7 to 4
   Migrating 6 to 3
   Migrating 5 to 4
   Migrating 2 to 3
   Migrating 1 to 4
   Migrating 0 to 3

Signed-off-by: Larry Woodman<lwoodman@redhat.com>


--------------020402010409030303080605
Content-Type: text/plain;
 name="upstream-do_migrate_pages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="upstream-do_migrate_pages.patch"

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 47296fe..2bd13e9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1012,6 +1012,9 @@ int do_migrate_pages(struct mm_struct *mm,
 		int dest = 0;
 
 		for_each_node_mask(s, tmp) {
+			/* no need to move if its already there */
+			if (node_isset(s, *to_nodes))
+				continue;
 			d = node_remap(s, *from_nodes, *to_nodes);
 			if (s == d)
 				continue;

--------------020402010409030303080605--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
