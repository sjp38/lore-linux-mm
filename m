Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C0BC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DD9C2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DD9C2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 156496B027B; Fri,  9 Aug 2019 12:01:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106E66B027C; Fri,  9 Aug 2019 12:01:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35DE6B027D; Fri,  9 Aug 2019 12:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A60E16B027C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so46640912wrv.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8XtTL7AZBji1RWpy+yxiwy8MvIxfjTmBQ8n1Fj2bgLY=;
        b=scnKrV4K6AwyWhRCybtngT6aL5Pxe8rXbe7PlIBvFzn6+iUGRIXJlEpN5AgSe4Dy25
         eSymu1VExYsygh084pIwE4TgqbEcKycyHNHq6Ctln3n0o8suP25iJ1ltKM22mpdJOrUm
         YoRCIyeBz80nZpFVI80oEJO7BXbMhcnKfmhVkY49aP02vQhHlhIijC+zv3NMtQGDqr8s
         RNGbofh4A6YClB9DJSxOjuChOAdSQ/RgYTkAJNGFbPPajWPJPsjKFGtzshgBsx859fUh
         AcMSGeK948K8VfnL5b8A6YnUMYyjtRj3hHDcpu9yyNpscoEZ2KOEc99tNbHggIk34mNs
         mH0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUt9N4n2LQJR8Fh3jUpEqFm/NyKfxCUrxEe77nKx8r2rrqNEbwL
	O/XxV5gjUcppSaG0uiDZy1tfDLFLtr7OrtoWjHSGoiFs8uFoss2dTt4NZkjDil4ylXzujCLTnk4
	4lrdbHnvIKR2oL/MqFr7Or6Mcn/6R4OuBwuJHUHEZmixkkJTss17sCjmCRB1amhZoiQ==
X-Received: by 2002:adf:f281:: with SMTP id k1mr25046962wro.154.1565366466265;
        Fri, 09 Aug 2019 09:01:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1wcKdVwLY3t2mZOdhvhMMkTe7REWHTbhHankBYj2BbTAoQ9QlCrSjYNZuCkVit3pNooeq
X-Received: by 2002:adf:f281:: with SMTP id k1mr25046802wro.154.1565366464721;
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366464; cv=none;
        d=google.com; s=arc-20160816;
        b=YQDap5+Fsm9KjZ63sxEHCMSENLYYeu/GvJ02QiPqZMXxj6+QJrSDHHurMVIOq3wYcn
         z0lUz0T54syZLB3ch10EiwFuiJyJx99IZ6m1gE3dYX+6uwxeUYq0UM3CkqpTexbJ/TGv
         64OUfSXnrAw/Vc4AF0sbu6SBaaKZu4bYsa+wG5IaafU0XtZbADVAgnDvXnef3770yQ0O
         ZFEBf6WGuy24mrLC61brEjB1ZXM3X4fXI7TyTupP6iN+dhKda277DEcm8Ph83Azac6yV
         MvB6wcbhO9fA27m1oVl92Uj9L93mQgjOS6wpuJVRmuNU/rhJzCZBYkUy6xrLVkzOoAVf
         ghRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8XtTL7AZBji1RWpy+yxiwy8MvIxfjTmBQ8n1Fj2bgLY=;
        b=hxIHBanp+tVkYdHCskm6k/t+lRq/4Rh+bxZLven4MNkH886cvtXQ1dym99hALC5gA5
         JXimCKBfJ2WWqD/MRDM8shopjTfxULNVwfWkMtwWNFXtY5PJPfCNfAnvo+iferVmwDud
         VGWjMkY9jeDcIlFxBkYCsDVJY5x8cq4EjSR0M2FtOOoh6WBvjo2ihLU9lOOjpVRNQ5Mc
         nGPhtooSEG6M3uyQM72ryvt7lbfmtilTZZ9FC+fRcVAsjCK8naMKF9nVPOzRjIeiCk+h
         +uQbKeFv0K+T3krBZwzhVeyoXMDUiMjwxU5Yg0tEGxcbwE55zCSTBKvWUUMYJTaj/ple
         spnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id y13si8316856wrp.174.2019.08.09.09.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 1DE1F305D3F4;
	Fri,  9 Aug 2019 19:01:04 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 3B6D5303EF08;
	Fri,  9 Aug 2019 19:01:03 +0300 (EEST)
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
Subject: [RFC PATCH v6 30/92] kvm: x86: add kvm_spt_fault()
Date: Fri,  9 Aug 2019 18:59:45 +0300
Message-Id: <20190809160047.8319-31-alazar@bitdefender.com>
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

This is needed to filter #PF introspection events, when not caused by
EPT/NPT fault. One such case is when handle_ud() calls the emulator
which failes to fetch the opcodes from stack (which is hooked rw-)
which leads to a page fault event.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h | 2 ++
 arch/x86/kvm/svm.c              | 8 ++++++++
 arch/x86/kvm/vmx/vmx.c          | 8 ++++++++
 arch/x86/kvm/x86.c              | 6 ++++++
 4 files changed, 24 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 7da1137a2b82..f1b3d89a0430 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1005,6 +1005,7 @@ struct kvm_x86_ops {
 	void (*cpuid_update)(struct kvm_vcpu *vcpu);
 
 	bool (*nested_pagefault)(struct kvm_vcpu *vcpu);
+	bool (*spt_fault)(struct kvm_vcpu *vcpu);
 
 	struct kvm *(*vm_alloc)(void);
 	void (*vm_free)(struct kvm *);
@@ -1596,5 +1597,6 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
 	*(type *)((buf) + (offset) - 0x7e00) = val
 
 bool kvm_mmu_nested_pagefault(struct kvm_vcpu *vcpu);
+bool kvm_spt_fault(struct kvm_vcpu *vcpu);
 
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 3c099c56099c..6b533698c73d 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -7103,6 +7103,13 @@ static bool svm_nested_pagefault(struct kvm_vcpu *vcpu)
 	return false;
 }
 
+static bool svm_spt_fault(struct kvm_vcpu *vcpu)
+{
+	const struct vcpu_svm *svm = to_svm(vcpu);
+
+	return (svm->vmcb->control.exit_code == SVM_EXIT_NPF);
+}
+
 static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = has_svm,
 	.disabled_by_bios = is_disabled,
@@ -7115,6 +7122,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.has_emulated_msr = svm_has_emulated_msr,
 
 	.nested_pagefault = svm_nested_pagefault,
+	.spt_fault = svm_spt_fault,
 
 	.vcpu_create = svm_create_vcpu,
 	.vcpu_free = svm_free_vcpu,
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index e10ee8fd1c67..97cfd5a316f3 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -7689,6 +7689,13 @@ static bool vmx_nested_pagefault(struct kvm_vcpu *vcpu)
 	return true;
 }
 
+static bool vmx_spt_fault(struct kvm_vcpu *vcpu)
+{
+	const struct vcpu_vmx *vmx = to_vmx(vcpu);
+
+	return (vmx->exit_reason == EXIT_REASON_EPT_VIOLATION);
+}
+
 static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = cpu_has_kvm_support,
 	.disabled_by_bios = vmx_disabled_by_bios,
@@ -7701,6 +7708,7 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.has_emulated_msr = vmx_has_emulated_msr,
 
 	.nested_pagefault = vmx_nested_pagefault,
+	.spt_fault = vmx_spt_fault,
 
 	.vm_init = vmx_vm_init,
 	.vm_alloc = vmx_vm_alloc,
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index c28e2a20dec2..257c4a262acd 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9884,6 +9884,12 @@ bool kvm_vector_hashing_enabled(void)
 }
 EXPORT_SYMBOL_GPL(kvm_vector_hashing_enabled);
 
+bool kvm_spt_fault(struct kvm_vcpu *vcpu)
+{
+	return kvm_x86_ops->spt_fault(vcpu);
+}
+EXPORT_SYMBOL(kvm_spt_fault);
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_fast_mmio);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_inj_virq);

