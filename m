Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 55BAE6B0093
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:34:34 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4832223pad.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:34:34 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 4/4] bootmem: fix wrong call parameter for free_bootmem()
Date: Tue, 13 Nov 2012 01:31:55 +0900
Message-Id: <1352737915-30906-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1352737915-30906-1-git-send-email-js1304@gmail.com>
References: <1352737915-30906-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

It is somehow strange that alloc_bootmem return virtual address
and free_bootmem require physical address.
Anyway, free_bootmem()'s first parameter should be physical address.

There are some call sites for free_bootmem() with virtual address.
So fix them.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/powerpc/platforms/cell/celleb_pci.c b/arch/powerpc/platforms/cell/celleb_pci.c
index abc8af4..1735681 100644
--- a/arch/powerpc/platforms/cell/celleb_pci.c
+++ b/arch/powerpc/platforms/cell/celleb_pci.c
@@ -401,11 +401,11 @@ error:
 	} else {
 		if (config && *config) {
 			size = 256;
-			free_bootmem((unsigned long)(*config), size);
+			free_bootmem(__pa(*config), size);
 		}
 		if (res && *res) {
 			size = sizeof(struct celleb_pci_resource);
-			free_bootmem((unsigned long)(*res), size);
+			free_bootmem(__pa(*res), size);
 		}
 	}
 
diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index 7d5a6b4..1963680 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -565,7 +565,7 @@ fail_msg_node:
 fail_db_node:
 	of_node_put(smu->db_node);
 fail_bootmem:
-	free_bootmem((unsigned long)smu, sizeof(struct smu_device));
+	free_bootmem(__pa(smu), sizeof(struct smu_device));
 	smu = NULL;
 fail_np:
 	of_node_put(np);
diff --git a/lib/cpumask.c b/lib/cpumask.c
index 402a54a..d327b87 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -161,6 +161,6 @@ EXPORT_SYMBOL(free_cpumask_var);
  */
 void __init free_bootmem_cpumask_var(cpumask_var_t mask)
 {
-	free_bootmem((unsigned long)mask, cpumask_size());
+	free_bootmem(__pa(mask), cpumask_size());
 }
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
