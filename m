Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6E41C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70C522089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70C522089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F51C6B0272; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12F6A6B0274; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0428D6B0275; Fri,  9 Aug 2019 12:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id A77196B0272
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:01 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id c14so1411104wml.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wo+pz1RlCIidxkw5/fraiu80jBJWqzzn04cQCaE7Zi4=;
        b=PF//CcCeOW0chUAN2miQpE0vSA00VQnOVw5KSECfHsdugsLzeG3pOh28UPMrW7EaAB
         QjkmM2zbOqtGLoxAo5lTTFwhvfKI40cOGSRDsy4DLTFhLaCzLakTl7ugNOTet0lOt+F0
         XFXWQ+ovwgi9qVMl7mBfeF0mpucU4QQKu99Adbg+HH19m/KKdsQiHHc+5n82k1quYpjT
         eiWB7PPl2TY6cTIrYlhuVQzeFCMhkVgpy08GS9fvbzoTs2AjIHIQ/ZhNmN5xZq63G9L1
         UwPWg4qCxAi25uaSKQs6bL8b8PhjCL1tzQ8mpmLnmAcmuqoTSPLAV/S13dd9/FDhAX4I
         Sqnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWzciSUuXjoHQ/+cHzSUIczLeuuuWnv9uCz3rVp8G8z8oA1aSpb
	wJ5H/PZKgzGXqzhs5i6kQgsOe6256GITiusyFAhQFugHh7A8VF3Oh7AFi7dL2DiV6hguodNuG7o
	sWzgF1ovXL1q3ozKqHuNyKIm2zFzc7rLhQBy3sveAgIzvutXYYmLxrpcqZVRl30ZwLw==
X-Received: by 2002:a05:600c:ce:: with SMTP id u14mr11545507wmm.5.1565366461240;
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSOsIm3Cr/reSGHlPolIukvdofb/UieXsOa8R1sdQjFTwXO4eBxXUpa7IUUOfaLwA7/n32
X-Received: by 2002:a05:600c:ce:: with SMTP id u14mr11545385wmm.5.1565366459619;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366459; cv=none;
        d=google.com; s=arc-20160816;
        b=PrOsR4637bIDotm8mkKZT1YNydWYjWwZWQUThnMETDpfzRnEUXvXXpz6rPXJeZWf6t
         uU7/SKDKMZonFkWqIMw2Ffx5ldwNmK8IEcfppwKeQUO7bYDOCnLLY3kl1NzC+c03PZ4r
         sYaD1CVvdds8Emfqg3lJ64g4KS5EtpNZFcPSkcId2f66RO8taoceXeVTIBmYJHbYMRtN
         NAqyv407GrKiw+ej0wvmShDBRcgHWvXLguNpYot60Cqd1YPd3MNTzkktluPmh//FD7LC
         C2e1iiyu7EUUeC0DQEXK/eakLA418YvxVWVAZge51zxj/lN+KgBjJZsxTGcYVA56G+n7
         dXFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wo+pz1RlCIidxkw5/fraiu80jBJWqzzn04cQCaE7Zi4=;
        b=Cg6O6+l/A68WOSN0nxfg0rc55Bvs+vXxniOhpMzcjq3Zbl+cjnZyeQpIj3estrLDjz
         NcXPR/w/Alw7/Xbp6xuS5lEiOMvBHRHccz92uHNq5MC2HQowEbg5absR6ALBJfujbQAm
         Y+G9K/sm/XUc8rkk5KzMyWlO/K5LfQtrLbSNa3guZrY3wVFX8MvYqIX0IQpeXPcQG7l4
         PrxOxgvp5vOSsQp7DWweLuCgeEnuMTUjObPnA0aXO4PDWCd5XARkRpZb6Zm5A+OSdlg1
         mjg1dnPeXvynWzrd0T/nXIJkyoXPB2k99pQs0YkRs3eBjTLE3cUiGxJStgAY/sf8d5+R
         WqtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id a70si4102434wma.62.2019.08.09.09.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 075DE305D3DA;
	Fri,  9 Aug 2019 19:00:59 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 92936305B7A5;
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	=?UTF-8?q?Mircea=20C=C3=AErjaliu?= <mcirjaliu@bitdefender.com>
Subject: [RFC PATCH v6 19/92] kvm: introspection: add KVMI_EVENT_CREATE_VCPU
Date: Fri,  9 Aug 2019 18:59:34 +0300
Message-Id: <20190809160047.8319-20-alazar@bitdefender.com>
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

From: Mircea Cîrjaliu <mcirjaliu@bitdefender.com>

This event is sent when a vCPU is ready to be introspected.

Signed-off-by: Mircea Cîrjaliu <mcirjaliu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 23 +++++++++++++++
 virt/kvm/kvmi.c                    | 47 ++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h                |  1 +
 virt/kvm/kvmi_msg.c                | 12 ++++++++
 4 files changed, 83 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 28e1a1c80551..b29cd1b80b4f 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -513,3 +513,26 @@ pause/stop/migrate the guest (see **Unhooking**) and the introspection
 has been enabled for this event (see **KVMI_CONTROL_VM_EVENTS**).
 The introspection tool has a chance to unhook and close the KVMI channel
 (signaling that the operation can proceed).
+
+2. KVMI_EVENT_CREATE_VCPU
+-------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+
+:Returns:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_event_reply;
+
+This event is sent when a new vCPU is created and the introspection has
+been enabled for this event (see *KVMI_CONTROL_VM_EVENTS*).
+
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 7eda49bf65c4..d0d9adf5b6ed 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -13,6 +13,7 @@
 static struct kmem_cache *msg_cache;
 static struct kmem_cache *job_cache;
 
+static bool kvmi_create_vcpu_event(struct kvm_vcpu *vcpu);
 static void kvmi_abort_events(struct kvm *kvm);
 
 void *kvmi_msg_alloc(void)
@@ -150,6 +151,11 @@ static struct kvmi_job *kvmi_pull_job(struct kvmi_vcpu *ivcpu)
 	return job;
 }
 
+static void kvmi_job_create_vcpu(struct kvm_vcpu *vcpu, void *ctx)
+{
+	kvmi_create_vcpu_event(vcpu);
+}
+
 static bool alloc_ivcpu(struct kvm_vcpu *vcpu)
 {
 	struct kvmi_vcpu *ivcpu;
@@ -245,6 +251,9 @@ int kvmi_vcpu_init(struct kvm_vcpu *vcpu)
 		goto out;
 	}
 
+	if (kvmi_add_job(vcpu, kvmi_job_create_vcpu, NULL, NULL))
+		ret = -ENOMEM;
+
 out:
 	kvmi_put(vcpu->kvm);
 
@@ -330,6 +339,10 @@ int kvmi_hook(struct kvm *kvm, const struct kvm_introspection *qemu)
 			err = -ENOMEM;
 			goto err_alloc;
 		}
+		if (kvmi_add_job(vcpu, kvmi_job_create_vcpu, NULL, NULL)) {
+			err = -ENOMEM;
+			goto err_alloc;
+		}
 	}
 
 	/* interact with other kernel components after structure allocation */
@@ -551,6 +564,40 @@ void kvmi_handle_common_event_actions(struct kvm_vcpu *vcpu, u32 action,
 	}
 }
 
+static bool __kvmi_create_vcpu_event(struct kvm_vcpu *vcpu)
+{
+	u32 action;
+	bool ret = false;
+
+	action = kvmi_msg_send_create_vcpu(vcpu);
+	switch (action) {
+	case KVMI_EVENT_ACTION_CONTINUE:
+		ret = true;
+		break;
+	default:
+		kvmi_handle_common_event_actions(vcpu, action, "CREATE");
+	}
+
+	return ret;
+}
+
+static bool kvmi_create_vcpu_event(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm;
+	bool ret = true;
+
+	ikvm = kvmi_get(vcpu->kvm);
+	if (!ikvm)
+		return true;
+
+	if (test_bit(KVMI_EVENT_CREATE_VCPU, ikvm->vm_ev_mask))
+		ret = __kvmi_create_vcpu_event(vcpu);
+
+	kvmi_put(vcpu->kvm);
+
+	return ret;
+}
+
 void kvmi_run_jobs(struct kvm_vcpu *vcpu)
 {
 	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 9750a9b9902b..c21f0fd5e16c 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -123,6 +123,7 @@ bool kvmi_sock_get(struct kvmi *ikvm, int fd);
 void kvmi_sock_shutdown(struct kvmi *ikvm);
 void kvmi_sock_put(struct kvmi *ikvm);
 bool kvmi_msg_process(struct kvmi *ikvm);
+u32 kvmi_msg_send_create_vcpu(struct kvm_vcpu *vcpu);
 int kvmi_msg_send_unhook(struct kvmi *ikvm);
 
 /* kvmi.c */
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 0c7c1e968007..8e8af572a4f4 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -725,3 +725,15 @@ int kvmi_msg_send_unhook(struct kvmi *ikvm)
 
 	return kvmi_sock_write(ikvm, vec, n, msg_size);
 }
+
+u32 kvmi_msg_send_create_vcpu(struct kvm_vcpu *vcpu)
+{
+	int err, action;
+
+	err = kvmi_send_event(vcpu, KVMI_EVENT_CREATE_VCPU, NULL, 0,
+			      NULL, 0, &action);
+	if (err)
+		return KVMI_EVENT_ACTION_CONTINUE;
+
+	return action;
+}

