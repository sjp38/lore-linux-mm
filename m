Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4DCAC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D2C12089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D2C12089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CE4C6B026B; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E3516B0269; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D91D86B0266; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B91E6B000E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4so47049616wrt.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b/kWZryj4Y6/QSPt+L5uVDY14gBUQOsrJvy73sCGukQ=;
        b=sttFT+gUuwyh0drbPlX3ZvLwDKx0yF+6IIzcpioN/wjDh46m7WRKXJnFNyBgOuNEZI
         jmXmAJJC5wVcGol8uy8Shvk970PSzoSZVORGxmJhAcDU+Ou/H1ZW9CXXSsf/TVGd8iJN
         rVdZptubRlgI2KAMUWl8JcDS7xIUJ1+8SKrSjX/cEPIGfpI6H4ao9/Yd90VQJ9H8y0f7
         q/05FyetH0IpQx67nqZEY27jI14BrzyPA9tfJCK1qQTsunSQFtBTg41op+6UsA1zzWTF
         mo6+wLUdmNFKoHw/Bwb5g7vi8QMh4o7MX4IAOhtFJB9oyNV1z+YBqSX1gWjCyma5q0Pw
         qixQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWFIsO9Cql6bkTv7xJTkcVfaUWoMhu2PFDnx5f7rgsfXutLSU9K
	5e6HzCFKVxCm3UOkT720JHQ48d2E6NMeBJfQdW+mB+uOANJNeHom2FeTzqSJDIqUGpTmKkZdBSq
	jiZrRxR3CuW2EONW0dVQuypWPlTT1ncQyle0U1I/QajJbOSJV0Z6guYtJZkc5ItoAZg==
X-Received: by 2002:a5d:63c8:: with SMTP id c8mr26285934wrw.21.1565366456006;
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNtdq28LbKvE7wIeYMxCvpBQ91I9iylaueUyFl+xZdQ/8IbghBs6YEg3i+ffndMdCgnHkM
X-Received: by 2002:a5d:63c8:: with SMTP id c8mr26285793wrw.21.1565366454436;
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366454; cv=none;
        d=google.com; s=arc-20160816;
        b=juoChTVxW6cECyrKXc8E6Ui4Ky9jX7r4bux3RDPOK8GZFbCie6gF1yBENiwy7eP5Zz
         QOo9XlosOtToIhnBRbhgJzLhzQ6XvlOH7Irp6lrW1DoFBXc8Qf5EWB0SJemQwlQkk7zV
         kSugnba2C3t8lYCmiet88vwbwO+hl840hJ1Dm3F8jhjfu2qLK+gw5iED+TIg4qhq5Spt
         5eHT3V5FrtAmWAUH41cvySIOjc5qyiYPZCyyDYma5lUJxu/Xm3kVW/LTb2mylrFAKkBk
         feJvumHlHrGDhkSaii+nFMHY8VaKF7/gsq/n4Qa/qxvPrLjeSvRQnKmaM9GtoWnhHOZE
         zf3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=b/kWZryj4Y6/QSPt+L5uVDY14gBUQOsrJvy73sCGukQ=;
        b=v2WLyXS1Qhwbfp2nJE15o05XiK5RFcMm8PWgm0+4Xm/eeGrblVY5qz9vSkSAUUfQsY
         tuEzSLyXeaWagnBTmGLuk5uWgEF2+lcKhUe9yVYtWU8SG66QO+70lcHEld+rWvXOKco9
         gWI8HJ+1Ev3RXIVhxpxx28bcHocyLh/frtLZz7ey/vaqHgrunEqCmfoM1UnlNs41sDEX
         7dgXBG5ndK5PkJ+r4iawOsuSiiKrSQCqGrXZzEmTOvNwBY6HCxjidadgrnuQhvq4UW5U
         78iOG+7cEcAzUTk4EmJAtXplLI299j2ILVPZM4la9rmMKRBgmxVsbxnpg/PjAYwrOn8n
         XxnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id 1si94601162wrg.389.2019.08.09.09.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id C03DD301AB36;
	Fri,  9 Aug 2019 19:00:53 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 82DC0305B7A0;
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
Subject: [RFC PATCH v6 05/92] kvm: introspection: add KVMI_GET_VERSION
Date: Fri,  9 Aug 2019 18:59:20 +0300
Message-Id: <20190809160047.8319-6-alazar@bitdefender.com>
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

This command should be used by the introspection tool to identify the
commands/events supported by the KVMi subsystem and, most important,
what messages must be used for event replies. The kernel side will accept
smaller or bigger command messages, but it can be more strict with bigger
event reply messages.

The command is always allowed and any attempt from userspace to disallow it
through KVM_INTROSPECTION_COMMAND will get -EPERM (unless userspace choose
to disable all commands, using id=-1, in which case KVMI_GET_VERSION is
quietly allowed, without an error).

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 28 ++++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          |  5 +++++
 virt/kvm/kvmi.c                    | 14 ++++++++++++++
 virt/kvm/kvmi_msg.c                | 13 +++++++++++++
 4 files changed, 60 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 1d4a1dcd7d2f..0f296e3c4244 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -224,3 +224,31 @@ device-specific memory (DMA, emulated MMIO, reserved by a passthrough
 device etc.). It is up to the user to determine, using the guest operating
 system data structures, the areas that are safe to access (code, stack, heap
 etc.).
+
+Commands
+--------
+
+The following C structures are meant to be used directly when communicating
+over the wire. The peer that detects any size mismatch should simply close
+the connection and report the error.
+
+1. KVMI_GET_VERSION
+-------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters: none
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_version_reply {
+		__u32 version;
+		__u32 padding;
+	};
+
+Returns the introspection API version.
+
+This command is always allowed and successful (if the introspection is
+built in kernel).
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 6c7600ed4564..9574ba0b9565 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -78,4 +78,9 @@ struct kvmi_error_code {
 	__u32 padding;
 };
 
+struct kvmi_get_version_reply {
+	__u32 version;
+	__u32 padding;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index afa31748d7f4..d5b6af21564e 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -68,6 +68,8 @@ static bool alloc_kvmi(struct kvm *kvm, const struct kvm_introspection *qemu)
 	if (!ikvm)
 		return false;
 
+	set_bit(KVMI_GET_VERSION, ikvm->cmd_allow_mask);
+
 	memcpy(&ikvm->uuid, &qemu->uuid, sizeof(ikvm->uuid));
 
 	ikvm->kvm = kvm;
@@ -290,6 +292,18 @@ int kvmi_ioctl_command(struct kvm *kvm, void __user *argp)
 	bitmap_from_u64(known, KVMI_KNOWN_COMMANDS);
 	bitmap_and(requested, requested, known, KVMI_NUM_COMMANDS);
 
+	if (!allow) {
+		DECLARE_BITMAP(always_allowed, KVMI_NUM_COMMANDS);
+
+		if (id == KVMI_GET_VERSION)
+			return -EPERM;
+
+		set_bit(KVMI_GET_VERSION, always_allowed);
+
+		bitmap_andnot(requested, requested, always_allowed,
+			      KVMI_NUM_COMMANDS);
+	}
+
 	return kvmi_ioctl_feature(kvm, allow, requested,
 				  offsetof(struct kvmi, cmd_allow_mask),
 				  KVMI_NUM_COMMANDS);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index af6bc47dc031..6fe04de29f7e 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -9,6 +9,7 @@
 #include "kvmi_int.h"
 
 static const char *const msg_IDs[] = {
+	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
 
 static bool is_known_message(u16 id)
@@ -129,6 +130,17 @@ static int kvmi_msg_vm_reply(struct kvmi *ikvm,
 	return kvmi_msg_reply(ikvm, msg, err, rpl, rpl_size);
 }
 
+static int handle_get_version(struct kvmi *ikvm,
+			      const struct kvmi_msg_hdr *msg, const void *req)
+{
+	struct kvmi_get_version_reply rpl;
+
+	memset(&rpl, 0, sizeof(rpl));
+	rpl.version = KVMI_VERSION;
+
+	return kvmi_msg_vm_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
+}
+
 static bool is_command_allowed(struct kvmi *ikvm, int id)
 {
 	return test_bit(id, ikvm->cmd_allow_mask);
@@ -139,6 +151,7 @@ static bool is_command_allowed(struct kvmi *ikvm, int id)
  */
 static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 			    const void *) = {
+	[KVMI_GET_VERSION]           = handle_get_version,
 };
 
 static bool is_vm_message(u16 id)

