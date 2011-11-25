Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9582C6B008C
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 12:40:54 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 08/10] Display current tcp failcnt in kmem cgroup
Date: Fri, 25 Nov 2011 15:38:14 -0200
Message-Id: <1322242696-27682-9-git-send-email-glommer@parallels.com>
In-Reply-To: <1322242696-27682-1-git-send-email-glommer@parallels.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

This patch introduces kmem.tcp.failcnt file, living in the
kmem_cgroup filesystem. Following the pattern in the other
memcg resources, this files keeps a counter of how many times
allocation failed due to limits being hit in this cgroup.
The root cgroup will always show a failcnt of 0.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/tcp_memcg.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_memcg.c b/net/ipv4/tcp_memcg.c
index a1ab613..da8d9c0 100644
--- a/net/ipv4/tcp_memcg.c
+++ b/net/ipv4/tcp_memcg.c
@@ -8,6 +8,7 @@
 static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft);
 static int tcp_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			    const char *buffer);
+static int tcp_cgroup_reset(struct cgroup *cont, unsigned int event);
 
 static struct cftype tcp_files[] = {
 	{
@@ -21,6 +22,12 @@ static struct cftype tcp_files[] = {
 		.read_u64 = tcp_cgroup_read,
 		.private = RES_USAGE,
 	},
+	{
+		.name = "kmem.tcp.failcnt",
+		.private = RES_FAILCNT,
+		.trigger = tcp_cgroup_reset,
+		.read_u64 = tcp_cgroup_read,
+	},
 };
 
 static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
@@ -188,12 +195,36 @@ static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
 	case RES_USAGE:
 		val = tcp_read_usage(memcg);
 		break;
+	case RES_FAILCNT:
+		val = tcp_read_stat(memcg, RES_FAILCNT, 0);
+		break;
 	default:
 		BUG();
 	}
 	return val;
 }
 
+static int tcp_cgroup_reset(struct cgroup *cont, unsigned int event)
+{
+	struct mem_cgroup *memcg;
+	struct tcp_memcontrol *tcp;
+	struct cg_proto *cg_proto;
+
+	memcg = mem_cgroup_from_cont(cont);
+	cg_proto = tcp_prot.proto_cgroup(memcg);
+	if (!cg_proto)
+		return 0;
+	tcp = tcp_from_cgproto(cg_proto);
+
+	switch (event) {
+	case RES_FAILCNT:
+		res_counter_reset_failcnt(&tcp->tcp_memory_allocated);
+		break;
+	}
+
+	return 0;
+}
+
 unsigned long long tcp_max_memory(const struct mem_cgroup *memcg)
 {
 	struct tcp_memcontrol *tcp;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
