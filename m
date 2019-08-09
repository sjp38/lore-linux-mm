Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66B6CC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10F4C2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10F4C2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 574F16B028F; Fri,  9 Aug 2019 12:01:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 525556B0290; Fri,  9 Aug 2019 12:01:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43C646B0291; Fri,  9 Aug 2019 12:01:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id E67B96B028F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:23 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u19so1066829wmj.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7BNbmmYb0LYug5NNEj0pkakD1AOCFOxbWBtCrPsCeHk=;
        b=Qt17J6x42uid8h6GvY+PUlq/kdyJRyzbn6aDoOTGYx7FIfM7lRpbzATXvTwCiJIVjI
         uE2dDiXkL703vlqWZYHlPyDO2SP1ZpdpeyvISiht64GESB8Sw22h5IPv9z+M0zd84Y9B
         uiR/0YzK7pNVNmaLBQkohj9nMvJVZTyr9CXjHHbGMYtM47M9H91z+1vW/RFrxzxpkDj3
         sGLpqTesRQMpWDsqyXUFpXGe/Tw9Kln9oxZFDcpMAXzzFCQTYCqIXHuOwPa6EX7xsjHV
         ztvuy72MAbaSdE9qoQrAbzKUItuvUG6Du/04VSabljEEcfAPjkKNhvf7H/8prk8oJ85y
         aW0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUavgehla4AUKOyWbWN5XTq/parDy2eJXrLoMCuHPNKQnpQ59si
	ipUNiHEAW4dV/MxefLk92LHdvB2jV9imRilWmk5wqknGo6G18kOZ8DY7H9xGEEvQ1m/PJI2DliX
	+jypR+54JuB0nGKkCf2T70hWGUkjYN2Gj0VXdJspGjf9BsjqKXclf2ufLA+/0Fw/t0g==
X-Received: by 2002:adf:eec5:: with SMTP id a5mr1709290wrp.352.1565366483503;
        Fri, 09 Aug 2019 09:01:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDp1xSMVM5fMsaQdbEt3KP4LIpta1dEuXk3/U/ZQGOBSvvKVc/j+MsyzuPYDNG9v2hdhCB
X-Received: by 2002:adf:eec5:: with SMTP id a5mr1709147wrp.352.1565366481985;
        Fri, 09 Aug 2019 09:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366481; cv=none;
        d=google.com; s=arc-20160816;
        b=PLrH82K24AgpJDaNTOQwcH3eZQTU7UuNF/ec1LUiz6KAElC8d3mghPHkctMuaMS3uY
         E1WSQnAGeQZNF/P7o3Fg2OkgDBG+VD/rqOF5k83dJzjvc5CdwKvIUDCc1vBh4vxHuVwa
         DS4zTC94MS4Ak8No/TTUnkjqcNkXMMT5e1kagidMpbEFo4d2+zUInUBm/VVQH8o1uX4b
         I3Ng/DWZOelM5yI0Lozbrt2sd7mnKhnELST3pNwsyKWZe+MB2dZSs+ACNhC43Twf4eM3
         UyMx9+uqZWM4pEJ8hx3otVDoFz36xFGTRc4dsXrX6vOqf888Z00rk59OTf9UxNTE/zIi
         s/3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7BNbmmYb0LYug5NNEj0pkakD1AOCFOxbWBtCrPsCeHk=;
        b=F/mn1Bo2ygolCygD+5A2OSv5KzZnzu5sE+Uqp0kKvraxRwji2CIn/a1RWkoblzCRVZ
         9ZR0X9ZmPUyeEUfRZrWeVLAyEtXqQo/UNVYWddupsPj/GYlTN+MSB1OkCEf1ejLpPVZd
         /TKqKoofpG/T9FJtniPug2ULQ/YcKPEDWqJvbfOqQWv/mJhHuB6PjMAXiT8DJzyryYWy
         de5aBEHSEMqVtYWiNf6SEU32GN8dRSnczrQGARvak6OGuVpIlEkYDPOmUiFJUIsPLk5e
         UJjZE1/ZRvVHDiux7cKPWPmHjVcXro8Q6xXZzIHdy93oC/9CTZbqJlUNCju3R/xUFOyN
         Y08g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i11si3852396wrr.434.2019.08.09.09.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 5F04F305D34D;
	Fri,  9 Aug 2019 19:01:21 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 188D8305B7A0;
	Fri,  9 Aug 2019 19:01:21 +0300 (EEST)
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
	Marian Rotariu <marian.c.rotariu@gmail.com>
Subject: [RFC PATCH v6 52/92] kvm: introspection: add KVMI_GET_CPUID
Date: Fri,  9 Aug 2019 19:00:07 +0300
Message-Id: <20190809160047.8319-53-alazar@bitdefender.com>
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

From: Marian Rotariu <marian.c.rotariu@gmail.com>

This command returns a CPUID leaf (as seen by the guest OS).

Signed-off-by: Marian Rotariu <marian.c.rotariu@gmail.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 36 ++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/kvmi.h   | 12 ++++++++++
 arch/x86/kvm/kvmi.c                | 19 ++++++++++++++++
 include/uapi/linux/kvm_para.h      |  1 +
 virt/kvm/kvmi_int.h                |  3 +++
 virt/kvm/kvmi_msg.c                | 16 +++++++++++++
 6 files changed, 87 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index b6722d071ab7..9e15132ed976 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -933,6 +933,42 @@ currently being handled is replied to.
 * -KVM_EINVAL - padding is not zero
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 
+19. KVMI_GET_CPUID
+------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_get_cpuid {
+		__u32 function;
+		__u32 index;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_cpuid_reply {
+		__u32 eax;
+		__u32 ebx;
+		__u32 ecx;
+		__u32 edx;
+	};
+
+Returns a CPUID leaf (as seen by the guest OS).
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOENT - the selected leaf is not present or is invalid
+
 Events
 ======
 
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
index 98fb27e1273c..fa2719226198 100644
--- a/arch/x86/include/uapi/asm/kvmi.h
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -41,4 +41,16 @@ struct kvmi_get_registers_reply {
 	struct kvm_msrs msrs;
 };
 
+struct kvmi_get_cpuid {
+	__u32 function;
+	__u32 index;
+};
+
+struct kvmi_get_cpuid_reply {
+	__u32 eax;
+	__u32 ebx;
+	__u32 ecx;
+	__u32 edx;
+};
+
 #endif /* _UAPI_ASM_X86_KVMI_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index a78771b21d2f..4615bbe9c0db 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -5,6 +5,7 @@
  * Copyright (C) 2019 Bitdefender S.R.L.
  */
 #include "x86.h"
+#include "cpuid.h"
 #include "../../../virt/kvm/kvmi_int.h"
 
 static void *alloc_get_registers_reply(const struct kvmi_msg_hdr *msg,
@@ -211,6 +212,24 @@ bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 	return ret;
 }
 
+int kvmi_arch_cmd_get_cpuid(struct kvm_vcpu *vcpu,
+			    const struct kvmi_get_cpuid *req,
+			    struct kvmi_get_cpuid_reply *rpl)
+{
+	struct kvm_cpuid_entry2 *e;
+
+	e = kvm_find_cpuid_entry(vcpu, req->function, req->index);
+	if (!e)
+		return -KVM_ENOENT;
+
+	rpl->eax = e->eax;
+	rpl->ebx = e->ebx;
+	rpl->ecx = e->ecx;
+	rpl->edx = e->edx;
+
+	return 0;
+}
+
 int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
 				struct kvmi_get_vcpu_info_reply *rpl)
 {
diff --git a/include/uapi/linux/kvm_para.h b/include/uapi/linux/kvm_para.h
index 07e3f2662b36..553f168331a4 100644
--- a/include/uapi/linux/kvm_para.h
+++ b/include/uapi/linux/kvm_para.h
@@ -19,6 +19,7 @@
 #define KVM_EOPNOTSUPP		95
 #define KVM_EAGAIN		11
 #define KVM_EBUSY		EBUSY
+#define KVM_ENOENT		ENOENT
 #define KVM_ENOMEM		ENOMEM
 
 #define KVM_HC_VAPIC_POLL_IRQ		1
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 7bc3dd1f2298..22508d147495 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -230,6 +230,9 @@ int kvmi_arch_cmd_set_page_write_bitmap(struct kvmi *ikvm,
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access);
+int kvmi_arch_cmd_get_cpuid(struct kvm_vcpu *vcpu,
+			    const struct kvmi_get_cpuid *req,
+			    struct kvmi_get_cpuid_reply *rpl);
 int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
 				struct kvmi_get_vcpu_info_reply *rpl);
 
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 355cec70a28d..9548042de618 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -29,6 +29,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CONTROL_VM_EVENTS]     = "KVMI_CONTROL_VM_EVENTS",
 	[KVMI_EVENT]                 = "KVMI_EVENT",
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
+	[KVMI_GET_CPUID]             = "KVMI_GET_CPUID",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
 	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
 	[KVMI_GET_PAGE_WRITE_BITMAP] = "KVMI_GET_PAGE_WRITE_BITMAP",
@@ -641,6 +642,20 @@ static int handle_control_events(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, ec, NULL, 0);
 }
 
+static int handle_get_cpuid(struct kvm_vcpu *vcpu,
+			    const struct kvmi_msg_hdr *msg,
+			    const void *req, vcpu_reply_fct reply_cb)
+{
+	struct kvmi_get_cpuid_reply rpl;
+	int ec;
+
+	memset(&rpl, 0, sizeof(rpl));
+
+	ec = kvmi_arch_cmd_get_cpuid(vcpu, req, &rpl);
+
+	return reply_cb(vcpu, msg, ec, &rpl, sizeof(rpl));
+}
+
 /*
  * These commands are executed on the vCPU thread. The receiving thread
  * passes the messages using a newly allocated 'struct kvmi_vcpu_cmd'
@@ -652,6 +667,7 @@ static int(*const msg_vcpu[])(struct kvm_vcpu *,
 			      vcpu_reply_fct) = {
 	[KVMI_CONTROL_EVENTS]   = handle_control_events,
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
+	[KVMI_GET_CPUID]        = handle_get_cpuid,
 	[KVMI_GET_REGISTERS]    = handle_get_registers,
 	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
 	[KVMI_SET_REGISTERS]    = handle_set_registers,

