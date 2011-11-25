Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A5F6F6B0098
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 12:40:59 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 09/10] Display maximum tcp memory allocation in kmem cgroup
Date: Fri, 25 Nov 2011 15:38:15 -0200
Message-Id: <1322242696-27682-10-git-send-email-glommer@parallels.com>
In-Reply-To: <1322242696-27682-1-git-send-email-glommer@parallels.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

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
 net/ipv4/tcp_memcg.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_memcg.c b/net/ipv4/tcp_memcg.c
index da8d9c0..e702f6a 100644
--- a/net/ipv4/tcp_memcg.c
+++ b/net/ipv4/tcp_memcg.c
@@ -28,6 +28,12 @@ static struct cftype tcp_files[] = {
 		.trigger = tcp_cgroup_reset,
 		.read_u64 = tcp_cgroup_read,
 	},
+	{
+		.name = "kmem.tcp.max_usage_in_bytes",
+		.private = RES_MAX_USAGE,
+		.trigger = tcp_cgroup_reset,
+		.read_u64 = tcp_cgroup_read,
+	},
 };
 
 static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
@@ -196,7 +202,8 @@ static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
 		val = tcp_read_usage(memcg);
 		break;
 	case RES_FAILCNT:
-		val = tcp_read_stat(memcg, RES_FAILCNT, 0);
+	case RES_MAX_USAGE:
+		val = tcp_read_stat(memcg, cft->private, 0);
 		break;
 	default:
 		BUG();
@@ -217,6 +224,9 @@ static int tcp_cgroup_reset(struct cgroup *cont, unsigned int event)
 	tcp = tcp_from_cgproto(cg_proto);
 
 	switch (event) {
+	case RES_MAX_USAGE:
+		res_counter_reset_max(&tcp->tcp_memory_allocated);
+		break;
 	case RES_FAILCNT:
 		res_counter_reset_failcnt(&tcp->tcp_memory_allocated);
 		break;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
