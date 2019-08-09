Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92C01C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D67C2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D67C2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173336B029A; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06F386B029D; Fri,  9 Aug 2019 12:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D873E6B029B; Fri,  9 Aug 2019 12:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79DF26B0299
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:30 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 21so1448773wmj.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1V63XmwuOPlBQYomwe2exe12eflZPTnOrcZ/Z2q4sZA=;
        b=ZUOnQkrthQlDMFx3Ol5gupfsSONoXBaeXk69Gc0j3MjvfFHrLlMEndv+Ss5fvTmaTm
         15Zl3qRt0jG8FaVbNWb3dC/mqlGcgvp2+e1Wict3EPfuITJHwnhNE+wRiBnGWFTFjMlN
         FG0ilsICjlG0uRF6pVvH8pnu+Rt+5UXGgITKKo8FlmxlF0yU6bM5PKKdURS/xCfPLVkD
         EabgqkdDrk9ekJqvDJJhLCtjqcEuK2L4uqprMUuCoCwVbl8kdQ8XTTM9DLo5WUiyGfqQ
         9l6VJ1f7DgQdv5Z/awh+Wk5W3JeAkzbqgpXTtSh+KNkdGuULFyOleSPInJMm0CHQspGt
         vLkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWMBsmixPIGMQI9vnbJI24ioLn4wOboSOqc9gq83SP0S4EQwoUj
	Yc+2JFnGs6LvZDOu+lha9hArSREed8XGWERO3EXSFqPG9D+KVWErBleIgHU7bI0blBc2cZEFl/c
	DhnZuAS/NIHbnuDlr3aeodqjL8JMOFHD60DUbPtGYfsrw2GdV5jE2DkUCvjsQtWktdw==
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr24255054wrx.175.1565366490022;
        Fri, 09 Aug 2019 09:01:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkkyksy1xlmdAVFJV85t6CT4QFzimPYQSAjpkw2yXNeGDq+Ja7WJaVxnoUhxiG5wXFC/Z/
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr24254835wrx.175.1565366487518;
        Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366487; cv=none;
        d=google.com; s=arc-20160816;
        b=v4io12vzHpdKkmk+CKTBnoh1+0xJkf/vMjEvRe21cRBEBmICddVdROG6IxeBoQi7RZ
         iR0b+GGltDm6hFrohzUF+yBBZPAE42yTeZdCT98lKNhl+U2MTSNGlxvlhKxrfuh3KIlq
         9i5wdgDjgDXSXrl+H6QmNYSoryHEEivIOHAUNMr86qG3mIlqsdiwT0cWm4Yz15/t9iPd
         m4DK8QBtlvzU7Cfk9tB1RLXtEcWvYlp6RMsAUs7pfB3PxfdV2iPzclJGHcjl/GNaQocc
         PRwAJZHrXyWfCL8g88ZvMh0pQ6O347YffjN7Y1RnsRMV26mHPHaL1jDoBKSXWC5aXN8j
         UrHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1V63XmwuOPlBQYomwe2exe12eflZPTnOrcZ/Z2q4sZA=;
        b=ExMsGrmhUR/S92DJEKq833nQsYuEkuJgWeYmsLwBuLFCIc3qPZs+umDTigCQS7J9nr
         wVesQ+gE1IefBX6VZOAzjwmBNiPOuK/myDPiETCHmUS+fZ27k2nd2mcEyafazI0eQ6At
         Q5LiTdO73GDApUlUDMoK5m3eapHuk9iXenVfp2sZyMJeBws8vYNm3egcIkaB2an11rz7
         PdCdIF0tPEMvvrI63Z26d852Dwb/V5H469r17wwSrcGr8kFOQkBPMP2npKvrkgk5dyg4
         vdyfYJD/Tt05nAxsiN6YUCTwOi+v/6kO6EfEokSj8DPaStTOLg/rBAa1J29QF1+666Jk
         Lsvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id x1si7026268wrl.353.2019.08.09.09.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E3DF3305D353;
	Fri,  9 Aug 2019 19:01:26 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 8B2DD305B7A0;
	Fri,  9 Aug 2019 19:01:26 +0300 (EEST)
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
Subject: [RFC PATCH v6 62/92] kvm: introspection: add KVMI_EVENT_HYPERCALL
Date: Fri,  9 Aug 2019 19:00:17 +0300
Message-Id: <20190809160047.8319-63-alazar@bitdefender.com>
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

This event is sent on a specific user hypercall.

It is used by the code residing inside the introspected guest to call the
introspection tool and to report certain details about its operation. For
example, a classic antimalware remediation tool can report what it has
found during a scan.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/hypercalls.txt | 34 +++++++++++++++++++++++-
 Documentation/virtual/kvm/kvmi.rst       | 31 +++++++++++++++++++++
 arch/x86/kvm/kvmi.c                      | 33 +++++++++++++++++++++++
 arch/x86/kvm/x86.c                       | 16 ++++++++---
 include/linux/kvmi.h                     |  2 ++
 include/uapi/linux/kvm_para.h            |  2 ++
 virt/kvm/kvmi.c                          | 22 +++++++++++++++
 virt/kvm/kvmi_int.h                      |  3 +++
 virt/kvm/kvmi_msg.c                      | 12 +++++++++
 9 files changed, 151 insertions(+), 4 deletions(-)

diff --git a/Documentation/virtual/kvm/hypercalls.txt b/Documentation/virtual/kvm/hypercalls.txt
index da24c138c8d1..1ab59537b2fb 100644
--- a/Documentation/virtual/kvm/hypercalls.txt
+++ b/Documentation/virtual/kvm/hypercalls.txt
@@ -122,7 +122,7 @@ compute the CLOCK_REALTIME for its clock, at the same instant.
 Returns KVM_EOPNOTSUPP if the host does not use TSC clocksource,
 or if clock type is different than KVM_CLOCK_PAIRING_WALLCLOCK.
 
-6. KVM_HC_SEND_IPI
+7. KVM_HC_SEND_IPI
 ------------------------
 Architecture: x86
 Status: active
@@ -141,3 +141,35 @@ a0 corresponds to the APIC ID in the third argument (a2), bit 1
 corresponds to the APIC ID a2+1, and so on.
 
 Returns the number of CPUs to which the IPIs were delivered successfully.
+
+8. KVM_HC_XEN_HVM_OP
+--------------------
+
+Architecture: x86
+Status: active
+Purpose: To enable communication between a guest agent and a VMI application
+Usage:
+
+An event will be sent to the VMI application (see kvmi.rst) if the following
+registers, which differ between 32bit and 64bit, have the following values:
+
+       32bit       64bit     value
+       ---------------------------
+       ebx (a0)    rdi       KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT
+       ecx (a1)    rsi       0
+
+This specification copies Xen's { __HYPERVISOR_hvm_op,
+HVMOP_guest_request_vm_event } hypercall and can originate from kernel or
+userspace.
+
+It returns 0 if successful, or a negative POSIX.1 error code if it fails. The
+absence of an active VMI application is not signaled in any way.
+
+The following registers are clobbered:
+
+  * 32bit: edx, esi, edi, ebp
+  * 64bit: rdx, r10, r8, r9
+
+In particular, for KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT, the last two
+registers can be poisoned deliberately and cannot be used for passing
+information.
diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index da216415bf32..2603813d1ee6 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1505,3 +1505,34 @@ trying to perform a certain operation (like creating a process).
 ``kvmi_event`` and the guest physical address are sent to the introspector.
 
 The *RETRY* action is used by the introspector for its own breakpoints.
+
+10. KVMI_EVENT_HYPERCALL
+------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+
+:Returns:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_event_reply;
+
+This event is sent on a specific user hypercall when the introspection has
+been enabled for this event (see *KVMI_CONTROL_EVENTS*).
+
+The hypercall number must be ``KVM_HC_XEN_HVM_OP`` with the
+``KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT`` sub-function
+(see hypercalls.txt).
+
+It is used by the code residing inside the introspected guest to call the
+introspection tool and to report certain details about its operation. For
+example, a classic antimalware remediation tool can report what it has
+found during a scan.
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index e998223bca1e..02e026ef5ed7 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -448,6 +448,39 @@ void kvmi_arch_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva, u8 insn_len)
 	}
 }
 
+#define KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT 24
+bool kvmi_arch_is_agent_hypercall(struct kvm_vcpu *vcpu)
+{
+	unsigned long subfunc1, subfunc2;
+	bool longmode = is_64_bit_mode(vcpu);
+
+	if (longmode) {
+		subfunc1 = kvm_register_read(vcpu, VCPU_REGS_RDI);
+		subfunc2 = kvm_register_read(vcpu, VCPU_REGS_RSI);
+	} else {
+		subfunc1 = kvm_register_read(vcpu, VCPU_REGS_RBX);
+		subfunc1 &= 0xFFFFFFFF;
+		subfunc2 = kvm_register_read(vcpu, VCPU_REGS_RCX);
+		subfunc2 &= 0xFFFFFFFF;
+	}
+
+	return (subfunc1 == KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT
+		&& subfunc2 == 0);
+}
+
+void kvmi_arch_hypercall_event(struct kvm_vcpu *vcpu)
+{
+	u32 action;
+
+	action = kvmi_msg_send_hypercall(vcpu);
+	switch (action) {
+	case KVMI_EVENT_ACTION_CONTINUE:
+		break;
+	default:
+		kvmi_handle_common_event_actions(vcpu, action, "HYPERCALL");
+	}
+}
+
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access)
 {
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index a9da8ac0d2b3..d568e60ae568 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7231,11 +7231,14 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 {
 	unsigned long nr, a0, a1, a2, a3, ret;
 	int op_64_bit;
+	bool kvmi_hc;
 
-	if (kvm_hv_hypercall_enabled(vcpu->kvm))
+	nr = kvm_register_read(vcpu, VCPU_REGS_RAX);
+	kvmi_hc = (u32)nr == KVM_HC_XEN_HVM_OP;
+
+	if (kvm_hv_hypercall_enabled(vcpu->kvm) && !kvmi_hc)
 		return kvm_hv_hypercall(vcpu);
 
-	nr = kvm_register_read(vcpu, VCPU_REGS_RAX);
 	a0 = kvm_register_read(vcpu, VCPU_REGS_RBX);
 	a1 = kvm_register_read(vcpu, VCPU_REGS_RCX);
 	a2 = kvm_register_read(vcpu, VCPU_REGS_RDX);
@@ -7252,7 +7255,7 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 		a3 &= 0xFFFFFFFF;
 	}
 
-	if (kvm_x86_ops->get_cpl(vcpu) != 0) {
+	if (kvm_x86_ops->get_cpl(vcpu) != 0 && !kvmi_hc) {
 		ret = -KVM_EPERM;
 		goto out;
 	}
@@ -7273,6 +7276,13 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_SEND_IPI:
 		ret = kvm_pv_send_ipi(vcpu->kvm, a0, a1, a2, a3, op_64_bit);
 		break;
+#ifdef CONFIG_KVM_INTROSPECTION
+	case KVM_HC_XEN_HVM_OP:
+		ret = 0;
+		if (!kvmi_hypercall_event(vcpu))
+			ret = -KVM_ENOSYS;
+		break;
+#endif /* CONFIG_KVM_INTROSPECTION */
 	default:
 		ret = -KVM_ENOSYS;
 		break;
diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
index 13b58b3202bb..59d83d2d0cca 100644
--- a/include/linux/kvmi.h
+++ b/include/linux/kvmi.h
@@ -17,6 +17,7 @@ int kvmi_ioctl_unhook(struct kvm *kvm, bool force_reset);
 int kvmi_vcpu_init(struct kvm_vcpu *vcpu);
 void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu);
 bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva, u8 insn_len);
+bool kvmi_hypercall_event(struct kvm_vcpu *vcpu);
 bool kvmi_queue_exception(struct kvm_vcpu *vcpu);
 void kvmi_trap_event(struct kvm_vcpu *vcpu);
 void kvmi_handle_requests(struct kvm_vcpu *vcpu);
@@ -36,6 +37,7 @@ static inline bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva,
 			{ return true; }
 static inline void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu) { }
 static inline void kvmi_handle_requests(struct kvm_vcpu *vcpu) { }
+static inline bool kvmi_hypercall_event(struct kvm_vcpu *vcpu) { return false; }
 static inline bool kvmi_queue_exception(struct kvm_vcpu *vcpu) { return true; }
 static inline void kvmi_trap_event(struct kvm_vcpu *vcpu) { }
 static inline void kvmi_init_emulate(struct kvm_vcpu *vcpu) { }
diff --git a/include/uapi/linux/kvm_para.h b/include/uapi/linux/kvm_para.h
index 553f168331a4..592bda92b6d5 100644
--- a/include/uapi/linux/kvm_para.h
+++ b/include/uapi/linux/kvm_para.h
@@ -33,6 +33,8 @@
 #define KVM_HC_CLOCK_PAIRING		9
 #define KVM_HC_SEND_IPI		10
 
+#define KVM_HC_XEN_HVM_OP		34 /* Xen's __HYPERVISOR_hvm_op */
+
 /*
  * hypercalls use architecture specific
  */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 4c868a94ac37..d04e13a0b244 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -1120,6 +1120,28 @@ bool kvmi_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva, u8 insn_len)
 }
 EXPORT_SYMBOL(kvmi_breakpoint_event);
 
+bool kvmi_hypercall_event(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm;
+	bool ret = false;
+
+	if (!kvmi_arch_is_agent_hypercall(vcpu))
+		return ret;
+
+	ikvm = kvmi_get(vcpu->kvm);
+	if (!ikvm)
+		return ret;
+
+	if (is_event_enabled(vcpu, KVMI_EVENT_HYPERCALL)) {
+		kvmi_arch_hypercall_event(vcpu);
+		ret = true;
+	}
+
+	kvmi_put(vcpu->kvm);
+
+	return ret;
+}
+
 /*
  * This function returns false if there is an exception or interrupt pending.
  * It returns true in all other cases including KVMI not being initialized.
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index d039446922e6..793ec269b9fa 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -185,6 +185,7 @@ int kvmi_send_event(struct kvm_vcpu *vcpu, u32 ev_id,
 		    void *ev, size_t ev_size,
 		    void *rpl, size_t rpl_size, int *action);
 u32 kvmi_msg_send_bp(struct kvm_vcpu *vcpu, u64 gpa, u8 insn_len);
+u32 kvmi_msg_send_hypercall(struct kvm_vcpu *vcpu);
 u32 kvmi_msg_send_pf(struct kvm_vcpu *vcpu, u64 gpa, u64 gva, u8 access,
 		     bool *singlestep, bool *rep_complete,
 		     u64 *ctx_addr, u8 *ctx, u32 *ctx_size);
@@ -255,6 +256,8 @@ bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 bool kvmi_arch_queue_exception(struct kvm_vcpu *vcpu);
 void kvmi_arch_trap_event(struct kvm_vcpu *vcpu);
 void kvmi_arch_breakpoint_event(struct kvm_vcpu *vcpu, u64 gva, u8 insn_len);
+bool kvmi_arch_is_agent_hypercall(struct kvm_vcpu *vcpu);
+void kvmi_arch_hypercall_event(struct kvm_vcpu *vcpu);
 int kvmi_arch_cmd_get_cpuid(struct kvm_vcpu *vcpu,
 			    const struct kvmi_get_cpuid *req,
 			    struct kvmi_get_cpuid_reply *rpl);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index c7a1fa5f7245..89f63f40f5cc 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -1096,6 +1096,18 @@ u32 kvmi_msg_send_bp(struct kvm_vcpu *vcpu, u64 gpa, u8 insn_len)
 	return action;
 }
 
+u32 kvmi_msg_send_hypercall(struct kvm_vcpu *vcpu)
+{
+	int err, action;
+
+	err = kvmi_send_event(vcpu, KVMI_EVENT_HYPERCALL, NULL, 0,
+			      NULL, 0, &action);
+	if (err)
+		return KVMI_EVENT_ACTION_CONTINUE;
+
+	return action;
+}
+
 u32 kvmi_msg_send_pf(struct kvm_vcpu *vcpu, u64 gpa, u64 gva, u8 access,
 		     bool *singlestep, bool *rep_complete, u64 *ctx_addr,
 		     u8 *ctx_data, u32 *ctx_size)

