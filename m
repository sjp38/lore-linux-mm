Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85E87C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 287402089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 287402089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796776B0293; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74B6C6B0295; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6354E6B0297; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 162BF6B0293
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:28 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j10so3893175wrb.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DiQE1S1ZZkQXnne2PNnTbedvnTzw0WiHKgWhPeB5E7M=;
        b=P1NT4rpWYlpfolcMAxlCLL60fi0GhJatn8z0SjwokjdbIF1pN559Y2eSrZYRduJa8E
         s5RzDaXTu4ItVHMgxcWJEgrggJC/qNoBcRv0/VU7Tqf1cA02UbapwpsZ0Jc9TMr8JW0Q
         8FO5P/NL3Q2brPFVxB9S9sYaclcj9eDApPKbTNOGFj2SzZnE6hErSPb/nOUX8S/3pUTV
         mLs4G8qb2ffFnJHlD0/3zbzrsfg2zWPXxNshMdIC5jqg/T6vrTYmrepl7fy5MB4xbI6b
         KJ/0/XmAlF/J72n7Pokn/UB05EYq8jeYzpCUG6k9DUzgHtLZLb7BFSZftTOnbx51hSII
         dJsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVFQm1j8w0r8FVAlv4R0joZphcDxcwZ/39umr4Wf/xrEe6dsLZZ
	Hvf9HG9I0c/wLmEjs55iXREOkx0B4yh+oHwvnzcSrpgTe7ZCvHt56RN4AOVa7gV35e/J+misV/c
	RGjRas6qF3FMnyQol8Ue/htPUC0N0/cg7t9ea0tfKC1LayMDOJyU4wKSixNYkvannuA==
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr7475048wrm.265.1565366487677;
        Fri, 09 Aug 2019 09:01:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEHF6KF+jog7uu+WTLDUSfeq6S0LYhxbsz27RCxfdvvfXBuAf/TLzU8Vz8MqArBqeuZEK6
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr7474978wrm.265.1565366486784;
        Fri, 09 Aug 2019 09:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366486; cv=none;
        d=google.com; s=arc-20160816;
        b=FFz/n871KpKOJFxAVbhwXkqL5I9TpA8GJZYlrWzbAr5+uBXkB9/iUip78Sr5Ss4Jtt
         jj+Nb8u89AouqK1jmZVk6I5lT7ca4YxJBsn1cOqY8UJGo18jFxB2/hq7Uq6+lqFrdKfr
         eQr5ySvxLUdC8drh+c34t22KRJDwkgB68++yJV5sywAfMmJ2LRMJnk46Kf7kDnX4gOYQ
         daOfSgFZrSam7FnZwpBSxjfg4FpvFrnmwWmj0J5EEalij2FYqdCh0rpqFX/DZSwKK6KH
         UU6tuYqtp/hZEeXaxD8wp4dwH3rQ/rv/TNitG9lpYg39yd/4vjVoK/tDOO/wbqiKHfZb
         +6ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DiQE1S1ZZkQXnne2PNnTbedvnTzw0WiHKgWhPeB5E7M=;
        b=uyN4J4F50HabtM9s6VRM00aLBsZQz2fz10NKMGYxwW58F8AbeIIVDwmV7Ncyh3Sqfg
         Z3ZbOO1djEan8I9AONFHlNaJTL4wy7kOve/tlDz32lrO0JQcTXmYaoJRCi3xUfdZKhoR
         t+RPNJieAwg1uQ4M0nSxb42qChjkV7qRkgfkRLBYfDc/kmR+lG5XITJzu24acwaGsWvO
         xby3KIANB3bcu8V+hFWdkQm0YH7+Y+e3qo3NbKAgL5aKFicxcZe+oOjBT9q0EkwGKQvz
         DEGvH7OMdkSZdsRF3/abd84acTMSm3c1RuaXx21I6a3S9nnw+dAy1XmUoQg+8VMsMZ5U
         bphw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id h7si1459194wmc.110.2019.08.09.09.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 3B25D305D351;
	Fri,  9 Aug 2019 19:01:26 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id D37A5305B7A0;
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
Subject: [RFC PATCH v6 60/92] kvm: x86: add kvm_arch_vcpu_set_guest_debug()
Date: Fri,  9 Aug 2019 19:00:15 +0300
Message-Id: <20190809160047.8319-61-alazar@bitdefender.com>
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

This function is need in order to intercept breakpoints and send
KVMI_EVENT_BREAKPOINT events to the introspection tool.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c       | 18 +++++++++++++-----
 include/linux/kvm_host.h |  2 ++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 278a286ba262..e633f297e86d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8747,14 +8747,12 @@ int kvm_arch_vcpu_ioctl_set_sregs(struct kvm_vcpu *vcpu,
 	return ret;
 }
 
-int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
-					struct kvm_guest_debug *dbg)
+int kvm_arch_vcpu_set_guest_debug(struct kvm_vcpu *vcpu,
+				  struct kvm_guest_debug *dbg)
 {
 	unsigned long rflags;
 	int i, r;
 
-	vcpu_load(vcpu);
-
 	if (dbg->control & (KVM_GUESTDBG_INJECT_DB | KVM_GUESTDBG_INJECT_BP)) {
 		r = -EBUSY;
 		if (vcpu->arch.exception.pending)
@@ -8800,10 +8798,20 @@ int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
 	r = 0;
 
 out:
-	vcpu_put(vcpu);
 	return r;
 }
 
+int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
+					struct kvm_guest_debug *dbg)
+{
+	int ret;
+
+	vcpu_load(vcpu);
+	ret = kvm_arch_vcpu_set_guest_debug(vcpu, dbg);
+	vcpu_put(vcpu);
+	return ret;
+}
+
 /*
  * Translate a guest virtual address to a guest physical address.
  */
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 3aad3b96107b..691c24598b4d 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -804,6 +804,8 @@ int kvm_arch_vcpu_ioctl_set_mpstate(struct kvm_vcpu *vcpu,
 				    struct kvm_mp_state *mp_state);
 int kvm_arch_vcpu_ioctl_set_guest_debug(struct kvm_vcpu *vcpu,
 					struct kvm_guest_debug *dbg);
+int kvm_arch_vcpu_set_guest_debug(struct kvm_vcpu *vcpu,
+				  struct kvm_guest_debug *dbg);
 int kvm_arch_vcpu_ioctl_run(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run);
 void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
 				  struct kvm_xsave *guest_xsave);

