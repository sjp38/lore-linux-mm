Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB8FC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E99E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E99E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5F0C6B000C; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAD156B0269; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80D376B0266; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8176B000D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u19so1066644wmj.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RaF6F7W1ahZpjcegiQ+z6Xfa2GK7HBnIqM0vUdkfy8A=;
        b=Tsqegtkrqtfgmpufn20L6OeqUJZ7xJmxfxUqWoxqmAARFtL0Q+j0OVIC1otfCA+k0d
         /wCc9c2uixuL9UAuMyKEgxxgT+egxqP09wpaROdZL7wdCSzAJ95OhlF+SldqTRwMRO4+
         FRrqpzZPqAZSHYDMM5IAI05BQnf6oWxxlMPSg5WF1ROXGWvvyBNuwkvRX+LlfHDoUyYe
         7jAe4pt7g3JL+d+ZlXJz0byrSBMOzLLUXYOHhOSWIFjzxuyOah+5TFg1tqxC2Dzio8Un
         JU0bzncWTPjK2C+XYMOk3cIwok2qnbQ7fEJ5t4TmrvEy3/j15RDPI2G/OBaQ3EC+wDZJ
         YHyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAU6AA8npL1oxijqKskvuNiI6mQqGIMHQzIlUjOpekfkz9pUUSzz
	LcmdYt4XmRiDeqL88z1f7c35ragKltEFnVBg8vkmSxadbxLiFuZ0AfgHT2EG0LyjjlAb3PIoiiS
	J70MqfC7hgylem0gnCCaB+zL3V63jKP58WulggJvFgn04y7G5tQZZvyiuKzpkW4HpEg==
X-Received: by 2002:a5d:460e:: with SMTP id t14mr755993wrq.171.1565366455698;
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfhbgoSmsVfj1WMQQ6oJntrhrrwdZQcH5TvuNqOEtS0L+S9uauC82WLKN4SVyFu9PHTOx1
X-Received: by 2002:a5d:460e:: with SMTP id t14mr755888wrq.171.1565366454668;
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366454; cv=none;
        d=google.com; s=arc-20160816;
        b=b5Ezcqw0xPMMWHd/b7SdxPJBnT1pmT942rTQ6ig90w3PIT9+MgIN1akV6lZXC/MxWP
         D4ReZydk5rjnRsb7aybqiWxdk0vC0d2QrWAHPEUnGbUSfmLWwZAtWPm77J69nm1S8ZNC
         8iQrKCsD0+dA4sXqcC8VzyAqqbdy1O9Wlpk64HOKYIj2bxgeLfHlZgq314609oPJ95dg
         rw0SNY95VHde41VDckaOTZJb7n8m/9GvYfMJOy7Vl25TePG+kdOt5YRDE4KOZIrJTPHm
         wlWIeqm98eZFegQi/xejhKLcG0lcP8kI8oYa+ibrWXE0MHN5LrLtc8YRyMdIa91qBi8O
         i8Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RaF6F7W1ahZpjcegiQ+z6Xfa2GK7HBnIqM0vUdkfy8A=;
        b=hSpuuQipHgs+WG1ks2LpDlcvutgN0J6bDzqpxpQpLphx3a3r0pZhMa2BUuETxS10Oy
         Z6frTqmYRwMQC05MVPpIwGpGSbTiNMYvAgfDakqTznahRhK5/SaCYl0slnWn9TxhRpv4
         6PSm4EdQGiRkeqGLWiVuUTgmyL89RdZG3ipVV8Z1NUYlT1UphZOrZTNgJsWw9+lu9Rlk
         ExhYp5RYy0EzTOHvwSenDYwUAyqM0vF+Hpst6WrH+cGUegUQUaW1bR7f2pPjpDnhhvj8
         8HQ0GojBFutZtSZG7t65orfdyZawWQSSiK2zHAeKABjYdtmqLmqFdw9DL77ip8MZEybk
         VgHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id w4si85104276wrn.31.2019.08.09.09.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 0D891301AB48;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id BFC3E305B7A4;
	Fri,  9 Aug 2019 19:00:53 +0300 (EEST)
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
Subject: [RFC PATCH v6 06/92] kvm: introspection: add KVMI_CONTROL_CMD_RESPONSE
Date: Fri,  9 Aug 2019 18:59:21 +0300
Message-Id: <20190809160047.8319-7-alazar@bitdefender.com>
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

This command enables/disables the command replies. It is useful when
the introspection tool send multiple messages with one write() call and
doesn't have to wait for a reply.

IIRC, the speed improvment seen during UnixBench tests in a VM
introspected through vsock (the introspection tool was running in a
different VM) was around 5-10%.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 50 ++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          |  7 ++++
 virt/kvm/kvmi_int.h                |  2 ++
 virt/kvm/kvmi_msg.c                | 57 ++++++++++++++++++++++++++++++
 4 files changed, 116 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 0f296e3c4244..82de474d512b 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -252,3 +252,53 @@ Returns the introspection API version.
 
 This command is always allowed and successful (if the introspection is
 built in kernel).
+
+2. KVMI_CONTROL_CMD_RESPONSE
+----------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_cmd_response {
+		__u8 enable;
+		__u8 now;
+		__u16 padding1;
+		__u32 padding2;
+	};
+
+:Returns:
+
+::
+	struct kvmi_error_code
+
+Enables or disables the command replies. By default, all commands need
+a reply.
+
+If `now` is 1, the command reply is enabled/disabled (according to
+`enable`) starting with the current command. For example, `enable=0`
+and `now=1` means that the reply is disabled for this command too,
+while `enable=0` and `now=0` means that a reply will be send for this
+command, but not for the next ones (until enabled back with another
+*KVMI_CONTROL_CMD_RESPONSE*).
+
+This command is used by the introspection tool to disable the replies
+for commands returning an error code only (eg. *KVMI_SET_REGISTERS*)
+when an error is less likely to happen. For example, the following
+commands can be used to reply to an event with a single `write()` call:
+
+	KVMI_CONTROL_CMD_RESPONSE enable=0 now=1
+	KVMI_SET_REGISTERS vcpu=N
+	KVMI_EVENT_REPLY   vcpu=N
+	KVMI_CONTROL_CMD_RESPONSE enable=1 now=0
+
+While the command reply is disabled:
+
+* the socket will be closed on any command for which the reply should
+  contain more than just an error code (eg. *KVMI_GET_REGISTERS*)
+
+* the reply status is ignored for any unsupported/unknown or disallowed
+  commands (and ``struct kvmi_error_code`` will be sent with -KVM_EOPNOTSUPP
+  or -KVM_PERM).
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 9574ba0b9565..a1ab39c5b8e0 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -83,4 +83,11 @@ struct kvmi_get_version_reply {
 	__u32 padding;
 };
 
+struct kvmi_control_cmd_response {
+	__u8 enable;
+	__u8 now;
+	__u16 padding1;
+	__u32 padding2;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 76119a4b69d8..157f765fb34d 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -85,6 +85,8 @@ struct kvmi {
 
 	DECLARE_BITMAP(cmd_allow_mask, KVMI_NUM_COMMANDS);
 	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
+
+	bool cmd_reply_disabled;
 };
 
 /* kvmi_msg.c */
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 6fe04de29f7e..ea5c7e23669a 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -9,6 +9,7 @@
 #include "kvmi_int.h"
 
 static const char *const msg_IDs[] = {
+	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
 
@@ -130,6 +131,36 @@ static int kvmi_msg_vm_reply(struct kvmi *ikvm,
 	return kvmi_msg_reply(ikvm, msg, err, rpl, rpl_size);
 }
 
+static bool kvmi_validate_no_reply(struct kvmi *ikvm,
+				   const struct kvmi_msg_hdr *msg,
+				   size_t rpl_size, int err)
+{
+	if (rpl_size) {
+		kvmi_err(ikvm, "Reply disabled for command %d", msg->id);
+		return false;
+	}
+
+	if (err)
+		kvmi_warn(ikvm, "Error code %d discarded for message id %d\n",
+			  err, msg->id);
+
+	return true;
+}
+
+static int kvmi_msg_vm_maybe_reply(struct kvmi *ikvm,
+				   const struct kvmi_msg_hdr *msg,
+				   int err, const void *rpl,
+				   size_t rpl_size)
+{
+	if (ikvm->cmd_reply_disabled) {
+		if (!kvmi_validate_no_reply(ikvm, msg, rpl_size, err))
+			return -KVM_EINVAL;
+		return 0;
+	}
+
+	return kvmi_msg_vm_reply(ikvm, msg, err, rpl, rpl_size);
+}
+
 static int handle_get_version(struct kvmi *ikvm,
 			      const struct kvmi_msg_hdr *msg, const void *req)
 {
@@ -146,11 +177,37 @@ static bool is_command_allowed(struct kvmi *ikvm, int id)
 	return test_bit(id, ikvm->cmd_allow_mask);
 }
 
+static int handle_control_cmd_response(struct kvmi *ikvm,
+					const struct kvmi_msg_hdr *msg,
+					const void *_req)
+{
+	const struct kvmi_control_cmd_response *req = _req;
+	bool disabled, now;
+	int err;
+
+	if (req->padding1 || req->padding2)
+		return -KVM_EINVAL;
+
+	disabled = !req->enable;
+	now = (req->now == 1);
+
+	if (now)
+		ikvm->cmd_reply_disabled = disabled;
+
+	err = kvmi_msg_vm_maybe_reply(ikvm, msg, 0, NULL, 0);
+
+	if (!now)
+		ikvm->cmd_reply_disabled = disabled;
+
+	return err;
+}
+
 /*
  * These commands are executed on the receiving thread/worker.
  */
 static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 			    const void *) = {
+	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };
 

