Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0942AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CD9320C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CD9320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1AD46B0288; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACAD86B028A; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944416B0289; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40EE66B0286
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x12so1339603wrw.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s77IzXXMMKjHf68JwnZKHXl1EG4XooBC3s85XD7NB7Q=;
        b=lkPwbMfWHx9h9itL4C9qZu/cJPvIFFBDLz5qf//dlTR+7EmzeHgLEZ3jUryGfs3wfB
         ilj4IC6+EMxHf70HdnXN8g5QdUEIgA11Xdrz7UvjYkhNLxyw9uZe65LTZQyro1eMaJLq
         gcXmb5Ftp/N1srg9gOT79h/1QYuRGMmljid0ALii71E0nanuDx54n9nEROetdJP2lNNp
         EgRD8r7l0XkmCOARKKgRQsmmajCC33mUP/LEsU5CukzL7qSdF5wtmXsjsuWWGuvwKmxv
         irPojihp72gBxAHVBgQngc0Q+TYoMwqq9RXVgd5IWQ9BN3vMYIfMggHMRNEwjNAF4mnY
         WWVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXbe2Sa7uGvRTRtpQDD/4q8BlLqiWnXjFkt0U00r5B8NlOuUyDU
	zkusWK623yvicDXVZG4zAndjzADXx+VPhZAx4TX7djKON6/0qvvraDH0ZHyMeAt80PlN6ECR4Yk
	7J1fGjYTWI5n1oGAkC3XMZPGx6WVWsz59xS8SlugOEKQEDEwsQ757OrsVHu9ibtX9RA==
X-Received: by 2002:a5d:48c5:: with SMTP id p5mr15309787wrs.217.1565366476853;
        Fri, 09 Aug 2019 09:01:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzewiByQIw1dSNu6uTo6Ra+zMhcOZ2J65fLJD0T3/7lXhAutn/BliZjuTQ8cvMXuen1uTPd
X-Received: by 2002:a5d:48c5:: with SMTP id p5mr15309580wrs.217.1565366474569;
        Fri, 09 Aug 2019 09:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366474; cv=none;
        d=google.com; s=arc-20160816;
        b=qH/iyYRmLsPOVu/MwFSO1m0OpDicukK9/BEYgSfXBeyHb9qVhk/R7IaJyVo6h2bmrv
         H40EkW3ysvFfZCFms+hT54PP2EXTKgvmNnf6rSraotYpu+uqjqKhRn3EQLheJ571+Yjf
         TiU6SyVYMSSJXLKTvca0FOkbF6oUeH6xw+j0VuKQDo+lXxPhp/E+ylfhFQOXHoXYOcBi
         oARD5k6ozbJQejaWZe0PGBD1U15bdYbyri8z9B6gxuz6ashSWFS2o2wvYlMdbberSgTY
         Vvch15+S9BOoyhhRJDaIe+yhkY6h3+R18MzQ5G6Vdsl6iqz7aHzJ/o5TIQsHSfyksMDM
         uFag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=s77IzXXMMKjHf68JwnZKHXl1EG4XooBC3s85XD7NB7Q=;
        b=096Rdu4M3Yd/idSzzQdenMRH5LYYxwhHmzS8F/V4VL9B3QfOzEqXBZ9ZTYt7GvvZJP
         qDXFoQ3QaLql9mCFLOyrSiioKRVXP5SZZmRroFyE8kujYPgWODkjVx+Wa8E76rpplqh1
         ZINRWPXOTj3Bb3F9nadFBAu22B9JLVjiD86gbHduO/mANkSru4dAr+yEkbclbDBa4hOW
         F7I63Hu2crzW1ihixsfAg5cu2Kqh/RE2hmBwve8zH5F5YqasaYGRfLUmuW/Vhhn82IEt
         xuZ4VwIFMiW4sPpi0jMnMoZ6vXrFDWdmRY+7+9wZ2+MqlDYNskgcIiNdFoUtpivVXXfX
         u6tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id j2si4214815wmk.27.2019.08.09.09.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E97213031EB8;
	Fri,  9 Aug 2019 19:01:13 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 8EE2C305B7A3;
	Fri,  9 Aug 2019 19:01:13 +0300 (EEST)
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
Subject: [RFC PATCH v6 43/92] kvm: introspection: add KVMI_CONTROL_SPP
Date: Fri,  9 Aug 2019 18:59:58 +0300
Message-Id: <20190809160047.8319-44-alazar@bitdefender.com>
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

This command enables/disables subpage protection (SPP) for the current VM.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 33 ++++++++++++++++++++++++++++++
 arch/x86/kvm/kvmi.c                |  4 ++++
 include/uapi/linux/kvmi.h          |  7 +++++++
 virt/kvm/kvmi_int.h                |  6 ++++++
 virt/kvm/kvmi_msg.c                | 33 ++++++++++++++++++++++++++++++
 5 files changed, 83 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index b64a030507cf..c1d12aaa8633 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -617,6 +617,39 @@ In order to 'forget' an address, all the access bits ('rwx') must be set.
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 * -KVM_ENOMEM - not enough memory to add the page tracking structures
 
+11. KVMI_CONTROL_SPP
+--------------------
+
+:Architectures: x86/intel
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_spp {
+		__u8 enable;
+		__u8 padding1;
+		__u16 padding2;
+		__u32 padding3;
+	}
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+
+Enables/disables subpage protection (SPP) for the current VM.
+
+If SPP is not enabled, *KVMI_GET_PAGE_WRITE_BITMAP* and
+*KVMI_SET_PAGE_WRITE_BITMAP* commands will fail.
+
+:Errors:
+
+* -KVM_EINVAL - padding is not zero
+* -KVM_EOPNOTSUPP - the hardware doesn't support SPP
+* -KVM_EOPNOTSUPP - the current implementation can't disable SPP
+
 Events
 ======
 
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 3238ef176ad6..01fd218e213c 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -260,3 +260,7 @@ int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
 	return ec;
 }
 
+int kvmi_arch_cmd_control_spp(struct kvmi *ikvm)
+{
+	return kvm_arch_init_spp(ikvm->kvm);
+}
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 2ddbb1fea807..9f2b13718e47 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -142,6 +142,13 @@ struct kvmi_set_page_access {
 	struct kvmi_page_access_entry entries[0];
 };
 
+struct kvmi_control_spp {
+	__u8 enable;
+	__u8 padding1;
+	__u16 padding2;
+	__u32 padding3;
+};
+
 struct kvmi_get_vcpu_info_reply {
 	__u64 tsc_speed;
 };
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index c54be93349b7..3f0c7a03b4a1 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -130,6 +130,11 @@ struct kvmi {
 	DECLARE_BITMAP(event_allow_mask, KVMI_NUM_EVENTS);
 	DECLARE_BITMAP(vm_ev_mask, KVMI_NUM_EVENTS);
 
+	struct {
+		bool initialized;
+		atomic_t enabled;
+	} spp;
+
 	bool cmd_reply_disabled;
 };
 
@@ -184,6 +189,7 @@ int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
 int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
 				  const struct kvmi_msg_hdr *msg,
 				  const struct kvmi_set_page_access *req);
+int kvmi_arch_cmd_control_spp(struct kvmi *ikvm);
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index c150e7bdd440..e501a807c8a2 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -25,6 +25,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
 	[KVMI_CONTROL_EVENTS]        = "KVMI_CONTROL_EVENTS",
+	[KVMI_CONTROL_SPP]           = "KVMI_CONTROL_SPP",
 	[KVMI_CONTROL_VM_EVENTS]     = "KVMI_CONTROL_VM_EVENTS",
 	[KVMI_EVENT]                 = "KVMI_EVENT",
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
@@ -300,6 +301,37 @@ static int kvmi_get_vcpu(struct kvmi *ikvm, unsigned int vcpu_idx,
 	return 0;
 }
 
+static bool enable_spp(struct kvmi *ikvm)
+{
+	if (!ikvm->spp.initialized) {
+		int err = kvmi_arch_cmd_control_spp(ikvm);
+
+		ikvm->spp.initialized = true;
+
+		if (!err)
+			atomic_set(&ikvm->spp.enabled, true);
+	}
+
+	return atomic_read(&ikvm->spp.enabled);
+}
+
+static int handle_control_spp(struct kvmi *ikvm,
+			      const struct kvmi_msg_hdr *msg,
+			      const void *_req)
+{
+	const struct kvmi_control_spp *req = _req;
+	int ec;
+
+	if (req->padding1 || req->padding2 || req->padding3)
+		ec = -KVM_EINVAL;
+	else if (req->enable && enable_spp(ikvm))
+		ec = 0;
+	else
+		ec = -KVM_EOPNOTSUPP;
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
 static int handle_control_cmd_response(struct kvmi *ikvm,
 					const struct kvmi_msg_hdr *msg,
 					const void *_req)
@@ -364,6 +396,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_CHECK_COMMAND]         = handle_check_command,
 	[KVMI_CHECK_EVENT]           = handle_check_event,
 	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
+	[KVMI_CONTROL_SPP]           = handle_control_spp,
 	[KVMI_CONTROL_VM_EVENTS]     = handle_control_vm_events,
 	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
 	[KVMI_GET_PAGE_ACCESS]       = handle_get_page_access,

