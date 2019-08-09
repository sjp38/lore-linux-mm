Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD217C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BCDE2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BCDE2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2433E6B026F; Fri,  9 Aug 2019 12:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15D3A6B0274; Fri,  9 Aug 2019 12:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD7086B0272; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD3F6B026D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id n13so1064814wmi.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CfiqzuZFOOxdzjJTBwO3zC4LYKKbKm79dnqSAEzx9a4=;
        b=NLlEcmpr603toO2DZgyJeTlfmMgVCEmiLu6+ccQ9+xoS1M0OQ096ou+8g8+Ks1xahY
         KtJQyXwKRLWwpBdYrd4rN0hLLeGeWE4lQS6K5NUql15Hg5de2B49s3/0u3iqJbIifXKK
         Ks+44Urupc2mNEIZD5W+KHZG42F19RIp033iwonVjQg+pm0P8+g8MKcLKWjYAeKauboI
         LUxNd7e1aQDjQqFpw0igdF8nXgr/Piqt/3vw0zblZqDNmQIQ+/C3d3kK5klQN6XqFRIm
         1qbmQr3CC0a0skzwJcTF2xmItqK+olKwhRgev9FOr83XKSkWiGOjdDWkb++nO5615oAW
         Y76A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUIujBJLzfXDj/JRoGbSSMI8nqRrziys6Y6S4zz1ezEsr1pE+lU
	FGlSr9zWSGHje68P1g8S8+TQMF/f2M/LbGNHcZzX/O5QX480WfnIPmraydSbrRIJAD1w73zr323
	R5OUIwrRk448gswQoVX5e8lk7rLa8rfZ8FKsn0KcZ6rDolIF/YrzAzlAarp5Q701Uzg==
X-Received: by 2002:a5d:4887:: with SMTP id g7mr18760677wrq.164.1565366460155;
        Fri, 09 Aug 2019 09:01:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRN4kVuCrV+1O3bc9wpioHPOzaw6M+S1E5nMnsm+mFcuS9/CmnixdSljXk/F61lkL5D+io
X-Received: by 2002:a5d:4887:: with SMTP id g7mr18760597wrq.164.1565366459244;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366459; cv=none;
        d=google.com; s=arc-20160816;
        b=dVBydU2psfPR4g5/XPBjMrNH+Tj2ur+i5poOxFv6JUC6udQZRF0f/sAEKCm2v9ddEP
         uwNtTtPWUjAvzm8IblW/kgGDKTM6Mw+ZWjQm6hzi4P8GwKiGR8LV67iV5La3naqxRs1v
         SXPWqOMb6QIPMFh8pVeLvfDoLmfxuZgVeMwLsP9RP/iqbnoc1TZFZWJVTF5ZyIbS4PEP
         fAViOlbvzSq8+DuB2PTMS5Opk/DYJDwJ1P4k/Xya7hSzF93k6t+jHR3qFzkV2nET1m5h
         Cag5yLO+M3ATKmphY/PMr2xGqYz4S8hG+fuHmHbDTgUfiYmC56u2APIoVctJP9ZRNKXY
         WVAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CfiqzuZFOOxdzjJTBwO3zC4LYKKbKm79dnqSAEzx9a4=;
        b=csUo9K8soI4wkfyQMD5XNcHrYEzMDBPM0k3VWwK9V+1JhO5V/xiUjAkBImABoclqiM
         5hza2GU4LcP9AbmE7i3FDUeuRP4OhjrIqy1gD2AeoUNZN0hyp4sZdph/sEFa3DREe7QM
         z7L8JqzJ7taOxu2KBUJBdjr7DO1qbvOdazdZdWLunpCcZgqDizWKfDSYeHG0zQMbHzrt
         gLcTHox5fy1HL8MhIoDjEdtV9saGOwPjG60Z/mYDwectMmfDT1j3gLENZ3JGlBiCe4BG
         2hZSlJwmH484Y8UY2RqJn4C3HwqGzm58X0/CGXfa6YF/PttPu/qC9DswpKM8gQbm70ZV
         iRgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id e23si4232827wmh.198.2019.08.09.09.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 9792F305D3D9;
	Fri,  9 Aug 2019 19:00:58 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 51651305B7A0;
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
Subject: [RFC PATCH v6 18/92] kvm: introspection: add KVMI_EVENT_UNHOOK
Date: Fri,  9 Aug 2019 18:59:33 +0300
Message-Id: <20190809160047.8319-19-alazar@bitdefender.com>
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

In certain situations (when the guest has to be paused, suspended,
migrated, etc.), userspace/QEMU will use the KVM_INTROSPECTION_UNHOOK
ioctl in order to trigger the KVMI_EVENT_UNHOOK. If the event is sent
successfully (the VM has an active introspection channel), userspace
should delay the action (pause/suspend/...) to give the introspection
tool the chance to remove its hooks (eg. breakpoints). Once a timeout
is reached or the introspection tool has closed the socket, QEMU should
continue with the planned action.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 20 ++++++++++++++++++
 virt/kvm/kvmi.c                    | 34 +++++++++++++++++++++++++++++-
 virt/kvm/kvmi_int.h                |  1 +
 virt/kvm/kvmi_msg.c                | 20 ++++++++++++++++++
 4 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 1ea4be0d5a45..28e1a1c80551 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -493,3 +493,23 @@ Some of the events accept the KVMI_EVENT_ACTION_RETRY action, to continue
 by re-entering the guest.
 
 Specific data can follow these common structures.
+
+1. KVMI_EVENT_UNHOOK
+--------------------
+
+:Architecture: all
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+
+:Returns: none
+
+This event is sent when the device manager (ie. QEMU) has to
+pause/stop/migrate the guest (see **Unhooking**) and the introspection
+has been enabled for this event (see **KVMI_CONTROL_VM_EVENTS**).
+The introspection tool has a chance to unhook and close the KVMI channel
+(signaling that the operation can proceed).
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 0d3560b74f2d..7eda49bf65c4 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -644,6 +644,9 @@ int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 
 static void kvmi_job_abort(struct kvm_vcpu *vcpu, void *ctx)
 {
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+
+	ivcpu->reply_waiting = false;
 }
 
 static void kvmi_abort_events(struct kvm *kvm)
@@ -655,6 +658,34 @@ static void kvmi_abort_events(struct kvm *kvm)
 		kvmi_add_job(vcpu, kvmi_job_abort, NULL, NULL);
 }
 
+static bool __kvmi_unhook_event(struct kvmi *ikvm)
+{
+	int err;
+
+	if (!test_bit(KVMI_EVENT_UNHOOK, ikvm->vm_ev_mask))
+		return false;
+
+	err = kvmi_msg_send_unhook(ikvm);
+
+	return !err;
+}
+
+static bool kvmi_unhook_event(struct kvm *kvm)
+{
+	struct kvmi *ikvm;
+	bool ret = true;
+
+	ikvm = kvmi_get(kvm);
+	if (!ikvm)
+		return false;
+
+	ret = __kvmi_unhook_event(ikvm);
+
+	kvmi_put(kvm);
+
+	return ret;
+}
+
 int kvmi_ioctl_unhook(struct kvm *kvm, bool force_reset)
 {
 	struct kvmi *ikvm;
@@ -664,7 +695,8 @@ int kvmi_ioctl_unhook(struct kvm *kvm, bool force_reset)
 	if (!ikvm)
 		return -EFAULT;
 
-	kvm_info("TODO: %s force_reset %d", __func__, force_reset);
+	if (!force_reset && !kvmi_unhook_event(kvm))
+		err = -ENOENT;
 
 	kvmi_put(kvm);
 
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 70c8ca0343a3..9750a9b9902b 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -123,6 +123,7 @@ bool kvmi_sock_get(struct kvmi *ikvm, int fd);
 void kvmi_sock_shutdown(struct kvmi *ikvm);
 void kvmi_sock_put(struct kvmi *ikvm);
 bool kvmi_msg_process(struct kvmi *ikvm);
+int kvmi_msg_send_unhook(struct kvmi *ikvm);
 
 /* kvmi.c */
 void *kvmi_msg_alloc(void);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 536034e1bea7..0c7c1e968007 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -705,3 +705,23 @@ int kvmi_send_event(struct kvm_vcpu *vcpu, u32 ev_id,
 	return err;
 }
 
+int kvmi_msg_send_unhook(struct kvmi *ikvm)
+{
+	struct kvmi_msg_hdr hdr;
+	struct kvmi_event common;
+	struct kvec vec[] = {
+		{.iov_base = &hdr,	.iov_len = sizeof(hdr)	 },
+		{.iov_base = &common,	.iov_len = sizeof(common)},
+	};
+	size_t msg_size = sizeof(hdr) + sizeof(common);
+	size_t n = ARRAY_SIZE(vec);
+
+	memset(&hdr, 0, sizeof(hdr));
+	hdr.id = KVMI_EVENT;
+	hdr.seq = new_seq(ikvm);
+	hdr.size = msg_size - sizeof(hdr);
+
+	kvmi_setup_event_common(&common, KVMI_EVENT_UNHOOK, 0);
+
+	return kvmi_sock_write(ikvm, vec, n, msg_size);
+}

