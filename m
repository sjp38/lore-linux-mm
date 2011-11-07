Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 430AC6B0073
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 10:29:06 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v5 09/10] Display current tcp memory allocation in kmem cgroup
Date: Mon,  7 Nov 2011 13:26:34 -0200
Message-Id: <1320679595-21074-10-git-send-email-glommer@parallels.com>
In-Reply-To: <1320679595-21074-1-git-send-email-glommer@parallels.com>
References: <1320679595-21074-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, Glauber Costa <glommer@parallels.com>

This patch introduces kmem.tcp.max_usage_in_bytes file, living in the
kmem_cgroup filesystem. The root cgroup will display a value equal
to RESOURCE_MAX. This is to avoid introducing any locking schemes in
the network paths when cgroups are not being actively used.

All others, will see the maximum memory ever used by this cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 mm/memcontrol.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9394224..b532f91 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -540,6 +540,12 @@ static struct cftype tcp_files[] = {
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
+	{
+		.name = "kmem.tcp.max_usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_KMEM_TCP, RES_MAX_USAGE),
+		.trigger = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read,
+	},
 };
 
 static void tcp_create_cgroup(struct mem_cgroup *cg, struct cgroup_subsys *ss)
@@ -4254,6 +4260,10 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	case RES_MAX_USAGE:
 		if (type == _MEM)
 			res_counter_reset_max(&mem->res);
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) && defined(CONFIG_INET)
+		else if (type == _KMEM_TCP)
+			res_counter_reset_max(&mem->tcp.tcp_memory_allocated);
+#endif
 		else
 			res_counter_reset_max(&mem->memsw);
 		break;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
