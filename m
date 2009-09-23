Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 685C46B005D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 19:53:17 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 13/80] pids 3/7: Add target_pid parameter to alloc_pidmap()
Date: Wed, 23 Sep 2009 19:50:53 -0400
Message-Id: <1253749920-18673-14-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

With support for setting a specific pid number for a process,
alloc_pidmap() will need a paramter a 'target_pid' parameter.

Changelog[v2]:
	- (Serge Hallyn) Check for 'pid < 0' in set_pidmap().(Code
	  actually checks for 'pid <= 0' for completeness).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 kernel/pid.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index 9c678ce..29cf119 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -147,11 +147,35 @@ static int alloc_pidmap_page(struct pidmap *map)
 	return 0;
 }
 
-static int alloc_pidmap(struct pid_namespace *pid_ns)
+static int set_pidmap(struct pid_namespace *pid_ns, int pid)
+{
+	int offset;
+	struct pidmap *map;
+
+	if (pid <= 0 || pid >= pid_max)
+		return -EINVAL;
+
+	offset = pid & BITS_PER_PAGE_MASK;
+	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+
+	if (alloc_pidmap_page(map))
+		return -ENOMEM;
+
+	if (test_and_set_bit(offset, map->page))
+		return -EBUSY;
+
+	atomic_dec(&map->nr_free);
+	return pid;
+}
+
+static int alloc_pidmap(struct pid_namespace *pid_ns, int target_pid)
 {
 	int i, rc, offset, max_scan, pid, last = pid_ns->last_pid;
 	struct pidmap *map;
 
+	if (target_pid)
+		return set_pidmap(pid_ns, target_pid);
+
 	pid = last + 1;
 	if (pid >= pid_max)
 		pid = RESERVED_PIDS;
@@ -270,7 +294,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+		nr = alloc_pidmap(tmp, 0);
 		if (nr < 0)
 			goto out_free;
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
