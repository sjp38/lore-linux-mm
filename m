Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id BB1AC6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:57:02 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Tue, 9 Jul 2013 14:51:26 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6B17E2190059
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 15:00:50 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r69Dul6n54853648
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 13:56:47 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r69DuvmP008714
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 07:56:58 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/4] PF: Make KVM_HVA_ERR_BAD usable on s390
Date: Tue,  9 Jul 2013 15:56:45 +0200
Message-Id: <1373378207-10451-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

Current common code uses PAGE_OFFSET to indicate a bad host virtual address.
As this check won't work on architectures that don't map kernel and user memory
into the same address space (e.g. s390), an additional implementation is made
available in the case that PAGE_OFFSET == 0.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 include/linux/kvm_host.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index a63d83e..f3c04e7 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -85,6 +85,18 @@ static inline bool is_noslot_pfn(pfn_t pfn)
 	return pfn == KVM_PFN_NOSLOT;
 }
 
+#if (PAGE_OFFSET == 0)
+
+#define KVM_HVA_ERR_BAD		(-1UL)
+#define KVM_HVA_ERR_RO_BAD	(-1UL)
+
+static inline bool kvm_is_error_hva(unsigned long addr)
+{
+	return addr == KVM_HVA_ERR_BAD;
+}
+
+#else
+
 #define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
 #define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
 
@@ -93,6 +105,8 @@ static inline bool kvm_is_error_hva(unsigned long addr)
 	return addr >= PAGE_OFFSET;
 }
 
+#endif
+
 #define KVM_ERR_PTR_BAD_PAGE	(ERR_PTR(-ENOENT))
 
 static inline bool is_error_page(struct page *page)
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
