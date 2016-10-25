Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94C006B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 23:02:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so117306504oig.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v123si7337483oia.241.2016.10.24.20.02.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 2/2] arm64/numa: support HAVE_MEMORYLESS_NODES
Date: Tue, 25 Oct 2016 10:59:18 +0800
Message-ID: <1477364358-10620-3-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

Some numa nodes may have no memory. For example:
1) a node has no memory bank plugged.
2) a node has no memory bank slots.

To ensure percpu variable areas and numa control blocks of the
memoryless numa nodes to be allocated from the nearest available node to
improve performance, defined node_distance_ready. And make its value to be
true immediately after node distances have been initialized.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 arch/arm64/Kconfig            | 4 ++++
 arch/arm64/include/asm/numa.h | 3 +++
 arch/arm64/mm/numa.c          | 6 +++++-
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 30398db..648dd13 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -609,6 +609,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
 	def_bool y
 	depends on NUMA

+config HAVE_MEMORYLESS_NODES
+	def_bool y
+	depends on NUMA
+
 source kernel/Kconfig.preempt
 source kernel/Kconfig.hz

diff --git a/arch/arm64/include/asm/numa.h b/arch/arm64/include/asm/numa.h
index 600887e..9d068bf 100644
--- a/arch/arm64/include/asm/numa.h
+++ b/arch/arm64/include/asm/numa.h
@@ -13,6 +13,9 @@
 int __node_distance(int from, int to);
 #define node_distance(a, b) __node_distance(a, b)

+extern int __initdata arch_node_distance_ready;
+#define node_distance_ready()	arch_node_distance_ready
+
 extern nodemask_t numa_nodes_parsed __initdata;

 /* Mappings between node number and cpus on that node. */
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 9a71d06..5db9765 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -36,6 +36,7 @@ static int cpu_to_node_map[NR_CPUS] = { [0 ... NR_CPUS-1] = NUMA_NO_NODE };
 static int numa_distance_cnt;
 static u8 *numa_distance;
 static bool numa_off;
+int __initdata arch_node_distance_ready;

 static __init int numa_parse_early_param(char *opt)
 {
@@ -395,9 +396,12 @@ static int __init numa_init(int (*init_func)(void))
 		return -EINVAL;
 	}

+	arch_node_distance_ready = 1;
 	ret = numa_register_nodes();
-	if (ret < 0)
+	if (ret < 0) {
+		arch_node_distance_ready = 0;
 		return ret;
+	}

 	setup_node_to_cpumask_map();

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
