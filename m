Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B749C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 415F92089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 415F92089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ED276B0278; Fri,  9 Aug 2019 12:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39EF56B0279; Fri,  9 Aug 2019 12:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 217E96B027A; Fri,  9 Aug 2019 12:01:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEF986B0279
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e6so46640827wrv.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gAIrs+HdpcxGOz+h2e7r46T79tbEj3TIwmtyPYJW7Xw=;
        b=FZJHLvzhCQUyXbOsxggeebTgJGz8D65BttkZ68yIt7Q444Yu6+1xuFuYVxTM5Yf6xG
         BdH6fjgmT2okYDtm4EO6cq9eL8TyMeo5wadjWew8lH+JnAnTP2KQ8NKceeUiPNuOJ5L8
         1tcpLrcEmefV7UMy1IPse0yXs8bjIhnMx3HaDG2X3P6/xsZz2lvoqKfDrXyNauQUGFxk
         1nPkfafMrOwvTfCwl7gu/FjJIhokPgN6cYhvgIgGeMZsgJ3uGnu5oSWLnMKnQNLarxtL
         g5zqf6J1peBy7R/Byk0OZkoxuMbRXM9P0B9J1iJAqamuofckmObE8VJLaZI++I5wMwRL
         lmoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWkKCQiQylXTZO1TNLjUm/axBGQFu4zrVFRzJNO1tVQhQwR5WY4
	sQdnFiAnnFwVZ2v8xARbE8nCqWRj/zYRpNU2k5DBTeQAE+el+8NtjjWA4VDWnqE6zcRha5xoZhm
	+eUY7UsovYy3OqkGeP+eiyEGDWzEB1W1IiirAh6CLCcejkiAKvEGdRhe62OLjlhK9rQ==
X-Received: by 2002:adf:ce05:: with SMTP id p5mr24705042wrn.197.1565366463323;
        Fri, 09 Aug 2019 09:01:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiOKBntuHO4srshmNyuXOhYrqHR3j3/v55JOCz7yWns3bOpwxzUL7yHmEGO3N8+EqgiyAH
X-Received: by 2002:adf:ce05:: with SMTP id p5mr24704927wrn.197.1565366462064;
        Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366462; cv=none;
        d=google.com; s=arc-20160816;
        b=tjQiiI88bMRpEgxjmORe/UBnewYOmVdeEPnk4yVv6WvVig1rGD9xF62VA8Ojdy0O1q
         QZv8huR+vmpBGb7DVibT9fBZ1RjN2AbS27zxs1ZCgNK30YtSnUsj0HhQuRpezi02PBK6
         6M8EhaDzyPUcpROX1ubGdEIMkA5Ba5gIY+2Yz+s+787PB1mIUn1Hfy3qX+VDdFe43ZNx
         DMMTtZ1pt3sxKcA2FSdHw+JncKuylkFSY/WoiIUOV4J7wJx7R4o8g1SceD4/+VFQDX9Q
         7E+WCJE7DBQ3Foqq/2sbvrIbyHyBH6/5QcZ5RmBU4q8Mm4LDwRlvDbK9y1vCpyaMaVa8
         DCBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=gAIrs+HdpcxGOz+h2e7r46T79tbEj3TIwmtyPYJW7Xw=;
        b=dngF1pfo8OT4U1ZTIQwrV27LQkjid0Nhw8RHlKLy5dOvV1MC/NjEDLavhnTib/pc3R
         J84RjG/Dfflj4w+nFmuxTpwcz52/JrRTiIYkHLVhSyT44vPIfrnAu/bqhlCu897Jbp+s
         bmaEA0IuqlhtdHAPMf1rE3B0Z4j6/Nmr54TgkI+OO1oOum+DAD196pPslk7NGw8bUVsz
         4f0ahoMUmQG9mAuqwWBFf9h4kihYOsU1/PFso6Kz45Smt5xA/EFwkAfyre/5KPYsrqKs
         HT4MKQrti47l39yxmDEaRF8pZnNW8s8anLAy11zsyS1L66VTOm13DwOiestoyqtQ0AVj
         wS8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id c6si86401123wrm.290.2019.08.09.09.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 517C2305D3DF;
	Fri,  9 Aug 2019 19:01:01 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id DF0E8305B7A4;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
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
	=?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>
Subject: [RFC PATCH v6 26/92] kvm: x86: add kvm_mmu_nested_pagefault()
Date: Fri,  9 Aug 2019 18:59:41 +0300
Message-Id: <20190809160047.8319-27-alazar@bitdefender.com>
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

This is needed to filter #PF introspection events.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Co-developed-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h | 4 ++++
 arch/x86/kvm/mmu.c              | 5 +++++
 arch/x86/kvm/svm.c              | 7 +++++++
 arch/x86/kvm/vmx/vmx.c          | 9 +++++++++
 4 files changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 2d6bde6fa59f..7da1137a2b82 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1004,6 +1004,8 @@ struct kvm_x86_ops {
 	bool (*has_emulated_msr)(int index);
 	void (*cpuid_update)(struct kvm_vcpu *vcpu);
 
+	bool (*nested_pagefault)(struct kvm_vcpu *vcpu);
+
 	struct kvm *(*vm_alloc)(void);
 	void (*vm_free)(struct kvm *);
 	int (*vm_init)(struct kvm *kvm);
@@ -1593,4 +1595,6 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
 #define put_smstate(type, buf, offset, val)                      \
 	*(type *)((buf) + (offset) - 0x7e00) = val
 
+bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu);
+
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index ff053f17b8c2..9eaf6cc776a9 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -6169,3 +6169,8 @@ void kvm_mmu_module_exit(void)
 	unregister_shrinker(&mmu_shrinker);
 	mmu_audit_disable();
 }
+
+bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu)
+{
+	return kvm_x86_ops->nested_pagefault(vcpu);
+}
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f13a3a24d360..3c099c56099c 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -7098,6 +7098,11 @@ static int nested_enable_evmcs(struct kvm_vcpu *vcpu,
 	return -ENODEV;
 }
 
+static bool svm_nested_pagefault(struct kvm_vcpu *vcpu)
+{
+	return false;
+}
+
 static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = has_svm,
 	.disabled_by_bios = is_disabled,
@@ -7109,6 +7114,8 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_accelerated_tpr = svm_cpu_has_accelerated_tpr,
 	.has_emulated_msr = svm_has_emulated_msr,
 
+	.nested_pagefault = svm_nested_pagefault,
+
 	.vcpu_create = svm_create_vcpu,
 	.vcpu_free = svm_free_vcpu,
 	.vcpu_reset = svm_vcpu_reset,
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 30a6bcd735ec..e10ee8fd1c67 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -7682,6 +7682,13 @@ static __exit void hardware_unsetup(void)
 	free_kvm_area();
 }
 
+static bool vmx_nested_pagefault(struct kvm_vcpu *vcpu)
+{
+	if (vcpu->arch.exit_qualification & EPT_VIOLATION_GVA_TRANSLATED)
+		return false;
+	return true;
+}
+
 static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = cpu_has_kvm_support,
 	.disabled_by_bios = vmx_disabled_by_bios,
@@ -7693,6 +7700,8 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.cpu_has_accelerated_tpr = report_flexpriority,
 	.has_emulated_msr = vmx_has_emulated_msr,
 
+	.nested_pagefault = vmx_nested_pagefault,
+
 	.vm_init = vmx_vm_init,
 	.vm_alloc = vmx_vm_alloc,
 	.vm_free = vmx_vm_free,

