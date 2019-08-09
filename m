Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 073FEC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9145D2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9145D2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 526B96B0266; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D7216B0271; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39F346B0270; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id F039A6B0266
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:59 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x12so1339127wrw.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TSZ0Sdd6A4ffCRtX/c6eCxL67k6xtFLlPM0mgEv7AAI=;
        b=odCSfMTSPJFUxwuw47pMNETEDyudrxsmx22BKYYiN4wHr6agBZnDRpxAyVA/fN0/Z0
         3STaygNTNQS/VA5pD9UOXXkbfEuejnFJPu76LGOKxUyDcbWXzSPt7W2CdOBqflcYLpkW
         TtRMoJ5Dao3HdOSGAhzsBPXyLg+cyJ78q5EAYkW+/vKJg4ds22L4d+NiOMe955B+fuv2
         hKSG7YFK3Q/fH3QFX/GZMdp6q3H7Nd+32Rl24cMUqCGtwSjHBgRNutHc4e1lz3sclJrT
         C3t6gWqxgnkN0eBRSZWyRXUWjcWKKYPStNF0h9UJL18SMnn5qNvos3A9udK5fV62D4Ju
         QKeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW57LmN+9Hs6FaAH76Zy0HnAD7aY4qOH5a6+5QHBGF2iepGVDrt
	9LiTLQJ47W6+rZUx8xjHZB4HROAN/zredrlkiW+hZlqGEbpUku3hlmBYIQJAfRATom27oX3mC7f
	DjjLvILKeUSZL9hpAa7K7+IDQfTHUI64IvQBrnBVu8b6YBGyK7cX0MR5PAXrApN35SA==
X-Received: by 2002:a5d:53c1:: with SMTP id a1mr25205074wrw.185.1565366459551;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd1o7hWOge3rwPg5meGrL/HWm7WH3+YY3BSAoIM+Dh1ySLdOHzDnSScRHf0pDJsT8bds2O
X-Received: by 2002:a5d:53c1:: with SMTP id a1mr25204931wrw.185.1565366458026;
        Fri, 09 Aug 2019 09:00:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366458; cv=none;
        d=google.com; s=arc-20160816;
        b=y3EKuen5zlwjgBxHAhxgmRko59UB27ICNC/zTF7qrI1/q9ZhGlCA1c0+Gev8xnWEz9
         LiPsH88Dvw6jwBC5dLFtRtHyH6I2MWt0bD+hWViUmE2lJxWFDEH9CJ/mDRFhcc3C44x/
         t3pxLo2BJfbj7nicvyp4jOJXK5BNti1Pq3P6BUzX+/EPzakTY9A7Zl1Z8HsO7m9XKjEf
         mITTpA1PeqURqpT7fttrf54fsAq4+SnQDFDgXp8FSorZZdyT9SomtLODlQ0/yMLiR6Jt
         RDJxMFLxtSz9A9mZpeNkpCNbZAT2VKC5ha8UWQgEY9Nn6QvrdsCDoliteBgrm9vsnVg2
         m6Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TSZ0Sdd6A4ffCRtX/c6eCxL67k6xtFLlPM0mgEv7AAI=;
        b=hNF+lw8ZDokJtsWZmx5S+K1R4mQuKfaEuI1MsUhwCCjfNuIwy4Y74/EFeQpG5AI9IS
         6w0ChZwS1eDFrvleie2AHTeAs4yXdrpw5Szuue+wtX3ITHJ6JYqv6zW7o76tQe9icN9N
         raye5DC9r/vds7XozRtT4DzWIcPbjD0EHK0o+NTrIl8vRmP4y2AzZNoRcaovBh9Ft6nX
         /N/T1U0z0b8n2s4b8QO20ImHrtK2DeggZSynaUcrEGX2x+Jk3pANRQNOJXYJzvcQcVp5
         PiWJuLWpmIrTbNTXzKqc2M1JjcXLKI/0SjEt1NpmhHoyj2SOMWMBbo7FVyFBS/sS6pCg
         AtdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id l23si4072624wmh.197.2019.08.09.09.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 60BF3305D3D5;
	Fri,  9 Aug 2019 19:00:57 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id E7403305B7A4;
	Fri,  9 Aug 2019 19:00:56 +0300 (EEST)
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
Subject: [RFC PATCH v6 14/92] kvm: introspection: handle introspection commands before returning to guest
Date: Fri,  9 Aug 2019 18:59:29 +0300
Message-Id: <20190809160047.8319-15-alazar@bitdefender.com>
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

The introspection requests (KVM_REQ_INTROSPECTION) are checked by any
introspected vCPU in two places:

  * on its way to guest - vcpu_enter_guest()
  * when halted - kvm_vcpu_block()

In kvm_vcpu_block(), we check to see if there are any introspection
requests during the swait loop, handle them outside of swait loop and
start swait again.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Mircea Cîrjaliu <mcirjaliu@bitdefender.com>
Signed-off-by: Mircea Cîrjaliu <mcirjaliu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c   |  3 +++
 include/linux/kvmi.h |  2 ++
 virt/kvm/kvm_main.c  | 28 ++++++++++++++++++++++------
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0163e1ad1aaa..adbdb1ceb618 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7742,6 +7742,9 @@ static int vcpu_enter_guest(struct kvm_vcpu *vcpu)
 		 */
 		if (kvm_check_request(KVM_REQ_HV_STIMER, vcpu))
 			kvm_hv_process_stimers(vcpu);
+
+		if (kvm_check_request(KVM_REQ_INTROSPECTION, vcpu))
+			kvmi_handle_requests(vcpu);
 	}
 
 	if (kvm_check_request(KVM_REQ_EVENT, vcpu) || req_int_win) {
diff --git a/include/linux/kvmi.h b/include/linux/kvmi.h
index e8d25d7da751..ae5de1905b55 100644
--- a/include/linux/kvmi.h
+++ b/include/linux/kvmi.h
@@ -16,6 +16,7 @@ int kvmi_ioctl_event(struct kvm *kvm, void __user *argp);
 int kvmi_ioctl_unhook(struct kvm *kvm, bool force_reset);
 int kvmi_vcpu_init(struct kvm_vcpu *vcpu);
 void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu);
+void kvmi_handle_requests(struct kvm_vcpu *vcpu);
 
 #else
 
@@ -25,6 +26,7 @@ static inline void kvmi_create_vm(struct kvm *kvm) { }
 static inline void kvmi_destroy_vm(struct kvm *kvm) { }
 static inline int kvmi_vcpu_init(struct kvm_vcpu *vcpu) { return 0; }
 static inline void kvmi_vcpu_uninit(struct kvm_vcpu *vcpu) { }
+static inline void kvmi_handle_requests(struct kvm_vcpu *vcpu) { }
 
 #endif /* CONFIG_KVM_INTROSPECTION */
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 94f15f393e37..2e11069b9565 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2282,16 +2282,32 @@ void kvm_vcpu_block(struct kvm_vcpu *vcpu)
 	kvm_arch_vcpu_blocking(vcpu);
 
 	for (;;) {
-		prepare_to_swait_exclusive(&vcpu->wq, &wait, TASK_INTERRUPTIBLE);
+		bool do_kvmi_work = false;
 
-		if (kvm_vcpu_check_block(vcpu) < 0)
-			break;
+		for (;;) {
+			prepare_to_swait_exclusive(&vcpu->wq, &wait,
+						   TASK_INTERRUPTIBLE);
+
+			if (kvm_vcpu_check_block(vcpu) < 0)
+				break;
+
+			waited = true;
+			schedule();
+
+			if (kvm_check_request(KVM_REQ_INTROSPECTION, vcpu)) {
+				do_kvmi_work = true;
+				break;
+			}
+		}
 
-		waited = true;
-		schedule();
+		finish_swait(&vcpu->wq, &wait);
+
+		if (do_kvmi_work)
+			kvmi_handle_requests(vcpu);
+		else
+			break;
 	}
 
-	finish_swait(&vcpu->wq, &wait);
 	cur = ktime_get();
 
 	kvm_arch_vcpu_unblocking(vcpu);

