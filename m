Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 484BBC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC2D32089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC2D32089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26E726B0294; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6116B0296; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094B36B0295; Fri,  9 Aug 2019 12:01:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A83676B0293
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:27 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b1so46834805wru.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ort1TBH1VSGPj7+xCWexdM+iz5s6O9TDHYbWNwaAOJc=;
        b=DtGXPM1CoEZVmmDDjXYrqUjmYsWwGI3VhPG8OSXvAX3vxjbasJ8b0N7eAQy+9o25jR
         5f/LlQzyp4A+sUJzIEGCSD7XkP6k3G92x7LiJwm9+JaTWezvc1C253CSsZZ6+wErfRtS
         JDdtzgfOWDg9qEP86/3tiXz5TBaqSUWexermJQzR+yHC7qy/IIIUm8lP3ffWpletNUlq
         aA2fwt100IwvPd/fT6gfzYpxNnP7w5/gNFWCmqk51LtK3A/BLiXcJktFV37DcmhFwBsq
         EAq0zkQMSipSgTvH0/crXK/msLsHULXvWTKsu6UHoPvLD0Zov0MP39ep4WldeT8s2n8m
         Egeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXl0jXAtJGGnX/jkGq5xFSdaM8SYOeTBQz3oSw/7Ur4PtdGYRkk
	nxrb1y0kTKyjaEkEsfky6ONxBrAcyg7IWYl6vGbji6UHOB30whVsY+8H6x1mhXwww5t2aoHw98c
	/kOPIpQfA6cjcisdqTJpgiiuvrwR0EjYtHKaMvofzUyszi85Jy9D1iVhBNtY/opVlAg==
X-Received: by 2002:a5d:6307:: with SMTP id i7mr12074267wru.144.1565366487269;
        Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfbilKSoJy6B8oD1PHUs4BMe0MEMe1Q65eo2T/adYRHqfhBwQ4h3sHMKe1xBbv15+FRDb4
X-Received: by 2002:a5d:6307:: with SMTP id i7mr12074132wru.144.1565366485785;
        Fri, 09 Aug 2019 09:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366485; cv=none;
        d=google.com; s=arc-20160816;
        b=i/ukF0m+g9hucXXtoxukh+d8oj2+SCTdBrDSqi8hJ7um0V62Y5J9RNgKC+xW9E28zE
         CXDHvZBztl7ykByqChjZNGGvgLq8pieyPA3YPeUMPLYGJ6xyj1tFeqcETNIK82PXuXUW
         EWI0L8qaT79+50OtieApzskcbK374Mr7/MB6akFlmylnO+Jtcu69cisv2rb6Lj6aHJ7b
         jo1K6g5E33oSJqclBXvalG+v6xQNGJEhvFdzpPBYTUlHIMgavmlZXj0J5zMQgARsIPG/
         ypxCe9/+6jg3S6gP0AEqaGEOQGcjwuTN10xcuElhzxxR5Gv7BT2RKBYtyEjGQmlQ55mA
         OOGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ort1TBH1VSGPj7+xCWexdM+iz5s6O9TDHYbWNwaAOJc=;
        b=FikLykJjPa+mGNXvQ2F0hAT71LyYUgXhTbBtx01t/km5KWxIEwKzOnK/qtxh6MC13S
         LtTctFayS4d0eBjiKEHnR+JA5WhHnc/nwEA0bwIZ43Dj1+hGJyGUEvaaIjIIA+Ln73+p
         lAI15sK3dXcfpAue+CuIRzpbtY1VSZStmfyWjTIk6/LJuWmeDnnga8BBeoDUbSwZSgkU
         pWqBc5xWU7rVDsHrWkGq5UIGKIE5YYmJS+QyvQmTgeqDtjp+wMlcrqC5kjFWzytXv2Ul
         43r9+uHDpnI2/EqN3Dzw/dhMlgn2PHrrMBCEyeJkQB5uh46+Ebd4w2XpM2/hWN70PNt2
         VbWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i12si68105975wrs.152.2019.08.09.09.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 3017E3031EBD;
	Fri,  9 Aug 2019 19:01:25 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id C3273305B7A0;
	Fri,  9 Aug 2019 19:01:24 +0300 (EEST)
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
	=?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>
Subject: [RFC PATCH v6 58/92] kvm: introspection: add KVMI_GET_MTRR_TYPE
Date: Fri,  9 Aug 2019 19:00:13 +0300
Message-Id: <20190809160047.8319-59-alazar@bitdefender.com>
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

This command returns the memory type for a guest physical address.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 32 ++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/kvmi.h   |  9 +++++++++
 arch/x86/kvm/kvmi.c                |  7 +++++++
 virt/kvm/kvmi_int.h                |  1 +
 virt/kvm/kvmi_msg.c                | 17 ++++++++++++++++
 5 files changed, 66 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index c43ea1b33a51..e58f0e22f188 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1112,6 +1112,38 @@ the buffer size from the message size.
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 * -KVM_ENOMEM - not enough memory to allocate the reply
 
+24. KVMI_GET_MTRR_TYPE
+----------------------
+
+:Architecture: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_get_mtrr_type {
+		__u64 gpa;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_mtrr_type_reply {
+		__u8 type;
+		__u8 padding[7];
+	};
+
+Returns the guest memory type for a specific physical address.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+
 Events
 ======
 
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
index a3fcb1ef8404..c3c96e6e2a26 100644
--- a/arch/x86/include/uapi/asm/kvmi.h
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -101,4 +101,13 @@ struct kvmi_get_xsave_reply {
 	__u32 region[0];
 };
 
+struct kvmi_get_mtrr_type {
+	__u64 gpa;
+};
+
+struct kvmi_get_mtrr_type_reply {
+	__u8 type;
+	__u8 padding[7];
+};
+
 #endif /* _UAPI_ASM_X86_KVMI_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 078d714b59d5..0114ed66f4f3 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -811,3 +811,10 @@ int kvmi_arch_cmd_get_xsave(struct kvm_vcpu *vcpu,
 
 	return 0;
 }
+
+int kvmi_arch_cmd_get_mtrr_type(struct kvm_vcpu *vcpu, u64 gpa, u8 *type)
+{
+	*type = kvm_mtrr_get_guest_memory_type(vcpu, gpa_to_gfn(gpa));
+
+	return 0;
+}
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 1a705cba4776..ac2e13787f01 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -267,5 +267,6 @@ int kvmi_arch_cmd_control_cr(struct kvm_vcpu *vcpu,
 			     const struct kvmi_control_cr *req);
 int kvmi_arch_cmd_control_msr(struct kvm_vcpu *vcpu,
 			      const struct kvmi_control_msr *req);
+int kvmi_arch_cmd_get_mtrr_type(struct kvm_vcpu *vcpu, u64 gpa, u8 *type);
 
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 6bc18b7973cf..ee54d92b07ec 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -33,6 +33,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
 	[KVMI_GET_CPUID]             = "KVMI_GET_CPUID",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
+	[KVMI_GET_MTRR_TYPE]         = "KVMI_GET_MTRR_TYPE",
 	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
 	[KVMI_GET_PAGE_WRITE_BITMAP] = "KVMI_GET_PAGE_WRITE_BITMAP",
 	[KVMI_GET_REGISTERS]         = "KVMI_GET_REGISTERS",
@@ -701,6 +702,21 @@ static int handle_get_cpuid(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, ec, &rpl, sizeof(rpl));
 }
 
+static int handle_get_mtrr_type(struct kvm_vcpu *vcpu,
+				const struct kvmi_msg_hdr *msg,
+				const void *_req, vcpu_reply_fct reply_cb)
+{
+	const struct kvmi_get_mtrr_type *req = _req;
+	struct kvmi_get_mtrr_type_reply rpl;
+	int ec;
+
+	memset(&rpl, 0, sizeof(rpl));
+
+	ec = kvmi_arch_cmd_get_mtrr_type(vcpu, req->gpa, &rpl.type);
+
+	return reply_cb(vcpu, msg, ec, &rpl, sizeof(rpl));
+}
+
 static int handle_get_xsave(struct kvm_vcpu *vcpu,
 			    const struct kvmi_msg_hdr *msg, const void *req,
 			    vcpu_reply_fct reply_cb)
@@ -730,6 +746,7 @@ static int(*const msg_vcpu[])(struct kvm_vcpu *,
 	[KVMI_CONTROL_MSR]      = handle_control_msr,
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
 	[KVMI_GET_CPUID]        = handle_get_cpuid,
+	[KVMI_GET_MTRR_TYPE]    = handle_get_mtrr_type,
 	[KVMI_GET_REGISTERS]    = handle_get_registers,
 	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
 	[KVMI_GET_XSAVE]        = handle_get_xsave,

