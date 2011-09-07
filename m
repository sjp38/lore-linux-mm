Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3C36B0171
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:25:26 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 8/9] Display current tcp memory allocation in kmem cgroup
Date: Wed,  7 Sep 2011 01:23:18 -0300
Message-Id: <1315369399-3073-9-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

This patch introduces kmem.tcp_current_memory file, living in the
kmem_cgroup filesystem. It is a simple read-only file that displays the
amount of kernel memory currently consumed by the cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/tcp.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e1918fa..ff5c0e0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -365,12 +365,29 @@ static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
 	return ret;
 }
 
+static u64 tcp_read_curmem(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
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
 		.name = "tcp_maxmem",
 		.write_u64 = tcp_write_maxmem,
 		.read_u64 = tcp_read_maxmem,
 	},
+	{
+		.name = "tcp_current_memory",
+		.read_u64 = tcp_read_curmem,
+	},
 };
 
 int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
