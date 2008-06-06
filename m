Message-ID: <4848955D.2020302@cn.fujitsu.com>
Date: Fri, 06 Jun 2008 09:39:41 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: clean up checking of  the disabled flag
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Those checks are unnecessary, because when the subsystem is disabled
it can't be mounted, so those functions won't get called.

The check is needed in functions which will be called in other places
except cgroup.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 memcontrol.c |    8 --------
 1 file changed, 8 deletions(-)

--- a/mm/memcontrol.c	2008-06-06 09:15:56.000000000 +0800
+++ b/mm/memcontrol.c	2008-06-06 09:09:04.000000000 +0800
@@ -845,9 +845,6 @@ static int mem_cgroup_force_empty(struct
 	int ret = -EBUSY;
 	int node, zid;
 
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-
 	css_get(&mem->css);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
@@ -1105,8 +1102,6 @@ static void mem_cgroup_destroy(struct cg
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	if (mem_cgroup_subsys.disabled)
-		return 0;
 	return cgroup_add_files(cont, ss, mem_cgroup_files,
 					ARRAY_SIZE(mem_cgroup_files));
 }
@@ -1119,9 +1114,6 @@ static void mem_cgroup_move_task(struct 
 	struct mm_struct *mm;
 	struct mem_cgroup *mem, *old_mem;
 
-	if (mem_cgroup_subsys.disabled)
-		return;
-
 	mm = get_task_mm(p);
 	if (mm == NULL)
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
