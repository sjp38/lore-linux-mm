Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11714C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E6842089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E6842089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C79446B0295; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2AC36B0296; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACA536B0297; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAA66B0296
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a5so39084732wrt.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LfSxYhqQOdjlPihS/Lqj9mf8IlThrlGg3X1ylYQLPYo=;
        b=Shxlw5lqJFVIoV3YdqSt/+Q442QzSdoNUEgHEeMJB7GCKvuIF6NHr+mZkXDLIvv6Pt
         pYmPAa5c+boc9Z/29irXBJXvuwDkfRw3OJ0I7QH5W6rTi30l+T/BNeDi5HZ+ruJoMCFq
         s6A0kUOBGDYErwx6SiiXIkZh6Uz3r6zGgYRCbvFkxPphw5nR8nSn6o79Dd/p13JS7Fy0
         gc8wnykQ3dJnX2g4YLcBaIGP6sN1woJQQQk7T62AuX3g/hX4d9YpIT7mzIncLKPXmQ/n
         HPHiHAvlP6hd8dHsFh+UqyDAAv9Hi4sJYmS5f02TfvAOrQSx15nqnREtzcbYuKIgW9p9
         kgSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUA748e/NWceo0w9uQuKaxlQGwxHDfdaxYuOiFMSpJIOayDdAnP
	i3SghbF0u0zQ3NBLQw2vp8tRG2yqfEezCW+hQGpzPFypW40n4rX4x08dD25ZOeDy8/0EKpDacTl
	qQS5F/YOiy0pNduPCyFKVC1saAxFhTe6tbKb5jADvza55xJ8sGSt1bkrPJF7WQEgSEg==
X-Received: by 2002:a5d:6307:: with SMTP id i7mr12074343wru.144.1565366487982;
        Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1RT0Jjkx0h2KAB4kDc3j3pc8J6hjLaAeYnUttPUS98M0N7pKPgq5bzJadqbEM0+hloFiA
X-Received: by 2002:a5d:6307:: with SMTP id i7mr12074203wru.144.1565366486499;
        Fri, 09 Aug 2019 09:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366486; cv=none;
        d=google.com; s=arc-20160816;
        b=H37h2rYXDVV26QsX3rUHudvM4aEuIifXmDTY8QyRc9BDfg6JTFTI4H1HPbaR6HsQbl
         3b2zwR8So70rB2Epa/NvByTqFb5kmRPUxw3budIJo3qPZe4DtnrecZqmOTJmd4v/aNeB
         jSA2NYmSs/khPQCHOdYGLXT4qNSen/pYkK70G0+1xjVQUvT9CuN6OmVt0YNPgP6pLMYU
         xwInBYyW85b6dy99wtPga288mOGKOhD0B6Nfvq1nwea/2j668vg9WWXVrmVgGS7CdlJO
         AGZaXJl8hUz2gWjk7RcD4t1K2V+5kmsvx+x5R9gpChV2tobN5Vspq1jhNip/gvTOUdQ7
         ibDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LfSxYhqQOdjlPihS/Lqj9mf8IlThrlGg3X1ylYQLPYo=;
        b=FcsQcmLKfavhZLoKCoB5R7rxeA+2I0NSRqAbgPw/JuS9X0W7WS6ftcd6AdG912yYiF
         au2xldMzNZlBitJeRJTmi7uoHvbuBhQhxJE4BkEEfU+brjue4QitSd9hidiZtY+ydZj9
         W9feRentwVbLIOj0k+ii52lK7Mk8kBwErV+rv076T9Q93/biOap7DKZtuPXtt4RfAmuZ
         z5NfexjPp2FP+qo7B3aa5wF0IlRawHYUEd4cob4kQWFNknA78RH6i/ZH/b3y2y6JQe/U
         J6AouK9ECIOAcC/vEteGMy3LsClVxp/BVi+ntSilj3H5tcr83Rr9GnXQeMPIXo2odwuA
         nO4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id o24si4259330wmh.34.2019.08.09.09.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id D9B4C305D350;
	Fri,  9 Aug 2019 19:01:25 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 81218305B7A1;
	Fri,  9 Aug 2019 19:01:25 +0300 (EEST)
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
Subject: [RFC PATCH v6 59/92] kvm: introspection: add KVMI_EVENT_XSETBV
Date: Fri,  9 Aug 2019 19:00:14 +0300
Message-Id: <20190809160047.8319-60-alazar@bitdefender.com>
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

This event is sent when the extended control register XCR0 is going to
be changed.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 25 +++++++++++++++++++
 arch/x86/include/asm/kvmi_host.h   |  5 ++++
 arch/x86/kvm/kvmi.c                | 39 ++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c                 |  5 ++++
 4 files changed, 74 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index e58f0e22f188..1d2431639770 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1444,3 +1444,28 @@ register (see **KVMI_CONTROL_EVENTS**).
 
 ``kvmi_event``, the MSR number, the old value and the new value are
 sent to the introspector. The *CONTINUE* action will set the ``new_val``.
+
+8. KVMI_EVENT_XSETBV
+--------------------
+
+:Architectures: x86
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
+This event is sent when the extended control register XCR0 is going
+to be changed and the introspection has been enabled for this event
+(see *KVMI_CONTROL_EVENTS*).
+
+``kvmi_event`` is sent to the introspector.
diff --git a/arch/x86/include/asm/kvmi_host.h b/arch/x86/include/asm/kvmi_host.h
index 86d90b7bed84..3f066e7feee2 100644
--- a/arch/x86/include/asm/kvmi_host.h
+++ b/arch/x86/include/asm/kvmi_host.h
@@ -15,6 +15,7 @@ bool kvmi_msr_event(struct kvm_vcpu *vcpu, struct msr_data *msr);
 bool kvmi_monitored_msr(struct kvm_vcpu *vcpu, u32 msr);
 bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
 		   unsigned long old_value, unsigned long *new_value);
+void kvmi_xsetbv_event(struct kvm_vcpu *vcpu);
 
 #else /* CONFIG_KVM_INTROSPECTION */
 
@@ -35,6 +36,10 @@ static inline bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
 	return true;
 }
 
+static inline void kvmi_xsetbv_event(struct kvm_vcpu *vcpu)
+{
+}
+
 #endif /* CONFIG_KVM_INTROSPECTION */
 
 #endif /* _ASM_X86_KVMI_HOST_H */
diff --git a/arch/x86/kvm/kvmi.c b/arch/x86/kvm/kvmi.c
index 0114ed66f4f3..0e9c91d2f282 100644
--- a/arch/x86/kvm/kvmi.c
+++ b/arch/x86/kvm/kvmi.c
@@ -389,6 +389,45 @@ bool kvmi_cr_event(struct kvm_vcpu *vcpu, unsigned int cr,
 	return ret;
 }
 
+static u32 kvmi_send_xsetbv(struct kvm_vcpu *vcpu)
+{
+	int err, action;
+
+	err = kvmi_send_event(vcpu, KVMI_EVENT_XSETBV, NULL, 0,
+			      NULL, 0, &action);
+	if (err)
+		return KVMI_EVENT_ACTION_CONTINUE;
+
+	return action;
+}
+
+static void __kvmi_xsetbv_event(struct kvm_vcpu *vcpu)
+{
+	u32 action;
+
+	action = kvmi_send_xsetbv(vcpu);
+	switch (action) {
+	case KVMI_EVENT_ACTION_CONTINUE:
+		break;
+	default:
+		kvmi_handle_common_event_actions(vcpu, action, "XSETBV");
+	}
+}
+
+void kvmi_xsetbv_event(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm;
+
+	ikvm = kvmi_get(vcpu->kvm);
+	if (!ikvm)
+		return;
+
+	if (is_event_enabled(vcpu, KVMI_EVENT_XSETBV))
+		__kvmi_xsetbv_event(vcpu);
+
+	kvmi_put(vcpu->kvm);
+}
+
 bool kvmi_arch_pf_event(struct kvm_vcpu *vcpu, gpa_t gpa, gva_t gva,
 			u8 access)
 {
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 05ff23180355..278a286ba262 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -868,6 +868,11 @@ static int __kvm_set_xcr(struct kvm_vcpu *vcpu, u32 index, u64 xcr)
 
 int kvm_set_xcr(struct kvm_vcpu *vcpu, u32 index, u64 xcr)
 {
+#ifdef CONFIG_KVM_INTROSPECTION
+	if (xcr != vcpu->arch.xcr0)
+		kvmi_xsetbv_event(vcpu);
+#endif /* CONFIG_KVM_INTROSPECTION */
+
 	if (kvm_x86_ops->get_cpl(vcpu) != 0 ||
 	    __kvm_set_xcr(vcpu, index, xcr)) {
 		kvm_inject_gp(vcpu, 0);

