Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0A17C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7742A2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7742A2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F12326B026D; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC40E6B0270; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B17576B026F; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9E36B026F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k10so4065694wru.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PGaLYSew8Jfr9ke/l8cNnme6xmXde0bNuA83fL+q+mA=;
        b=Obzx/F85x8ttunpYjNz4qKx/ez9gh9NIRYgl3Ia+87+R7+5b/6EmdNuP4DV/C34YbR
         JusMIdw82rEt1NvYiIKy6+q+qb9d5ISjluKHHyAH4Ra3xn61h1vpTcRr/PFizXmlZdrY
         Jc1mNAl7PWEf/h7xcvLKebip4JHFLopKpqu6cDxpwMp3xW4/lHm0CXdPnuztQe9OTi0w
         UcJRVHIIgwXrbzPREwGNJ0cWvB0mY6OWVdpvsjAbRqKfd8hhtJlLwiwr8MiLKYuTaHXv
         qoZdcZIvSykiycvh99+iC2O5u6Nrlj8Mz2vRXqeqSPqVa6+6zKa1ZvGtSmWcn5CUkncp
         qWrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUvWVckpJEja8i3Dp/uIAKGMiwKSzVS4DVkWscav0UZ1+F4O/XG
	UxTw8nCz4vb1x4Yn3+X3Be3oj1N0uZgJLyvxphjMl3S0N80CnDaticzXWcaXcQBShPypxbzoYqe
	tJHQz8Kq4GH5rQrEnFD2OZDGum/IuYYM3CYlGZ76Sb/5sUi1f5kgFBsdIJqpkcFujsA==
X-Received: by 2002:a5d:4492:: with SMTP id j18mr22118338wrq.53.1565366459890;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoXHKFtFT7qMztoveGT3FAlui7Ei06H3YUUAf2OGqX/MnE7MrfMA2zh6xuNeKuTmF8vfLL
X-Received: by 2002:a5d:4492:: with SMTP id j18mr22118268wrq.53.1565366459040;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366459; cv=none;
        d=google.com; s=arc-20160816;
        b=fAsamf+1yPP0QzsZzP0SA2xlZRUEFFfwv+8dd7luf7OLDxkA5sTvfLtvVEiutwqRJ0
         x2B7GI36kpKv1S8xxzwPssHKSjKFO1J1xX2wGK99uLwFQmXHTepYRcldV+Wj1uZXU53j
         46b6nWbpSysSrMfXM7UmFiYVJCKiV6bw/umskzaByt+v4DSbKmCokyqtmqDyqe6b7lN5
         XDn6YgsGZgGY1/QjKhbap/Thso+vtH9UEyz1/17lJdWKcbj6oJfBt9rzr6BdYJhqNat9
         d4HwfUyAJn13ljIX7BoUvxKDb+8xa5UO/+/ohxe3vJUzReQLhqNto/ZZ0xo/TQe77A9W
         Ka7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PGaLYSew8Jfr9ke/l8cNnme6xmXde0bNuA83fL+q+mA=;
        b=Ff+4gqqm6S4jz+FLoXiJaih3OHm06dP44a5SlhVGpNZF2a9uji03aQlja9Ui+bsa9U
         i4nEYt3cAOM24sdt3pbaUK8NTIKsMIfbPY21JICoBIJbOqowo700nHBCDwx2Zl08Dlvf
         IIKHgL4sifxtcGa33aY/VQWSgNdhOPVQvidUJ+kGjry9zJAeszmjjWi+UUN5FQ1hkHmi
         tfFVLL8wVCPZNHBq6IICS/GmLmSnfGQCmqAWAt4eycff6ouF2EMM2hQT6UYsdWKgaKml
         X4b1hWB6xza0rLtk4F8qz/HFK5QZ0tgAxSc3r608ALQd5v93kBhwXQwI5JDpjGBcqNf6
         NW3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id y13si8316632wrp.174.2019.08.09.09.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 57BB6305D3D8;
	Fri,  9 Aug 2019 19:00:58 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 1301E305B7A4;
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
Subject: [RFC PATCH v6 17/92] kvm: introspection: introduce event actions
Date: Fri,  9 Aug 2019 18:59:32 +0300
Message-Id: <20190809160047.8319-18-alazar@bitdefender.com>
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

All vCPU event replies contains the action requested by the introspection
tool, which can be one of the following:

  * KVMI_EVENT_ACTION_CONTINUE
  * KVMI_EVENT_ACTION_RETRY
  * KVMI_EVENT_ACTION_CRASH

The CONTINUE action can be seen as "continue with the old KVM code
path", while the RETRY action as "re-enter guest".

Note: KVMI_EVENT_UNHOOK, a VM event, doesn't have/need a reply.

Suggested-by: Paolo Bonzini <pbonzini@redhat.com>
Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 10 ++++++++
 include/uapi/linux/kvmi.h          |  4 +++
 kernel/signal.c                    |  1 +
 virt/kvm/kvmi.c                    | 40 ++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index e7d9a3816e00..1ea4be0d5a45 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -482,4 +482,14 @@ with two common structures::
 		__u32 padding2;
 	};
 
+All events accept the KVMI_EVENT_ACTION_CRASH action, which stops the
+guest ungracefully but as soon as possible.
+
+Most of the events accept the KVMI_EVENT_ACTION_CONTINUE action, which
+lets the instruction that caused the event to continue (unless specified
+otherwise).
+
+Some of the events accept the KVMI_EVENT_ACTION_RETRY action, to continue
+by re-entering the guest.
+
 Specific data can follow these common structures.
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index dda2ae352611..ccf2239b5db4 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -66,6 +66,10 @@ enum {
 	KVMI_NUM_EVENTS
 };
 
+#define KVMI_EVENT_ACTION_CONTINUE      0
+#define KVMI_EVENT_ACTION_RETRY         1
+#define KVMI_EVENT_ACTION_CRASH         2
+
 #define KVMI_MSG_SIZE (4096 - sizeof(struct kvmi_msg_hdr))
 
 struct kvmi_msg_hdr {
diff --git a/kernel/signal.c b/kernel/signal.c
index 57b7771e20d7..9befbfaaa710 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1413,6 +1413,7 @@ int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
 		 */
 	}
 }
+EXPORT_SYMBOL(kill_pid_info);
 
 static int kill_proc_info(int sig, struct kernel_siginfo *info, pid_t pid)
 {
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 3cc7bb035796..0d3560b74f2d 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -511,6 +511,46 @@ void kvmi_destroy_vm(struct kvm *kvm)
 	wait_for_completion_killable(&kvm->kvmi_completed);
 }
 
+static int kvmi_vcpu_kill(int sig, struct kvm_vcpu *vcpu)
+{
+	int err = -ESRCH;
+	struct pid *pid;
+	struct kernel_siginfo siginfo[1] = {};
+
+	rcu_read_lock();
+	pid = rcu_dereference(vcpu->pid);
+	if (pid)
+		err = kill_pid_info(sig, siginfo, pid);
+	rcu_read_unlock();
+
+	return err;
+}
+
+static void kvmi_vm_shutdown(struct kvm *kvm)
+{
+	int i;
+	struct kvm_vcpu *vcpu;
+
+	kvm_for_each_vcpu(i, vcpu, kvm)
+		kvmi_vcpu_kill(SIGTERM, vcpu);
+}
+
+void kvmi_handle_common_event_actions(struct kvm_vcpu *vcpu, u32 action,
+				      const char *str)
+{
+	struct kvm *kvm = vcpu->kvm;
+
+	switch (action) {
+	case KVMI_EVENT_ACTION_CRASH:
+		kvmi_vm_shutdown(kvm);
+		break;
+
+	default:
+		kvmi_err(IKVM(kvm), "Unsupported action %d for event %s\n",
+			 action, str);
+	}
+}
+
 void kvmi_run_jobs(struct kvm_vcpu *vcpu)
 {
 	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);

