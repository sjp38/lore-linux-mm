Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF7996B02FA
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l87so10063792qki.7
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:24 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id k39si2314937qte.352.2017.06.27.03.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:24 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id 91so3251262qkq.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:23 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 05/17] powerpc: store and restore the pkey state across context switches
Date: Tue, 27 Jun 2017 03:11:47 -0700
Message-Id: <1498558319-32466-6-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Store and restore the AMR, IAMR and UMOR register state of the task
before scheduling out and after scheduling in, respectively.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/processor.h |  5 +++++
 arch/powerpc/kernel/process.c        | 18 ++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/arch/powerpc/include/asm/processor.h b/arch/powerpc/include/asm/processor.h
index a2123f2..1f714df 100644
--- a/arch/powerpc/include/asm/processor.h
+++ b/arch/powerpc/include/asm/processor.h
@@ -310,6 +310,11 @@ struct thread_struct {
 	struct thread_vr_state ckvr_state; /* Checkpointed VR state */
 	unsigned long	ckvrsave; /* Checkpointed VRSAVE */
 #endif /* CONFIG_PPC_TRANSACTIONAL_MEM */
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	unsigned long	amr;
+	unsigned long	iamr;
+	unsigned long	uamor;
+#endif
 #ifdef CONFIG_KVM_BOOK3S_32_HANDLER
 	void*		kvm_shadow_vcpu; /* KVM internal data */
 #endif /* CONFIG_KVM_BOOK3S_32_HANDLER */
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index baae104..37d001a 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -1096,6 +1096,11 @@ static inline void save_sprs(struct thread_struct *t)
 		t->tar = mfspr(SPRN_TAR);
 	}
 #endif
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	t->amr = mfspr(SPRN_AMR);
+	t->iamr = mfspr(SPRN_IAMR);
+	t->uamor = mfspr(SPRN_UAMOR);
+#endif
 }
 
 static inline void restore_sprs(struct thread_struct *old_thread,
@@ -1131,6 +1136,14 @@ static inline void restore_sprs(struct thread_struct *old_thread,
 			mtspr(SPRN_TAR, new_thread->tar);
 	}
 #endif
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	if (old_thread->amr != new_thread->amr)
+		mtspr(SPRN_AMR, new_thread->amr);
+	if (old_thread->iamr != new_thread->iamr)
+		mtspr(SPRN_IAMR, new_thread->iamr);
+	if (old_thread->uamor != new_thread->uamor)
+		mtspr(SPRN_UAMOR, new_thread->uamor);
+#endif
 }
 
 struct task_struct *__switch_to(struct task_struct *prev,
@@ -1686,6 +1699,11 @@ void start_thread(struct pt_regs *regs, unsigned long start, unsigned long sp)
 	current->thread.tm_texasr = 0;
 	current->thread.tm_tfiar = 0;
 #endif /* CONFIG_PPC_TRANSACTIONAL_MEM */
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	current->thread.amr   = 0x0ul;
+	current->thread.iamr  = 0x0ul;
+	current->thread.uamor = 0x0ul;
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
 }
 EXPORT_SYMBOL(start_thread);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
