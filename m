Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0A51C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 692062089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 692062089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B55B6B028A; Fri,  9 Aug 2019 12:01:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2669A6B028B; Fri,  9 Aug 2019 12:01:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E2F56B028C; Fri,  9 Aug 2019 12:01:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A73BA6B028A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:18 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id q9so5429230wrc.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XQ66wxUeFPu0Nlr4ex7Ryxh0JWqBTFjM7EtSvdEn6bc=;
        b=U87RA8nmpoJQJoaNLznFFDoma5l5GfKUYdQuDbIShQFA5kT28BBpFzXXarCz7S9lZk
         /G2Ur0knHrdtz56oz4CLuqc82M3jTCfC8kOEabjpatP7hm3kGR2WKHW/I47Yj+h85kJn
         mrSiFxjmOUeGaUwjP7O06l6plJFdiV8e/ULBt9ZxNYf25SoJ9eQiommu8MWv7mj2l4ru
         GyBx3MQDBYJFqOS4LDhS7Px0fVTLX+KqmL7NLREmcNPawzCI4QGAgqfw4KQ/USD4beSk
         vhMNmJJkPjgzd7Qc16cqB0yyEamxhqfh4gRUCGl+h11ZV0GcLor6cVUu19Fj4CntOu6T
         FEMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAU6UIfHPFoB3xKgVfyuK4WHs1Uy+kyCWlVNlGcZDaUdNlV1yTAZ
	ZaMJ8t0y0MmW0Sjeh7eX26suLnD3gclQKdHylv3qZuCnIwXdT1bTFoOtvcqBBBZGvZUYExNe8ZJ
	6hWqgaNCpj9f34qyaPgBzVF5BFPFxg9Odbrhk8OcSZRZNVunS9Gt/p/pmf04TQZPUGg==
X-Received: by 2002:a1c:be11:: with SMTP id o17mr11597604wmf.115.1565366478226;
        Fri, 09 Aug 2019 09:01:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrWVcchqejlOrl74irl1d1+/0NKsh0jiCwbmVMNnoYdd2ffZ94/uNdQtLwBMtsFbKfNnke
X-Received: by 2002:a1c:be11:: with SMTP id o17mr11597462wmf.115.1565366476540;
        Fri, 09 Aug 2019 09:01:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366476; cv=none;
        d=google.com; s=arc-20160816;
        b=qOW0tGxWpuqbVZ0gJwDrij2GYvA0MniJwE7s/bMHGc6KIF7olx02bI8UN8irQEDUTw
         jlfEpyZOyla0V3cyBFTk251taJXMoSYWFAiZR0fM4jH5Tr4wqSxuabV8q0psE3qeVasy
         Uy7h0PnbPsZI4IkXXoT/ItbIgfoiOnsu21BDUqWmLlz6ZONa2Uxqc2HKmq7rdRIsarfA
         Q/R9POSkldJcZ5d2DpSBtd6/Z6QkBKopT7dlyJYo/qBdiMuhZfxY2bbeYTTSfZlLCyb5
         Tb6uk6InxSaCMk7LMIfDenG6lJsNahRplS23d1BPTZzdd//Ro4FbLHNgeT6KS5WvCwo+
         WwwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XQ66wxUeFPu0Nlr4ex7Ryxh0JWqBTFjM7EtSvdEn6bc=;
        b=C1+aBxVUGmQ1gUbQPXQ2duJA6MtFhNWzQGTkzg7hroQhy5I7jdijs+wYnus1OM31rK
         rtIc9Fqm46E/XJ95zTbF2IjQaQk1khvfcJ207s3eUan+pY3u5V2x5UuhZsgXde5L1HcC
         wDgSQ/wuvPz077KeiPVHyR0/EZ4GXlncGyeZYxE8klCDzixGMlbljXfK1SFRE8Q8+zxh
         orQWCyBYW55oDAvvM/ls5q7YHCSdJUN60QvTzkgeOI+BDkAOt5H1m9g7OBuJAYaOVhKu
         GJJ/IIcaH4Ez/FJAYM7K7N4lmntoBlcc8Z3axsB++10lTji/jjSgNTMw/jiWpyj3N0Pz
         aV5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id j19si16000568wre.125.2019.08.09.09.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E5204305D346;
	Fri,  9 Aug 2019 19:01:15 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 9420E305B7A0;
	Fri,  9 Aug 2019 19:01:15 +0300 (EEST)
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
Subject: [RFC PATCH v6 45/92] kvm: introspection: add KVMI_GET_PAGE_WRITE_BITMAP
Date: Fri,  9 Aug 2019 19:00:00 +0300
Message-Id: <20190809160047.8319-46-alazar@bitdefender.com>
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

This command returns subpage protection (SPP) write bitmaps for an array
of guest physical addresses of 4KB size.

Like the KVMI_GET_PAGE_ACCESS command, it checks only the radix tree,
not the SPP tables.  So, either we change it to check the SPP tables
or we drop it. Given the fact that the KVMI_EVENT_PF events are filter
using the radix tree and that the introspection tool should know what
it tracks, we should choose the later.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 44 ++++++++++++++++++++++++++++++
 arch/x86/kvm/kvmi.c                | 44 ++++++++++++++++++++++++++++++
 include/uapi/linux/kvmi.h          | 11 ++++++++
 virt/kvm/kvmi.c                    | 11 ++++++++
 virt/kvm/kvmi_int.h                | 11 ++++++++
 virt/kvm/kvmi_msg.c                | 18 ++++++++++++
 6 files changed, 139 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index c1d12aaa8633..2ffb92b0fa71 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -650,6 +650,50 @@ If SPP is not enabled, *KVMI_GET_PAGE_WRITE_BITMAP* and
 * -KVM_EOPNOTSUPP - the hardware doesn't support SPP
 * -KVM_EOPNOTSUPP - the current implementation can't disable SPP
 
+12. KVMI_GET_PAGE_WRITE_BITMAP
+------------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_page_write_bitmap {
+		__u16 view;
+		__u16 count;
+		__u32 padding;
+		__u64 gpa[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_page_write_bitmap_reply {
+		__u32 bitmap[0];
+	};
+
+Returns subpage protection (SPP) write bitmaps for an array of ``count``
+guest physical addresses of 4KB size.
+
+By default, for any guest physical address, the returned bits will be zero
+(no write access for any subpage if the *KVMI_PAGE_ACCESS_W* flag has been
+cleared for the whole 4KB page - see *KVMI_SET_PAGE_ACCESS*).
+
+On Intel hardware with multiple EPT views, the ``view`` argument selects the
+EPT view (0 is primary). On all other hardware it must be zero.
+
+:Errors:
+
+* -KVM_EINVAL - the selected SPT view is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EOPNOTSUPP - a SPT view was selected but the hardware doesn't support it
+* -KVM_EOPNOTSUPP - the hardware doesn't support SPP or hasn't been enabled
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
 Events
 ======
 
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 01fd218e213c..356ec79936b3 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -224,6 +224,50 @@ int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
 	return 0;
 }
 
+int kvmi_arch_cmd_get_page_write_bitmap(struct kvmi *ikvm,
+					const struct kvmi_msg_hdr *msg,
+					const struct kvmi_get_page_write_bitmap
+					*req,
+					struct kvmi_get_page_write_bitmap_reply
+					**dest, size_t *dest_size)
+{
+	struct kvmi_get_page_write_bitmap_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	u16 k, n = req->count;
+	int ec = 0;
+
+	if (req->padding)
+		return -KVM_EINVAL;
+
+	if (msg->size < sizeof(*req) + req->count * sizeof(req->gpa[0]))
+		return -KVM_EINVAL;
+
+	if (!kvmi_spp_enabled(ikvm))
+		return -KVM_EOPNOTSUPP;
+
+	if (req->view != 0)	/* TODO */
+		return -KVM_EOPNOTSUPP;
+
+	rpl_size = sizeof(*rpl) + sizeof(rpl->bitmap[0]) * n;
+	rpl = kvmi_msg_alloc_check(rpl_size);
+	if (!rpl)
+		return -KVM_ENOMEM;
+
+	for (k = 0; k < n && ec == 0; k++)
+		ec = kvmi_cmd_get_page_write_bitmap(ikvm, req->gpa[k],
+						    &rpl->bitmap[k]);
+
+	if (ec) {
+		kvmi_msg_free(rpl);
+		return ec;
+	}
+
+	*dest = rpl;
+	*dest_size = rpl_size;
+
+	return 0;
+}
+
 int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
 				  const struct kvmi_msg_hdr *msg,
 				  const struct kvmi_set_page_access *req)
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 9f2b13718e47..19a6a50df96b 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -149,6 +149,17 @@ struct kvmi_control_spp {
 	__u32 padding3;
 };
 
+struct kvmi_get_page_write_bitmap {
+	__u16 view;
+	__u16 count;
+	__u32 padding;
+	__u64 gpa[0];
+};
+
+struct kvmi_get_page_write_bitmap_reply {
+	__u32 bitmap[0];
+};
+
 struct kvmi_get_vcpu_info_reply {
 	__u64 tsc_speed;
 };
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index e18dfffa25ac..22e233ca474c 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -1161,6 +1161,17 @@ int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access)
 	return 0;
 }
 
+int kvmi_cmd_get_page_write_bitmap(struct kvmi *ikvm, u64 gpa,
+				   u32 *write_bitmap)
+{
+	gfn_t gfn = gpa_to_gfn(gpa);
+	u8 ignored_access;
+
+	kvmi_get_gfn_access(ikvm, gfn, &ignored_access, write_bitmap);
+
+	return 0;
+}
+
 int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access)
 {
 	gfn_t gfn = gpa_to_gfn(gpa);
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index d9a10a3b7082..7243c57be27a 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -150,6 +150,11 @@ static inline bool is_event_enabled(struct kvm_vcpu *vcpu, int event)
 	return test_bit(event, IVCPU(vcpu)->ev_mask);
 }
 
+static inline bool kvmi_spp_enabled(struct kvmi *ikvm)
+{
+	return atomic_read(&ikvm->spp.enabled);
+}
+
 /* kvmi_msg.c */
 bool kvmi_sock_get(struct kvmi *ikvm, int fd);
 void kvmi_sock_shutdown(struct kvmi *ikvm);
@@ -167,6 +172,7 @@ void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
 int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access);
 int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access);
+int kvmi_cmd_get_page_write_bitmap(struct kvmi *ikvm, u64 gpa, u32 *bitmap);
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
@@ -191,6 +197,11 @@ int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
 				  const struct kvmi_msg_hdr *msg,
 				  const struct kvmi_set_page_access *req);
 int kvmi_arch_cmd_control_spp(struct kvmi *ikvm);
+int kvmi_arch_cmd_get_page_write_bitmap(struct kvmi *ikvm,
+					const struct kvmi_msg_hdr *msg,
+					const struct kvmi_get_page_write_bitmap *req,
+					struct kvmi_get_page_write_bitmap_reply **dest,
+					size_t *dest_size);
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index e501a807c8a2..eb247ac3e037 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -31,6 +31,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
 	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
+	[KVMI_GET_PAGE_WRITE_BITMAP] = "KVMI_GET_PAGE_WRITE_BITMAP",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 	[KVMI_SET_PAGE_ACCESS]       = "KVMI_SET_PAGE_ACCESS",
@@ -383,6 +384,22 @@ static int handle_set_page_access(struct kvmi *ikvm,
 	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
 }
 
+static int handle_get_page_write_bitmap(struct kvmi *ikvm,
+					const struct kvmi_msg_hdr *msg,
+					const void *req)
+{
+	struct kvmi_get_page_write_bitmap_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	int err, ec;
+
+	ec = kvmi_arch_cmd_get_page_write_bitmap(ikvm, msg, req, &rpl,
+						 &rpl_size);
+
+	err = kvmi_msg_vm_maybe_reply(ikvm, msg, ec, rpl, rpl_size);
+	kvmi_msg_free(rpl);
+	return err;
+}
+
 static bool invalid_vcpu_hdr(const struct kvmi_vcpu_hdr *hdr)
 {
 	return hdr->padding1 || hdr->padding2;
@@ -400,6 +417,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_CONTROL_VM_EVENTS]     = handle_control_vm_events,
 	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
 	[KVMI_GET_PAGE_ACCESS]       = handle_get_page_access,
+	[KVMI_GET_PAGE_WRITE_BITMAP] = handle_get_page_write_bitmap,
 	[KVMI_GET_VERSION]           = handle_get_version,
 	[KVMI_SET_PAGE_ACCESS]       = handle_set_page_access,
 };

