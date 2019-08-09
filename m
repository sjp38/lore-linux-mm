Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1434FC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF0E92089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0E92089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6ED56B000E; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31086B000D; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9E06B0266; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E92706B000D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 21so1448256wmj.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5ej265kFxOPzM8Q/7TbuGm4q/UWbLN48p6d9XnuhRkY=;
        b=VubpJCETtUJXHXJwUpReYG3SVVaW6w/mLnj5YI+1Z/cGAZpDmsnhiXiQaL39JU1po1
         cmpNo3hqaNP9Pe+MO1sHQQjfFeUGiwdtMkFClPKpZbO8UstYdSvefaFtWx3K/t5wZlp1
         KqRhUlpUKrwiHEhrNdH40/WcOWcFHb6SDX2Pg1VpiMUFTWtL/4H274CqI3te+xa4Hhuy
         +16zP0qkyBc6PQLoZxPY5jdyUSwmCuUHCh9V8NY1T9JHv4gj5xNAgVG4RuZOgkHISSqS
         75I7tJObXB22fMzRHBAR21UWw9XaZ8iiVsI03xuluNQKMbJG1fxUkawwQ0WsNZjc4WMY
         c1Pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW2G6jgcAVPmuO8PpIRwyENzI9Tmu0awNOf/CKawNkEiEqTLqYy
	P0MmCGm2YrssR2lz4xiiyUzRdcQrjWbYVUSglbPU+OPLDSftIPSkGTh9cG3Eovii++B3hmkfEBL
	8QZc0HGN/xw8lzRFRkL2xrkBRlKggQfa5BjgueCYhkg7OqdvfkT0BIG1mD53rJ0GlBA==
X-Received: by 2002:a1c:8185:: with SMTP id c127mr11747396wmd.126.1565366456482;
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2PqQ4aBL2lmJNUIeFKfGaHVwLGfL2z9nLLHHNZy9YOGL4Npp0jlfG/9iirusMnqs7saeT
X-Received: by 2002:a1c:8185:: with SMTP id c127mr11747301wmd.126.1565366455243;
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366455; cv=none;
        d=google.com; s=arc-20160816;
        b=0rKhn6LyPpWgZ1VEPikRJeQLmoadH47WO/Uk+/navADaIr/MPa7LDAcf5JVJyqz4EX
         nVMNRUFq5f5FcbBMrJlY/POEXkWGhMg4cJZFm8Yr2cwalRBJ9ArfjgY2iEe6TYlAbReE
         Mt0ZFcWOcKsmaw2VAL8D1S/qinVbSIpiW1A8rhg13kOybwYxj9vW5Z7i5DNATTWsIsiU
         B/rXvloAh9lXxfMLcDvZZ/3qDTn/G5LNErCTZ0ellb+PqHV5pTtbiVVwuaHsEDUw7P+f
         CY5TrfYKwc00iDxBArk5s86rfGJqGktFGokYDEATRIkTBXww7yaQC6Myi9Ei80JQuyZR
         Q5uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5ej265kFxOPzM8Q/7TbuGm4q/UWbLN48p6d9XnuhRkY=;
        b=hwDBFrr79tWPRx9AdgGFI0FSadib3EC5c2HYepls1pvLU8H3qdADAYKf3lkpxBNNKE
         bB8n8Kl/LglnKv1+wNq3jeYAkeKi2eKsgjSwQhAhqFRdKpV210TD+fq6yPOWnWCKne02
         5RPnMqLAxaNycfYblG34Nc1hzGRbYH9tv/SCmi1JpNhsHljs/mfRcigyIizoAN+WKzvo
         90inAbIZmco2IATvx6Sff7uiLiCztCAxQ0FjYcUOgGW5l6XbqtJZvzpcgcPAAuofAwap
         IuJKBa9VqJ17JWgr126Jt9sTK1B07b2cX0doRHP5lM0uuZ2HlrvqKuLEBLouZ/UBtEZR
         f4Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id v17si8013050wro.188.2019.08.09.09.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id A06B1301AB49;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 5C80F305B7A3;
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
Subject: [RFC PATCH v6 08/92] kvm: introspection: add KVMI_CHECK_COMMAND and KVMI_CHECK_EVENT
Date: Fri,  9 Aug 2019 18:59:23 +0300
Message-Id: <20190809160047.8319-9-alazar@bitdefender.com>
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

These commands can be used by the introspection tool to check what
introspection commands and events are supported (by KVMi) and allowed
(by userspace/QEMU).

The introspection tool will get one of the following error codes:
  * -KVM_EOPNOTSUPP (unsupported command/event)
  * -KVM_PERM (disallowed command/event)
  * -KVM_EINVAL (the padding space, used for future extensions,
                 is not zero)
  * 0 (the command/event is supported and allowed)

These commands can be seen as an alternative method to KVMI_GET_VERSION
in checking if the introspection supports a specific command/event.

As with the KVMI_GET_VERSION command, these commands can never be
disallowed by userspace/QEMU.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 60 ++++++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          | 12 ++++++
 virt/kvm/kvmi.c                    |  8 +++-
 virt/kvm/kvmi_msg.c                | 38 +++++++++++++++++++
 4 files changed, 117 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 82de474d512b..61cf69aa5d07 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -302,3 +302,63 @@ While the command reply is disabled:
 * the reply status is ignored for any unsupported/unknown or disallowed
   commands (and ``struct kvmi_error_code`` will be sent with -KVM_EOPNOTSUPP
   or -KVM_PERM).
+
+3. KVMI_CHECK_COMMAND
+---------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_check_command {
+		__u16 id;
+		__u16 padding1;
+		__u32 padding2;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+
+Checks if the command specified by ``id`` is allowed.
+
+This command is always allowed.
+
+:Errors:
+
+* -KVM_PERM - the command specified by ``id`` is disallowed
+* -KVM_EINVAL - padding is not zero
+
+4. KVMI_CHECK_EVENT
+-------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_check_event {
+		__u16 id;
+		__u16 padding1;
+		__u32 padding2;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+
+Checks if the event specified by ``id`` is allowed.
+
+This command is always allowed.
+
+:Errors:
+
+* -KVM_PERM - the event specified by ``id`` is disallowed
+* -KVM_EINVAL - padding is not zero
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index a1ab39c5b8e0..7390303371c9 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -90,4 +90,16 @@ struct kvmi_control_cmd_response {
 	__u32 padding2;
 };
 
+struct kvmi_check_command {
+	__u16 id;
+	__u16 padding1;
+	__u32 padding2;
+};
+
+struct kvmi_check_event {
+	__u16 id;
+	__u16 padding1;
+	__u32 padding2;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index d5b6af21564e..dc1bb8326763 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -69,6 +69,8 @@ static bool alloc_kvmi(struct kvm *kvm, const struct kvm_introspection *qemu)
 		return false;
 
 	set_bit(KVMI_GET_VERSION, ikvm->cmd_allow_mask);
+	set_bit(KVMI_CHECK_COMMAND, ikvm->cmd_allow_mask);
+	set_bit(KVMI_CHECK_EVENT, ikvm->cmd_allow_mask);
 
 	memcpy(&ikvm->uuid, &qemu->uuid, sizeof(ikvm->uuid));
 
@@ -295,10 +297,14 @@ int kvmi_ioctl_command(struct kvm *kvm, void __user *argp)
 	if (!allow) {
 		DECLARE_BITMAP(always_allowed, KVMI_NUM_COMMANDS);
 
-		if (id == KVMI_GET_VERSION)
+		if (id == KVMI_GET_VERSION
+				|| id == KVMI_CHECK_COMMAND
+				|| id == KVMI_CHECK_EVENT)
 			return -EPERM;
 
 		set_bit(KVMI_GET_VERSION, always_allowed);
+		set_bit(KVMI_CHECK_COMMAND, always_allowed);
+		set_bit(KVMI_CHECK_EVENT, always_allowed);
 
 		bitmap_andnot(requested, requested, always_allowed,
 			      KVMI_NUM_COMMANDS);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 2237a6ed25f6..e24996611e3a 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -9,6 +9,8 @@
 #include "kvmi_int.h"
 
 static const char *const msg_IDs[] = {
+	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
+	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
@@ -177,6 +179,40 @@ static bool is_command_allowed(struct kvmi *ikvm, int id)
 	return test_bit(id, ikvm->cmd_allow_mask);
 }
 
+static int handle_check_command(struct kvmi *ikvm,
+				const struct kvmi_msg_hdr *msg,
+				const void *_req)
+{
+	const struct kvmi_check_command *req = _req;
+	int ec = 0;
+
+	if (req->padding1 || req->padding2)
+		ec = -KVM_EINVAL;
+	else if (!is_command_allowed(ikvm, req->id))
+		ec = -KVM_EPERM;
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
+static bool is_event_allowed(struct kvmi *ikvm, int id)
+{
+	return test_bit(id, ikvm->event_allow_mask);
+}
+
+static int handle_check_event(struct kvmi *ikvm,
+			      const struct kvmi_msg_hdr *msg, const void *_req)
+{
+	const struct kvmi_check_event *req = _req;
+	int ec = 0;
+
+	if (req->padding1 || req->padding2)
+		ec = -KVM_EINVAL;
+	else if (!is_event_allowed(ikvm, req->id))
+		ec = -KVM_EPERM;
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
 static int handle_control_cmd_response(struct kvmi *ikvm,
 					const struct kvmi_msg_hdr *msg,
 					const void *_req)
@@ -207,6 +243,8 @@ static int handle_control_cmd_response(struct kvmi *ikvm,
  */
 static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 			    const void *) = {
+	[KVMI_CHECK_COMMAND]         = handle_check_command,
+	[KVMI_CHECK_EVENT]           = handle_check_event,
 	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };

