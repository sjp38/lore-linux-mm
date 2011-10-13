Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CAC116B002F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 09:11:13 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v7 7/8] Display current tcp memory allocation in kmem cgroup
Date: Thu, 13 Oct 2011 17:09:41 +0400
Message-Id: <1318511382-31051-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1318511382-31051-1-git-send-email-glommer@parallels.com>
References: <1318511382-31051-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, Glauber Costa <glommer@parallels.com>

This patch introduces kmem.tcp_current_memory file, living in the
kmem_cgroup filesystem. It is a simple read-only file that displays the
amount of kernel memory currently consumed by the cgroup.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
CC: David S. Miller <davem@davemloft.net>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/cgroups/memory.txt |    1 +
 mm/memcontrol.c                  |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index e773bd7..b937a99 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -79,6 +79,7 @@ Brief summary of control files.
  memory.independent_kmem_limit	 # select whether or not kernel memory limits are
 				   independent of user limits
  memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
+ memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
 
 1. History
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b696267..1ba318d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -543,6 +543,11 @@ static struct cftype tcp_files[] = {
 		.read_u64 = mem_cgroup_read,
 		.private = MEMFILE_PRIVATE(_KMEM_TCP, RES_LIMIT),
 	},
+	{
+		.name = "kmem.tcp.usage_in_bytes",
+		.read_u64 = mem_cgroup_read,
+		.private = MEMFILE_PRIVATE(_KMEM_TCP, RES_USAGE),
+	},
 };
 
 static void tcp_create_cgroup(struct mem_cgroup *cg, struct cgroup_subsys *ss)
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
