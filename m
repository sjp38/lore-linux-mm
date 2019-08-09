Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF8F4C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DBCA2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DBCA2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776226B0277; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B9426B0274; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492356B0277; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFEA76B0273
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:01 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s18so5312533wrt.21
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r1S6pzU0/Hk4OFWHO9t0+lm6HUktaigxe8FDAARZhnw=;
        b=SNZlnNb10N+hvFaRYEEFNEVsgMRio3kTigvL1g0vCllXIAhQo5QuUmN9ibZQSYWEIv
         YKCcnpdAav7+NfcF2Ivc95G51+Rl0+gmjc0jsTZjHXmXyg6/LUxNO0yMqBHSNf1F140N
         E28+w9P25IS66UOk1/A4vaCrZ3kfDUf5soyIvKY9E5eWIOcbd7HczTOFv3dgvzjSfqkz
         PIC7tEOgMgfxzDYVUTl8SOyuEgsF7g18Hpbw3zRkZHj3PUbpcUaCCkW2YJgMXDOJKIzO
         QuMZsP8P/UL4yoRAPRfwCbFUGgaYUCgjcrZhYKpEJiR4NzG3V0RAJrgnvW5bFkUZN+p9
         Fs9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVKkf48E4TlnuEyQuAy6zjFMZMxrMFOnxTqBEHykX8O+RL9BAd/
	Ay5AbSrwJ8NdIyN0LPbaoQU9ko/thb246EqrQxRhXiDNXn+UbsZpkI0kzCCOrPkQcHH05pA29D9
	l2WZ7et5O5fiS2qFxLcYMIphZAW9zX9RURM10C/Gw2C5/GQg4LkSiAOnlPlKTnwgXiw==
X-Received: by 2002:a1c:a584:: with SMTP id o126mr11922813wme.147.1565366461474;
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ4b8xfqR6wtiP/41apHeJuzCE+59uzux8qDqpRXoQJj0L3nMPFRjMRcPMGoOZPZanWl2C
X-Received: by 2002:a1c:a584:: with SMTP id o126mr11922687wme.147.1565366459886;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366459; cv=none;
        d=google.com; s=arc-20160816;
        b=L7ymabIT3lKaus81VaqcvLU9b487+O4A0Z5XICAGuejDW4AVeC/4XnDqGSi2Ljpl4T
         Mpt1eweY+ow7GSiw48TAnVk2MGtaGqWlLDN8rtrgi6dCZC6rr59ha383YgTVAHrPs7Ef
         YeYUnA7BDZ8e3oYI/lAmDov7ocKgJUB79OEWIWdpOARWtYlGNPfmWX2GfQSffBKGjBZw
         SDYi+jPFZZf6SuSprfJYrF8bIpJi1xrFfKvlRHebmo1WGqu39aSSpgSVXRiF/Ts3CVLd
         Qg02H4Q7qmJn66GMPESzSYYSS2n+0LAlLMxToEsF/iFz9XlIUcsKxYdzvSGF82Cu6Evr
         33SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r1S6pzU0/Hk4OFWHO9t0+lm6HUktaigxe8FDAARZhnw=;
        b=LDb4Dd2IsNdTHcAdDTF8q/diE8qR0cBY9U9e5gS5s2fphaiquvwpxuraKAyOq1QuW4
         rjfGzy7HM6J/7RXZc+Fg4GywwnoENWeFjw+LzqWSZgEYTLl/gO+WesphXltbJ1cjhzKo
         MIfULODbFCV6Py1I5jhemwJ6CMAC0c5TZhyYD4bAE+mr5MD3zF/LzIeOLPrdvfvwU8z8
         q9rN3dWtmWlgIG4sKFRdBrj5y2r/G/PhPriEMPspLLBxx4u7PvYhCy0hg2keQP3qrtWo
         rT2MNVy/S6JBLKhmzBfmPjgfN+pFX+5Enj+MchjJtMDH8LQVWyEYO9rt4enoI5fDxKzp
         qh4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id h9si87505122wrp.261.2019.08.09.09.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 49B84305D3DC;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id F37DF305B7A0;
	Fri,  9 Aug 2019 19:00:58 +0300 (EEST)
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
Subject: [RFC PATCH v6 20/92] kvm: introspection: add KVMI_GET_VCPU_INFO
Date: Fri,  9 Aug 2019 18:59:35 +0300
Message-Id: <20190809160047.8319-21-alazar@bitdefender.com>
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

For now, this command returns the TSC frequency (in HZ) for the specified
vCPU if available (otherwise it returns zero).

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 29 +++++++++++++++++++++++++++++
 arch/x86/kvm/kvmi.c                | 12 ++++++++++++
 include/uapi/linux/kvmi.h          |  4 ++++
 virt/kvm/kvmi_int.h                |  2 ++
 virt/kvm/kvmi_msg.c                | 14 ++++++++++++++
 5 files changed, 61 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index b29cd1b80b4f..71897338e85a 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -427,6 +427,35 @@ in almost all cases, it must reply with: continue, retry, crash, etc.
 * -KVM_EINVAL - padding is not zero
 * -KVM_EPERM - the access is restricted by the host
 
+7. KVMI_GET_VCPU_INFO
+---------------------
+
+:Architectures: all
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
+	struct kvmi_get_vcpu_info_reply {
+		__u64 tsc_speed;
+	};
+
+Returns the TSC frequency (in HZ) for the specified vCPU if available
+(otherwise it returns zero).
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+
 Events
 ======
 
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 9aecca551673..97c72cdc6fb0 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -90,3 +90,15 @@ void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev)
 	ev->arch.mode = kvmi_vcpu_mode(vcpu, &event->sregs);
 	kvmi_get_msrs(vcpu, event);
 }
+
+int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
+				struct kvmi_get_vcpu_info_reply *rpl)
+{
+	if (kvm_has_tsc_control)
+		rpl->tsc_speed = 1000ul * vcpu->arch.virtual_tsc_khz;
+	else
+		rpl->tsc_speed = 0;
+
+	return 0;
+}
+
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index ccf2239b5db4..aa5bc909e278 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -112,6 +112,10 @@ struct kvmi_get_guest_info_reply {
 	__u32 padding[3];
 };
 
+struct kvmi_get_vcpu_info_reply {
+	__u64 tsc_speed;
+};
+
 struct kvmi_control_vm_events {
 	__u16 event_id;
 	__u8 enable;
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index c21f0fd5e16c..7cff91bc1acc 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -139,5 +139,7 @@ int kvmi_add_job(struct kvm_vcpu *vcpu,
 
 /* arch */
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
+int kvmi_arch_cmd_get_vcpu_info(struct kvm_vcpu *vcpu,
+				struct kvmi_get_vcpu_info_reply *rpl);
 
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 8e8af572a4f4..3372d8c7e74f 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -28,6 +28,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_EVENT]                 = "KVMI_EVENT",
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
+	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
 
@@ -390,6 +391,18 @@ static int handle_event_reply(struct kvm_vcpu *vcpu,
 	return expected->error;
 }
 
+static int handle_get_vcpu_info(struct kvm_vcpu *vcpu,
+				const struct kvmi_msg_hdr *msg,
+				const void *req, vcpu_reply_fct reply_cb)
+{
+	struct kvmi_get_vcpu_info_reply rpl;
+
+	memset(&rpl, 0, sizeof(rpl));
+	kvmi_arch_cmd_get_vcpu_info(vcpu, &rpl);
+
+	return reply_cb(vcpu, msg, 0, &rpl, sizeof(rpl));
+}
+
 /*
  * These commands are executed on the vCPU thread. The receiving thread
  * passes the messages using a newly allocated 'struct kvmi_vcpu_cmd'
@@ -400,6 +413,7 @@ static int(*const msg_vcpu[])(struct kvm_vcpu *,
 			      const struct kvmi_msg_hdr *, const void *,
 			      vcpu_reply_fct) = {
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
+	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
 };
 
 static void kvmi_job_vcpu_cmd(struct kvm_vcpu *vcpu, void *_ctx)

