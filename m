Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12E386B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 05:28:41 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id p129so3874183ybg.2
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 02:28:41 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h192si1199301ybb.821.2017.12.01.02.28.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 02:28:39 -0800 (PST)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [RESEND] x86/numa: move setting parsed numa node to num_add_memblk
Date: Fri, 1 Dec 2017 18:13:52 +0800
Message-ID: <1512123232-7263-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, minchan@kernel.org, vbabka@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

The acpi table are very much like user input. it is likely to
introduce some unreasonable node in some architecture. but
they do not ingore the node and bail out in time. it will result
in unnecessary print.
e.g  x86:  start is equal to end is a unreasonable node.
numa_blk_memblk will fails but return 0.

meanwhile, Arm64 node will double set it to "numa_node_parsed"
after NUMA adds a memblk successfully.  but X86 is not. because
numa_add_memblk is not set in X86.

In view of the above problems. I think it need a better improvement.
we add a check here for bypassing the invalid memblk node.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 arch/x86/mm/amdtopology.c | 1 -
 arch/x86/mm/numa.c        | 3 ++-
 drivers/acpi/numa.c       | 5 ++++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/amdtopology.c b/arch/x86/mm/amdtopology.c
index 91f501b..7657042 100644
--- a/arch/x86/mm/amdtopology.c
+++ b/arch/x86/mm/amdtopology.c
@@ -151,7 +151,6 @@ int __init amd_numa_init(void)
 
 		prevbase = base;
 		numa_add_memblk(nodeid, base, limit);
-		node_set(nodeid, numa_nodes_parsed);
 	}
 
 	if (!nodes_weight(numa_nodes_parsed))
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 25504d5..8f87f26 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -150,6 +150,8 @@ static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
 	mi->blk[mi->nr_blks].end = end;
 	mi->blk[mi->nr_blks].nid = nid;
 	mi->nr_blks++;
+
+	node_set(nid, numa_nodes_parsed);
 	return 0;
 }
 
@@ -693,7 +695,6 @@ static int __init dummy_numa_init(void)
 	printk(KERN_INFO "Faking a node at [mem %#018Lx-%#018Lx]\n",
 	       0LLU, PFN_PHYS(max_pfn) - 1);
 
-	node_set(0, numa_nodes_parsed);
 	numa_add_memblk(0, 0, PFN_PHYS(max_pfn));
 
 	return 0;
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 917f1cc..f2e33cb 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -294,7 +294,9 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 		goto out_err_bad_srat;
 	}
 
-	node_set(node, numa_nodes_parsed);
+	/* some architecture is likely to ignore a unreasonable node */
+	if (!node_isset(node, numa_nodes_parsed))
+		goto out;
 
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
 		node, pxm,
@@ -309,6 +311,7 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 
 	max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
 
+out:
 	return 0;
 out_err_bad_srat:
 	bad_srat();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
