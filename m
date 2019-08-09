Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA773C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A0122089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A0122089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 798286B000D; Fri,  9 Aug 2019 12:00:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7246B6B0010; Fri,  9 Aug 2019 12:00:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54DEE6B0266; Fri,  9 Aug 2019 12:00:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 097DB6B000D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e6so46640690wrv.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QmbuV8UcqQ4blTwNU/O928EeP3af39xnnyk2K4TDayE=;
        b=BFBfFxOzdqcr4hglp9lWM6mz1rT/xM6VqDRmTO96g8iZom/WaI4xed8VxCkHHC5l6n
         x3NbK36s4HEDknWtJoVh9WP0W4qRNLy1QpdLF+TU03PCDqm/kef/5+8G1AJ4mQzeWcAz
         Y/MgOXxE+pH3NbMgzKNrwuyR5ZSzf0qEHyhH+pfQp58c5Wu5lhkSU0J8s/2goiOTX7iI
         7rUSSO6JS5vjnho6RJJJnAyZ+QhU/AzqJB2tczOBxA3v+Ny/bkDXVsDSf/WIc8cV0rlM
         KldGud2ozBFi7tT3i55RlXdnIMhayo9cTFkjRBwc3/Go+Pn+C1IIjmsb14QkBJhnx6kN
         Zldw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVOiyKKomkVhE2IuO5PL1bfPvKK8xxpxSp61tsOhWFOQvlBTgF/
	1JmgxgLc2jQfNaAc6VI6vyDv2xZGM4CWH7Utyi+33dmtYTMbLbdLU2kvHSPZ3M+Wr8+3nyeX/QS
	WVK679i9xK453wnxHJ7gQbQj1WDACwN1Me2P027sSRRo6fek6qaS4m9vAxjWJbC/jFA==
X-Received: by 2002:a5d:470c:: with SMTP id y12mr9833829wrq.136.1565366457593;
        Fri, 09 Aug 2019 09:00:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyovGyW5AYCFX/Knu5A+waO8PqQFV6gHy5orMnC9SKZDxDFtUqV3HD/zeP9/ccDIdLPRYPf
X-Received: by 2002:a5d:470c:: with SMTP id y12mr9833695wrq.136.1565366456026;
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366456; cv=none;
        d=google.com; s=arc-20160816;
        b=nOH0TmTwoLk8+ojlzX4XuGSScuk0nxrFhLFNREuSzPcptDC7IeaMMchTUDznFp0+Na
         1YBy9qkBHIM+A0NEr/81D8bkQJ18oagq+PCxH8T3EdmZJLMjShCa8VN9OXPRd9A0m0oV
         bdM5OyTGVxOmH8cHCVDcCV2jEJFExtjjHDduU9F/TDxRjbCt5MSJDcjNGR9YTZLdM0AF
         NqIjR4DGu1nlUPlfa+6ohhKvgLq5wGksNMLvcqz9aZaHbtYtTqyPMAGbgsF4owi7d8ev
         wQ+HqDAcRr7ZT3d+E3ey3roq3UNAi/wEVqhNhHElevGT53kdiCqcFaqAlwou39rGPq0e
         f6uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QmbuV8UcqQ4blTwNU/O928EeP3af39xnnyk2K4TDayE=;
        b=F1PHgVsUChIm+/JYO52oeuL6xfz14cTuRWQz0SgE27XxgvCZ+m7ogzfElBQqWoydco
         lSauJXTAM5D8hYXZ9BbXutUynBNj4stoPjs2X68pT/NrCxwtYCja1ooA4UAn5wvoah0O
         aSoc0b2P4KP23cNyT5iQbol6HhXLhsO7ju2FVM0OZmMHzqxFEfg+isuCTUEvzxoW3BmU
         WRTuWGZH6x1ozcknUD4uZExeQiITk2d5+kmEzjdT5+VrQc20cxtt8d/RxeLiiC04qLaD
         nEnvxVCHOLldJIZ7P9ZEdq7QyLH4DOvRe/EmgbcEuFg9OebB8xNEWxeSMjblT9HS/nXB
         LnlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i5si84765181wrs.39.2019.08.09.09.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 64B15305D3D1;
	Fri,  9 Aug 2019 19:00:55 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id E3EF1305B7A3;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
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
Subject: [RFC PATCH v6 10/92] kvm: introspection: add KVMI_CONTROL_VM_EVENTS
Date: Fri,  9 Aug 2019 18:59:25 +0300
Message-Id: <20190809160047.8319-11-alazar@bitdefender.com>
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

No introspection event (neither VM event, nor vCPU event) will be sent
to the introspection tool unless enabled/requested.

This command enables/disables VM events. For now, these events are:

  * KVMI_EVENT_UNHOOK
  * KVMI_EVENT_CREATE_VCPU

The first event is initiated by userspace/QEMU in order to give the
introspection tool a chance to remove its hooks in the event of
pause/suspend/migrate.

The second event is actually a vCPU event, added to cover the case when
the introspection tool has paused all vCPUs and userspace hotplugs (and
starts) another one. The event is controlled by this command because its
status (enabled/disabled) is kept in the VM related structures (as opposed
to vCPU related structures). I didn't had a better idea. Not to mention
that, the vCPU events are controlled with commands like "enable/disable
event X for vCPU Y" and Y is _unknown_ for X=KVMI_EVENT_CREATE_VCPU.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 39 ++++++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          |  7 ++++++
 virt/kvm/kvmi.c                    | 11 +++++++++
 virt/kvm/kvmi_int.h                |  3 +++
 virt/kvm/kvmi_msg.c                | 23 ++++++++++++++++++
 5 files changed, 83 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 2fbe7c28e4f1..a660def20b23 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -380,3 +380,42 @@ This command is always allowed.
 	};
 
 Returns the number of online vCPUs.
+
+6. KVMI_CONTROL_VM_EVENTS
+-------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_vm_events {
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
+Enables/disables VM introspection events. This command can be used with
+the following events::
+
+	KVMI_EVENT_CREATE_VCPU
+	KVMI_EVENT_UNHOOK
+
+When an event is enabled, the introspection tool is notified and,
+in almost all cases, it must reply with: continue, retry, crash, etc.
+(see **Events** below).
+
+:Errors:
+
+* -KVM_EINVAL - the event ID is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EPERM - the access is restricted by the host
+
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 367c8ec28f75..ff35faabb7ed 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -107,4 +107,11 @@ struct kvmi_get_guest_info_reply {
 	__u32 padding[3];
 };
 
+struct kvmi_control_vm_events {
+	__u16 event_id;
+	__u8 enable;
+	__u8 padding1;
+	__u32 padding2;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index dc1bb8326763..961e6cc13fb6 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -338,6 +338,17 @@ void kvmi_destroy_vm(struct kvm *kvm)
 	wait_for_completion_killable(&kvm->kvmi_completed);
 }
 
+int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
+			       bool enable)
+{
+	if (enable)
+		set_bit(event_id, ikvm->vm_ev_mask);
+	else
+		clear_bit(event_id, ikvm->vm_ev_mask);
+
+	return 0;
+}
+
 int kvmi_ioctl_unhook(struct kvm *kvm, bool force_reset)
 {
 	struct kvmi *ikvm;
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 157f765fb34d..84ba43bd9a9d 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -85,6 +85,7 @@ struct kvmi {
 
 	DECLARE_BITMAP(cmd_allow_mask, KVMI_NUM_COMMANDS);
 	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
+	DECLARE_BITMAP(vm_ev_mask, KVMI_NUM_EVENTS);
 
 	bool cmd_reply_disabled;
 };
@@ -99,5 +100,7 @@ bool kvmi_msg_process(struct kvmi *ikvm);
 void *kvmi_msg_alloc(void);
 void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
+int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
+			       bool enable);
 
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index cf8a120b0eae..a55c9e35be36 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -12,6 +12,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
+	[KVMI_CONTROL_VM_EVENTS]     = "KVMI_CONTROL_VM_EVENTS",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
@@ -226,6 +227,27 @@ static int handle_get_guest_info(struct kvmi *ikvm,
 	return kvmi_msg_vm_maybe_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
 }
 
+static int handle_control_vm_events(struct kvmi *ikvm,
+				    const struct kvmi_msg_hdr *msg,
+				    const void *_req)
+{
+	const unsigned long known_events = KVMI_KNOWN_VM_EVENTS;
+	const struct kvmi_control_vm_events *req = _req;
+	int ec;
+
+	if (req->padding1 || req->padding2)
+		ec = -KVM_EINVAL;
+	else if (!test_bit(req->event_id, &known_events))
+		ec = -KVM_EINVAL;
+	else if (!is_event_allowed(ikvm, req->event_id))
+		ec = -KVM_EPERM;
+	else
+		ec = kvmi_cmd_control_vm_events(ikvm, req->event_id,
+						req->enable);
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
 static int handle_control_cmd_response(struct kvmi *ikvm,
 					const struct kvmi_msg_hdr *msg,
 					const void *_req)
@@ -259,6 +281,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_CHECK_COMMAND]         = handle_check_command,
 	[KVMI_CHECK_EVENT]           = handle_check_event,
 	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
+	[KVMI_CONTROL_VM_EVENTS]     = handle_control_vm_events,
 	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };

