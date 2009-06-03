Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E73BF5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:42:10 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:49:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH mmotm 1/2] memcg: add interface to reset limits
Message-Id: <20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Setting mem.limit or memsw.limit to 0 has no meaning
in actual use(no process can run in such condition).

We don't have interface to reset mem.limit or memsw.limit now,
so let's reset the mem.limit or memsw.limit to default(unlimited)
when they are being set to 0.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/memory.txt |    1 +
 include/linux/res_counter.h      |    2 ++
 kernel/res_counter.c             |    2 +-
 mm/memcontrol.c                  |    2 ++
 4 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 1a60887..e1c69f3 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -204,6 +204,7 @@ We can alter the memory limit:
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
 mega or gigabytes.
+NOTE: We can write "0" to reset the *.limit_in_bytes(unlimited).
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 4c5bcf6..511f42f 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -49,6 +49,8 @@ struct res_counter {
 	struct res_counter *parent;
 };
 
+#define RESOURCE_MAX (unsigned long long)LLONG_MAX
+
 /**
  * Helpers to interact with userspace
  * res_counter_read_u64() - returns the value of the specified member.
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index bf8e753..0a45778 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,7 @@
 void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
-	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a83e039..6629ed2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2040,6 +2040,8 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (ret)
 			break;
+		if (!val)
+			val = RESOURCE_MAX;
 		if (type == _MEM)
 			ret = mem_cgroup_resize_limit(memcg, val);
 		else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
