Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B86C56B6A32
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:06:55 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w24so5834964otk.22
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:06:55 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y23si7282604otj.129.2018.12.03.10.06.53
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:06:54 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 05/25] ACPI / APEI: Make estatus pool allocation a static size
Date: Mon,  3 Dec 2018 18:05:53 +0000
Message-Id: <20181203180613.228133-6-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Adding new NMI-like notifications duplicates the calls that grow
and shrink the estatus pool. This is all pretty pointless, as the
size is capped to 64K. Allocate this for each ghes and drop
the code that grows and shrinks the pool.

Suggested-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 49 +++++-----------------------------------
 drivers/acpi/apei/hest.c |  2 +-
 include/acpi/ghes.h      |  2 +-
 3 files changed, 8 insertions(+), 45 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 78058adb2574..7c2e9ac140d4 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -162,27 +162,18 @@ static void ghes_iounmap_irq(void)
 	clear_fixmap(FIX_APEI_GHES_IRQ);
 }
 
-static int ghes_estatus_pool_expand(unsigned long len); //temporary
-
-int ghes_estatus_pool_init(void)
+int ghes_estatus_pool_init(int num_ghes)
 {
+	unsigned long addr, len;
+
 	ghes_estatus_pool = gen_pool_create(GHES_ESTATUS_POOL_MIN_ALLOC_ORDER, -1);
 	if (!ghes_estatus_pool)
 		return -ENOMEM;
 
-	return ghes_estatus_pool_expand(GHES_ESTATUS_CACHE_AVG_SIZE *
-					GHES_ESTATUS_CACHE_ALLOCED_MAX);
-}
-
-static int ghes_estatus_pool_expand(unsigned long len)
-{
-	unsigned long size, addr;
-
-	ghes_estatus_pool_size_request += PAGE_ALIGN(len);
-	size = gen_pool_size(ghes_estatus_pool);
-	if (size >= ghes_estatus_pool_size_request)
-		return 0;
+	len = GHES_ESTATUS_CACHE_AVG_SIZE * GHES_ESTATUS_CACHE_ALLOCED_MAX;
+	len += (num_ghes * GHES_ESOURCE_PREALLOC_MAX_SIZE);
 
+	ghes_estatus_pool_size_request = PAGE_ALIGN(len);
 	addr = (unsigned long)vmalloc(PAGE_ALIGN(len));
 	if (!addr)
 		return -ENOMEM;
@@ -954,32 +945,8 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 	return ret;
 }
 
-static unsigned long ghes_esource_prealloc_size(
-	const struct acpi_hest_generic *generic)
-{
-	unsigned long block_length, prealloc_records, prealloc_size;
-
-	block_length = min_t(unsigned long, generic->error_block_length,
-			     GHES_ESTATUS_MAX_SIZE);
-	prealloc_records = max_t(unsigned long,
-				 generic->records_to_preallocate, 1);
-	prealloc_size = min_t(unsigned long, block_length * prealloc_records,
-			      GHES_ESOURCE_PREALLOC_MAX_SIZE);
-
-	return prealloc_size;
-}
-
-static void ghes_estatus_pool_shrink(unsigned long len)
-{
-	ghes_estatus_pool_size_request -= PAGE_ALIGN(len);
-}
-
 static void ghes_nmi_add(struct ghes *ghes)
 {
-	unsigned long len;
-
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_expand(len);
 	mutex_lock(&ghes_list_mutex);
 	if (list_empty(&ghes_nmi))
 		register_nmi_handler(NMI_LOCAL, ghes_notify_nmi, 0, "ghes");
@@ -989,8 +956,6 @@ static void ghes_nmi_add(struct ghes *ghes)
 
 static void ghes_nmi_remove(struct ghes *ghes)
 {
-	unsigned long len;
-
 	mutex_lock(&ghes_list_mutex);
 	list_del_rcu(&ghes->list);
 	if (list_empty(&ghes_nmi))
@@ -1001,8 +966,6 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	 * freed after NMI handler finishes.
 	 */
 	synchronize_rcu();
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_shrink(len);
 }
 
 static void ghes_nmi_init_cxt(void)
diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
index da5fabaeb48f..66e1e2fd7bc4 100644
--- a/drivers/acpi/apei/hest.c
+++ b/drivers/acpi/apei/hest.c
@@ -201,7 +201,7 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
 	if (!ghes_arr.ghes_devs)
 		return -ENOMEM;
 
-	rc = ghes_estatus_pool_init();
+	rc = ghes_estatus_pool_init(ghes_count);
 	if (rc)
 		goto out;
 
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 46ef5566e052..cd9ee507d860 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -52,7 +52,7 @@ enum {
 	GHES_SEV_PANIC = 0x3,
 };
 
-int ghes_estatus_pool_init(void);
+int ghes_estatus_pool_init(int num_ghes);
 
 /* From drivers/edac/ghes_edac.c */
 
-- 
2.19.2
