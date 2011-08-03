Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C4A86B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 08:42:26 -0400 (EDT)
Date: Wed, 3 Aug 2011 09:37:27 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm/mempolicy.c: make sys_mbind & sys_set_mempolicy aware of
 task_struct->mems_allowed
Message-ID: <20110803123721.GA2892@x61.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

Among several other features enabled when CONFIG_CPUSETS is defined, task_struct is enhanced with the nodemask_t mems_allowed element that serves to register/report on which memory nodes the task may obtain memory. Also, two new lines that reflect the value registered at task_struct->mems_allowed are added to the '/proc/[pid]/status' file:
	  Mems_allowed:   ...,00000000,0000000f
	  Mems_allowed_list:      0-3

The system calls sys_mbind and sys_set_mempolicy, which serve to cope with NUMA memory policies, and receive a nodemask_t parameter, do not set task_struct->mems_allowed accordingly to their received nodemask, when CONFIG_CPUSETS is defined. This unawareness causes unexpected values being reported at '/proc/[pid]/status' Mems_allowed fields, for applications relying on those syscalls, or spawned by numactl.

Despite not affecting the memory policy operation itself, the aforementioned unawareness is source of confusion and annoyance when one is trying to figure out which resources are bound to a given task.

Reproduceability:
a. in a NUMA box, spaw a bash shell with numactl setting a nodelist to --membind, or --interleave:
[root@localhost ~]# numactl --membind=1,2 /bin/bash

b. in the spawned bash shell, verify '/proc/$$/status' Mems_allowed field:
[root@localhost ~]# grep Mems_allowed /proc/$$/status
Mems_allowed:     ...,00000000,0000000f
Mems_allowed_list:	0-3

As we can check, the expected reported list would be "1,2", instead of "0-3".

The attached patch is a proposal to make sys_mbind and sys_set_mempolicy system calls properly set task_struct->mems_allowed, in order to avoid the scenario shown above.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 mm/mempolicy.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8b57173..bc966da 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -95,6 +95,14 @@
 #include <asm/uaccess.h>
 #include <linux/random.h>
 
+#ifdef CONFIG_CPUSETS
+#include <linux/cpuset.h>
+#else
+static inline void set_mems_allowed(nodemask_t nodemask)
+{
+}
+#endif
+
 #include "internal.h"
 
 /* Internal flags */
@@ -1256,7 +1264,10 @@ SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
 	err = get_nodes(&nodes, nmask, maxnode);
 	if (err)
 		return err;
-	return do_mbind(start, len, mode, mode_flags, &nodes, flags);
+	err = do_mbind(start, len, mode, mode_flags, &nodes, flags);
+	if (!err)
+		set_mems_allowed(nodes);
+	return err;
 }
 
 /* Set the process memory policy */
@@ -1276,7 +1287,10 @@ SYSCALL_DEFINE3(set_mempolicy, int, mode, unsigned long __user *, nmask,
 	err = get_nodes(&nodes, nmask, maxnode);
 	if (err)
 		return err;
-	return do_set_mempolicy(mode, flags, &nodes);
+	err = do_set_mempolicy(mode, flags, &nodes);
+	if (!err)
+		set_mems_allowed(nodes);
+	return err;
 }
 
 SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
