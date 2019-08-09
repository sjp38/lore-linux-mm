Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEC5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32CE82089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32CE82089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19966B0271; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACF866B0273; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80C6B6B0271; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B42E6B026D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q9so5428737wrc.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MJrx9QFUdbiG1zFQ5CnTIj/yz5ZyansMDWH1Z1DeBN0=;
        b=ccxjN1fUgorQyvZtY+c43A3xH22H+xYxRMZDinnWIXR24DYRL3aIE58lXy6EWDJvvU
         TeqCuWRcyiJqJCehFh5ccI3mvkazzccd7cfwMkeq1syqNodkdR69Tfgr2QZCux4VXihX
         irzrU23TlVvWPooMsvYlxhnk51E78cfKI/jd3o3+HjxmDEv7X4kM0acrQTY3JTgXrwPh
         ouULkvDXezF2EsoC/jmjdUX0WYIc2uRQquFgX5qPTMQu5ohDPY5Tzwo41bxTgZ+ENWrp
         t2Dg6OmhCg3dolAGvuERYykW/vcNOKPORN7zQ/KVikFkZhRdherBGl5PRdOkf/kazhUV
         +WrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWWSU88HJmCXFh0CBqjI5ZXqfeLy5YHt1Werf4Qh+O7dO0Y6mTb
	zQecWTMiSnTEQNqia7NpxSHzP/Lgt393l7sTHZtjDCjM/dGKcJVbj9rQwYKcWGu+VM2TGbF1ubD
	H8/qCkWKVXa6KBKgbkkLiwNu75qlui1OtMnzMmxmghHBF/RvlMA+CgnPOX46eWO+7dg==
X-Received: by 2002:a1c:f418:: with SMTP id z24mr11600447wma.80.1565366459663;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVyohc34AEdnSbFWd1Yh0TK6amLHTqDGU54DcVzVsqZX4hohbpPP0RfmRdbjzhzW5bXMya
X-Received: by 2002:a1c:f418:: with SMTP id z24mr11600345wma.80.1565366458410;
        Fri, 09 Aug 2019 09:00:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366458; cv=none;
        d=google.com; s=arc-20160816;
        b=Dg/7jqyzcdhinGOY5QzgRkeA6iRXmAEuym8lsVgGVW4a4qWaKvta4bo1dP05iCel3E
         S34j1MofswinGlXkF0qFHt8UI3fhSgPV02eVzjzEpn86OF9GvKU24WqdZQkB8H65275K
         c3fmMZRadrlXVTafb5LsgD2Og1mCkwXxfLg4W5et3Kowjtzp2sa8K6Qj4Fpi2S7KO8fr
         gO8gPPPF7X2r5E05Mp4MWmaOpGuFv9L2sxUfu/SJXR11/KEfPo4hz0k9CR4Pxbyk6Qss
         /eQZmI6N7C1umDUaC9txbt/v3XUhMx9S95ebgY0I77u1SxnZy5YDp1BwyIJNQl3gQOZc
         zx/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MJrx9QFUdbiG1zFQ5CnTIj/yz5ZyansMDWH1Z1DeBN0=;
        b=0Uq77QjCpo7wz1sS07hAYS6GO4Ed+Z7rVpra4aLw78o8zdRElnUN/xs/3txb/ZtEbm
         Q8QmleRHSpcuLVY9N5cge4KQsPrBExfyUmnrXapE6dMVdxIZjPn1c9yamFKPgpXQjaLF
         AEdHTJsMH4h+gyHuC0XGK5V+6yN8zf/Y+h1ar8Nay1c053nVmxg51w4CAEh2kldcYQt6
         OGglvQpbMrYtiP1hJNaTQ6RC/ZhectbRRORiKUwgL0nb0j9tS5ac0ixqQmuiS2yCZk6w
         zYphy2qedPVCPXL4QDXoTvmofA0EwRYg055Fc56fjBXSAmEQfyae/3gZxrR9Xn5xGa/E
         5rDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id p1si4260544wmi.153.2019.08.09.09.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id B6D12305D3D6;
	Fri,  9 Aug 2019 19:00:57 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 5F13B305B7A0;
	Fri,  9 Aug 2019 19:00:57 +0300 (EEST)
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
Subject: [RFC PATCH v6 15/92] kvm: introspection: handle vCPU related introspection commands
Date: Fri,  9 Aug 2019 18:59:30 +0300
Message-Id: <20190809160047.8319-16-alazar@bitdefender.com>
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

Following the common structure used for all messages (kvmi_msg_hdr), all
vCPU related commands have another common structure (kvmi_vcpu_hdr). This
allows the receiving worker to validate and dispatch the message to the
proper vCPU (adding the handling function to its jobs list).

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Nicușor Cîțu <ncitu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst |   8 ++
 include/uapi/linux/kvm_para.h      |   4 +-
 include/uapi/linux/kvmi.h          |   6 ++
 virt/kvm/kvmi_int.h                |   3 +
 virt/kvm/kvmi_msg.c                | 159 ++++++++++++++++++++++++++++-
 5 files changed, 177 insertions(+), 3 deletions(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index a660def20b23..7f3c4f8fce63 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -232,6 +232,14 @@ The following C structures are meant to be used directly when communicating
 over the wire. The peer that detects any size mismatch should simply close
 the connection and report the error.
 
+The commands related to vCPU-s start with::
+
+	struct kvmi_vcpu_hdr {
+		__u16 vcpu;
+		__u16 padding1;
+		__u32 padding2;
+	}
+
 1. KVMI_GET_VERSION
 -------------------
 
diff --git a/include/uapi/linux/kvm_para.h b/include/uapi/linux/kvm_para.h
index 6c0ce49931e5..54c0e20f5b64 100644
--- a/include/uapi/linux/kvm_para.h
+++ b/include/uapi/linux/kvm_para.h
@@ -10,13 +10,15 @@
  * - kvm_para_available
  */
 
-/* Return values for hypercalls */
+/* Return values for hypercalls and VM introspection */
 #define KVM_ENOSYS		1000
 #define KVM_EFAULT		EFAULT
 #define KVM_EINVAL		EINVAL
 #define KVM_E2BIG		E2BIG
 #define KVM_EPERM		EPERM
 #define KVM_EOPNOTSUPP		95
+#define KVM_EAGAIN		11
+#define KVM_ENOMEM		ENOMEM
 
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index ff35faabb7ed..29452da818e3 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -114,4 +114,10 @@ struct kvmi_control_vm_events {
 	__u32 padding2;
 };
 
+struct kvmi_vcpu_hdr {
+	__u16 vcpu;
+	__u16 padding1;
+	__u32 padding2;
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 47418e9a86f6..33ea05cb99af 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -118,5 +118,8 @@ void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 			       bool enable);
+int kvmi_add_job(struct kvm_vcpu *vcpu,
+		 void (*fct)(struct kvm_vcpu *vcpu, void *ctx),
+		 void *ctx, void (*free_fct)(void *ctx));
 
 #endif
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index a55c9e35be36..2728e6870d47 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -8,6 +8,18 @@
 #include <linux/net.h>
 #include "kvmi_int.h"
 
+typedef int (*vcpu_reply_fct)(struct kvm_vcpu *vcpu,
+			      const struct kvmi_msg_hdr *msg, int err,
+			      const void *rpl, size_t rpl_size);
+
+struct kvmi_vcpu_cmd {
+	vcpu_reply_fct reply_cb;
+	struct {
+		struct kvmi_msg_hdr hdr;
+		struct kvmi_vcpu_hdr cmd;
+	} *msg;
+};
+
 static const char *const msg_IDs[] = {
 	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
@@ -165,6 +177,23 @@ static int kvmi_msg_vm_maybe_reply(struct kvmi *ikvm,
 	return kvmi_msg_vm_reply(ikvm, msg, err, rpl, rpl_size);
 }
 
+int kvmi_msg_vcpu_reply(struct kvm_vcpu *vcpu,
+			const struct kvmi_msg_hdr *msg, int err,
+			const void *rpl, size_t rpl_size)
+{
+	return kvmi_msg_reply(IKVM(vcpu->kvm), msg, err, rpl, rpl_size);
+}
+
+int kvmi_msg_vcpu_drop_reply(struct kvm_vcpu *vcpu,
+			      const struct kvmi_msg_hdr *msg, int err,
+			      const void *rpl, size_t rpl_size)
+{
+	if (!kvmi_validate_no_reply(IKVM(vcpu->kvm), msg, rpl_size, err))
+		return -KVM_EINVAL;
+
+	return 0;
+}
+
 static int handle_get_version(struct kvmi *ikvm,
 			      const struct kvmi_msg_hdr *msg, const void *req)
 {
@@ -248,6 +277,23 @@ static int handle_control_vm_events(struct kvmi *ikvm,
 	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
 }
 
+static int kvmi_get_vcpu(struct kvmi *ikvm, unsigned int vcpu_idx,
+			 struct kvm_vcpu **dest)
+{
+	struct kvm *kvm = ikvm->kvm;
+	struct kvm_vcpu *vcpu;
+
+	if (vcpu_idx >= atomic_read(&kvm->online_vcpus))
+		return -KVM_EINVAL;
+
+	vcpu = kvm_get_vcpu(kvm, vcpu_idx);
+	if (!vcpu)
+		return -KVM_EINVAL;
+
+	*dest = vcpu;
+	return 0;
+}
+
 static int handle_control_cmd_response(struct kvmi *ikvm,
 					const struct kvmi_msg_hdr *msg,
 					const void *_req)
@@ -273,6 +319,11 @@ static int handle_control_cmd_response(struct kvmi *ikvm,
 	return err;
 }
 
+static bool invalid_vcpu_hdr(const struct kvmi_vcpu_hdr *hdr)
+{
+	return hdr->padding1 || hdr->padding2;
+}
+
 /*
  * These commands are executed on the receiving thread/worker.
  */
@@ -286,16 +337,66 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };
 
+/*
+ * These commands are executed on the vCPU thread. The receiving thread
+ * passes the messages using a newly allocated 'struct kvmi_vcpu_cmd'
+ * and signals the vCPU to handle the command (which includes
+ * sending back the reply).
+ */
+static int(*const msg_vcpu[])(struct kvm_vcpu *,
+			      const struct kvmi_msg_hdr *, const void *,
+			      vcpu_reply_fct) = {
+};
+
+static void kvmi_job_vcpu_cmd(struct kvm_vcpu *vcpu, void *_ctx)
+{
+	const struct kvmi_vcpu_cmd *ctx = _ctx;
+	size_t id = ctx->msg->hdr.id;
+	int err;
+
+	err = msg_vcpu[id](vcpu, &ctx->msg->hdr, ctx->msg + 1, ctx->reply_cb);
+
+	if (err) {
+		struct kvmi *ikvm = IKVM(vcpu->kvm);
+
+		kvmi_err(ikvm,
+			 "%s: cmd id: %zu (%s), err: %d\n", __func__,
+			 id, id2str(id), err);
+		kvmi_sock_shutdown(ikvm);
+	}
+}
+
+static void kvmi_free_ctx(void *_ctx)
+{
+	const struct kvmi_vcpu_cmd *ctx = _ctx;
+
+	kvmi_msg_free(ctx->msg);
+	kfree(ctx);
+}
+
+static int kvmi_msg_queue_to_vcpu(struct kvm_vcpu *vcpu,
+				  const struct kvmi_vcpu_cmd *cmd)
+{
+	return kvmi_add_job(vcpu, kvmi_job_vcpu_cmd, (void *)cmd,
+			    kvmi_free_ctx);
+}
+
 static bool is_vm_message(u16 id)
 {
 	return id < ARRAY_SIZE(msg_vm) && !!msg_vm[id];
 }
 
+static bool is_vcpu_message(u16 id)
+{
+	return id < ARRAY_SIZE(msg_vcpu) && !!msg_vcpu[id];
+}
+
 static bool is_unsupported_message(u16 id)
 {
 	bool supported;
 
-	supported = is_known_message(id) && is_vm_message(id);
+	supported = is_known_message(id) &&
+			(is_vm_message(id) || is_vcpu_message(id));
 
 	return !supported;
 }
@@ -364,12 +465,66 @@ static int kvmi_msg_dispatch_vm_cmd(struct kvmi *ikvm,
 	return msg_vm[msg->id](ikvm, msg, msg + 1);
 }
 
+static int kvmi_msg_dispatch_vcpu_job(struct kvmi *ikvm,
+				      struct kvmi_vcpu_cmd *job,
+				      bool *queued)
+{
+	struct kvmi_msg_hdr *hdr = &job->msg->hdr;
+	struct kvmi_vcpu_hdr *cmd = &job->msg->cmd;
+	struct kvm_vcpu *vcpu = NULL;
+	int err;
+
+	if (invalid_vcpu_hdr(cmd))
+		return -KVM_EINVAL;
+
+	err = kvmi_get_vcpu(ikvm, cmd->vcpu, &vcpu);
+
+	if (!err && vcpu->arch.mp_state == KVM_MP_STATE_UNINITIALIZED)
+		err = -KVM_EAGAIN;
+
+	if (err)
+		return kvmi_msg_vm_maybe_reply(ikvm, hdr, err, NULL, 0);
+
+	err = kvmi_msg_queue_to_vcpu(vcpu, job);
+	if (!err)
+		*queued = true;
+
+	return err;
+}
+
+static int kvmi_msg_dispatch_vcpu_msg(struct kvmi *ikvm,
+				      struct kvmi_msg_hdr *msg,
+				      bool *queued)
+{
+	struct kvmi_vcpu_cmd *job_msg;
+	int err;
+
+	job_msg = kzalloc(sizeof(*job_msg), GFP_KERNEL);
+	if (!job_msg)
+		return -KVM_ENOMEM;
+
+	job_msg->reply_cb = ikvm->cmd_reply_disabled
+				? kvmi_msg_vcpu_drop_reply
+				: kvmi_msg_vcpu_reply;
+	job_msg->msg = (void *)msg;
+
+	err = kvmi_msg_dispatch_vcpu_job(ikvm, job_msg, queued);
+
+	if (!*queued)
+		kfree(job_msg);
+
+	return err;
+}
+
 static int kvmi_msg_dispatch(struct kvmi *ikvm,
 			     struct kvmi_msg_hdr *msg, bool *queued)
 {
 	int err;
 
-	err = kvmi_msg_dispatch_vm_cmd(ikvm, msg);
+	if (is_vcpu_message(msg->id))
+		err = kvmi_msg_dispatch_vcpu_msg(ikvm, msg, queued);
+	else
+		err = kvmi_msg_dispatch_vm_cmd(ikvm, msg);
 
 	if (err)
 		kvmi_err(ikvm, "%s: msg id: %u (%s), err: %d\n", __func__,

