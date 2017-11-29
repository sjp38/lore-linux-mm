Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE6696B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:21:52 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o20so1561401wro.8
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:21:52 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id l18si1011949wre.410.2017.11.29.01.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 01:21:51 -0800 (PST)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [PATCH] x86/numa: move setting parse numa node to num_add_memblk
Date: Wed, 29 Nov 2017 17:13:27 +0800
Message-ID: <1511946807-22024-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, lenb@kernel.org, mhocko@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org
Cc: richard.weiyang@gmail.com, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

Currently, Arm64 and x86 use the common code wehn parsing numa node
in a acpi way. The arm64 will set the parsed node in numa_add_memblk,
but the x86 is not set in that , then it will result in the repeatly
setting. And the parsed node maybe is  unreasonable to the system.

we would better not set it although it also still works. because the
parsed node is unresonable. so we should skip related operate in this
node. This patch just set node in various architecture individually.
it is no functional change.

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
