Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9F46C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F9262089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F9262089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 463F46B027E; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4169F6B0280; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B3866B0281; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D05446B027E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:07 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 21so1448425wmj.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Qp8I9hKj0axgqSM+ki1QLqtqi6sGL9OSrOxsJ+4Y5o=;
        b=fpjzYzHimZoaQTG9BZj8NNdQgH4xZCJb1vKroQgkVa/c00UGnIF22WR54pTg1ylF2w
         FrToilJvgANN3luRl0IEoQhFDZKI3GyK0X3f0HVYfsVbHHYsddXx5bcIXjLwVNFRRnoU
         vUKqG9nEAxjJh+JD8GsjUqc3rQQar2w+YYCuYwEaWfx9dcVT30LK5hr4QvhYy0BwZ29R
         w4pdFwxmJsrT8r6FO1tsBVnHGtyGSBfazI/mcVuXtPJhUT0gOAGTHU+D+TmnDERExw2O
         qOW09AWD8wy4vxRFL/a3oMBwdPwfhvi1AL2U7rJHSf0LwvjTw8tkhIhtOVqG+ZWIfAqg
         ZOEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUpMN18IDZz0nK/DPc/fBpXX6Zb1PH87y2S08pCGly6yAgOe7zS
	2vAcfGz2dHlFIHoyjjF4JQPkL0FfLBYMsXpjyHQXdvDmqvh8El7Hce4mfONoOnSRpzhyf6YCSmd
	eZK9ZAL97b8wiaBYla2qOdNnLGeHx2qjD6scSLjF4odAISH/A/W45CC4hAmIqFH9AOA==
X-Received: by 2002:a05:600c:21d3:: with SMTP id x19mr11546374wmj.45.1565366467324;
        Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzWq7Bajv0U/WI0yYd4nDNdk+ALavHxw5L5j/fwnzUH2Nm1C8aCbbdY/hFKfoNcB92/Ivu
X-Received: by 2002:a05:600c:21d3:: with SMTP id x19mr11546217wmj.45.1565366465530;
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366465; cv=none;
        d=google.com; s=arc-20160816;
        b=ZESW+BH+jP/7JXm1Jd5Dib34d5NcGAvugY+NAZ99Wyk3L7KnlGdhWVnE5rDYms5hXw
         HKe8Z+wZEzh04h3bye8P3Bm8/sSIZ4Ew8JYyrKZ4jNvtHWY3ltFyiJ8MK9d5xVauxaeE
         zhYqLgKUJ4t0yt6ndDWyZ/5UJa06nZAADNxSpoN+eTiTO/iDm5O0/BdiQ+KdmxRS7Mbd
         zpiBL+XdLgbkHiAToFGbBvmNW1nLU7EjTnzplRsI/Zm+Mg3BhuE39h0LDdCDwwZp6LyI
         HsDC8gZxGCNgAY5CdCicujzNrXhGqj1i/Plgd+lQ0+G4cTjgxJx/2CKwZX8qmi1Hj9Mx
         CYlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Qp8I9hKj0axgqSM+ki1QLqtqi6sGL9OSrOxsJ+4Y5o=;
        b=JSt0rZfjAwbJwZ0v/lOshRSLWE+H6ptboV0tlXEfQ/x0qm8a2cuEHMX1nPGzIbJZoJ
         KB9W3DtIyFnYYbBvOF+GDSbqVTgSjj/WuQi9oK72rz3kI5J0D0GWuN6NVKcGbgA+amv8
         R005I5ZHHKkspu6Yo1rIAM1EHv2bRXyQBlIM0KruSRul95ZdVdbGbEB1gTgir6ee3ejZ
         pCj+CXA9JzbleU5Hp7uwtujkmsyGDPvaPun+cigsEv/S9coJHvGZplXqxQZ2o9Ej8fr0
         +l1IiJUiwin9OrQJDqniBKF5zvklNMwZ4nF6Y85hwurYW7mnqEGjGrp7dPuZpI7PrRoj
         Bmdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id s13si85688439wrv.408.2019.08.09.09.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id DF35E305D341;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 96C2F305B7A1;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
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
Subject: [RFC PATCH v6 33/92] kvm: introspection: add KVMI_SET_PAGE_ACCESS
Date: Fri,  9 Aug 2019 18:59:48 +0300
Message-Id: <20190809160047.8319-34-alazar@bitdefender.com>
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

This command sets the spte access bits (rwx) for an array of guest
physical addresses (through the page track subsystem).

These pages, with the requested access bits, are also kept in a radix
tree in order to filter out the #PF events which are of no interest to
the introspection tool.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 54 ++++++++++++++++++++++++++
 arch/x86/kvm/kvmi.c                | 36 ++++++++++++++++++
 include/uapi/linux/kvmi.h          | 15 ++++++++
 virt/kvm/kvmi.c                    | 61 ++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h                |  4 ++
 virt/kvm/kvmi_msg.c                | 13 +++++++
 6 files changed, 183 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index c27fea73ccfb..b64a030507cf 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -563,6 +563,60 @@ EPT view (0 is primary). On all other hardware it must be zero.
 * -KVM_EAGAIN - the selected vCPU can't be introspected yet
 * -KVM_ENOMEM - not enough memory to allocate the reply
 
+10. KVMI_SET_PAGE_ACCESS
+------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_set_page_access {
+		__u16 view;
+		__u16 count;
+		__u32 padding;
+		struct kvmi_page_access_entry entries[0];
+	};
+
+where::
+
+	struct kvmi_page_access_entry {
+		__u64 gpa;
+		__u8 access;
+		__u8 padding1;
+		__u16 padding2;
+		__u32 padding3;
+	};
+
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Sets the spte access bits (rwx) for an array of ``count`` guest physical
+addresses.
+
+The command will fail with -KVM_EINVAL if any of the specified combination
+of access bits is not supported.
+
+The command will make the changes in order and it will stop on the first
+error. The introspection tool should handle the rollback.
+
+In order to 'forget' an address, all the access bits ('rwx') must be set.
+
+:Errors:
+
+* -KVM_EINVAL - the specified access bits combination is invalid
+* -KVM_EINVAL - the selected SPT view is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EINVAL - the message size is invalid
+* -KVM_EOPNOTSUPP - a SPT view was selected but the hardware doesn't support it
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOMEM - not enough memory to add the page tracking structures
+
 Events
 ======
 
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 59cf33127b4b..3238ef176ad6 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -224,3 +224,39 @@ int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
 	return 0;
 }
 
+int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const struct kvmi_set_page_access *req)
+{
+	const struct kvmi_page_access_entry *entry = req->entries;
+	const struct kvmi_page_access_entry *end = req->entries + req->count;
+	u8 unknown_bits = ~(KVMI_PAGE_ACCESS_R | KVMI_PAGE_ACCESS_W
+			    | KVMI_PAGE_ACCESS_X);
+	int ec = 0;
+
+	if (req->padding)
+		return -KVM_EINVAL;
+
+	if (msg->size < sizeof(*req) + (end - entry) * sizeof(*entry))
+		return -KVM_EINVAL;
+
+	if (req->view != 0)	/* TODO */
+		return -KVM_EOPNOTSUPP;
+
+	for (; entry < end; entry++) {
+		if ((entry->access & unknown_bits) || entry->padding1
+				|| entry->padding2 || entry->padding3)
+			ec = -KVM_EINVAL;
+		else
+			ec = kvmi_cmd_set_page_access(ikvm, entry->gpa,
+						      entry->access);
+		if (ec)
+			kvmi_warn(ikvm, "%s: %llx %x padding %x,%x,%x",
+				  __func__, entry->gpa, entry->access,
+				  entry->padding1, entry->padding2,
+				  entry->padding3);
+	}
+
+	return ec;
+}
+
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 047436a0bdc0..2ddbb1fea807 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -127,6 +127,21 @@ struct kvmi_get_page_access_reply {
 	__u8 access[0];
 };
 
+struct kvmi_page_access_entry {
+	__u64 gpa;
+	__u8 access;
+	__u8 padding1;
+	__u16 padding2;
+	__u32 padding3;
+};
+
+struct kvmi_set_page_access {
+	__u16 view;
+	__u16 count;
+	__u32 padding;
+	struct kvmi_page_access_entry entries[0];
+};
+
 struct kvmi_get_vcpu_info_reply {
 	__u64 tsc_speed;
 };
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 20505e4c4b5f..4a9a4430a460 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -73,6 +73,57 @@ static int kvmi_get_gfn_access(struct kvmi *ikvm, const gfn_t gfn,
 	return m ? 0 : -1;
 }
 
+static int kvmi_set_gfn_access(struct kvm *kvm, gfn_t gfn, u8 access)
+{
+	struct kvmi_mem_access *m;
+	struct kvmi_mem_access *__m;
+	struct kvmi *ikvm = IKVM(kvm);
+	int err = 0;
+	int idx;
+
+	m = kmem_cache_zalloc(radix_cache, GFP_KERNEL);
+	if (!m)
+		return -KVM_ENOMEM;
+
+	m->gfn = gfn;
+	m->access = access;
+
+	if (radix_tree_preload(GFP_KERNEL)) {
+		err = -KVM_ENOMEM;
+		goto exit;
+	}
+
+	idx = srcu_read_lock(&kvm->srcu);
+	spin_lock(&kvm->mmu_lock);
+	write_lock(&ikvm->access_tree_lock);
+
+	__m = __kvmi_get_gfn_access(ikvm, gfn);
+	if (__m) {
+		__m->access = access;
+		kvmi_arch_update_page_tracking(kvm, NULL, __m);
+		if (access == full_access) {
+			radix_tree_delete(&ikvm->access_tree, gfn);
+			kmem_cache_free(radix_cache, __m);
+		}
+	} else {
+		radix_tree_insert(&ikvm->access_tree, gfn, m);
+		kvmi_arch_update_page_tracking(kvm, NULL, m);
+		m = NULL;
+	}
+
+	write_unlock(&ikvm->access_tree_lock);
+	spin_unlock(&kvm->mmu_lock);
+	srcu_read_unlock(&kvm->srcu, idx);
+
+	radix_tree_preload_end();
+
+exit:
+	if (m)
+		kmem_cache_free(radix_cache, m);
+
+	return err;
+}
+
 static bool kvmi_restricted_access(struct kvmi *ikvm, gpa_t gpa, u8 access)
 {
 	u8 allowed_access;
@@ -1081,6 +1132,16 @@ int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access)
 	return 0;
 }
 
+int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access)
+{
+	gfn_t gfn = gpa_to_gfn(gpa);
+	u8 ignored_access;
+
+	kvmi_get_gfn_access(ikvm, gfn, &ignored_access);
+
+	return kvmi_set_gfn_access(ikvm->kvm, gfn, access);
+}
+
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable)
 {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 00dc5cf72f88..c54be93349b7 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -160,6 +160,7 @@ void *kvmi_msg_alloc(void);
 void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
 int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access);
+int kvmi_cmd_set_page_access(struct kvmi *ikvm, u64 gpa, u8 access);
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
@@ -180,6 +181,9 @@ int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
 				  const struct kvmi_get_page_access *req,
 				  struct kvmi_get_page_access_reply **dest,
 				  size_t *dest_size);
+int kvmi_arch_cmd_set_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const struct kvmi_set_page_access *req);
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 09ad17479abb..c150e7bdd440 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -32,6 +32,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
+	[KVMI_SET_PAGE_ACCESS]       = "KVMI_SET_PAGE_ACCESS",
 };
 
 static bool is_known_message(u16 id)
@@ -339,6 +340,17 @@ static int handle_get_page_access(struct kvmi *ikvm,
 	return err;
 }
 
+static int handle_set_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const void *req)
+{
+	int ec;
+
+	ec = kvmi_arch_cmd_set_page_access(ikvm, msg, req);
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
+}
+
 static bool invalid_vcpu_hdr(const struct kvmi_vcpu_hdr *hdr)
 {
 	return hdr->padding1 || hdr->padding2;
@@ -356,6 +368,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
 	[KVMI_GET_PAGE_ACCESS]       = handle_get_page_access,
 	[KVMI_GET_VERSION]           = handle_get_version,
+	[KVMI_SET_PAGE_ACCESS]       = handle_set_page_access,
 };
 
 static int handle_event_reply(struct kvm_vcpu *vcpu,

