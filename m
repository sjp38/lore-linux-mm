Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85824C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18418214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18418214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACBC86B02E4; Fri,  9 Aug 2019 12:02:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA3C06B02E5; Fri,  9 Aug 2019 12:02:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9910C6B02E6; Fri,  9 Aug 2019 12:02:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2956B02E4
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:02:52 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x2so46738747wru.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:02:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f6BvYVYGOA9rPmHw8bpG6rQbrNablAgbg1AUCMttmB8=;
        b=ULkwHj3r32E/4BOFcsLMPx3xM7xJ9TEC7C1l+xkKp2qXLL6LEvFzmkrBSBu8GjCh7i
         Yy8WCkoFNVaLdVMORaTNz5s+JbWt+SxneSnDR+4exdL1MTF0byyaP0L2tK+WiYh/SyQr
         5HvXS53ktWlVTnQXdcQ/2GlJ+TMZc2cm0iZNI7pjmXs5fV6IVlhRtT8tiC7TA0BolIos
         +5iSkO1nnTw0XzhY1Iw43OvOv21mlSXp5MgbC9+7/c5KdEC0rVOol/UwNnLtFd5L5dCn
         MJ7jko/1xR2N4rzRallOzLDGKIhwKVUv/M9+qLycOnpRRZJJe8GIn0T3zM0zy1n6Kzbo
         430w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAX5VqL39WDU4uHH3+Zff4XRiKM/G07qIaC+31M7eQHiV+bxCyjF
	CDtSQUOtTjG1K7+8ZgaZt/35GwzvhGUfnd7y7oOwo5XOFq00S3O1r23QQ9JVX+WtWLK612hJqj3
	UFHvivqYPekxAOsyPKCoYkWBdRe2ehP6RNlfUl4taPeYFm7feI3ubrnx2LtWYMnhNJw==
X-Received: by 2002:a1c:2314:: with SMTP id j20mr11709465wmj.152.1565366571855;
        Fri, 09 Aug 2019 09:02:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmsGVTx/dtN41MSYCDUM/3AwGIuGNMxQgf4sgqye+KQWShMr+Ooi8MTsOXC4V+Yj0tAGf/
X-Received: by 2002:a1c:2314:: with SMTP id j20mr11699618wmj.152.1565366464713;
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366464; cv=none;
        d=google.com; s=arc-20160816;
        b=IOH01R9i40NqfyUtQmrTwRWrGUyv73vAizKveid63NLWKFCPe2JVfALj9CtX6U5wOD
         IKKhXa9KEC+RN6TQ6rCA+2t2200+s55m6ByhbvC2fgXYqGAsBqOs3+OVe4XNt3hhJTy0
         TqVRFXri8Z/KNFYYNtfH7El0k6RhqUbHh9hAkkqhLAfn5OLzJ4uUm55Lb50Hqvyx1nkA
         FnoZ1sjv9m5BWvH5eFCqwZSfKgzVMe7fzTgHnGPPl0H8sg4ojKnymIvHjgc7dg44tiG/
         zFTbTdHpESRjMo8j3cqxNjRK9G2Ko3aHERErJCxmBgF3PYZccfj8NH6h7QzNSrnnVI+p
         acCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=f6BvYVYGOA9rPmHw8bpG6rQbrNablAgbg1AUCMttmB8=;
        b=OFx9W8HSEgrvVTN+uhOkRW7eGu5mm9UGLIaiBPk2/RqfcFaXTp1nV78WSawSBhrNvn
         dzQtu84q8rhrnJKJeDN2PVkFLzQfWpXKr4QN/vn/x08xt7E4XM13716OdBe9ZuP4exIU
         jJfHjHYOpH+HC6HQcG9B2vmOJkOx26QUqgeKQ8ylNvWiUBUCtN5ac7sYRXkWI1gQtrj5
         XOgeVWt2Ut/HfZOh8vZoXlvtI48jZX2l6dja3E1YYIuVQaBCtKWFtwRA0G1ZD9jn+H50
         tojxkCFYXCgse6sTsc5YF6lBWmX1amlVqWk+tyqg8CkkMdYHmBdBwU55bTw7A5BwUkFU
         pHfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i14si87707405wrp.198.2019.08.09.09.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 178D6305D3F3;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id B5DC3305B7A5;
	Fri,  9 Aug 2019 19:01:02 +0300 (EEST)
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
Subject: [RFC PATCH v6 29/92] kvm: introspection: add KVMI_CONTROL_EVENTS
Date: Fri,  9 Aug 2019 18:59:44 +0300
Message-Id: <20190809160047.8319-30-alazar@bitdefender.com>
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

This command enables/disables vCPU introspection events.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 53 ++++++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          |  7 ++++
 virt/kvm/kvmi.c                    | 13 ++++++++
 virt/kvm/kvmi_int.h                |  6 +++-
 virt/kvm/kvmi_msg.c                | 24 ++++++++++++++
 5 files changed, 102 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 71897338e85a..957641802cac 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -456,6 +456,59 @@ Returns the TSC frequency (in HZ) for the specified vCPU if available
 * -KVM_EINVAL - padding is not zero
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 
+8. KVMI_CONTROL_EVENTS
+----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_control_events {
+		__u16 event_id;
+		__u8 enable;
+		__u8 padding1;
+		__u32 padding2;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Enables/disables vCPU introspection events. This command can be used with
+the following events::
+
+	KVMI_EVENT_CR
+	KVMI_EVENT_MSR
+	KVMI_EVENT_XSETBV
+	KVMI_EVENT_BREAKPOINT
+	KVMI_EVENT_HYPERCALL
+	KVMI_EVENT_PF
+	KVMI_EVENT_TRAP
+	KVMI_EVENT_DESCRIPTOR
+	KVMI_EVENT_SINGLESTEP
+
+When an event is enabled, the introspection tool is notified and it
+must reply with: continue, retry, crash, etc. (see **Events** below).
+
+The *KVMI_EVENT_PAUSE_VCPU* event is always allowed,
+because it is triggered by the *KVMI_PAUSE_VCPU* command.
+The *KVMI_EVENT_CREATE_VCPU* and *KVMI_EVENT_UNHOOK* events are controlled
+by the *KVMI_CONTROL_VM_EVENTS* command.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the event ID is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EPERM - the access is restricted by the host
+* -KVM_EOPNOTSUPP - one the events can't be intercepted in the current setup
+
 Events
 ======
 
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index c56e676ddb2b..934c0610140a 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -120,6 +120,13 @@ struct kvmi_get_vcpu_info_reply {
 	__u64 tsc_speed;
 };
 
+struct kvmi_control_events {
+	__u16 event_id;
+	__u8 enable;
+	__u8 padding1;
+	__u32 padding2;
+};
+
 struct kvmi_control_vm_events {
 	__u16 event_id;
 	__u8 enable;
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 5cbc82b284f4..14963474617e 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -969,6 +969,19 @@ void kvmi_handle_requests(struct kvm_vcpu *vcpu)
 	kvmi_put(vcpu->kvm);
 }
 
+int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
+			    bool enable)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+
+	if (enable)
+		set_bit(event_id, ivcpu->ev_mask);
+	else
+		clear_bit(event_id, ivcpu->ev_mask);
+
+	return 0;
+}
+
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 			       bool enable)
 {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index d798908d0f70..c0044cae8089 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -95,6 +95,8 @@ struct kvmi_vcpu {
 	bool reply_waiting;
 	struct kvmi_vcpu_reply reply;
 
+	DECLARE_BITMAP(ev_mask, KVMI_NUM_EVENTS);
+
 	struct list_head job_list;
 	spinlock_t job_lock;
 
@@ -131,7 +133,7 @@ struct kvmi_mem_access {
 
 static inline bool is_event_enabled(struct kvm_vcpu *vcpu, int event)
 {
-	return false; /* TODO */
+	return test_bit(event, IVCPU(vcpu)->ev_mask);
 }
 
 /* kvmi_msg.c */
@@ -146,6 +148,8 @@ int kvmi_msg_send_unhook(struct kvmi *ikvm);
 void *kvmi_msg_alloc(void);
 void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
+int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
+			    bool enable);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 			       bool enable);
 int kvmi_run_jobs_and_wait(struct kvm_vcpu *vcpu);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 3372d8c7e74f..a3c67af8674e 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -24,6 +24,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
+	[KVMI_CONTROL_EVENTS]        = "KVMI_CONTROL_EVENTS",
 	[KVMI_CONTROL_VM_EVENTS]     = "KVMI_CONTROL_VM_EVENTS",
 	[KVMI_EVENT]                 = "KVMI_EVENT",
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
@@ -403,6 +404,28 @@ static int handle_get_vcpu_info(struct kvm_vcpu *vcpu,
 	return reply_cb(vcpu, msg, 0, &rpl, sizeof(rpl));
 }
 
+static int handle_control_events(struct kvm_vcpu *vcpu,
+				 const struct kvmi_msg_hdr *msg,
+				 const void *_req,
+				 vcpu_reply_fct reply_cb)
+{
+	unsigned long known_events = KVMI_KNOWN_VCPU_EVENTS;
+	const struct kvmi_control_events *req = _req;
+	struct kvmi *ikvm = IKVM(vcpu->kvm);
+	int ec;
+
+	if (req->padding1 || req->padding2)
+		ec = -KVM_EINVAL;
+	else if (!test_bit(req->event_id, &known_events))
+		ec = -KVM_EINVAL;
+	else if (!is_event_allowed(ikvm, req->event_id))
+		ec = -KVM_EPERM;
+	else
+		ec = kvmi_cmd_control_events(vcpu, req->event_id, req->enable);
+
+	return reply_cb(vcpu, msg, ec, NULL, 0);
+}
+
 /*
  * These commands are executed on the vCPU thread. The receiving thread
  * passes the messages using a newly allocated 'struct kvmi_vcpu_cmd'
@@ -412,6 +435,7 @@ static int handle_get_vcpu_info(struct kvm_vcpu *vcpu,
 static int(*const msg_vcpu[])(struct kvm_vcpu *,
 			      const struct kvmi_msg_hdr *, const void *,
 			      vcpu_reply_fct) = {
+	[KVMI_CONTROL_EVENTS]   = handle_control_events,
 	[KVMI_EVENT_REPLY]      = handle_event_reply,
 	[KVMI_GET_VCPU_INFO]    = handle_get_vcpu_info,
 };

