Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71561C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1F062085B
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1F062085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8D8D6B02EC; Fri,  9 Aug 2019 12:03:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3F1E6B02ED; Fri,  9 Aug 2019 12:03:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2F836B02EE; Fri,  9 Aug 2019 12:03:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51FE46B02EC
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:24 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l16so1451857wmg.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QkhPHmDRDm9xz6GVeVMZJK2nYW4a7RE6/ZIT/O9pC1s=;
        b=VCLspdiyorkhqb4Gc1dchU7PF2dQK8udEVwHQBYyzUuHbzVwmKLmtceQzh9qROK867
         LZzVBl+iS3Aol9Y7NxSwQZg8YIVM1JcCU6HsUw+5IQn3T8rswMcktz08HM7w8FGn6seD
         aiUuGyPfZT7FN/EnTwN54BMDBTg/7TeerS0YsdY7Rak5Ul0Z75au4Q5i0hVCk+VrdPTI
         XAnY5fBvde+MtegqcAyljs8Ued35hpvgy+rHD88pCqdJ+J0RMd9W0ZMWeuWOD2A4Vi1k
         NMPKIOhQilP4Q03LTFwnP5fU/3X7Uhk0d5Wv+2fByLh5AKCMvsxhGV87+VCC1VsC8+kW
         vsSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUIHLEJKNENJ2o2EXs2F+qaw6FAx/h8SzGkfrUFpMr/YXzO++UQ
	7DNCenjQ85U5PPu1PUwCoPKCFGeTso+gOcgZ87J0mkcpnliy3tL2yvLjaW4QbnkgyCrPh04Ublv
	4MuSri58KNyZvnvYww7EXiESa+WbAqiQ9qfVugylF7s6vQQ7KZl5uq+ztC0/1to7MmQ==
X-Received: by 2002:adf:a348:: with SMTP id d8mr12870366wrb.235.1565366603893;
        Fri, 09 Aug 2019 09:03:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysm17OnKufzw9c8LIGv0PlUpS7zJl6DQKWE+hEOrVSrn2H6B1jmy6ILohUFDgAquIHEwkg
X-Received: by 2002:adf:a348:: with SMTP id d8mr12857122wrb.235.1565366479144;
        Fri, 09 Aug 2019 09:01:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366479; cv=none;
        d=google.com; s=arc-20160816;
        b=YFVNTH0aecEUVfyGd+CFWWs74oc/HWUmwhwrkdG24dnpQBRIlTWcW0ecxwnyunLzh0
         d7C9Wk9ogny2GamdFbXnvbk9zbDKvYdgtUh8R3rXxb7AdcBb/0N4MXh4aALT6an04kYw
         VzUW0GSbZOPlCTSeZmqw+mlb8tEEF7yXs6Hq+Cmoo1n2Vc09IL2HW0aI4z/vQHJs3Quq
         DIXxlIUB8faEPcPiQFrSGCMJD6mpNF/3J0dUIVMltQGFQYTISyMCAJdf0wPE9PANsNMk
         /iGr9RLAGw8pxkRaitvxU51akR86YnqZskDqKrbOjZECD+kNEv1FZXiqH/3lLIYzs/GA
         bynQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QkhPHmDRDm9xz6GVeVMZJK2nYW4a7RE6/ZIT/O9pC1s=;
        b=twMRsbk9IDS+E5/moxJWK/H2ind0Ri3N8oxV2Mtes2GguYGVuZnf/06jHOvmLOOKUj
         AAJ2dFF9yNZRn3U4AaJPwYpDS/y9mUn6u6Tp3Wb2sA57idDYGslm2WrRYynRcZnDoHWF
         KLE4K41wAI2odW8YVVGnu14jRuRbf7FAYvXdOTNFggG2QMhDKQiyJGy3dZiZKEgniCKE
         co2PXk0xY3kCDDJfx6S0WdO7o+zbbSioZDusN1iHV8GNrM3RfG26MPO7TEyZqer9aenx
         QDdT28R4bBnaSMtXW87I/0NuDsdXYZkqoTRsEZlGQ/bi4m2eKEvlbeXOUdMWchA3ioGZ
         BkEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id a10si4305435wrr.429.2019.08.09.09.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 7BFAD305D348;
	Fri,  9 Aug 2019 19:01:18 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3571E305B7A9;
	Fri,  9 Aug 2019 19:01:17 +0300 (EEST)
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
Subject: [RFC PATCH v6 47/92] kvm: introspection: add KVMI_READ_PHYSICAL and KVMI_WRITE_PHYSICAL
Date: Fri,  9 Aug 2019 19:00:02 +0300
Message-Id: <20190809160047.8319-48-alazar@bitdefender.com>
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

These commands allows the introspection tool to read/write from/to the
guest memory.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Adalbert Lazăr <alazar@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst |  60 ++++++++++++++++
 include/uapi/linux/kvmi.h          |  11 +++
 virt/kvm/kvmi.c                    | 107 +++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h                |   7 ++
 virt/kvm/kvmi_msg.c                |  42 +++++++++++
 5 files changed, 227 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 69557c63ff94..eef32107837a 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -760,6 +760,66 @@ corresponding bit set to 1.
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 * -KVM_ENOMEM - not enough memory to add the page tracking structures
 
+14. KVMI_READ_PHYSICAL
+----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_read_physical {
+		__u64 gpa;
+		__u64 size;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	__u8 data[0];
+
+Reads from the guest memory.
+
+Currently, the size must be non-zero and the read must be restricted to
+one page (offset + size <= PAGE_SIZE).
+
+:Errors:
+
+* -KVM_EINVAL - the specified gpa is invalid
+
+15. KVMI_WRITE_PHYSICAL
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_write_physical {
+		__u64 gpa;
+		__u64 size;
+		__u8  data[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Writes into the guest memory.
+
+Currently, the size must be non-zero and the write must be restricted to
+one page (offset + size <= PAGE_SIZE).
+
+:Errors:
+
+* -KVM_EINVAL - the specified gpa is invalid
+
 Events
 ======
 
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 0b3139c52a30..be3f066f314e 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -191,6 +191,17 @@ struct kvmi_control_vm_events {
 	__u32 padding2;
 };
 
+struct kvmi_read_physical {
+	__u64 gpa;
+	__u64 size;
+};
+
+struct kvmi_write_physical {
+	__u64 gpa;
+	__u64 size;
+	__u8  data[0];
+};
+
 struct kvmi_vcpu_hdr {
 	__u16 vcpu;
 	__u16 padding1;
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index d2bebef98d8d..a84eb150e116 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -5,6 +5,7 @@
  * Copyright (C) 2017-2019 Bitdefender S.R.L.
  *
  */
+#include <linux/mmu_context.h>
 #include <uapi/linux/kvmi.h>
 #include "kvmi_int.h"
 #include <linux/kthread.h>
@@ -1220,6 +1221,112 @@ int kvmi_cmd_set_page_write_bitmap(struct kvmi *ikvm, u64 gpa,
 	return kvmi_set_gfn_access(ikvm->kvm, gfn, access, write_bitmap);
 }
 
+unsigned long gfn_to_hva_safe(struct kvm *kvm, gfn_t gfn)
+{
+	unsigned long hva;
+	int srcu_idx;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	hva = gfn_to_hva(kvm, gfn);
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+
+	return hva;
+}
+
+static long get_user_pages_remote_unlocked(struct mm_struct *mm,
+	unsigned long start,
+	unsigned long nr_pages,
+	unsigned int gup_flags,
+	struct page **pages)
+{
+	long ret;
+	struct task_struct *tsk = NULL;
+	struct vm_area_struct **vmas = NULL;
+	int locked = 1;
+
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages_remote(tsk, mm, start, nr_pages, gup_flags,
+		pages, vmas, &locked);
+	if (locked)
+		up_read(&mm->mmap_sem);
+	return ret;
+}
+
+static void *get_page_ptr(struct kvm *kvm, gpa_t gpa, struct page **page,
+			  bool write)
+{
+	unsigned int flags = write ? FOLL_WRITE : 0;
+	unsigned long hva;
+
+	*page = NULL;
+
+	hva = gfn_to_hva_safe(kvm, gpa_to_gfn(gpa));
+
+	if (kvm_is_error_hva(hva)) {
+		kvmi_err(IKVM(kvm), "Invalid gpa %llx\n", gpa);
+		return NULL;
+	}
+
+	if (get_user_pages_remote_unlocked(kvm->mm, hva, 1, flags, page) != 1) {
+		kvmi_err(IKVM(kvm),
+			 "Failed to get the page for hva %lx gpa %llx\n",
+			 hva, gpa);
+		return NULL;
+	}
+
+	return kmap_atomic(*page);
+}
+
+static void put_page_ptr(void *ptr, struct page *page)
+{
+	if (ptr)
+		kunmap_atomic(ptr);
+	if (page)
+		put_page(page);
+}
+
+int kvmi_cmd_read_physical(struct kvm *kvm, u64 gpa, u64 size, int(*send)(
+	struct kvmi *, const struct kvmi_msg_hdr *,
+	int err, const void *buf, size_t),
+	const struct kvmi_msg_hdr *ctx)
+{
+	int err, ec = 0;
+	struct page *page = NULL;
+	void *ptr_page = NULL, *ptr = NULL;
+	size_t ptr_size = 0;
+
+	ptr_page = get_page_ptr(kvm, gpa, &page, false);
+	if (!ptr_page) {
+		ec = -KVM_EINVAL;
+		goto out;
+	}
+
+	ptr = ptr_page + (gpa & ~PAGE_MASK);
+	ptr_size = size;
+
+out:
+	err = send(IKVM(kvm), ctx, ec, ptr, ptr_size);
+
+	put_page_ptr(ptr_page, page);
+	return err;
+}
+
+int kvmi_cmd_write_physical(struct kvm *kvm, u64 gpa, u64 size, const void *buf)
+{
+	struct page *page;
+	void *ptr;
+
+	ptr = get_page_ptr(kvm, gpa, &page, true);
+	if (!ptr)
+		return -KVM_EINVAL;
+
+	memcpy(ptr + (gpa & ~PAGE_MASK), buf, size);
+
+	put_page_ptr(ptr, page);
+
+	return 0;
+}
+
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable)
 {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 18c00dae0f2f..7bdff70d4309 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -174,6 +174,13 @@ int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access);
 int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access);
 int kvmi_cmd_get_page_write_bitmap(struct kvmi *ikvm, u64 gpa, u32 *bitmap);
 int kvmi_cmd_set_page_write_bitmap(struct kvmi *ikvm, u64 gpa, u32 bitmap);
+int kvmi_cmd_read_physical(struct kvm *kvm, u64 gpa, u64 size,
+			   int (*send)(struct kvmi *,
+					const struct kvmi_msg_hdr*,
+					int err, const void *buf, size_t),
+			   const struct kvmi_msg_hdr *ctx);
+int kvmi_cmd_write_physical(struct kvm *kvm, u64 gpa, u64 size,
+			    const void *buf);
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index f9efb52d49c3..9c20a9cfda42 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -34,8 +34,10 @@ static const char *const msg_IDs[] = {
 	[KVMI_GET_PAGE_WRITE_BITMAP] = "KVMI_GET_PAGE_WRITE_BITMAP",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
+	[KVMI_READ_PHYSICAL]         = "KVMI_READ_PHYSICAL",
 	[KVMI_SET_PAGE_ACCESS]       = "KVMI_SET_PAGE_ACCESS",
 	[KVMI_SET_PAGE_WRITE_BITMAP] = "KVMI_SET_PAGE_WRITE_BITMAP",
+	[KVMI_WRITE_PHYSICAL]        = "KVMI_WRITE_PHYSICAL",
 };
 
 static bool is_known_message(u16 id)
@@ -303,6 +305,44 @@ static int kvmi_get_vcpu(struct kvmi *ikvm, unsigned int vcpu_idx,
 	return 0;
 }
 
+static bool invalid_page_access(u64 gpa, u64 size)
+{
+	u64 off = gpa & ~PAGE_MASK;
+
+	return (size == 0 || size > PAGE_SIZE || off + size > PAGE_SIZE);
+}
+
+static int handle_read_physical(struct kvmi *ikvm,
+				const struct kvmi_msg_hdr *msg,
+				const void *_req)
+{
+	const struct kvmi_read_physical *req = _req;
+
+	if (invalid_page_access(req->gpa, req->size))
+		return -EINVAL;
+
+	return kvmi_cmd_read_physical(ikvm->kvm, req->gpa, req->size,
+				      kvmi_msg_vm_maybe_reply, msg);
+}
+
+static int handle_write_physical(struct kvmi *ikvm,
+				 const struct kvmi_msg_hdr *msg,
+				 const void *_req)
+{
+	const struct kvmi_write_physical *req = _req;
+	int ec;
+
+	if (invalid_page_access(req->gpa, req->size))
+		return -EINVAL;
+
+	if (msg->size < sizeof(*req) + req->size)
+		return -EINVAL;
+
+	ec = kvmi_cmd_write_physical(ikvm->kvm, req->gpa, req->size, req->data);
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
 static bool enable_spp(struct kvmi *ikvm)
 {
 	if (!ikvm->spp.initialized) {
@@ -431,8 +471,10 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_GET_PAGE_ACCESS]       = handle_get_page_access,
 	[KVMI_GET_PAGE_WRITE_BITMAP] = handle_get_page_write_bitmap,
 	[KVMI_GET_VERSION]           = handle_get_version,
+	[KVMI_READ_PHYSICAL]         = handle_read_physical,
 	[KVMI_SET_PAGE_ACCESS]       = handle_set_page_access,
 	[KVMI_SET_PAGE_WRITE_BITMAP] = handle_set_page_write_bitmap,
+	[KVMI_WRITE_PHYSICAL]        = handle_write_physical,
 };
 
 static int handle_event_reply(struct kvm_vcpu *vcpu,

