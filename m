Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 322F0C41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF4BF214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF4BF214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 266CD6B02DA; Fri,  9 Aug 2019 12:02:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21CE26B02DC; Fri,  9 Aug 2019 12:02:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE8E26B02DD; Fri,  9 Aug 2019 12:02:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F99A6B02DA
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:02:31 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v11so4025325wrg.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:02:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sjplyAM4BOjpyd8CZ8L+3sE7JvUagqycKa3bgiNu+gY=;
        b=s2E4OcnIKO3TZuun44em61YCxed9SI/HsVB5bg/X4e9lf9E0IXyWdMz8G74Wy18fCT
         u2Ix+Hwr96cc3bwYX8VY7oW1S4IlFWSPi3L3EkMCWw1kkkK4YijrhXbAe5dqLWPo+DIE
         bffmLYEhofDEsS7bo2PjXL2EREHiyaqowm+bLAFlDwRqLwd5BjurPDDAAveyiur1/erq
         ipzCQyjmGKLnFi3KLEVeKsR2lar5eBJC5U1zlcsfaM1eHJw832gVs6IZE5kZ1JYZz5X7
         JXwQfbj094I+aF4QgB2nTgryO3tIHOxjnr5jzDcVbl60iOncthDP3+EABMIBDdYajjq3
         HSHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW4q76LWSCfAIueSIuKSxaOHkzbj8SXguBmPILjuxaVI4yI1iwA
	HJzNF8jdvYckrzObEAkWzPeZR+VQnaDzfOeD2Qxnvx3Lk4j5eK84up9U62Td+j3xVr8Z0NN4GwJ
	TT8hrSngsDMLJ/m4p8xtXqkH9mD8JwUvRxlD96Wu2byIdtsE7X/cwmKwuzvnNndlZVQ==
X-Received: by 2002:a1c:61d4:: with SMTP id v203mr10559653wmb.164.1565366551107;
        Fri, 09 Aug 2019 09:02:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylL4YkVEIlAKvc+HOuv9n8RoMhBJY6gi4p3ybExaragocultwJWkQW9x+Y7i3s+bWPeGx3
X-Received: by 2002:a1c:61d4:: with SMTP id v203mr10550586wmb.164.1565366454243;
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366454; cv=none;
        d=google.com; s=arc-20160816;
        b=sR8m5545NWqFRP6n9z2yzvIIDrZ3A01yaHbgHpSM0MIzhI2Zo4Qh4hYzLsveaDJAMt
         nQ25s0FwfyDCnCxhpYyBvNSCZerMA7De2mKAOk3OkOVAy9/+9BMGIFF8AJvSJIrqCliJ
         lWCxmBRMkFA2uar4g0gdzd5Y6q2tjhEmR8sco3Tr8g4nw0Gck39vl1t7qzauB8PdICu3
         Ky5JD4hYKqjf7kiLsIIZJZUv1zh3yHpujh7NoORg2BNCQBpSQytjzVeXYDL8Z8WmQnVq
         Gu+bxtXzeZbJ5TvhmP7i4+xriAfSdg8FFT0022VJaLxQe7uoUqCAazBgcs7zbAjD0A8p
         9yUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sjplyAM4BOjpyd8CZ8L+3sE7JvUagqycKa3bgiNu+gY=;
        b=SG+yPsKePm/hB7Krhm/e0TsoF7EugJtygpCzCl2jhleIKYejaPe/08H0KGop/jAgOs
         ToqCn8qrGEdyqp5XhB/Fgn9T5ug/LJYuySmSIA9Tj3LkxdsLblr8JH1eX0tTE4opBZm6
         A6N3d4JOw61f4e2xA6dwD1HAyRvpwNh5h/kg94Ze0JUYiT2FhF0Sv4zNhPcS1HjaopwI
         3TaFJcJq7Ig4hVXQ/Qf6D04Uxk6MD00Kn6os++WqJxaxZ5YxNfviEBshOBzc+mRs8vUv
         nukQEnk2OvrWsRwzG6PKXMNyQmAJ4cQPOFRXo4kl+hZ8NnKnTcU9i561Z2NHFg7MIVvo
         AO1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id s133si4083379wme.79.2019.08.09.09.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 8379A301AB43;
	Fri,  9 Aug 2019 19:00:53 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 43B2A305B7A3;
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
Subject: [RFC PATCH v6 04/92] kvm: introspection: add the read/dispatch message function
Date: Fri,  9 Aug 2019 18:59:19 +0300
Message-Id: <20190809160047.8319-5-alazar@bitdefender.com>
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

Based on the common header used by all messages (struct kvmi_msg_hdr),
the worker will read/validate all messages, execute the VM introspection
commands (eg. KVMI_GET_GUEST_INFO) and dispatch to vCPUs the vCPU
introspection commands (eg. KVMI_GET_REGISTERS) and the replies to
vCPU events. The vCPU threads will reply to vCPU introspection commands
without the help of the receiving worker.

Because of the command header (struct kvmi_error_code) used in any
command reply, this worker could respond to any unsupported/disallowed
command with an error code.

This thread will end when the socket is closed (signaled by userspace/QEMU
or the introspection tool) or on the first API error (eg. wrong message
size).

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst |  86 +++++++++++
 include/uapi/linux/kvmi.h          |  13 ++
 virt/kvm/kvmi.c                    |  43 +++++-
 virt/kvm/kvmi_int.h                |   7 +
 virt/kvm/kvmi_msg.c                | 240 ++++++++++++++++++++++++++++-
 5 files changed, 386 insertions(+), 3 deletions(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 47b7c36d334a..1d4a1dcd7d2f 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -64,6 +64,85 @@ used on that guest. Obviously, whether the guest can really continue
 normal execution depends on whether the introspection tool has made any
 modifications that require an active KVMI channel.
 
+All messages (commands or events) have a common header::
+
+	struct kvmi_msg_hdr {
+		__u16 id;
+		__u16 size;
+		__u32 seq;
+	};
+
+The replies have the same header, with the sequence number (``seq``)
+and message id (``id``) matching the command/event.
+
+After ``kvmi_msg_hdr``, ``id`` specific data of ``size`` bytes will
+follow.
+
+The message header and its data must be sent with one ``sendmsg()`` call
+to the socket. This simplifies the receiver loop and avoids
+the reconstruction of messages on the other side.
+
+The wire protocol uses the host native byte-order. The introspection tool
+must check this during the handshake and do the necessary conversion.
+
+A command reply begins with::
+
+	struct kvmi_error_code {
+		__s32 err;
+		__u32 padding;
+	}
+
+followed by the command specific data if the error code ``err`` is zero.
+
+The error code -KVM_EOPNOTSUPP is returned for unsupported commands.
+
+The error code -KVM_EPERM is returned for disallowed commands (see **Hooking**).
+
+The error code is related to the message processing, including unsupported
+commands. For all the other errors (incomplete messages, wrong sequence
+numbers, socket errors etc.) the socket will be closed. The device
+manager should reconnect.
+
+While all commands will have a reply as soon as possible, the replies
+to events will probably be delayed until a set of (new) commands will
+complete::
+
+   Host kernel               Tool
+   -----------               ----
+   event 1 ->
+                             <- command 1
+   command 1 reply ->
+                             <- command 2
+   command 2 reply ->
+                             <- event 1 reply
+
+If both ends send a message at the same time::
+
+   Host kernel               Tool
+   -----------               ----
+   event X ->                <- command X
+
+the host kernel will reply to 'command X', regardless of the receive time
+(before or after the 'event X' was sent).
+
+As it can be seen below, the wire protocol specifies occasional padding. This
+is to permit working with the data by directly using C structures or to round
+the structure size to a multiple of 8 bytes (64bit) to improve the copy
+operations that happen during ``recvmsg()`` or ``sendmsg()``. The members
+should have the native alignment of the host (4 bytes on x86). All padding
+must be initialized with zero otherwise the respective commands will fail
+with -KVM_EINVAL.
+
+To describe the commands/events, we reuse some conventions from api.txt:
+
+  - Architectures: which instruction set architectures provide this command/event
+
+  - Versions: which versions provide this command/event
+
+  - Parameters: incoming message data
+
+  - Returns: outgoing/reply message data
+
 Handshake
 ---------
 
@@ -99,6 +178,13 @@ commands/events) to KVM, and forget about it. It will be notified by
 KVM when the introspection tool closes the file handle (in case of
 errors), and should reinitiate the handshake.
 
+Once the file handle reaches KVM, the introspection tool should use
+the *KVMI_GET_VERSION* command to get the API version and/or
+the *KVMI_CHECK_COMMAND* and *KVMI_CHECK_EVENTS* commands to see which
+commands/events are allowed for this guest. The error code -KVM_EPERM
+will be returned if the introspection tool uses a command or enables an
+event which is disallowed.
+
 Unhooking
 ---------
 
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index dbf63ad0862f..6c7600ed4564 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -65,4 +65,17 @@ enum {
 	KVMI_NUM_EVENTS
 };
 
+#define KVMI_MSG_SIZE (4096 - sizeof(struct kvmi_msg_hdr))
+
+struct kvmi_msg_hdr {
+	__u16 id;
+	__u16 size;
+	__u32 seq;
+};
+
+struct kvmi_error_code {
+	__s32 err;
+	__u32 padding;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index dc64f975998f..afa31748d7f4 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -10,13 +10,54 @@
 #include <linux/kthread.h>
 #include <linux/bitmap.h>
 
-int kvmi_init(void)
+static struct kmem_cache *msg_cache;
+
+void *kvmi_msg_alloc(void)
+{
+	return kmem_cache_zalloc(msg_cache, GFP_KERNEL);
+}
+
+void *kvmi_msg_alloc_check(size_t size)
+{
+	if (size > KVMI_MSG_SIZE_ALLOC)
+		return NULL;
+	return kvmi_msg_alloc();
+}
+
+void kvmi_msg_free(void *addr)
+{
+	if (addr)
+		kmem_cache_free(msg_cache, addr);
+}
+
+static void kvmi_cache_destroy(void)
 {
+	kmem_cache_destroy(msg_cache);
+	msg_cache = NULL;
+}
+
+static int kvmi_cache_create(void)
+{
+	msg_cache = kmem_cache_create("kvmi_msg", KVMI_MSG_SIZE_ALLOC,
+				      4096, SLAB_ACCOUNT, NULL);
+
+	if (!msg_cache) {
+		kvmi_cache_destroy();
+
+		return -1;
+	}
+
 	return 0;
 }
 
+int kvmi_init(void)
+{
+	return kvmi_cache_create();
+}
+
 void kvmi_uninit(void)
 {
+	kvmi_cache_destroy();
 }
 
 static bool alloc_kvmi(struct kvm *kvm, const struct kvm_introspection *qemu)
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index bd8b539e917a..76119a4b69d8 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -23,6 +23,8 @@
 #define kvmi_err(ikvm, fmt, ...) \
 	kvm_info("%pU ERROR: " fmt, &ikvm->uuid, ## __VA_ARGS__)
 
+#define KVMI_MSG_SIZE_ALLOC (sizeof(struct kvmi_msg_hdr) + KVMI_MSG_SIZE)
+
 #define KVMI_KNOWN_VCPU_EVENTS ( \
 		BIT(KVMI_EVENT_CR) | \
 		BIT(KVMI_EVENT_MSR) | \
@@ -91,4 +93,9 @@ void kvmi_sock_shutdown(struct kvmi *ikvm);
 void kvmi_sock_put(struct kvmi *ikvm);
 bool kvmi_msg_process(struct kvmi *ikvm);
 
+/* kvmi.c */
+void *kvmi_msg_alloc(void);
+void *kvmi_msg_alloc_check(size_t size);
+void kvmi_msg_free(void *addr);
+
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 4de012eafb6d..af6bc47dc031 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -8,6 +8,19 @@
 #include <linux/net.h>
 #include "kvmi_int.h"
 
+static const char *const msg_IDs[] = {
+};
+
+static bool is_known_message(u16 id)
+{
+	return id < ARRAY_SIZE(msg_IDs) && msg_IDs[id];
+}
+
+static const char *id2str(u16 id)
+{
+	return is_known_message(id) ? msg_IDs[id] : "unknown";
+}
+
 bool kvmi_sock_get(struct kvmi *ikvm, int fd)
 {
 	struct socket *sock;
@@ -35,8 +48,231 @@ void kvmi_sock_shutdown(struct kvmi *ikvm)
 	kernel_sock_shutdown(ikvm->sock, SHUT_RDWR);
 }
 
+static int kvmi_sock_read(struct kvmi *ikvm, void *buf, size_t size)
+{
+	struct kvec i = {
+		.iov_base = buf,
+		.iov_len = size,
+	};
+	struct msghdr m = { };
+	int rc;
+
+	rc = kernel_recvmsg(ikvm->sock, &m, &i, 1, size, MSG_WAITALL);
+
+	if (rc > 0)
+		print_hex_dump_debug("read: ", DUMP_PREFIX_NONE, 32, 1,
+					buf, rc, false);
+
+	if (unlikely(rc != size)) {
+		if (rc >= 0)
+			rc = -EPIPE;
+		else
+			kvmi_err(ikvm, "kernel_recvmsg: %d\n", rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+static int kvmi_sock_write(struct kvmi *ikvm, struct kvec *i, size_t n,
+			   size_t size)
+{
+	struct msghdr m = { };
+	int rc, k;
+
+	rc = kernel_sendmsg(ikvm->sock, &m, i, n, size);
+
+	if (rc > 0)
+		for (k = 0; k < n; k++)
+			print_hex_dump_debug("write: ", DUMP_PREFIX_NONE, 32, 1,
+					i[k].iov_base, i[k].iov_len, false);
+
+	if (unlikely(rc != size)) {
+		kvmi_err(ikvm, "kernel_sendmsg: %d\n", rc);
+		if (rc >= 0)
+			rc = -EPIPE;
+		return rc;
+	}
+
+	return 0;
+}
+
+static int kvmi_msg_reply(struct kvmi *ikvm,
+			  const struct kvmi_msg_hdr *msg, int err,
+			  const void *rpl, size_t rpl_size)
+{
+	struct kvmi_error_code ec;
+	struct kvmi_msg_hdr h;
+	struct kvec vec[3] = {
+		{ .iov_base = &h, .iov_len = sizeof(h) },
+		{ .iov_base = &ec, .iov_len = sizeof(ec) },
+		{ .iov_base = (void *)rpl, .iov_len = rpl_size },
+	};
+	size_t size = sizeof(h) + sizeof(ec) + (err ? 0 : rpl_size);
+	size_t n = err ? ARRAY_SIZE(vec) - 1 : ARRAY_SIZE(vec);
+
+	memset(&h, 0, sizeof(h));
+	h.id = msg->id;
+	h.seq = msg->seq;
+	h.size = size - sizeof(h);
+
+	memset(&ec, 0, sizeof(ec));
+	ec.err = err;
+
+	return kvmi_sock_write(ikvm, vec, n, size);
+}
+
+static int kvmi_msg_vm_reply(struct kvmi *ikvm,
+			     const struct kvmi_msg_hdr *msg, int err,
+			     const void *rpl, size_t rpl_size)
+{
+	return kvmi_msg_reply(ikvm, msg, err, rpl, rpl_size);
+}
+
+static bool is_command_allowed(struct kvmi *ikvm, int id)
+{
+	return test_bit(id, ikvm->cmd_allow_mask);
+}
+
+/*
+ * These commands are executed on the receiving thread/worker.
+ */
+static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
+			    const void *) = {
+};
+
+static bool is_vm_message(u16 id)
+{
+	return id < ARRAY_SIZE(msg_vm) && !!msg_vm[id];
+}
+
+static bool is_unsupported_message(u16 id)
+{
+	bool supported;
+
+	supported = is_known_message(id) && is_vm_message(id);
+
+	return !supported;
+}
+
+static int kvmi_consume_bytes(struct kvmi *ikvm, size_t bytes)
+{
+	size_t to_read;
+	u8 buf[1024];
+	int err = 0;
+
+	while (bytes && !err) {
+		to_read = min(bytes, sizeof(buf));
+
+		err = kvmi_sock_read(ikvm, buf, to_read);
+
+		bytes -= to_read;
+	}
+
+	return err;
+}
+
+static struct kvmi_msg_hdr *kvmi_msg_recv(struct kvmi *ikvm, bool *unsupported)
+{
+	struct kvmi_msg_hdr *msg;
+	int err;
+
+	*unsupported = false;
+
+	msg = kvmi_msg_alloc();
+	if (!msg)
+		goto out_err;
+
+	err = kvmi_sock_read(ikvm, msg, sizeof(*msg));
+	if (err)
+		goto out_err;
+
+	if (msg->size > KVMI_MSG_SIZE)
+		goto out_err_msg;
+
+	if (is_unsupported_message(msg->id)) {
+		if (msg->size && kvmi_consume_bytes(ikvm, msg->size) < 0)
+			goto out_err_msg;
+
+		*unsupported = true;
+		return msg;
+	}
+
+	if (msg->size && kvmi_sock_read(ikvm, msg + 1, msg->size) < 0)
+		goto out_err_msg;
+
+	return msg;
+
+out_err_msg:
+	kvmi_err(ikvm, "%s id %u (%s) size %u\n",
+		 __func__, msg->id, id2str(msg->id), msg->size);
+
+out_err:
+	kvmi_msg_free(msg);
+
+	return NULL;
+}
+
+static int kvmi_msg_dispatch_vm_cmd(struct kvmi *ikvm,
+				    const struct kvmi_msg_hdr *msg)
+{
+	return msg_vm[msg->id](ikvm, msg, msg + 1);
+}
+
+static int kvmi_msg_dispatch(struct kvmi *ikvm,
+			     struct kvmi_msg_hdr *msg, bool *queued)
+{
+	int err;
+
+	err = kvmi_msg_dispatch_vm_cmd(ikvm, msg);
+
+	if (err)
+		kvmi_err(ikvm, "%s: msg id: %u (%s), err: %d\n", __func__,
+			 msg->id, id2str(msg->id), err);
+
+	return err;
+}
+
+static bool is_message_allowed(struct kvmi *ikvm, __u16 id)
+{
+	if (id == KVMI_EVENT_REPLY)
+		return true;
+
+	/*
+	 * Some commands (eg.pause) request events that might be
+	 * disallowed. The command is allowed here, but the function
+	 * handling the command will return -KVM_EPERM if the event
+	 * is disallowed.
+	 */
+	return is_command_allowed(ikvm, id);
+}
+
 bool kvmi_msg_process(struct kvmi *ikvm)
 {
-	kvmi_info(ikvm, "TODO: %s", __func__);
-	return false;
+	struct kvmi_msg_hdr *msg;
+	bool queued = false;
+	bool unsupported;
+	int err = -1;
+
+	msg = kvmi_msg_recv(ikvm, &unsupported);
+	if (!msg)
+		goto out;
+
+	if (unsupported) {
+		err = kvmi_msg_vm_reply(ikvm, msg, -KVM_EOPNOTSUPP, NULL, 0);
+		goto out;
+	}
+
+	if (!is_message_allowed(ikvm, msg->id)) {
+		err = kvmi_msg_vm_reply(ikvm, msg, -KVM_EPERM, NULL, 0);
+		goto out;
+	}
+
+	err = kvmi_msg_dispatch(ikvm, msg, &queued);
+
+out:
+	if (!queued)
+		kvmi_msg_free(msg);
+
+	return err == 0;
 }

