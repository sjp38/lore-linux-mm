Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B91EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161E12089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161E12089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E1956B0296; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BBBE6B0298; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D1BB6B0299; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC406B0296
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:29 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g2so47045677wrq.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uoZxYevB8WqlaQ1r9b6d5AmWCykIuaJUUkn328mm/84=;
        b=PWHyddw1HtUQjbl3lMw2blNB2rK9WHvqeWNdawJsoL/Jh6mGU8sP7TxY+B5vLqq4xk
         8HKHRbNRdltRxahhvkNCPKZ/OqH3E1PoXD5R0tm1G7GGZv+mkihEct3K4prMo+nAXE4n
         BY/DjmZ2RpLDJsoKQkxZB1yIy0iXA/lTPn4zpEeLgI5TfDRdc5vVkRt4SbL9K5akuWrY
         4eThTUNezh9ij+RXrtzAhQlpobde1C/MW2fJg6IDDICXU05wp/qQFsQJnTYxIDi/2QYb
         DmxYJgH0cwJx/YrDGnbQ8NLzkKFmFAbHuj3uCkBIALSWSmBp0rG+opF0ZVz2CYo/9yle
         JpYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUhxOYIb/nxet1+eWjw7/UHF3Glqlq7s/7gyvkAH0xwdDs3jEAc
	oWjwNW5b7pYu4f9vOYMYvyE9h6k2iFIY150GSgPEp39lDeXN8xg5R5qfkuz8Yq9Pw9tn5ilqBxH
	owyO2FsqgvZm4sbBkKn+Vx30CeaTSqrt5XACzro3+3iOOy6TA/vEVovJetadqwGl7Xg==
X-Received: by 2002:a1c:9696:: with SMTP id y144mr11651294wmd.73.1565366488760;
        Fri, 09 Aug 2019 09:01:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHUZntz28eFd5+8PE0NCTQh2JwSPTXkP0BGgEkrB9qCmJxaTd6nvKmFe/JLElUm8iir0Yc
X-Received: by 2002:a1c:9696:: with SMTP id y144mr11651018wmd.73.1565366485425;
        Fri, 09 Aug 2019 09:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366485; cv=none;
        d=google.com; s=arc-20160816;
        b=X9XmIv4c6BiftR5KGphqm8QIweI061+VMVXqXR99KPECtcwdPSkoYHqhPntW/9mJt2
         9+tLEN1QTm9Feymgz6GdkLXJbmz4Uy614aI0FHp5Gas51FOSd8HIh9LPt0AkiGi4vLJk
         lKCjhdRWubTZG+sz794o11WS9Oax/2rAmHrS/NH93gSHXckrU8p0nfTliaVG+LZwdqLG
         x0pfS89b7qF0m9u6TPU4nbwm1M76dxzLoS6s/e3Yn9a6WEekfLujbGbYrPYyRBZqNulZ
         HbdD6dBdMtMQBcVcITjwccckvzdZW4T25AWei/vLV8hJ+EAbQyLzVmHzTHr7pT+8synZ
         2tTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uoZxYevB8WqlaQ1r9b6d5AmWCykIuaJUUkn328mm/84=;
        b=mlw6nTn/c5Eyb2hqiwXa3pi2L65qYYLj3cP79Ta97V+6XmYFJ880YpaV+Cxvnzos+n
         yvZBhH6A+GgEoads1+W02xPpJlGL5gmP3bB51pRpfIMX/PYoTS1TvTaRQ6SuzGXwW/b7
         eEuhHk7aqLChPy3pB0VSnxvy5kPLQxpCzU5fqbvhkMl/Aj7T9ra6ZN/HB1WYVQntRdpv
         GsekFreEsvqI8Azy3lqM9TdOePbCD9CzCdvknbhVSvBNYugq5Yd1hNLpn7d/mlEKF7by
         Rs4bskkOvGsq5E1QscXScRrX3VZHwXvRbA7r/Xku9fm1ksf4rGfzM03c7INBWiLjH3/D
         rrtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i15si3998828wrm.234.2019.08.09.09.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id C6D4A3031EBB;
	Fri,  9 Aug 2019 19:01:24 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3E940305B7A1;
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 57/92] kvm: introspection: add KVMI_GET_XSAVE
Date: Fri,  9 Aug 2019 19:00:12 +0300
Message-Id: <20190809160047.8319-58-alazar@bitdefender.com>
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

This vCPU command is used to get the XSAVE area.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 31 ++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/kvmi.h   |  4 ++++
 arch/x86/kvm/kvmi.c                | 21 ++++++++++++++++++++
 arch/x86/kvm/x86.c                 |  4 ++--
 include/linux/kvm_host.h           |  2 ++
 virt/kvm/kvmi_int.h                |  3 +++
 virt/kvm/kvmi_msg.c                | 17 ++++++++++++++++
 7 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index c41c3edb0134..c43ea1b33a51 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1081,6 +1081,37 @@ to control events for any other register will fail with -KVM_EINVAL::
 * -KVM_EINVAL - padding is not zero
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 
+23. KVMI_GET_XSAVE
+------------------
+
+:Architecture: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_xsave_reply {
+		__u32 region[0];
+	};
+
+Returns a buffer containing the XSAVE area. Currently, the size of
+``kvm_xsave`` is used, but it could change. The userspace should get
+the buffer size from the message size.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
 Events
 ======
 
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
index 08af2eccbdfb..a3fcb1ef8404 100644
--- a/arch/x86/include/uapi/asm/kvmi.h
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -97,4 +97,8 @@ struct kvmi_event_msr_reply {
 	__u64 new_val;
 };
 
+struct kvmi_get_xsave_reply {
+	__u32 region[0];
+};
+
 #endif /* _UAPI_ASM_X86_KVMI_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index fc6956b50da2..078d714b59d5 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -790,3 +790,24 @@ int kvmi_arch_cmd_control_spp(struct kvmi *ikvm)
 {
 	return kvm_arch_init_spp(ikvm->kvm);
 }
+
+int kvmi_arch_cmd_get_xsave(struct kvm_vcpu *vcpu,
+			    struct kvmi_get_xsave_reply **dest,
+			    size_t *dest_size)
+{
+	struct kvmi_get_xsave_reply *rpl = NULL;
+	size_t rpl_size = sizeof(*rpl) + sizeof(struct kvm_xsave);
+	struct kvm_xsave *area;
+
+	rpl = kvmi_msg_alloc_check(rpl_size);
+	if (!rpl)
+		return -KVM_ENOMEM;
+
+	area = (struct kvm_xsave *) &rpl->region[0];
+	kvm_vcpu_ioctl_x86_get_xsave(vcpu, area);
+
+	*dest = rpl;
+	*dest_size = rpl_size;
+
+	return 0;
+}
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index ac027471c4f3..05ff23180355 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3745,8 +3745,8 @@ static void load_xsave(struct kvm_vcpu *vcpu, u8 *src)
 	}
 }
 
-static void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
-					 struct kvm_xsave *guest_xsave)
+void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
+				  struct kvm_xsave *guest_xsave)
 {
 	if (boot_cpu_has(X86_FEATURE_XSAVE)) {
 		memset(guest_xsave, 0, sizeof(struct kvm_xsave));
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index c8eb1a4d997f..3aad3b96107b 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -805,6 +805,8 @@ int kvm_arch_vcpu_ioctl_set_mpstate(struct kvm_vcpu *vcpu,
 int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
 					struct kvm_guest_debug *dbg);
 int kvm_arch_vcpu_ioctl_run(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run);
+void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
+				  struct kvm_xsave *guest_xsave);
 
 int kvm_arch_init(void *opaque);
 void kvm_arch_exit(void);
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 640a78b54947..1a705cba4776 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -255,6 +255,9 @@ void kvmi_arch_trap_event(struct kvm_vcpu *vcpu);
 int kvmi_arch_cmd_get_cpuid(struct kvm_vcpu *vcpu,
 			    const struct kvmi_get_cpuid *req,
 			    struct kvmi_get_cpuid_reply *rpl);
+int kvmi_arch_cmd_get_xsave(struct kvm_vcpu *vcpu,
+			    struct kvmi_get_xsave_reply **dest,
+			    size_t *dest_size);
 int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
 				struct kvmi_get_vcpu_info_reply *rpl);
 int kvmi_arch_cmd_inject_exception(struct kvm_vcpu *vcpu, u8 vector,
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 8a8951f13f8e..6bc18b7973cf 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -38,6 +38,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_GET_REGISTERS]         = "KVMI_GET_REGISTERS",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
+	[KVMI_GET_XSAVE]             = "KVMI_GET_XSAVE",
 	[KVMI_INJECT_EXCEPTION]      = "KVMI_INJECT_EXCEPTION",
 	[KVMI_PAUSE_VCPU]            = "KVMI_PAUSE_VCPU",
 	[KVMI_READ_PHYSICAL]         = "KVMI_READ_PHYSICAL",
@@ -700,6 +701,21 @@ static int handle_get_cpuid(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, ec, &rpl, sizeof(rpl));
 }
 
+static int handle_get_xsave(struct kvm_vcpu *vcpu,
+			    const struct kvmi_msg_hdr *msg, const void *req,
+			    vcpu_reply_fct reply_cb)
+{
+	struct kvmi_get_xsave_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	int err, ec;
+
+	ec = kvmi_arch_cmd_get_xsave(vcpu, &rpl, &rpl_size);
+
+	err = reply_cb(vcpu, msg, ec, rpl, rpl_size);
+	kvmi_msg_free(rpl);
+	return err;
+}
+
 /*
  * These commands are executed on the vCPU thread. The receiving thread
  * passes the messages using a newly allocated 'struct kvmi_vcpu_cmd'
@@ -716,6 +732,7 @@ static int(*const msg_vcpu[])(struct kvm_vcpu *,
 	[KVMI_GET_CPUID]        = handle_get_cpuid,
 	[KVMI_GET_REGISTERS]    = handle_get_registers,
 	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
+	[KVMI_GET_XSAVE]        = handle_get_xsave,
 	[KVMI_INJECT_EXCEPTION] = handle_inject_exception,
 	[KVMI_SET_REGISTERS]    = handle_set_registers,
 };

