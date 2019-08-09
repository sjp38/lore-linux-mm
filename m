Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C4B9C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0B0D2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0B0D2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B42F66B0282; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACFAB6B0284; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 945DB6B0285; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 450B36B0282
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e8so46642676wrw.15
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m+NJgMcH+qSaFGizKvzEHID3VO0ZmLjWT3Z3kbousew=;
        b=Zx5KQuZBK6H442ceoD/XeDbbIecklnUv5C2SME42axDwB4IOuNwQe6J5wYYpDNqA4v
         h3Q8kuQxJz38zoTV01MljHMOa0FtjK+BFt8hxdLpYNCvmGquFqdlCp407vvUYPOPln2a
         hrkKNxgGLZa2MyZyArBscIG7wkEt9kZHEcTVwQ/m5+5x2gESmC1G+x0yyivKQ80qVPGn
         /b2fIchrUExzBB9n734+asOY2Tr3Ta7+tzPWsuA5beJA4Lc6/2smArwd1Cf5N1BHlC6e
         KW9sdPwosRnPG8mg+u//qiZo8cg2eXUO8gLA+UGrNmt6u5KHJ5HjLAt7ozvFKxdeXonz
         wlww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXcf2GvJizRUQCjVxOAveh3K7HL8sZh90fF4MYvup4ylCoxvb1I
	jU9bVFu5f2VGS6aqRwpbT2TqM/WUB3lp0u1xiSqI3W7cbfG3NBPlvFEaYG43gpDBmkPik66OSfy
	ZAUeVrHJAPBSain226Cp9crxsQqSxanki5onIkB8SXKf2NIudEn5INjBBLq7kTyVZ+Q==
X-Received: by 2002:a1c:c542:: with SMTP id v63mr11433740wmf.97.1565366472842;
        Fri, 09 Aug 2019 09:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFu8CwXlDh6g9TfLMebv5X6O4vBLkv5U4ZY7bQU/F7mswS1AnL/Anq9UNYmbBhEdwy3CH5
X-Received: by 2002:a1c:c542:: with SMTP id v63mr11433595wmf.97.1565366471150;
        Fri, 09 Aug 2019 09:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366471; cv=none;
        d=google.com; s=arc-20160816;
        b=Lf65ZN4HHrmlPnCy42rEg8XROdv3U9iYwTOwTO3za21qthnBuyx7GiaowIeQ0TegjB
         QnZFTJF7xp/EkpvBUI+7/TT8wg/q3AC/96C1q9s9LuM+GuYOaUoSOsFliI1HkEnBm4no
         Pzn/yGg0/WKVgFZ3wQxp1Ghxj8n2Akx/B0/EUpOsVv1XtiWlw2CdVnsTprQNARCkVKp9
         eT8B54KLzJIBQwz//g1OVLWY7FSM6ktvjLF+Ggg3DVrOjEp+sn/UvXU+KPMBbo7PhvFn
         tWSxaj5BHeMa3e0segABOd7D540/dwHg1vaQpr5i1MzRhsR+kdL+sMTsBNqDhUQS/Eqp
         OYaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=m+NJgMcH+qSaFGizKvzEHID3VO0ZmLjWT3Z3kbousew=;
        b=xW9g/0KxZwuAZpK8XCqS9priInQ3EJPVaqaKMyXEgW0Ki3mFlshV5HmivTo/hDgEIE
         I9a6RFXYmNJOgGUFt2VgSfFlsqY6guMuBH9LonUhvzSJDcbCtt7w53EVkQcF/p7vupVI
         8d913NIwV8VGW+CX7jpCQKHsVpWDPoh/eHMCZlOUfhgnSYjcLG431gFCZGNwSFKOQLGQ
         aVxUZRdPDa8kwMi2J5nssLr2HXnpz0+xQnxdUjOR9ajznrGLLlYIEwrba53ue6gU7XUw
         rPOAc61SAiO+UtugshTREAw2oa08etdjKGPQqOQGfrX27FOtQM5hjniCjEdwvqzdU45Z
         KAMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id x5si4160666wmk.191.2019.08.09.09.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 82BAC302478F;
	Fri,  9 Aug 2019 19:01:10 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3469D305B7A1;
	Fri,  9 Aug 2019 19:01:10 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	He Chen <he.chen@linux.intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [RFC PATCH v6 40/92] KVM: VMX: Handle SPP induced vmexit and page fault
Date: Fri,  9 Aug 2019 18:59:55 +0300
Message-Id: <20190809160047.8319-41-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Weijiang <weijiang.yang@intel.com>

If write to subpage is not allowed, EPT violation is generated,
it's propagated to QEMU or VMI to handle.

If the target page is SPP protected, however SPPT missing is
encoutered while traversing with gfn, vmexit is generated so
that KVM can handle the issue. Any SPPT misconfig will be
propagated to QEMU or VMI.

A SPP specific bit(11) is added to exit_qualification and a new
exit reason(66) is introduced for SPP.

Co-developed-by: He Chen <he.chen@linux.intel.com>
Signed-off-by: He Chen <he.chen@linux.intel.com>
Co-developed-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-8-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/vmx.h      |  7 ++++
 arch/x86/include/uapi/asm/vmx.h |  2 +
 arch/x86/kvm/mmu.c              | 17 ++++++++
 arch/x86/kvm/vmx/vmx.c          | 71 +++++++++++++++++++++++++++++++++
 include/uapi/linux/kvm.h        |  5 +++
 5 files changed, 102 insertions(+)

diff --git a/arch/x86/include/asm/vmx.h b/arch/x86/include/asm/vmx.h
index 6cb05ac07453..11ca64ced578 100644
--- a/arch/x86/include/asm/vmx.h
+++ b/arch/x86/include/asm/vmx.h
@@ -547,6 +547,13 @@ struct vmx_msr_entry {
 #define EPT_VIOLATION_EXECUTABLE	(1 << EPT_VIOLATION_EXECUTABLE_BIT)
 #define EPT_VIOLATION_GVA_TRANSLATED	(1 << EPT_VIOLATION_GVA_TRANSLATED_BIT)
 
+/*
+ * Exit Qualifications for SPPT-Induced vmexits
+ */
+#define SPPT_INDUCED_EXIT_TYPE_BIT     11
+#define SPPT_INDUCED_EXIT_TYPE         (1 << SPPT_INDUCED_EXIT_TYPE_BIT)
+#define SPPT_INTR_INFO_UNBLOCK_NMI     INTR_INFO_UNBLOCK_NMI
+
 /*
  * VM-instruction error numbers
  */
diff --git a/arch/x86/include/uapi/asm/vmx.h b/arch/x86/include/uapi/asm/vmx.h
index f0b0c90dd398..ac67622bac5a 100644
--- a/arch/x86/include/uapi/asm/vmx.h
+++ b/arch/x86/include/uapi/asm/vmx.h
@@ -85,6 +85,7 @@
 #define EXIT_REASON_PML_FULL            62
 #define EXIT_REASON_XSAVES              63
 #define EXIT_REASON_XRSTORS             64
+#define EXIT_REASON_SPP                 66
 
 #define VMX_EXIT_REASONS \
 	{ EXIT_REASON_EXCEPTION_NMI,         "EXCEPTION_NMI" }, \
@@ -141,6 +142,7 @@
 	{ EXIT_REASON_ENCLS,                 "ENCLS" }, \
 	{ EXIT_REASON_RDSEED,                "RDSEED" }, \
 	{ EXIT_REASON_PML_FULL,              "PML_FULL" }, \
+	{ EXIT_REASON_SPP,                   "SPP" }, \
 	{ EXIT_REASON_XSAVES,                "XSAVES" }, \
 	{ EXIT_REASON_XRSTORS,               "XRSTORS" }
 
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 38e79210d010..d59108a3ebbf 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3692,6 +3692,19 @@ static bool fast_page_fault(struct kvm_vcpu *vcpu, gva_t gva, int level,
 		if ((error_code & PFERR_WRITE_MASK) &&
 		    spte_can_locklessly_be_made_writable(spte))
 		{
+			/*
+			 * Record write protect fault caused by
+			 * Sub-page Protection, let VMI decide
+			 * the next step.
+			 */
+			if (spte & PT_SPP_MASK) {
+				fault_handled = true;
+				vcpu->run->exit_reason = KVM_EXIT_SPP;
+				vcpu->run->spp.addr = gva;
+				kvm_skip_emulated_instruction(vcpu);
+				break;
+			}
+
 			new_spte |= PT_WRITABLE_MASK;
 
 			/*
@@ -5880,6 +5893,10 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u64 error_code,
 		r = vcpu->arch.mmu->page_fault(vcpu, cr2,
 					       lower_32_bits(error_code),
 					       false);
+
+		if (vcpu->run->exit_reason == KVM_EXIT_SPP)
+			return 0;
+
 		WARN_ON(r == RET_PF_INVALID);
 	}
 
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index a50dd2b9d438..5d4b61aaff9a 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -5335,6 +5335,76 @@ static int handle_monitor(struct kvm_vcpu *vcpu)
 	return handle_nop(vcpu);
 }
 
+static int handle_spp(struct kvm_vcpu *vcpu)
+{
+	unsigned long exit_qualification;
+	struct kvm_memory_slot *slot;
+	gpa_t gpa;
+	gfn_t gfn;
+
+	exit_qualification = vmcs_readl(EXIT_QUALIFICATION);
+
+	/*
+	 * SPP VM exit happened while executing iret from NMI,
+	 * "blocked by NMI" bit has to be set before next VM entry.
+	 * There are errata that may cause this bit to not be set:
+	 * AAK134, BY25.
+	 */
+	if (!(to_vmx(vcpu)->idt_vectoring_info & VECTORING_INFO_VALID_MASK) &&
+	    (exit_qualification & SPPT_INTR_INFO_UNBLOCK_NMI))
+		vmcs_set_bits(GUEST_INTERRUPTIBILITY_INFO,
+			      GUEST_INTR_STATE_NMI);
+
+	vcpu->arch.exit_qualification = exit_qualification;
+	if (exit_qualification & SPPT_INDUCED_EXIT_TYPE) {
+		struct kvm_subpage spp_info = {0};
+		int ret;
+
+		/*
+		 * SPPT missing
+		 * We don't set SPP write access for the corresponding
+		 * GPA, if we haven't setup, we need to construct
+		 * SPP table here.
+		 */
+		pr_info("SPP - SPPT entry missing!\n");
+		gpa = vmcs_read64(GUEST_PHYSICAL_ADDRESS);
+		gfn = gpa >> PAGE_SHIFT;
+		slot = gfn_to_memslot(vcpu->kvm, gfn);
+		if (!slot)
+		      return -EFAULT;
+
+		/*
+		 * if the target gfn is not protected, but SPPT is
+		 * traversed now, regard this as some kind of fault.
+		 */
+		spp_info.base_gfn = gfn;
+		spp_info.npages = 1;
+
+		spin_lock(&(vcpu->kvm->mmu_lock));
+		ret = kvm_mmu_get_subpages(vcpu->kvm, &spp_info, true);
+		if (ret == 1) {
+			kvm_mmu_setup_spp_structure(vcpu,
+				spp_info.access_map[0], gfn);
+		}
+		spin_unlock(&(vcpu->kvm->mmu_lock));
+
+		return 1;
+
+	}
+
+	/*
+	 * SPPT Misconfig
+	 * This is probably caused by some mis-configuration in SPPT
+	 * entries, cannot handle it here, escalate the fault to
+	 * emulator.
+	 */
+	WARN_ON(1);
+	vcpu->run->exit_reason = KVM_EXIT_UNKNOWN;
+	vcpu->run->hw.hardware_exit_reason = EXIT_REASON_SPP;
+	pr_alert("SPP - SPPT Misconfiguration!\n");
+	return 0;
+}
+
 static int handle_invpcid(struct kvm_vcpu *vcpu)
 {
 	u32 vmx_instruction_info;
@@ -5538,6 +5608,7 @@ static int (*kvm_vmx_exit_handlers[])(struct kvm_vcpu *vcpu) = {
 	[EXIT_REASON_INVVPID]                 = handle_vmx_instruction,
 	[EXIT_REASON_RDRAND]                  = handle_invalid_op,
 	[EXIT_REASON_RDSEED]                  = handle_invalid_op,
+	[EXIT_REASON_SPP]                     = handle_spp,
 	[EXIT_REASON_XSAVES]                  = handle_xsaves,
 	[EXIT_REASON_XRSTORS]                 = handle_xrstors,
 	[EXIT_REASON_PML_FULL]		      = handle_pml_full,
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index 86dd57e67539..81f08eec9061 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -244,6 +244,7 @@ struct kvm_hyperv_exit {
 #define KVM_EXIT_S390_STSI        25
 #define KVM_EXIT_IOAPIC_EOI       26
 #define KVM_EXIT_HYPERV           27
+#define KVM_EXIT_SPP              28
 
 /* For KVM_EXIT_INTERNAL_ERROR */
 /* Emulate instruction failed. */
@@ -399,6 +400,10 @@ struct kvm_run {
 		struct {
 			__u8 vector;
 		} eoi;
+		/* KVM_EXIT_SPP */
+		struct {
+			__u64 addr;
+		} spp;
 		/* KVM_EXIT_HYPERV */
 		struct kvm_hyperv_exit hyperv;
 		/* Fix the size of the union. */

