Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 5E0CE6B005C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:41 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 929A7125804E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:38 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wFab5898524
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wG4K026718
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:17 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 12/25] powerpc: Return all the valid pte ecndoing in KVM_PPC_GET_SMMU_INFO ioctl
Date: Thu,  4 Apr 2013 11:27:50 +0530
Message-Id: <1365055083-31956-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/kvm/book3s_hv.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 48f6d99..f472414 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1508,14 +1508,24 @@ long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
 static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
 				     int linux_psize)
 {
+	int i, index = 0;
 	struct mmu_psize_def *def = &mmu_psize_defs[linux_psize];
 
 	if (!def->shift)
 		return;
 	(*sps)->page_shift = def->shift;
 	(*sps)->slb_enc = def->sllp;
-	(*sps)->enc[0].page_shift = def->shift;
-	(*sps)->enc[0].pte_enc = def->penc[linux_psize];
+	for (i = 0; i < MMU_PAGE_COUNT; i++) {
+		if (def->penc[i] != -1) {
+			if (index >= KVM_PPC_PAGE_SIZES_MAX_SZ) {
+				WARN_ON(1);
+				break;
+			}
+			(*sps)->enc[index].page_shift = mmu_psize_defs[i].shift;
+			(*sps)->enc[index].pte_enc = def->penc[i];
+			index++;
+		}
+	}
 	(*sps)++;
 }
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
