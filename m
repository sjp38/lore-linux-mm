Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D726C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:12:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18C5221019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:12:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="uk/18V8h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18C5221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0B336B026A; Wed, 12 Jun 2019 13:12:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBB7F6B026B; Wed, 12 Jun 2019 13:12:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAA4C6B026F; Wed, 12 Jun 2019 13:12:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 858416B026A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:12:33 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id x22so1883434vsj.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:12:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1l13rRWuFlC2jtnumLOMqJEjamUkvWPQRDS+qbpg+64=;
        b=aJpG2l8vA6xFqLcagyDx4OlButQs/iy4pHnbB0zKrMsT/tbdZRX90c1sfRObB7R39f
         ZHYWHVNyX4YbJ4JoqggYW7NDOEp7oUP0oRity7kcxXn7G44knhtdROpvE0L5XpNuV82Z
         t0a9N2WI9dDI/nJ3xNWTX7vN18yz6y627R62u4DTQ4el/eKmmDrowrg+FlRix+iPS8pU
         cSYOTlUbnAQRHi6MCcPAQv1LnacD1WL7IqW3CNaSxf9Z50hPzVBMZr007H/+GP5UEOdw
         Hv2ML5xz5Ml/bySoXAC+TKNgOJzPfyrJU+Sp6+WhbAPUIYbWS1PcZTxXNN7LBCZqqi/P
         IhXQ==
X-Gm-Message-State: APjAAAULJCWucW+bbhAu5SadPE0CXOqm2r+dQ9++vpBqkyfp6H2tDy1/
	C5vHw3xbj6kdru9+JV2FY5D8Vw6/XUQsheulPfrsgIee7xgpHQe2E8ByPUEnvDbgoL4O7hvk/Nj
	K9hXXwfors0npr1w/yKVxrDmDasdSqPD8J1hM76xDC52vbsh6QLM1GfYWrQ4hLn+4+w==
X-Received: by 2002:a67:ebcb:: with SMTP id y11mr5574198vso.138.1560359553217;
        Wed, 12 Jun 2019 10:12:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWYwTMwez1sfue5lxed/psTe5JgQg6m8pzs/uQqMNsLshAJn8bZM1gLBhQamnOb/zVLiaC
X-Received: by 2002:a67:ebcb:: with SMTP id y11mr5574116vso.138.1560359552468;
        Wed, 12 Jun 2019 10:12:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359552; cv=none;
        d=google.com; s=arc-20160816;
        b=xpRfBQQZdbtZgDb/SGd4CKV3Ynu8T7bs/RIEd3/QIVLgGYcQ2dU6YsTv7dncw/YqeY
         S247vSepSz0fC6A26m3kvafzGqgQEwNzJtOglA3QxVG7yiChVrpL1sHsZwKLyzMacg3V
         8rujAwrjHH/iMfG1uXtPKm+lO+m6TCqved1UePVGh7HtXVqq/LRwVriENl4wnebiTU1e
         O47+bxbtO3IeGjDzHg+kElJqgQ9IKP3JA68E5inehtk6vYZRpMyOjvBbCotMV69zrbVv
         sAWRxNcTa5pt3WqdAL3gNdeBEfc4qaS30UtMEXwdlrTKraCsTpFoINI0mtK5lpC+dWiL
         kxeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1l13rRWuFlC2jtnumLOMqJEjamUkvWPQRDS+qbpg+64=;
        b=rF3eIyOfv75uFLHVtz+YwnvSdOfaILKAmKqIH/nTq4g7zsbfIG+31I2+jLY2dNJCEt
         yZM7M6GPTJ9MgUn4Qy78MoLAiWrE04pOjnXowpp9KWV01SweL68nuK0doDASs7yYPIZX
         CY/in6YQcXCniWGsl5Gbm4qoY0auDqMUt4vPf8biio3fGrh3HVQQDExOZrtE6iHlll1P
         UBvSGO2LSH18oOEydAVMoPugy0oCyxHVlDnyPvF326mSsAPTHxpc1AMsqjQ5nYUV68T1
         PMPprOlOGyjwtCYJoIr+dEytibrpNSFZxZloD0CbVq3yaUMucn6w+YIc1U+LLPuLmNJ8
         T5ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b="uk/18V8h";
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id b65si84188vsb.403.2019.06.12.10.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:12:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) client-ip=207.171.190.10;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b="uk/18V8h";
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.190.10 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359552; x=1591895552;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=1l13rRWuFlC2jtnumLOMqJEjamUkvWPQRDS+qbpg+64=;
  b=uk/18V8hWiCKkVWuXL+SyHhzilKdjRSv0RC4LZ0o9eqeou4CKbEIUUDh
   863ATNCWmA85T2Dtp3itccqngvWdOIPngEAd/sfRiKyL5hePWmBnTW7zO
   NEctAVSYBT+6jMV6GwqNZzjcaMekLnylqHljtwllmeStw3Wz9N98yrSUt
   w=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="805048939"
Received: from sea3-co-svc-lb6-vlan2.sea.amazon.com (HELO email-inbound-relay-1a-807d4a99.us-east-1.amazon.com) ([10.47.22.34])
  by smtp-border-fw-out-33001.sea14.amazon.com with ESMTP; 12 Jun 2019 17:12:30 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (iad7-ws-svc-lb50-vlan2.amazon.com [10.0.93.210])
	by email-inbound-relay-1a-807d4a99.us-east-1.amazon.com (Postfix) with ESMTPS id 44B25A05E6;
	Wed, 12 Jun 2019 17:12:28 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHCPHK018985;
	Wed, 12 Jun 2019 19:12:25 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHCPu3018963;
	Wed, 12 Jun 2019 19:12:25 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>,
        Julian Stecklina <js@alien8.de>
Subject: [RFC 10/10] kvm, x86: move guest FPU state into process local memory
Date: Wed, 12 Jun 2019 19:08:44 +0200
Message-Id: <20190612170834.14855-11-mhillenb@amazon.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612170834.14855-1-mhillenb@amazon.de>
References: <20190612170834.14855-1-mhillenb@amazon.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

FPU registers contain guest data and must be protected from information
leak vulnerabilities in the kernel.

FPU register state for vCPUs are allocated from the globally-visible
kernel heap. Change this to use process-local memory instead and thus
prevent access (or prefetching) in any other context in the kernel.

Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Inspired-by: Julian Stecklina <js@alien8.de> (while jsteckli@amazon.de)
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/include/asm/kvm_host.h |  8 ++++++++
 arch/x86/kvm/x86.c              | 24 ++++++++++++------------
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 4896ecde1c11..b3574217b011 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -36,6 +36,7 @@
 #include <asm/asm.h>
 #include <asm/kvm_page_track.h>
 #include <asm/hyperv-tlfs.h>
+#include <asm/proclocal.h>
 
 #define KVM_MAX_VCPUS 288
 #define KVM_SOFT_MAX_VCPUS 240
@@ -545,6 +546,7 @@ struct kvm_vcpu_arch_hidden {
 	 * kvm_{register,rip}_{read,write} functions.
 	 */
 	kvm_arch_regs_t regs;
+	struct fpu guest_fpu;
 };
 #endif
 
@@ -631,9 +633,15 @@ struct kvm_vcpu_arch {
 	 * it is switched out separately at VMENTER and VMEXIT time. The
 	 * "guest_fpu" state here contains the guest FPU context, with the
 	 * host PRKU bits.
+	 *
+	 * With process-local memory, the guest FPU state will be hidden in
+	 * kvm_vcpu_arch_hidden. Thus, access to this struct must go through
+	 * kvm_vcpu_arch_state(vcpu).
 	 */
 	struct fpu user_fpu;
+#ifndef CONFIG_KVM_PROCLOCAL
 	struct fpu guest_fpu;
+#endif
 
 	u64 xcr0;
 	u64 guest_supported_xcr0;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 35e41a772807..480b4ed438ae 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3792,7 +3792,7 @@ static int kvm_vcpu_ioctl_x86_set_debugregs(struct kvm_vcpu *vcpu,
 
 static void fill_xsave(u8 *dest, struct kvm_vcpu *vcpu)
 {
-	struct xregs_state *xsave = &vcpu->arch.guest_fpu.state.xsave;
+	struct xregs_state *xsave = &kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.xsave;
 	u64 xstate_bv = xsave->header.xfeatures;
 	u64 valid;
 
@@ -3834,7 +3834,7 @@ static void fill_xsave(u8 *dest, struct kvm_vcpu *vcpu)
 
 static void load_xsave(struct kvm_vcpu *vcpu, u8 *src)
 {
-	struct xregs_state *xsave = &vcpu->arch.guest_fpu.state.xsave;
+	struct xregs_state *xsave = &kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.xsave;
 	u64 xstate_bv = *(u64 *)(src + XSAVE_HDR_OFFSET);
 	u64 valid;
 
@@ -3882,7 +3882,7 @@ static void kvm_vcpu_ioctl_x86_get_xsave(struct kvm_vcpu *vcpu,
 		fill_xsave((u8 *) guest_xsave->region, vcpu);
 	} else {
 		memcpy(guest_xsave->region,
-			&vcpu->arch.guest_fpu.state.fxsave,
+			&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.fxsave,
 			sizeof(struct fxregs_state));
 		*(u64 *)&guest_xsave->region[XSAVE_HDR_OFFSET / sizeof(u32)] =
 			XFEATURE_MASK_FPSSE;
@@ -3912,7 +3912,7 @@ static int kvm_vcpu_ioctl_x86_set_xsave(struct kvm_vcpu *vcpu,
 		if (xstate_bv & ~XFEATURE_MASK_FPSSE ||
 			mxcsr & ~mxcsr_feature_mask)
 			return -EINVAL;
-		memcpy(&vcpu->arch.guest_fpu.state.fxsave,
+		memcpy(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.fxsave,
 			guest_xsave->region, sizeof(struct fxregs_state));
 	}
 	return 0;
@@ -8302,7 +8302,7 @@ static void kvm_load_guest_fpu(struct kvm_vcpu *vcpu)
 	preempt_disable();
 	copy_fpregs_to_fpstate(&vcpu->arch.user_fpu);
 	/* PKRU is separately restored in kvm_x86_ops->run.  */
-	__copy_kernel_to_fpregs(&vcpu->arch.guest_fpu.state,
+	__copy_kernel_to_fpregs(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state,
 				~XFEATURE_MASK_PKRU);
 	preempt_enable();
 	trace_kvm_fpu(1);
@@ -8312,7 +8312,7 @@ static void kvm_load_guest_fpu(struct kvm_vcpu *vcpu)
 static void kvm_put_guest_fpu(struct kvm_vcpu *vcpu)
 {
 	preempt_disable();
-	copy_fpregs_to_fpstate(&vcpu->arch.guest_fpu);
+	copy_fpregs_to_fpstate(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu);
 	copy_kernel_to_fpregs(&vcpu->arch.user_fpu.state);
 	preempt_enable();
 	++vcpu->stat.fpu_reload;
@@ -8807,7 +8807,7 @@ int kvm_arch_vcpu_ioctl_get_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu *fpu)
 
 	vcpu_load(vcpu);
 
-	fxsave = &vcpu->arch.guest_fpu.state.fxsave;
+	fxsave = &kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.fxsave;
 	memcpy(fpu->fpr, fxsave->st_space, 128);
 	fpu->fcw = fxsave->cwd;
 	fpu->fsw = fxsave->swd;
@@ -8827,7 +8827,7 @@ int kvm_arch_vcpu_ioctl_set_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu *fpu)
 
 	vcpu_load(vcpu);
 
-	fxsave = &vcpu->arch.guest_fpu.state.fxsave;
+	fxsave = &kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.fxsave;
 
 	memcpy(fxsave->st_space, fpu->fpr, 128);
 	fxsave->cwd = fpu->fcw;
@@ -8883,9 +8883,9 @@ static int sync_regs(struct kvm_vcpu *vcpu)
 
 static void fx_init(struct kvm_vcpu *vcpu)
 {
-	fpstate_init(&vcpu->arch.guest_fpu.state);
+	fpstate_init(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state);
 	if (boot_cpu_has(X86_FEATURE_XSAVES))
-		vcpu->arch.guest_fpu.state.xsave.header.xcomp_bv =
+		kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.xsave.header.xcomp_bv =
 			host_xcr0 | XSTATE_COMPACTION_ENABLED;
 
 	/*
@@ -9009,11 +9009,11 @@ void kvm_vcpu_reset(struct kvm_vcpu *vcpu, bool init_event)
 		 */
 		if (init_event)
 			kvm_put_guest_fpu(vcpu);
-		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu.state.xsave,
+		mpx_state_buffer = get_xsave_addr(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.xsave,
 					XFEATURE_MASK_BNDREGS);
 		if (mpx_state_buffer)
 			memset(mpx_state_buffer, 0, sizeof(struct mpx_bndreg_state));
-		mpx_state_buffer = get_xsave_addr(&vcpu->arch.guest_fpu.state.xsave,
+		mpx_state_buffer = get_xsave_addr(&kvm_vcpu_arch_state(&vcpu->arch)->guest_fpu.state.xsave,
 					XFEATURE_MASK_BNDCSR);
 		if (mpx_state_buffer)
 			memset(mpx_state_buffer, 0, sizeof(struct mpx_bndcsr));
-- 
2.21.0

