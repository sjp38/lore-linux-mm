Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAJFUWVO032127
	for <linux-mm@kvack.org>; Thu, 20 Nov 2008 02:30:32 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJFT1Ia4137192
	for <linux-mm@kvack.org>; Thu, 20 Nov 2008 02:29:03 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJFSklV031431
	for <linux-mm@kvack.org>; Thu, 20 Nov 2008 02:28:46 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 19 Nov 2008 20:58:42 +0530
Message-Id: <20081119152842.10651.31873.sendpatchset@balbir-laptop>
Subject: [mm][PATCH] Memory cgroup fix hierarchy selector
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Andrew and Li reviewed and found that we need to check for val being 1 or 0
for the root container as well. use_hierarchy's type is changed to bool.
We still continue to use the ease of write_X64 for writing to it and then
check if the values are sane.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN mm/memcontrol.c~memcg-fix-add-hierarchy-selector mm/memcontrol.c
--- linux-2.6.28-rc4/mm/memcontrol.c~memcg-fix-add-hierarchy-selector	2008-11-19 11:07:21.000000000 +0530
+++ linux-2.6.28-rc4-balbir/mm/memcontrol.c	2008-11-19 14:11:56.000000000 +0530
@@ -151,7 +151,7 @@ struct mem_cgroup {
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
-	unsigned long use_hierarchy;
+	bool use_hierarchy;
 
 	int		obsolete;
 	atomic_t	refcnt;
@@ -1556,8 +1556,8 @@ static int mem_cgroup_hierarchy_write(st
 	 * For the root cgroup, parent_mem is NULL, we allow value to be
 	 * set if there are no children.
 	 */
-	if (!parent_mem || (!parent_mem->use_hierarchy &&
-				(val == 1 || val == 0))) {
+	if ((!parent_mem || !parent_mem->use_hierarchy) &&
+				(val == 1 || val == 0)) {
 		if (list_empty(&cont->children))
 			mem->use_hierarchy = val;
 		else
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
