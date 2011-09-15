Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0EF6B002A
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 21:48:23 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 7/7] Display current tcp memory allocation in kmem cgroup
Date: Wed, 14 Sep 2011 22:46:15 -0300
Message-Id: <1316051175-17780-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1316051175-17780-1-git-send-email-glommer@parallels.com>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>

This patch introduces kmem.tcp_current_memory file, living in the
kmem_cgroup filesystem. It is a simple read-only file that displays the
amount of kernel memory currently consumed by the cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/cgroups/memory.txt |    1 +
 mm/memcontrol.c                  |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ce825ee..59d9416 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -79,6 +79,7 @@ Brief summary of control files.
  memory.independent_kmem_limit	 # select whether or not kernel memory limits are
 				   independent of user limits
  memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
+ memory.kmem.tcp.current_memory  # show current tcp buf memory allocation
 
 1. History
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b48e517..dd0121f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -482,12 +482,29 @@ static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
 	return ret;
 }
 
+static u64 tcp_read_curmem(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
+	u64 ret;
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+	ret = atomic_long_read(&sg->tcp_memory_allocated);
+
+	cgroup_unlock();
+	return ret;
+}
+
 static struct cftype tcp_files[] = {
 	{
 		.name = "kmem.tcp.max_memory",
 		.write_u64 = tcp_write_maxmem,
 		.read_u64 = tcp_read_maxmem,
 	},
+	{
+		.name = "kmem.tcp.current_memory",
+		.read_u64 = tcp_read_curmem,
+	},
 };
 
 /*
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
