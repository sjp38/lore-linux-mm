Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DD41C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 312C32089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 312C32089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7D0A6B028E; Fri,  9 Aug 2019 12:01:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5A046B028F; Fri,  9 Aug 2019 12:01:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91B8C6B0290; Fri,  9 Aug 2019 12:01:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 378C36B028F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:23 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b1so46834706wru.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VcZQM88UoYg57TtSmP8OZuorfCjqPAXWKwnvWTqKe4E=;
        b=fjc1riWqUnSGnTDwC9HW2eMqIJLQo9gGuwMcPb4ShYQ19DNS9lqhHC6Y7eEtbSvtwe
         GW7pLK3g2GB8ltvyAKfjH5AUp/1GLNAcDenOCpxXXdTyZm1cS4h9H2OM0YD1xN4qzCrk
         GIsS1aTNlQCdHo+rkiDKhIOrk5lGLPZwi9w31oI02zadjoahLqwh0q+eapuYMMJGUax4
         oa4zAs+S3IRux3yEo0JilalSm1cx7wEKngWM+kf8c4VS07AWsIKlRPqR3xb5J3dRPW6r
         7dAmk7qcJxL439tB1Ff1g+C+tNRICv/IrQyrYikPVI0nscOnX6wNHAZCjJ0Dbwyi6t4R
         xGfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAU7YqmtTgQZq0KxvXfj0xOKTEqRjqAa7E5sn1xBtZqLxxgfFWop
	txlYI9HLJKwHu4QcpgfXAdnTNhvU1wvpOy8DRx5NNNpejWntMrclTZGQ4CoOELHAdprGWfDFHWV
	avySN0INVjPaMS4KM/nr/xf5mPAscxfoCom4+fmKMc0QOZcd/cF+/9Ot9eEbFaoTXJA==
X-Received: by 2002:a5d:4fc8:: with SMTP id h8mr25114997wrw.177.1565366482800;
        Fri, 09 Aug 2019 09:01:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN+sYkoz/QDyTvAcZmGdBL1ubZum9pKj2c50Jy4qsCe3Sx0yrkxNB+Cwi8qG3YOp78L3BW
X-Received: by 2002:a5d:4fc8:: with SMTP id h8mr25114855wrw.177.1565366481204;
        Fri, 09 Aug 2019 09:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366481; cv=none;
        d=google.com; s=arc-20160816;
        b=ov8xHmjKZBpNtvTV6+QKcAfIaT99mo5RWVXG2NgMvDvUvbbiR8hfCRj7Hz+/jN/iIE
         4uY8ew6SPHhx5L6JKgLWnEB6a2Njq+Xh3Lx4DO1oz67tTxh+1szQlDdkQZxoRun1UAAG
         vxmA4xOuCKGkbx1zOtymxEKxDTAGtSXIKAyiC/23+iF5X1r/kMRpAtdWacoOfcyV2ykm
         vGx3z9fVgw6LQiHjzP5VExtNx/TAt/cLWodHInK9jPGImfmj0dQpRW6SqhFSxmFD4PVO
         8UpLBMhBV3N774dy92Mss0DlqMzGeIKWkCs23k8CsI8AaL8W9fNe7gjJ22mMykGhg+G+
         zujg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VcZQM88UoYg57TtSmP8OZuorfCjqPAXWKwnvWTqKe4E=;
        b=m7XiJuwQ2oW03KHyeBVXfcaLdQ3JRVSBB1vfK334D2Y2DdwLSy8+q2kLT7/E4vdDmV
         DNpA+zgbWiCG7zw1wS8NgEzLGqOCIXRiCR0wjgJ8BHW3o9Wg79Z10+7XEfqoATfBXk/6
         bK142xe/IzP60+pijCFZNPU/QIHheqBlW+sIxK+a9liGSDURzE96CgcwkCn0Qu5o8FJA
         16UoNEkdZXvHNaVlDIFqZte+KlrL5GFWKuXejD6a9nZr5oNSQfwOjPseGkAer3BlnlWU
         amR09oQTdLM5GOtGPUU6gSPN/+EpSy7ySJJNp7BnT65/WO5IqrjNgG3JuQMBg65czEtm
         2tjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id g12si25409045wrr.34.2019.08.09.09.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 97291305D34B;
	Fri,  9 Aug 2019 19:01:20 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id DC9B0305B7A0;
	Fri,  9 Aug 2019 19:01:19 +0300 (EEST)
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
Subject: [RFC PATCH v6 50/92] kvm: introspection: add KVMI_GET_REGISTERS
Date: Fri,  9 Aug 2019 19:00:05 +0300
Message-Id: <20190809160047.8319-51-alazar@bitdefender.com>
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

This command is used to get kvm_regs and kvm_sregs structures,
plus the list of struct kvm_msrs.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 43 ++++++++++++++++
 arch/x86/include/uapi/asm/kvmi.h   | 15 ++++++
 arch/x86/kvm/kvmi.c                | 78 ++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h                |  5 ++
 virt/kvm/kvmi_msg.c                | 17 +++++++
 5 files changed, 158 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 558d3eb6007f..edf81e03ca3c 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -862,6 +862,49 @@ The introspection tool should use *KVMI_CONTROL_VM_EVENTS* to enable the
 * -KVM_EBUSY  - the selected vCPU has too many queued *KVMI_EVENT_PAUSE_VCPU* events
 * -KVM_EPERM  - the *KVMI_EVENT_PAUSE_VCPU* event is disallowed (see *KVMI_CONTROL_EVENTS*)
 		and the introspection tool expects a reply.
+
+17. KVMI_GET_REGISTERS
+----------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_get_registers {
+		__u16 nmsrs;
+		__u16 padding1;
+		__u32 padding2;
+		__u32 msrs_idx[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_registers_reply {
+		__u32 mode;
+		__u32 padding;
+		struct kvm_regs regs;
+		struct kvm_sregs sregs;
+		struct kvm_msrs msrs;
+	};
+
+For the given vCPU and the ``nmsrs`` sized array of MSRs registers,
+returns the current vCPU mode (in bytes: 2, 4 or 8), the general purpose
+registers, the special registers and the requested set of MSRs.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - one of the indicated MSR-s is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
 Events
 ======
 
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
index 551f9ed1ed9c..98fb27e1273c 100644
--- a/arch/x86/include/uapi/asm/kvmi.h
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -26,4 +26,19 @@ struct kvmi_event_arch {
 	} msrs;
 };
 
+struct kvmi_get_registers {
+	__u16 nmsrs;
+	__u16 padding1;
+	__u32 padding2;
+	__u32 msrs_idx[0];
+};
+
+struct kvmi_get_registers_reply {
+	__u32 mode;
+	__u32 padding;
+	struct kvm_regs regs;
+	struct kvm_sregs sregs;
+	struct kvm_msrs msrs;
+};
+
 #endif /* _UAPI_ASM_X86_KVMI_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index fa290fbf1f75..a78771b21d2f 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -7,6 +7,25 @@
 #include "x86.h"
 #include "../../../virt/kvm/kvmi_int.h"
 
+static void *alloc_get_registers_reply(const struct kvmi_msg_hdr *msg,
+				       const struct kvmi_get_registers *req,
+				       size_t *rpl_size)
+{
+	struct kvmi_get_registers_reply *rpl;
+	u16 k, n = req->nmsrs;
+
+	*rpl_size = sizeof(*rpl) + sizeof(rpl->msrs.entries[0]) * n;
+	rpl = kvmi_msg_alloc_check(*rpl_size);
+	if (rpl) {
+		rpl->msrs.nmsrs = n;
+
+		for (k = 0; k < n; k++)
+			rpl->msrs.entries[k].index = req->msrs_idx[k];
+	}
+
+	return rpl;
+}
+
 /*
  * TODO: this can be done from userspace.
  *   - all these registers are sent with struct kvmi_event_arch
@@ -38,6 +57,65 @@ static unsigned int kvmi_vcpu_mode(const struct kvm_vcpu *vcpu,
 	return mode;
 }
 
+static int kvmi_get_registers(struct kvm_vcpu *vcpu, u32 *mode,
+			      struct kvm_regs *regs,
+			      struct kvm_sregs *sregs,
+			      struct kvm_msrs *msrs)
+{
+	struct kvm_msr_entry *msr = msrs->entries;
+	struct kvm_msr_entry *end = msrs->entries + msrs->nmsrs;
+
+	kvm_arch_vcpu_get_regs(vcpu, regs);
+	kvm_arch_vcpu_get_sregs(vcpu, sregs);
+	*mode = kvmi_vcpu_mode(vcpu, sregs);
+
+	for (; msr < end; msr++) {
+		struct msr_data m = {
+			.index = msr->index,
+			.host_initiated = true
+		};
+		int err = kvm_get_msr(vcpu, &m);
+
+		if (err)
+			return -KVM_EINVAL;
+
+		msr->data = m.data;
+	}
+
+	return 0;
+}
+
+int kvmi_arch_cmd_get_registers(struct kvm_vcpu *vcpu,
+				const struct kvmi_msg_hdr *msg,
+				const struct kvmi_get_registers *req,
+				struct kvmi_get_registers_reply **dest,
+				size_t *dest_size)
+{
+	struct kvmi_get_registers_reply *rpl;
+	size_t rpl_size = 0;
+	int err;
+
+	if (req->padding1 || req->padding2)
+		return -KVM_EINVAL;
+
+	if (msg->size < sizeof(struct kvmi_vcpu_hdr)
+			+ sizeof(*req) + req->nmsrs * sizeof(req->msrs_idx[0]))
+		return -KVM_EINVAL;
+
+	rpl = alloc_get_registers_reply(msg, req, &rpl_size);
+	if (!rpl)
+		return -KVM_ENOMEM;
+
+	err = kvmi_get_registers(vcpu, &rpl->mode, &rpl->regs,
+				 &rpl->sregs, &rpl->msrs);
+
+	*dest = rpl;
+	*dest_size = rpl_size;
+
+	return err;
+
+}
+
 static void kvmi_get_msrs(struct kvm_vcpu *vcpu, struct kvmi_event_arch *event)
 {
 	struct msr_data msr;
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index cb3b0ce87bc1..b547809d13ae 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -200,6 +200,11 @@ void kvmi_handle_common_event_actions(struct kvm_vcpu *vcpu, u32 action,
 void kvmi_arch_update_page_tracking(struct kvm *kvm,
 				    struct kvm_memory_slot *slot,
 				    struct kvmi_mem_access *m);
+int kvmi_arch_cmd_get_registers(struct kvm_vcpu *vcpu,
+				const struct kvmi_msg_hdr *msg,
+				const struct kvmi_get_registers *req,
+				struct kvmi_get_registers_reply **dest,
+				size_t *dest_size);
 int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
 				  const struct kvmi_msg_hdr *msg,
 				  const struct kvmi_get_page_access *req,
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index a4446eed354d..9ae0622ff09e 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -32,6 +32,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
 	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
 	[KVMI_GET_PAGE_WRITE_BITMAP] = "KVMI_GET_PAGE_WRITE_BITMAP",
+	[KVMI_GET_REGISTERS]         = "KVMI_GET_REGISTERS",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 	[KVMI_PAUSE_VCPU]            = "KVMI_PAUSE_VCPU",
@@ -589,6 +590,21 @@ static int handle_get_vcpu_info(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, 0, &rpl, sizeof(rpl));
 }
 
+static int handle_get_registers(struct kvm_vcpu *vcpu,
+				const struct kvmi_msg_hdr *msg,
+				const void *req, vcpu_reply_fct reply_cb)
+{
+	struct kvmi_get_registers_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	int err, ec;
+
+	ec = kvmi_arch_cmd_get_registers(vcpu, msg, req, &rpl, &rpl_size);
+
+	err = reply_cb(vcpu, msg, ec, rpl, rpl_size);
+	kvmi_msg_free(rpl);
+	return err;
+}
+
 static int handle_control_events(struct kvm_vcpu *vcpu,
 				 const struct kvmi_msg_hdr *msg,
 				 const void *_req,
@@ -622,6 +638,7 @@ static int(*const msg_vcpu[])(struct kvm_vcpu *,
 			      vcpu_reply_fct) = {
 	[KVMI_CONTROL_EVENTS]   = handle_control_events,
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
+	[KVMI_GET_REGISTERS]    = handle_get_registers,
 	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
 };
 

