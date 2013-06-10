Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 77EE56B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:57 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 10 Jun 2013 13:01:41 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id EE8F62190056
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:07:11 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5AC3glj38994064
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 12:03:42 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5AC3rbD016691
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 06:03:53 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/4] PF: Move architecture specifics to the backends
Date: Mon, 10 Jun 2013 14:03:46 +0200
Message-Id: <1370865828-2053-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

Current common code use PAGE_OFFSET to indicate a bad host virtual address.
This works for x86 but not necessarily on other architectures. So the check
is moved into architecture specific code.

Todo:
 - apply to other architectures when applicable

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/kvm_host.h | 12 ++++++++++++
 arch/x86/include/asm/kvm_host.h  |  8 ++++++++
 include/linux/kvm_host.h         |  8 --------
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/arch/s390/include/asm/kvm_host.h b/arch/s390/include/asm/kvm_host.h
index deb1990..e014bba 100644
--- a/arch/s390/include/asm/kvm_host.h
+++ b/arch/s390/include/asm/kvm_host.h
@@ -277,6 +277,18 @@ struct kvm_arch{
 	int css_support;
 };
 
+#define KVM_HVA_ERR_BAD		(-1UL)
+#define KVM_HVA_ERR_RO_BAD	(-1UL)
+
+static inline bool kvm_is_error_hva(unsigned long addr)
+{
+	/*
+	 * on s390, this check is not needed as kernel and user memory
+	 * is not mapped into the same address space
+	 */
+	return false;
+}
+
 extern int sie64a(struct kvm_s390_sie_block *, u64 *);
 extern unsigned long sie_exit_addr;
 #endif
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 4979778..5ed7c83 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -94,6 +94,14 @@
 
 #define ASYNC_PF_PER_VCPU 64
 
+#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
+#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
+
+static inline bool kvm_is_error_hva(unsigned long addr)
+{
+	return addr >= PAGE_OFFSET;
+}
+
 extern raw_spinlock_t kvm_lock;
 extern struct list_head vm_list;
 
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index c139582..9bd29ef 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -84,14 +84,6 @@ static inline bool is_noslot_pfn(pfn_t pfn)
 	return pfn == KVM_PFN_NOSLOT;
 }
 
-#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
-#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
-
-static inline bool kvm_is_error_hva(unsigned long addr)
-{
-	return addr >= PAGE_OFFSET;
-}
-
 #define KVM_ERR_PTR_BAD_PAGE	(ERR_PTR(-ENOENT))
 
 static inline bool is_error_page(struct page *page)
-- 
1.8.1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
