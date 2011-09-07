Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9CD6B0170
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:25:18 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 7/9] tcp buffer limitation: per-cgroup limit
Date: Wed,  7 Sep 2011 01:23:17 -0300
Message-Id: <1315369399-3073-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

This patch uses the "tcp_max_mem" field of the kmem_cgroup to
effectively control the amount of kernel memory pinned by a cgroup.

We have to make sure that none of the memory pressure thresholds
specified in the namespace are bigger than the current cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/kmem_cgroup.h |    1 +
 net/ipv4/sysctl_net_ipv4.c  |    8 ++++++
 net/ipv4/tcp.c              |   56 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
index 89ad0a1..57a432b 100644
--- a/include/linux/kmem_cgroup.h
+++ b/include/linux/kmem_cgroup.h
@@ -26,6 +26,7 @@ struct kmem_cgroup {
 
 #ifdef CONFIG_INET
 	int tcp_memory_pressure;
+	int tcp_max_memory;
 	atomic_long_t tcp_memory_allocated;
 	struct percpu_counter tcp_sockets_allocated;
 	long tcp_prot_mem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0d74b9d..5e89480 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/nsproxy.h>
+#include <linux/kmem_cgroup.h>
 #include <linux/swap.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
@@ -181,6 +182,7 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 {
 	int ret;
 	unsigned long vec[3];
+	struct kmem_cgroup *kmem = kcg_from_task(current);
 	struct net *net = current->nsproxy->net_ns;
 	int i;
 
@@ -200,7 +202,13 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 		return ret;
 
 	for (i = 0; i < 3; i++)
+		if (vec[i] > kmem->tcp_max_memory)
+			return -EINVAL;
+
+	for (i = 0; i < 3; i++) {
 		net->ipv4.sysctl_tcp_mem[i] = vec[i];
+		kmem->tcp_prot_mem[i] = net->ipv4.sysctl_tcp_mem[i];
+	}
 
 	return 0;
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0725dc4..e1918fa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -324,6 +324,55 @@ atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
 	return &(sg->tcp_memory_allocated);
 }
 
+static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
+	struct net *net = current->nsproxy->net_ns;
+	int i;
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+
+	/*
+	 * We can't allow more memory than our parents. Since this
+	 * will be tested for all calls, by induction, there is no need
+	 * to test any parent other than our own
+	 * */
+	if (sg->parent && (val > sg->parent->tcp_max_memory))
+		val = sg->parent->tcp_max_memory;
+
+	sg->tcp_max_memory = val;
+
+	for (i = 0; i < 3; i++)
+		sg->tcp_prot_mem[i]  = min_t(long, val,
+					     net->ipv4.sysctl_tcp_mem[i]);
+
+	cgroup_unlock();
+
+	return 0;
+}
+
+static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
+	u64 ret;
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+	ret = sg->tcp_max_memory;
+
+	cgroup_unlock();
+	return ret;
+}
+
+static struct cftype tcp_files[] = {
+	{
+		.name = "tcp_maxmem",
+		.write_u64 = tcp_write_maxmem,
+		.read_u64 = tcp_read_maxmem,
+	},
+};
+
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 {
 	struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
@@ -337,11 +386,16 @@ int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
 	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 
+	if (sg->parent)
+		sg->tcp_max_memory = sg->parent->tcp_max_memory;
+	else
+		sg->tcp_max_memory = limit * 2;
+
 	sg->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
 	sg->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
 	sg->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
 
-	return 0;
+	return cgroup_add_files(cgrp, ss, tcp_files, ARRAY_SIZE(tcp_files));
 }
 EXPORT_SYMBOL(tcp_init_cgroup);
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
