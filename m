Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDA70C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4215E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4215E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E00346B0297; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8B496B0298; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2A0B6B0299; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8696B0297
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t62so2757707wmt.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/efoTNKK+nnQq7SjRJA8bZkhs0q4JuXc9WIPlxv4DKA=;
        b=I6dOmWiP1q+3jR2oNSkWqtxYMm/TRZK/blrko2pLVofcmwhzEsq0wludAqWc2Q6H1i
         XM00s6m7xPuz0P/+M8WgLv8IEc7zXckEPMZ0NVax1qT1nL6ImwOY/Bvzm1MeYbt//XB9
         gZD0hOd/ueGfyJAf8IKhrB8kKdzbhrEnLZpXy06FSaUi263faCikchI0/1bZwn1dA37a
         ZBrjsl41uMG0Ec8kr90yB00PtsHVMNVtcsbaAYrKf2QNT03TONKSLF8jhFhRu0/sOw/m
         88Fs5PEqt3mNZ1rTRev3QIgl97fkiEkVke6Z7JPYkZQezoJpk83RmrcTUtzAp4TovCuw
         FaVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAV6BtYN80cMZAI5zXW49+MRFtO2bixN1KG4iQN1sKA/+MSKkjty
	2+m5W7YShAVI0ugJXOPLsOeDD7hs462/HajyoG14TTEqKJn7m5DvJFeAScGVTDPwJWQxki7hWRL
	E5skO3Pht7cnOIYqLO7eczy1qXV7GnoNoMu+e4oYPMGuFe0ZE7QnZHtH+zGsLdMnGvw==
X-Received: by 2002:a7b:cd8e:: with SMTP id y14mr11728012wmj.155.1565366488965;
        Fri, 09 Aug 2019 09:01:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweg5OExW1YwpGd0BOvn4fTaXqggTBcNi8OnhbIjikQo04xVwG9EyiWlzicjlBnj2eqhpL8
X-Received: by 2002:a7b:cd8e:: with SMTP id y14mr11727584wmj.155.1565366483866;
        Fri, 09 Aug 2019 09:01:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366483; cv=none;
        d=google.com; s=arc-20160816;
        b=1C7KTEeUuxG6UC/kZjdfGtyIZFlXH4yhChAgV1pSQmSF5kgiD/WIO/Mgo7J2d10Tij
         XPOpQDPsF9YVg3RU2gm9pdsu/KdP6EiWZhlc+27uhJiWkboqD0X6I6L1Fo7Xhi29ibBK
         ylPXYQyOUbKVVzkHVts9KSdhPfoTCnTmrRgK5IXuwLKx+x61US+s4nON4Z8YcfNA0vAl
         hXmpN4lNDkW5bhaC84m8FDuvr0B4AaKDpxTZWgOPTzxUaTnz3mNIy+qt6J8KB1dEIoDz
         PQxRKcEGp+XZ04ve1L4crjPIM3i+wrV/F0ASMClyVuknzQXa8eYzs7pwDdKov8D8NCTv
         1Vug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=/efoTNKK+nnQq7SjRJA8bZkhs0q4JuXc9WIPlxv4DKA=;
        b=qP4asFMr9TBXbJuBqYrRX8mE/Mf2YV/gtaWftb0Hs5p8Odn38SXYxQkD7rYt1FkxRe
         1jvzfnBaVTBCX0tRCb3DqiUpLb+9EyhhFuH2g8JAypTVV3NX6Qg+ocpotsKBdhu+WxsO
         az3zHKOpZn5//Euas+c/pkmVSGMioM2fcCpdnHkbn5I0mgUL7kgAmLvA0AETlVqJcS42
         B9Q0DbDpLBkWgtgWfHWGbIKxzS5z7SVpwKHMGb0JJgUV+GaVSXj7Kb7byjRD9JI/grmx
         7h+y32v59vPwuXy8IDsDSHk896bY0dXzcyd2sHa6Kt+01wqFjUEkyC+RvvOln1OOLFAZ
         UJqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id u12si8490812wrq.86.2019.08.09.09.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 426F4305D34F;
	Fri,  9 Aug 2019 19:01:23 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id C1E6C305B7A0;
	Fri,  9 Aug 2019 19:01:22 +0300 (EEST)
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 54/92] kvm: introspection: add KVMI_CONTROL_CR and KVMI_EVENT_CR
Date: Fri,  9 Aug 2019 19:00:09 +0300
Message-Id: <20190809160047.8319-55-alazar@bitdefender.com>
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

From: Mihai Donțu <mdontu@bitdefender.com>

Using the KVMI_CONTROL_CR command, the introspection tool subscribes to
KVMI_EVENT_CR events that will be sent when CR{0,3,4} is going to
be changed.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 70 ++++++++++++++++++++++
 arch/x86/include/asm/kvm_host.h    |  2 +
 arch/x86/include/asm/kvmi_host.h   | 16 +++++
 arch/x86/include/uapi/asm/kvmi.h   | 18 ++++++
 arch/x86/kvm/kvmi.c                | 95 ++++++++++++++++++++++++++++++
 arch/x86/kvm/svm.c                 |  5 ++
 arch/x86/kvm/vmx/vmx.c             | 14 +++++
 arch/x86/kvm/x86.c                 | 19 +++++-
 virt/kvm/kvmi_int.h                |  7 +++
 virt/kvm/kvmi_msg.c                | 13 ++++
 10 files changed, 258 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 1eaed7c61148..2e6e285c8e2e 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1007,6 +1007,41 @@ order to be notified if the expection was not delivered.
 * -KVM_EINVAL - padding is not zero
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 
+21. KVMI_CONTROL_CR
+-------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_control_cr {
+		__u8 enable;
+		__u8 padding1;
+		__u16 padding2;
+		__u32 cr;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Enables/disables introspection for a specific control register and must
+be used in addition to *KVMI_CONTROL_EVENTS* with the *KVMI_EVENT_CR*
+ID set.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified control register is not part of the CR0, CR3
+   or CR4 set
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+
 Events
 ======
 
@@ -1238,3 +1273,38 @@ introspection has been enabled for this event (see *KVMI_CONTROL_EVENTS*).
 ``kvmi_event``, exception/interrupt number (vector), exception/interrupt
 type, exception code (``error_code``) and CR2 are sent to the introspector.
 
+6. KVMI_EVENT_CR
+----------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_cr {
+		__u16 cr;
+		__u16 padding[3];
+		__u64 old_value;
+		__u64 new_value;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_event_reply;
+	struct kvmi_event_cr_reply {
+		__u64 new_val;
+	};
+
+This event is sent when a control register is going to be changed and the
+introspection has been enabled for this event and for this specific
+register (see **KVMI_CONTROL_EVENTS**).
+
+``kvmi_event``, the control register number, the old value and the new value
+are sent to the introspector. The *CONTINUE* action will set the ``new_val``.
+
diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 7ee6e1ff5ee9..22f08f2732cc 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1013,6 +1013,7 @@ struct kvm_x86_ops {
 	bool (*has_emulated_msr)(int index);
 	void (*cpuid_update)(struct kvm_vcpu *vcpu);
 
+	void (*cr3_write_exiting)(struct kvm_vcpu *vcpu, bool enable);
 	bool (*nested_pagefault)(struct kvm_vcpu *vcpu);
 	bool (*spt_fault)(struct kvm_vcpu *vcpu);
 
@@ -1622,5 +1623,6 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
 
 bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu);
 bool kvm_spt_fault(struct kvm_vcpu *vcpu);
+void kvm_control_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/include/asm/kvmi_host.h b/arch/x86/include/asm/kvmi_host.h
index 7ab6dd71a0c2..83a098dc8939 100644
--- a/arch/x86/include/asm/kvmi_host.h
+++ b/arch/x86/include/asm/kvmi_host.h
@@ -9,4 +9,20 @@ struct kvmi_arch_mem_access {
 	unsigned long active[KVM_PAGE_TRACK_MAX][BITS_TO_LONGS(KVM_MEM_SLOTS_NUM)];
 };
 
+#ifdef CONFIG_KVM_INTROSPECTION
+
+bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
+		   unsigned long old_value, unsigned long *new_value);
+
+#else /* CONFIG_KVM_INTROSPECTION */
+
+static inline bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
+				 unsigned long old_value,
+				 unsigned long *new_value)
+{
+	return true;
+}
+
+#endif /* CONFIG_KVM_INTROSPECTION */
+
 #endif /* _ASM_X86_KVMI_HOST_H */
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
index b074ad735e84..c983b4bd2c72 100644
--- a/arch/x86/include/uapi/asm/kvmi.h
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -61,4 +61,22 @@ struct kvmi_get_cpuid_reply {
 	__u32 edx;
 };
 
+struct kvmi_control_cr {
+	__u8 enable;
+	__u8 padding1;
+	__u16 padding2;
+	__u32 cr;
+};
+
+struct kvmi_event_cr {
+	__u16 cr;
+	__u16 padding[3];
+	__u64 old_value;
+	__u64 new_value;
+};
+
+struct kvmi_event_cr_reply {
+	__u64 new_val;
+};
+
 #endif /* _UAPI_ASM_X86_KVMI_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 8c18030d12f4..b3cab0db6a70 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -171,6 +171,72 @@ void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev)
 	kvmi_get_msrs(vcpu, event);
 }
 
+static u32 kvmi_send_cr(struct kvm_vcpu *vcpu, u32 cr, u64 old_value,
+			u64 new_value, u64 *ret_value)
+{
+	struct kvmi_event_cr e = {
+		.cr = cr,
+		.old_value = old_value,
+		.new_value = new_value
+	};
+	struct kvmi_event_cr_reply r;
+	int err, action;
+
+	err = kvmi_send_event(vcpu, KVMI_EVENT_CR, &e, sizeof(e),
+			      &r, sizeof(r), &action);
+	if (err) {
+		*ret_value = new_value;
+		return KVMI_EVENT_ACTION_CONTINUE;
+	}
+
+	*ret_value = r.new_val;
+	return action;
+}
+
+static bool __kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
+			    unsigned long old_value, unsigned long *new_value)
+{
+	u64 ret_value;
+	u32 action;
+	bool ret = false;
+
+	if (!test_bit(cr, IVCPU(vcpu)->cr_mask))
+		return true;
+
+	action = kvmi_send_cr(vcpu, cr, old_value, *new_value, &ret_value);
+	switch (action) {
+	case KVMI_EVENT_ACTION_CONTINUE:
+		*new_value = ret_value;
+		ret = true;
+		break;
+	default:
+		kvmi_handle_common_event_actions(vcpu, action, "CR");
+	}
+
+	return ret;
+}
+
+bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
+		   unsigned long old_value, unsigned long *new_value)
+{
+	struct kvmi *ikvm;
+	bool ret = true;
+
+	if (old_value == *new_value)
+		return true;
+
+	ikvm = kvmi_get(vcpu->kvm);
+	if (!ikvm)
+		return true;
+
+	if (is_event_enabled(vcpu, KVMI_EVENT_CR))
+		ret = __kvmi_cr_event(vcpu, cr, old_value, new_value);
+
+	kvmi_put(vcpu->kvm);
+
+	return ret;
+}
+
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access)
 {
@@ -349,6 +415,35 @@ int kvmi_arch_cmd_inject_exception(struct kvm_vcpu *vcpu, u8 vector,
 	return 0;
 }
 
+int kvmi_arch_cmd_control_cr(struct kvm_vcpu *vcpu,
+			     const struct kvmi_control_cr *req)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	u32 cr = req->cr;
+
+	if (req->padding1 || req->padding2)
+		return -KVM_EINVAL;
+
+	switch (cr) {
+	case 0:
+		break;
+	case 3:
+		kvm_control_cr3_write_exiting(vcpu, req->enable);
+		break;
+	case 4:
+		break;
+	default:
+		return -KVM_EINVAL;
+	}
+
+	if (req->enable)
+		set_bit(cr, ivcpu->cr_mask);
+	else
+		clear_bit(cr, ivcpu->cr_mask);
+
+	return 0;
+}
+
 static const struct {
 	unsigned int allow_bit;
 	enum kvm_page_track_mode track_mode;
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 6b533698c73d..fc78b0052dee 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -7110,6 +7110,10 @@ static bool svm_spt_fault(struct kvm_vcpu *vcpu)
 	return (svm->vmcb->control.exit_code == SVM_EXIT_NPF);
 }
 
+static void svm_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable)
+{
+}
+
 static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = has_svm,
 	.disabled_by_bios = is_disabled,
@@ -7121,6 +7125,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_accelerated_tpr = svm_cpu_has_accelerated_tpr,
 	.has_emulated_msr = svm_has_emulated_msr,
 
+	.cr3_write_exiting = svm_cr3_write_exiting,
 	.nested_pagefault = svm_nested_pagefault,
 	.spt_fault = svm_spt_fault,
 
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 5d4b61aaff9a..6450c8c44771 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -7784,6 +7784,19 @@ static __exit void hardware_unsetup(void)
 	free_kvm_area();
 }
 
+static void vmx_cr3_write_exiting(struct kvm_vcpu *vcpu,
+					 bool enable)
+{
+	if (enable)
+		vmcs_set_bits(CPU_BASED_VM_EXEC_CONTROL,
+				CPU_BASED_CR3_LOAD_EXITING);
+	else
+		vmcs_clear_bits(CPU_BASED_VM_EXEC_CONTROL,
+				CPU_BASED_CR3_LOAD_EXITING);
+
+	/* TODO: nested ? vmcs12->cpu_based_vm_exec_control */
+}
+
 static bool vmx_nested_pagefault(struct kvm_vcpu *vcpu)
 {
 	if (vcpu->arch.exit_qualification & EPT_VIOLATION_GVA_TRANSLATED)
@@ -7831,6 +7844,7 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.cpu_has_accelerated_tpr = report_flexpriority,
 	.has_emulated_msr = vmx_has_emulated_msr,
 
+	.cr3_write_exiting = vmx_cr3_write_exiting,
 	.nested_pagefault = vmx_nested_pagefault,
 	.spt_fault = vmx_spt_fault,
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e38c0b95a0e7..2cd146ccc6ff 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -22,6 +22,7 @@
 #include <linux/kvm_host.h>
 #include <uapi/linux/kvmi.h>
 #include <linux/kvmi.h>
+#include <asm/kvmi_host.h>
 #include "irq.h"
 #include "mmu.h"
 #include "i8254.h"
@@ -777,6 +778,9 @@ int kvm_set_cr0(struct kvm_vcpu *vcpu, unsigned long cr0)
 	if (!(cr0 & X86_CR0_PG) && kvm_read_cr4_bits(vcpu, X86_CR4_PCIDE))
 		return 1;
 
+	if (!kvmi_cr_event(vcpu, 0, old_cr0, &cr0))
+		return 1;
+
 	kvm_x86_ops->set_cr0(vcpu, cr0);
 
 	if ((cr0 ^ old_cr0) & X86_CR0_PG) {
@@ -921,6 +925,9 @@ int kvm_set_cr4(struct kvm_vcpu *vcpu, unsigned long cr4)
 			return 1;
 	}
 
+	if (!kvmi_cr_event(vcpu, 4, old_cr4, &cr4))
+		return 1;
+
 	if (kvm_x86_ops->set_cr4(vcpu, cr4))
 		return 1;
 
@@ -937,6 +944,7 @@ EXPORT_SYMBOL_GPL(kvm_set_cr4);
 
 int kvm_set_cr3(struct kvm_vcpu *vcpu, unsigned long cr3)
 {
+	unsigned long old_cr3 = kvm_read_cr3(vcpu);
 	bool skip_tlb_flush = false;
 #ifdef CONFIG_X86_64
 	bool pcid_enabled = kvm_read_cr4_bits(vcpu, X86_CR4_PCIDE);
@@ -947,7 +955,7 @@ int kvm_set_cr3(struct kvm_vcpu *vcpu, unsigned long cr3)
 	}
 #endif
 
-	if (cr3 == kvm_read_cr3(vcpu) && !pdptrs_changed(vcpu)) {
+	if (cr3 == old_cr3 && !pdptrs_changed(vcpu)) {
 		if (!skip_tlb_flush) {
 			kvm_mmu_sync_roots(vcpu);
 			kvm_make_request(KVM_REQ_TLB_FLUSH, vcpu);
@@ -962,6 +970,9 @@ int kvm_set_cr3(struct kvm_vcpu *vcpu, unsigned long cr3)
 		   !load_pdptrs(vcpu, vcpu->arch.walk_mmu, cr3))
 		return 1;
 
+	if (!kvmi_cr_event(vcpu, 3, old_cr3, &cr3))
+		return 1;
+
 	kvm_mmu_new_cr3(vcpu, cr3, skip_tlb_flush);
 	vcpu->arch.cr3 = cr3;
 	__set_bit(VCPU_EXREG_CR3, (ulong *)&vcpu->arch.regs_avail);
@@ -10072,6 +10083,12 @@ bool kvm_vector_hashing_enabled(void)
 }
 EXPORT_SYMBOL_GPL(kvm_vector_hashing_enabled);
 
+void kvm_control_cr3_write_exiting(struct kvm_vcpu *vcpu, bool enable)
+{
+	kvm_x86_ops->cr3_write_exiting(vcpu, enable);
+}
+EXPORT_SYMBOL(kvm_control_cr3_write_exiting);
+
 bool kvm_spt_fault(struct kvm_vcpu *vcpu)
 {
 	return kvm_x86_ops->spt_fault(vcpu);
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 2eadeb6efde8..c92be3c2c131 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -26,6 +26,8 @@
 
 #define IVCPU(vcpu) ((struct kvmi_vcpu *)((vcpu)->kvmi))
 
+#define KVMI_NUM_CR 9
+
 #define KVMI_CTX_DATA_SIZE FIELD_SIZEOF(struct kvmi_event_pf_reply, ctx_data)
 
 #define KVMI_MSG_SIZE_ALLOC (sizeof(struct kvmi_msg_hdr) + KVMI_MSG_SIZE)
@@ -117,6 +119,7 @@ struct kvmi_vcpu {
 	struct kvm_regs delayed_regs;
 
 	DECLARE_BITMAP(ev_mask, KVMI_NUM_EVENTS);
+	DECLARE_BITMAP(cr_mask, KVMI_NUM_CR);
 
 	struct list_head job_list;
 	spinlock_t job_lock;
@@ -204,6 +207,8 @@ int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 			       bool enable);
 int kvmi_cmd_pause_vcpu(struct kvm_vcpu *vcpu, bool wait);
+struct kvmi * __must_check kvmi_get(struct kvm *kvm);
+void kvmi_put(struct kvm *kvm);
 int kvmi_run_jobs_and_wait(struct kvm_vcpu *vcpu);
 void kvmi_post_reply(struct kvm_vcpu *vcpu);
 int kvmi_add_job(struct kvm_vcpu *vcpu,
@@ -251,5 +256,7 @@ int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
 int kvmi_arch_cmd_inject_exception(struct kvm_vcpu *vcpu, u8 vector,
 				   bool error_code_valid, u32 error_code,
 				   u64 address);
+int kvmi_arch_cmd_control_cr(struct kvm_vcpu *vcpu,
+			     const struct kvmi_control_cr *req);
 
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index e80d28dbb061..d4f5459722bb 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -24,6 +24,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
+	[KVMI_CONTROL_CR]            = "KVMI_CONTROL_CR",
 	[KVMI_CONTROL_EVENTS]        = "KVMI_CONTROL_EVENTS",
 	[KVMI_CONTROL_SPP]           = "KVMI_CONTROL_SPP",
 	[KVMI_CONTROL_VM_EVENTS]     = "KVMI_CONTROL_VM_EVENTS",
@@ -662,6 +663,17 @@ static int handle_control_events(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, ec, NULL, 0);
 }
 
+static int handle_control_cr(struct kvm_vcpu *vcpu,
+			     const struct kvmi_msg_hdr *msg, const void *req,
+			     vcpu_reply_fct reply_cb)
+{
+	int ec;
+
+	ec = kvmi_arch_cmd_control_cr(vcpu, req);
+
+	return reply_cb(vcpu, msg, ec, NULL, 0);
+}
+
 static int handle_get_cpuid(struct kvm_vcpu *vcpu,
 			    const struct kvmi_msg_hdr *msg,
 			    const void *req, vcpu_reply_fct reply_cb)
@@ -685,6 +697,7 @@ static int handle_get_cpuid(struct kvm_vcpu *vcpu,
 static int(*const msg_vcpu[])(struct kvm_vcpu *,
 			      const struct kvmi_msg_hdr *, const void *,
 			      vcpu_reply_fct) = {
+	[KVMI_CONTROL_CR]       = handle_control_cr,
 	[KVMI_CONTROL_EVENTS]   = handle_control_events,
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
 	[KVMI_GET_CPUID]        = handle_get_cpuid,

