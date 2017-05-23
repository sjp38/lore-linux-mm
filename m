Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C678E6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 00:05:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n75so150494614pfh.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:36 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id 188si19378980pgb.399.2017.05.22.21.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 21:05:35 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id u26so24493333pfd.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:35 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 1/6] powerpc/mm: Wire up hpte_removebolted for powernv
Date: Tue, 23 May 2017 14:05:19 +1000
Message-Id: <20170523040524.13717-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, Anton Blanchard <anton@samba.org>, Oliver O'Halloran <oohall@gmail.com>

From: Anton Blanchard <anton@samba.org>

Adds support for removing bolted (i.e kernel linear mapping) mappings on
powernv. This is needed to support memory hot unplug operations which
are required for the teardown of DAX/PMEM devices.

Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
v1 -> v2: Fixed the commit author
          Added VM_WARN_ON() if we attempt to remove an unbolted hpte
---
 arch/powerpc/mm/hash_native_64.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_native_64.c
index 65bb8f33b399..b534d041cfe8 100644
--- a/arch/powerpc/mm/hash_native_64.c
+++ b/arch/powerpc/mm/hash_native_64.c
@@ -407,6 +407,38 @@ static void native_hpte_updateboltedpp(unsigned long newpp, unsigned long ea,
 	tlbie(vpn, psize, psize, ssize, 0);
 }
 
+/*
+ * Remove a bolted kernel entry. Memory hotplug uses this.
+ *
+ * No need to lock here because we should be the only user.
+ */
+static int native_hpte_removebolted(unsigned long ea, int psize, int ssize)
+{
+	unsigned long vpn;
+	unsigned long vsid;
+	long slot;
+	struct hash_pte *hptep;
+
+	vsid = get_kernel_vsid(ea, ssize);
+	vpn = hpt_vpn(ea, vsid, ssize);
+
+	slot = native_hpte_find(vpn, psize, ssize);
+	if (slot == -1)
+		return -ENOENT;
+
+	hptep = htab_address + slot;
+
+	VM_WARN_ON(!(be64_to_cpu(hptep->v) & HPTE_V_BOLTED));
+
+	/* Invalidate the hpte */
+	hptep->v = 0;
+
+	/* Invalidate the TLB */
+	tlbie(vpn, psize, psize, ssize, 0);
+	return 0;
+}
+
+
 static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
 				   int bpsize, int apsize, int ssize, int local)
 {
@@ -725,6 +757,7 @@ void __init hpte_init_native(void)
 	mmu_hash_ops.hpte_invalidate	= native_hpte_invalidate;
 	mmu_hash_ops.hpte_updatepp	= native_hpte_updatepp;
 	mmu_hash_ops.hpte_updateboltedpp = native_hpte_updateboltedpp;
+	mmu_hash_ops.hpte_removebolted = native_hpte_removebolted;
 	mmu_hash_ops.hpte_insert	= native_hpte_insert;
 	mmu_hash_ops.hpte_remove	= native_hpte_remove;
 	mmu_hash_ops.hpte_clear_all	= native_hpte_clear;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
