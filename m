Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FDF5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:00:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 364C92089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:00:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 364C92089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726CB6B000A; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 660916B000C; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52D9A6B000E; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6A086B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:55 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v7so46845420wrt.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G6omFgr3glRrqnOiyFZ0Kr0FkKY7plvNBaSQRFGxKaE=;
        b=YQbqmcqlky1non+Isnlfa5uDky0/fE+lcu9HSSkvZNWFGwejYW4oNx7KBUygnIBAwM
         bWbAJEMTGWxjUf9Af9Q3lqhf5Wq9dt/xEEsSbdJYu+6/0w4WjHglsmZJ2M8X9WWmpBXk
         hOkgpa0d0fUeNV4F4yBT+fjK468h5CN/0gf6WDyth44HZi95JDQ/moRiyVxeFDxX/pqU
         SfDUBHhCZzTysY5uT6PqTx1olLZ+fIGLOMRF+4GFr95f2McMVhDqJue3Htk9XnufItJL
         HTjYJ93JYnHs0Wlw/id76sEj39ACcmi5y6whDAmQ1piF6m0DVUoeSwZ7TVd4vpiYEuEP
         QUtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVRlFEwmZBY3IiGpjkhOZIsberaA6w4rfRRyC1iPTCiOHrPkXJE
	tChysnuqSB2I5zS5ipddIC8qtjKnYP0qoZ4NxucQjiF/S1HprnV85tdB5hYh9KGLjrVpACy8HGB
	GLh9vteMvXblz3i2rh3xOsddEgYj9kEdefq1in2th9tbWGrawKKeTKN/fDrbqCFoLBQ==
X-Received: by 2002:adf:fe4f:: with SMTP id m15mr24721819wrs.36.1565366455392;
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIxysptf82D9v6ojWahB847bm8zrQsihKwu3MQ/bKXVcH+B8CrUghhE0WULGkzoSud7jFy
X-Received: by 2002:adf:fe4f:: with SMTP id m15mr24721685wrs.36.1565366453916;
        Fri, 09 Aug 2019 09:00:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366453; cv=none;
        d=google.com; s=arc-20160816;
        b=TfEfx9t91OAHIaWFQGk9Syi3qNHenHQF6W+GUD1XbKTv25KnjliScCCR3FAsB01Xsz
         3LTPNeuzmJN+bf/lZrm/o+0Rt0Lmor01LNo+MfKYCkSUU0KVH4GZQjyd+jmlEaN95qgk
         xGijffAfpQrHB1f7vBKAEaoj9rzUxg1FO1oe51K+nXxyJ7wt3CEyj4SAh24f5q2LGgPy
         zDX71ln8taeun/bi09iuj7AtccXlQU4hn2sJ50wAZqvvG710Sb0J+ChXqNEhSlY2yrV5
         vsZ+F6yixf+bYuyJNVywtSLtDSEaDHgNnyQSw3GWT2mMjnVLcRB3Ei7Btu1xT00evWdn
         OStA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=G6omFgr3glRrqnOiyFZ0Kr0FkKY7plvNBaSQRFGxKaE=;
        b=VW1yoHeLGHyHSCYmjj+GKmf/0kvsqNKPL4Oo4iQPd5gqQoXW15LH5l+LJMARyZeYc8
         nL4nGQeIVL5WCPTkN2mRNsX0fkn9pf0JhQ3+PmlOXQfgzskY53ubmViWwT64F3dO4gGh
         LgZPKy9+haasdFS+ijvzhmhpW+F3Tby48eRBt5gC+Vnb47T8ly8JXKXh23dpZfUym8IK
         hs8OAjmOCpDVBkpEwRhp8lHYM5AAnogWm+oT9SIYDJBGp6r6qldj4k9xTevAx68H/Ulu
         kv4FqzzwrGuFFLtHAG4jtLvkTk9Uqxbdz/D2y2XmySN6xUniUJRnizv++U6sPWy2GJc0
         JwTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id v19si70860798wrd.29.2019.08.09.09.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 42DA8305D3CF;
	Fri,  9 Aug 2019 19:00:53 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id EF259305B7A1;
	Fri,  9 Aug 2019 19:00:52 +0300 (EEST)
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
Subject: [RFC PATCH v6 03/92] kvm: introspection: add permission access ioctls
Date: Fri,  9 Aug 2019 18:59:18 +0300
Message-Id: <20190809160047.8319-4-alazar@bitdefender.com>
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

KVM_INTROSPECTION_COMMAND and KVM_INTROSPECTION_EVENTS should be used
by userspace/QEMU to allow access to specific (or all) introspection
commands and events.

By default, all introspection events and almost all introspection commands
are disallowed. There are a couple of commands that are always allowed
(those querying the introspection capabilities).

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/api.txt | 56 +++++++++++++++++++-
 include/uapi/linux/kvm.h          |  6 +++
 virt/kvm/kvm_main.c               |  6 +++
 virt/kvm/kvmi.c                   | 85 +++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h               | 51 +++++++++++++++++++
 5 files changed, 203 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/api.txt b/Documentation/virtual/kvm/api.txt
index 28d4429f9ae9..ea3135d365c7 100644
--- a/Documentation/virtual/kvm/api.txt
+++ b/Documentation/virtual/kvm/api.txt
@@ -3889,7 +3889,61 @@ It will fail with -EINVAL if padding is not zero.
 The KVMI version can be retrieved using the KVM_CAP_INTROSPECTION of
 the KVM_CHECK_EXTENSION ioctl() at run-time.
 
-4.997 KVM_INTROSPECTION_UNHOOK
+4.997 KVM_INTROSPECTION_COMMAND
+
+Capability: KVM_CAP_INTROSPECTION
+Architectures: x86
+Type: vm ioctl
+Parameters: struct kvm_introspection_feature (in)
+Returns: 0 on success, a negative value on error
+
+This ioctl is used to allow or disallow introspection commands
+for the current VM. By default, almost all commands are disallowed
+except for those used to query the API.
+
+struct kvm_introspection_feature {
+	__u32 allow;
+	__s32 id;
+};
+
+If allow is 1, the command specified by id is allowed. If allow is 0,
+the command is disallowed.
+
+Unless set to -1 (meaning all commands), id must be a command ID
+(e.g. KVMI_GET_VERSION, KVMI_GET_GUEST_INFO etc.)
+
+Errors:
+
+  -EINVAL if the command is unknown
+  -EPERM if the command can't be disallowed (e.g. KVMI_GET_VERSION)
+
+4.998 KVM_INTROSPECTION_EVENT
+
+Capability: KVM_CAP_INTROSPECTION
+Architectures: x86
+Type: vm ioctl
+Parameters: struct kvm_introspection_feature (in)
+Returns: 0 on success, a negative value on error
+
+This ioctl is used to allow or disallow introspection events
+for the current VM. By default, all events are disallowed.
+
+struct kvm_introspection_feature {
+	__u32 allow;
+	__s32 id;
+};
+
+If allow is 1, the event specified by id is allowed. If allow is 0,
+the event is disallowed.
+
+Unless set to -1 (meaning all event), id must be a event ID
+(e.g. KVMI_EVENT_UNHOOK, KVMI_EVENT_CR, etc.)
+
+Errors:
+
+  -EINVAL if the event is unknown
+
+4.999 KVM_INTROSPECTION_UNHOOK
 
 Capability: KVM_CAP_INTROSPECTION
 Architectures: x86
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index bae37bf37338..2ff05fd123e3 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -1527,9 +1527,15 @@ struct kvm_introspection {
 	__u32 padding;
 	__u8 uuid[16];
 };
+struct kvm_introspection_feature {
+	__u32 allow;
+	__s32 id;
+};
 #define KVM_INTROSPECTION_HOOK    _IOW(KVMIO, 0xff, struct kvm_introspection)
 #define KVM_INTROSPECTION_UNHOOK  _IO(KVMIO, 0xfe)
 /* write true on force-reset, false otherwise */
+#define KVM_INTROSPECTION_COMMAND _IOW(KVMIO, 0xfd, struct kvm_introspection_feature)
+#define KVM_INTROSPECTION_EVENT   _IOW(KVMIO, 0xfc, struct kvm_introspection_feature)
 
 #define KVM_DEV_ASSIGN_ENABLE_IOMMU	(1 << 0)
 #define KVM_DEV_ASSIGN_PCI_2_3		(1 << 1)
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 09a930ac007d..8399b826f2d2 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3270,6 +3270,12 @@ static long kvm_vm_ioctl(struct file *filp,
 	case KVM_INTROSPECTION_HOOK:
 		r = kvmi_ioctl_hook(kvm, argp);
 		break;
+	case KVM_INTROSPECTION_COMMAND:
+		r = kvmi_ioctl_command(kvm, argp);
+		break;
+	case KVM_INTROSPECTION_EVENT:
+		r = kvmi_ioctl_event(kvm, argp);
+		break;
 	case KVM_INTROSPECTION_UNHOOK:
 		r = kvmi_ioctl_unhook(kvm, arg);
 		break;
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 591f6ee22135..dc64f975998f 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -169,6 +169,91 @@ int kvmi_ioctl_hook(struct kvm *kvm, void __user *argp)
 	return kvmi_hook(kvm, &i);
 }
 
+static int kvmi_ioctl_get_feature(void __user *argp, bool *allow, int *id,
+				  unsigned long *bitmask)
+{
+	struct kvm_introspection_feature feat;
+	int all_bits = -1;
+
+	if (copy_from_user(&feat, argp, sizeof(feat)))
+		return -EFAULT;
+
+	if (feat.id < 0 && feat.id != all_bits)
+		return -EINVAL;
+
+	*allow = !!(feat.allow & 1);
+	*id = feat.id;
+	*bitmask = *id == all_bits ? -1 : BIT(feat.id);
+
+	return 0;
+}
+
+static int kvmi_ioctl_feature(struct kvm *kvm,
+			      bool allow, unsigned long *requested,
+			      size_t off_dest, unsigned int nbits)
+{
+	unsigned long *dest;
+	struct kvmi *ikvm;
+
+	if (bitmap_empty(requested, nbits))
+		return -EINVAL;
+
+	ikvm = kvmi_get(kvm);
+	if (!ikvm)
+		return -EFAULT;
+
+	dest = (unsigned long *)((char *)ikvm + off_dest);
+
+	if (allow)
+		bitmap_or(dest, dest, requested, nbits);
+	else
+		bitmap_andnot(dest, dest, requested, nbits);
+
+	kvmi_put(kvm);
+
+	return 0;
+}
+
+int kvmi_ioctl_event(struct kvm *kvm, void __user *argp)
+{
+	DECLARE_BITMAP(requested, KVMI_NUM_EVENTS);
+	DECLARE_BITMAP(known, KVMI_NUM_EVENTS);
+	bool allow;
+	int err;
+	int id;
+
+	err = kvmi_ioctl_get_feature(argp, &allow, &id, requested);
+	if (err)
+		return err;
+
+	bitmap_from_u64(known, KVMI_KNOWN_EVENTS);
+	bitmap_and(requested, requested, known, KVMI_NUM_EVENTS);
+
+	return kvmi_ioctl_feature(kvm, allow, requested,
+				  offsetof(struct kvmi, event_allow_mask),
+				  KVMI_NUM_EVENTS);
+}
+
+int kvmi_ioctl_command(struct kvm *kvm, void __user *argp)
+{
+	DECLARE_BITMAP(requested, KVMI_NUM_COMMANDS);
+	DECLARE_BITMAP(known, KVMI_NUM_COMMANDS);
+	bool allow;
+	int err;
+	int id;
+
+	err = kvmi_ioctl_get_feature(argp, &allow, &id, requested);
+	if (err)
+		return err;
+
+	bitmap_from_u64(known, KVMI_KNOWN_COMMANDS);
+	bitmap_and(requested, requested, known, KVMI_NUM_COMMANDS);
+
+	return kvmi_ioctl_feature(kvm, allow, requested,
+				  offsetof(struct kvmi, cmd_allow_mask),
+				  KVMI_NUM_COMMANDS);
+}
+
 void kvmi_create_vm(struct kvm *kvm)
 {
 	init_completion(&kvm->kvmi_completed);
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 9bc5205c8714..bd8b539e917a 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -23,6 +23,54 @@
 #define kvmi_err(ikvm, fmt, ...) \
 	kvm_info("%pU ERROR: " fmt, &ikvm->uuid, ## __VA_ARGS__)
 
+#define KVMI_KNOWN_VCPU_EVENTS ( \
+		BIT(KVMI_EVENT_CR) | \
+		BIT(KVMI_EVENT_MSR) | \
+		BIT(KVMI_EVENT_XSETBV) | \
+		BIT(KVMI_EVENT_BREAKPOINT) | \
+		BIT(KVMI_EVENT_HYPERCALL) | \
+		BIT(KVMI_EVENT_PF) | \
+		BIT(KVMI_EVENT_TRAP) | \
+		BIT(KVMI_EVENT_DESCRIPTOR) | \
+		BIT(KVMI_EVENT_PAUSE_VCPU) | \
+		BIT(KVMI_EVENT_SINGLESTEP))
+
+#define KVMI_KNOWN_VM_EVENTS ( \
+		BIT(KVMI_EVENT_CREATE_VCPU) | \
+		BIT(KVMI_EVENT_UNHOOK))
+
+#define KVMI_KNOWN_EVENTS (KVMI_KNOWN_VCPU_EVENTS | KVMI_KNOWN_VM_EVENTS)
+
+#define KVMI_KNOWN_COMMANDS ( \
+		BIT(KVMI_GET_VERSION) | \
+		BIT(KVMI_CHECK_COMMAND) | \
+		BIT(KVMI_CHECK_EVENT) | \
+		BIT(KVMI_GET_GUEST_INFO) | \
+		BIT(KVMI_PAUSE_VCPU) | \
+		BIT(KVMI_CONTROL_VM_EVENTS) | \
+		BIT(KVMI_CONTROL_EVENTS) | \
+		BIT(KVMI_CONTROL_CR) | \
+		BIT(KVMI_CONTROL_MSR) | \
+		BIT(KVMI_CONTROL_VE) | \
+		BIT(KVMI_GET_REGISTERS) | \
+		BIT(KVMI_SET_REGISTERS) | \
+		BIT(KVMI_GET_CPUID) | \
+		BIT(KVMI_GET_XSAVE) | \
+		BIT(KVMI_READ_PHYSICAL) | \
+		BIT(KVMI_WRITE_PHYSICAL) | \
+		BIT(KVMI_INJECT_EXCEPTION) | \
+		BIT(KVMI_GET_PAGE_ACCESS) | \
+		BIT(KVMI_SET_PAGE_ACCESS) | \
+		BIT(KVMI_GET_MAP_TOKEN) | \
+		BIT(KVMI_CONTROL_SPP) | \
+		BIT(KVMI_GET_PAGE_WRITE_BITMAP) | \
+		BIT(KVMI_SET_PAGE_WRITE_BITMAP) | \
+		BIT(KVMI_GET_MTRR_TYPE) | \
+		BIT(KVMI_CONTROL_CMD_RESPONSE) | \
+		BIT(KVMI_GET_VCPU_INFO))
+
+#define KVMI_NUM_COMMANDS KVMI_NEXT_AVAILABLE_COMMAND
+
 #define IKVM(kvm) ((struct kvmi *)((kvm)->kvmi))
 
 struct kvmi {
@@ -32,6 +80,9 @@ struct kvmi {
 	struct task_struct *recv;
 
 	uuid_t uuid;
+
+	DECLARE_BITMAP(cmd_allow_mask, KVMI_NUM_COMMANDS);
+	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
 };
 
 /* kvmi_msg.c */

