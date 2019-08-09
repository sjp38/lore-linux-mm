Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B80F2C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53920214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53920214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9AE96B02E1; Fri,  9 Aug 2019 12:02:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E733E6B02E2; Fri,  9 Aug 2019 12:02:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D61D26B02E3; Fri,  9 Aug 2019 12:02:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 859CD6B02E1
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:02:48 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b135so1065849wmg.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:02:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5dYm/m2ik1q9vsz+PfO5GkzWEFmR5EG17a+eqHO9q/c=;
        b=mJTVclRjI20j80fSsCO13M8CReifhoJX/yfsgiVFapnpKXDLrCMluENT4uBZtNEf/8
         5OFT4+2AcS2QhKlUdHVSI0li1peye18a6aL/P9gppBNXaIAMl7UuHqgCqyHLBLFqbjqy
         956h/l3uJ4eQn8oaKmbVFNCTjTkcHSK3izVR/TjDlrI39OcziJ4bDxjKWVIyNJKlSTK4
         iyz7aQSiV2+LY0bTpWspLTdsrpXRrxDVhW1rOMChwJprDntlsd9E4GxSZQ5yLsyj9GZU
         Auh6UYvqf57kcFQGZQhP7GI+YwCnwzZkynMXqoD/eRydsbT8g9LgX4kjXV34+1JWvGgh
         D22g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXRwBmnaSUOMDmXsZdBnu8oa+H3FyCYV4BchUDycQirly/kQDa7
	KyWQoIv7uhYDrxmJVsXlqtlpYDbO9MrURpz5cz8gPz2T3NKzbtsbAxlkE5ya6k/I6MS/sZLF2Of
	GB23ZYsrGI5dcdNtv6WKIJLDCFeIhkpq8Oraz3pMx6pnKI4vkLklU87rVmdMt/bFqSg==
X-Received: by 2002:adf:e40e:: with SMTP id g14mr23070579wrm.161.1565366568093;
        Fri, 09 Aug 2019 09:02:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsPKpDE4yQYqKroQzAX5qDemZViEEkVdigpuT79zwxXQOXG9yruCvKUK/JE2+MWZ/2qP9J
X-Received: by 2002:adf:e40e:: with SMTP id g14mr23060887wrm.161.1565366465221;
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366465; cv=none;
        d=google.com; s=arc-20160816;
        b=vEy8paknZb+Ya8FrH8QwMSD87wqWc9vihbREXMfGO4XWUVndynKwOj6fp97dKYIutA
         Qh0ARJYmEa0pxZi7DkXyxKicNIN2ugbokEa2XVB+5TPOUeGnqsDIPQQNZ4UeCsJWbj6i
         IEgDdCMQewSiLkMNH2wsgNZLx2FgVS40cM6ctLeQYO8BVww1Ghz55u7JiYAjODfWksmx
         bUkL/v11wwQfaHo2rKIBvDSgpXek9VDPNQFZuOf8UPs70f7NZWz3TfGHa3CCURc3Y5G7
         8QOQnIoF7QdnAX8Ikn8RGItJPcZ7Wt5Mn/xN5OIBlaa+dZBQytDuVxeMxLZF1mHc7+/H
         +OYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5dYm/m2ik1q9vsz+PfO5GkzWEFmR5EG17a+eqHO9q/c=;
        b=vYaXVUoq9WH7GCZk9wDMfGo1TYZW8vlC6xdGyU9KSLvMxeLCsOUyKhZe8IJjCIitGk
         B3RdKmWOwnROIgAJgM9EEaieKVM0OBjISm+0+ExkGxRUKaP3M284A7tVGltv001alyhV
         3l0MV0kTK4Z/uSGP02h6CH+G7/7RN6RA2e5QM4jH4Jj8mLl2p5ZYu0TsGtE4mw6KiG30
         uv8kZcnF6XlaRbdSb+gneowhAgiGvwgX1boGnirLj//exZYSR+sZifnCvTOkc2WmNMPc
         QhchAYil2UVIjYcVFyr65EprBBbFKznsBQ+Vq9rsORVYMgOox0JwUlnhTmYyqUncC3dI
         B4SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id g6si4054016wrv.368.2019.08.09.09.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 99999305D340;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3DF27305B7AB;
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
Subject: [RFC PATCH v6 32/92] kvm: introspection: add KVMI_GET_PAGE_ACCESS
Date: Fri,  9 Aug 2019 18:59:47 +0300
Message-Id: <20190809160047.8319-33-alazar@bitdefender.com>
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

Returns the spte access bits (rwx) for an array of guest physical
addresses.

It does this by checking the radix tree in which only the spte bits
"enforced" by the introspection tool are saved. This information should
already be known by the tool. Not to mention that the KVMI_EVENT_PF
events are sent only for EPT violation caused by these restrictions.
So, we might drop this command.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 54 ++++++++++++++++++++++++++++++
 arch/x86/kvm/kvmi.c                | 41 +++++++++++++++++++++++
 include/uapi/linux/kvmi.h          | 11 ++++++
 virt/kvm/kvmi.c                    |  9 +++++
 virt/kvm/kvmi_int.h                |  6 ++++
 virt/kvm/kvmi_msg.c                | 17 ++++++++++
 6 files changed, 138 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 0fc51b57b1e8..c27fea73ccfb 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -509,6 +509,60 @@ by the *KVMI_CONTROL_VM_EVENTS* command.
 * -KVM_EPERM - the access is restricted by the host
 * -KVM_EOPNOTSUPP - one the events can't be intercepted in the current setup
 
+9. KVMI_GET_PAGE_ACCESS
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_page_access {
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
+	struct kvmi_get_page_access_reply {
+		__u8 access[0];
+	};
+
+Returns the spte access bits (rwx) for an array of ``count`` guest
+physical addresses.
+
+The valid access bits for *KVMI_GET_PAGE_ACCESS* and *KVMI_SET_PAGE_ACCESS*
+are::
+
+	KVMI_PAGE_ACCESS_R
+	KVMI_PAGE_ACCESS_W
+	KVMI_PAGE_ACCESS_X
+
+By default, for any guest physical address, the returned access mode will
+be 'rwx' (all the above bits). If the introspection tool must prevent
+the code execution from a guest page, for example, it should use the
+KVMI_SET_PAGE_ACCESS command to set the 'rw' bits for any guest physical
+addresses contained in that page. Of course, in order to receive
+page fault events when these violations take place, the KVMI_CONTROL_EVENTS
+command must be used to enable this type of event (KVMI_EVENT_PF).
+
+On Intel hardware with multiple EPT views, the ``view`` argument selects the
+EPT view (0 is primary). On all other hardware it must be zero.
+
+:Errors:
+
+* -KVM_EINVAL - the selected SPT view is invalid
+* -KVM_EINVAL - padding is not zero
+* -KVM_EOPNOTSUPP - a SPT view was selected but the hardware doesn't support it
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
 Events
 ======
 
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 121819f9c487..59cf33127b4b 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -183,3 +183,44 @@ void kvmi_arch_update_page_tracking(struct kvm *kvm,
 		}
 	}
 }
+
+int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const struct kvmi_get_page_access *req,
+				  struct kvmi_get_page_access_reply **dest,
+				  size_t *dest_size)
+{
+	struct kvmi_get_page_access_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	size_t k, n = req->count;
+	int ec = 0;
+
+	if (req->padding)
+		return -KVM_EINVAL;
+
+	if (msg->size < sizeof(*req) + req->count * sizeof(req->gpa[0]))
+		return -KVM_EINVAL;
+
+	if (req->view != 0)	/* TODO */
+		return -KVM_EOPNOTSUPP;
+
+	rpl_size = sizeof(*rpl) + sizeof(rpl->access[0]) * n;
+	rpl = kvmi_msg_alloc_check(rpl_size);
+	if (!rpl)
+		return -KVM_ENOMEM;
+
+	for (k = 0; k < n && ec == 0; k++)
+		ec = kvmi_cmd_get_page_access(ikvm, req->gpa[k],
+					      &rpl->access[k]);
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
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 40a5c304c26f..047436a0bdc0 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -116,6 +116,17 @@ struct kvmi_get_guest_info_reply {
 	__u32 padding[3];
 };
 
+struct kvmi_get_page_access {
+	__u16 view;
+	__u16 count;
+	__u32 padding;
+	__u64 gpa[0];
+};
+
+struct kvmi_get_page_access_reply {
+	__u8 access[0];
+};
+
 struct kvmi_get_vcpu_info_reply {
 	__u64 tsc_speed;
 };
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 0264115a7f4d..20505e4c4b5f 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -1072,6 +1072,15 @@ void kvmi_handle_requests(struct kvm_vcpu *vcpu)
 	kvmi_put(vcpu->kvm);
 }
 
+int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access)
+{
+	gfn_t gfn = gpa_to_gfn(gpa);
+
+	kvmi_get_gfn_access(ikvm, gfn, access);
+
+	return 0;
+}
+
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable)
 {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index d478d9a2e769..00dc5cf72f88 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -159,6 +159,7 @@ int kvmi_msg_send_unhook(struct kvmi *ikvm);
 void *kvmi_msg_alloc(void);
 void *kvmi_msg_alloc_check(size_t size);
 void kvmi_msg_free(void *addr);
+int kvmi_cmd_get_page_access(struct kvmi *ikvm, u64 gpa, u8 *access);
 int kvmi_cmd_control_events(struct kvm_vcpu *vcpu, unsigned int event_id,
 			    bool enable);
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
@@ -174,6 +175,11 @@ void kvmi_handle_common_event_actions(struct kvm_vcpu *vcpu, u32 action,
 void kvmi_arch_update_page_tracking(struct kvm *kvm,
 				    struct kvm_memory_slot *slot,
 				    struct kvmi_mem_access *m);
+int kvmi_arch_cmd_get_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const struct kvmi_get_page_access *req,
+				  struct kvmi_get_page_access_reply **dest,
+				  size_t *dest_size);
 void kvmi_arch_setup_event(struct kvm_vcpu *vcpu, struct kvmi_event *ev);
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access);
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index 0642356d4e04..09ad17479abb 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -29,6 +29,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_EVENT]                 = "KVMI_EVENT",
 	[KVMI_EVENT_REPLY]           = "KVMI_EVENT_REPLY",
 	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
+	[KVMI_GET_PAGE_ACCESS]       = "KVMI_GET_PAGE_ACCESS",
 	[KVMI_GET_VCPU_INFO]         = "KVMI_GET_VCPU_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
@@ -323,6 +324,21 @@ static int handle_control_cmd_response(struct kvmi *ikvm,
 	return err;
 }
 
+static int handle_get_page_access(struct kvmi *ikvm,
+				  const struct kvmi_msg_hdr *msg,
+				  const void *req)
+{
+	struct kvmi_get_page_access_reply *rpl = NULL;
+	size_t rpl_size = 0;
+	int err, ec;
+
+	ec = kvmi_arch_cmd_get_page_access(ikvm, msg, req, &rpl, &rpl_size);
+
+	err = kvmi_msg_vm_maybe_reply(ikvm, msg, ec, rpl, rpl_size);
+	kvmi_msg_free(rpl);
+	return err;
+}
+
 static bool invalid_vcpu_hdr(const struct kvmi_vcpu_hdr *hdr)
 {
 	return hdr->padding1 || hdr->padding2;
@@ -338,6 +354,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
 	[KVMI_CONTROL_VM_EVENTS]     = handle_control_vm_events,
 	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
+	[KVMI_GET_PAGE_ACCESS]       = handle_get_page_access,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };
 

