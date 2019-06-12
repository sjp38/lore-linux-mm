Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AA8AC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D796621019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="uegwbgsJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D796621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862CD6B026C; Wed, 12 Jun 2019 13:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 813386B026D; Wed, 12 Jun 2019 13:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DAAB6B026E; Wed, 12 Jun 2019 13:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B02E6B026C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:11:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z16so15175527qto.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mHyM8SWHlAfs7A/FW6SKOCGNM1rYZjxh4Tkjo7ZhY7U=;
        b=WHs4NJLyK+221pRnef4OAQP4T1kDXtDAwTUpefjJpc/DYcXMka9whcPeSdFIti4lFU
         jFzILf5BwHpqtmSIhdynM4mkAA26ZhMGJ8uPB0ZxcDyRwuaVVTiC50SnMHYFbXmjs8GE
         x2AWVhB32Nb8sqdzfVS3+zdykdWMPdu1DDWma55Ib+RJqr+lIo7adgRYQvg50jyK4OMf
         z05rRtYgA6aYjc2rr2Fsw1h6J4GbRjArhO3rofkioRXgc8HDn6DMWow357GcJjklGNeE
         u1ZmxN5sl8wW3Jz7gzObMscCwwMSokm5+HXoJHtJYGuLp9kYh0NtSdpWGcrjw29EFh9K
         cDVQ==
X-Gm-Message-State: APjAAAUY/cQ6CMT9BEJyhe219K/Wkd8Pxu7EOEVQor0itvl0w2KUUNrR
	B89+hTFqqF/U3Cokerv09GwQ4hvf+Hr0bZYiGqAgjRyWEWSX8TLjDs5OEOemtzKLqRvh2X8W3QT
	0A+pIN6kG2m/YHVOHEZbHxq0AvbuNtKVBxt41m2ZU3vS1ovwNaIrt2aVa0Elgn5d1fg==
X-Received: by 2002:ac8:4601:: with SMTP id p1mr71942330qtn.181.1560359499965;
        Wed, 12 Jun 2019 10:11:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzv8YgQFGAlIosKzE6Y8gZylL1e3UeYonjtrvG/PB0em2fOPU2QBOQx+NI6HRX4Zu7uE4Dr
X-Received: by 2002:ac8:4601:: with SMTP id p1mr71942241qtn.181.1560359498360;
        Wed, 12 Jun 2019 10:11:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359498; cv=none;
        d=google.com; s=arc-20160816;
        b=MjUfRcYqHSfzKhxuvJpKj0Th7w+vcm9PrcQnx2S9qrPfoizJNIjiOL96eRxZq48VaM
         mLSY+ixAjgCB/Y/FvDpxk23+cm3s4Q299MfnvZMbgrP9IdwszG8/5Tk9EEowtpSLrTfX
         2GQ782byuQwMahISN7MTjwsvZo2rQMI/Ol02s1F+US95ifEFV8sjUOXUgYs0DeScHvl9
         igxHbkmkpar2h/tZDTfHLxaCEHmyksLD/I/tz503Kbf0hxCHRy6Jtflo6Q5hPoKvxlBk
         S1+h3kcuD7fTEOK4JtUBjXU9g1S+Vgpci91+QZLbGEITzJxOs0Kw0I2qqJAY5cQQ5Ty8
         TGNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mHyM8SWHlAfs7A/FW6SKOCGNM1rYZjxh4Tkjo7ZhY7U=;
        b=Tb539RKvTfVyVfFT5j7ZsCddGo6Y6tV8IO/Q7v0gDGgkXNJT0z8lFOkX4PnlwacuMG
         7uDw2yBItw7pCobh5uUB/3XY8FGYezSOOU66nVi9nWusxKIU+H0/PnjEam4tr+jYgH+F
         /b0nwC4LcqPWD6AYVFhKSLi7o3EV4IjWqFQ/e+6iEQLDzWJX2MjUqjheLWVMrvxFmXG9
         gHyt6CnwvHCyEEB3v6ZntkW6XZVBlRRFEsBSiFrNvMX6YjmWzuGguVECtN/CvDmkBgvX
         U7XLVfcKUONem6aGfDu4uRKx5LUNXWcYkRK9+miaeYRXktmyRPCaXJKVVUAZxsHO6Gyl
         95Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=uegwbgsJ;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.49.90 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id q54si312674qtf.138.2019.06.12.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:11:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.49.90 as permitted sender) client-ip=52.95.49.90;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=uegwbgsJ;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 52.95.49.90 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359498; x=1591895498;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=mHyM8SWHlAfs7A/FW6SKOCGNM1rYZjxh4Tkjo7ZhY7U=;
  b=uegwbgsJzOC7Sam9PEZ8KhrDVtTbb/25iUP9MY2fmSXMCc7j4Wrycr6q
   MIMxfL2p0wx4XYL1iZoOTtvVrtB7PhFuxm+prJaycTE3MFiIvwLduU95u
   ecacg5PhNY3gQT2IGEBKqdBcMvvqKPAfKNDbDU9SWN+tjC1bpCANSx2P9
   o=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="406138085"
Received: from iad6-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-2b-4ff6265a.us-west-2.amazon.com) ([10.124.125.6])
  by smtp-border-fw-out-6002.iad6.amazon.com with ESMTP; 12 Jun 2019 17:11:30 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (pdx2-ws-svc-lb17-vlan2.amazon.com [10.247.140.66])
	by email-inbound-relay-2b-4ff6265a.us-west-2.amazon.com (Postfix) with ESMTPS id 57BB3A1956;
	Wed, 12 Jun 2019 17:11:29 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CHBRZt018256;
	Wed, 12 Jun 2019 19:11:27 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CHBQ5g018255;
	Wed, 12 Jun 2019 19:11:26 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
Subject: [RFC 06/10] kvm/x86: add support for storing vCPU state in process-local memory
Date: Wed, 12 Jun 2019 19:08:36 +0200
Message-Id: <20190612170834.14855-7-mhillenb@amazon.de>
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

The hidden KVM state will both contain guest state that is specific to
x86-64 as well as state specific to SVM or VMX, respectively. Thus,
allocate the hidden state in the code paths specific to SVM and VMX. For
the code that is shared between SVM and VMX, introduce a common struct
for hidden guest state.

Signed-off-by: Marius Hillenbrand <mhillenb@amazon.de>
Cc: Alexander Graf <graf@amazon.de>
Cc: David Woodhouse <dwmw@amazon.co.uk>
---
 arch/x86/include/asm/kvm_host.h |  9 ++++++++
 arch/x86/kvm/Kconfig            | 10 +++++++++
 arch/x86/kvm/svm.c              | 37 +++++++++++++++++++++++++++++++-
 arch/x86/kvm/vmx.c              | 38 ++++++++++++++++++++++++++++++++-
 arch/x86/kvm/x86.c              |  5 +++++
 5 files changed, 97 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 5772fba1c64e..41c7b06588f9 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -534,7 +534,16 @@ struct kvm_vcpu_hv {
 	cpumask_t tlb_flush;
 };
 
+#ifdef CONFIG_KVM_PROCLOCAL
+struct kvm_vcpu_arch_hidden {
+	u64 placeholder;
+};
+#endif
+
 struct kvm_vcpu_arch {
+#ifdef CONFIG_KVM_PROCLOCAL
+	struct kvm_vcpu_arch_hidden *hidden;
+#endif
 	/*
 	 * rip and regs accesses must go through
 	 * kvm_{register,rip}_{read,write} functions.
diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
index 80abc68b3e90..a3640e2f1a32 100644
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -97,6 +97,16 @@ config KVM_MMU_AUDIT
 	 This option adds a R/W kVM module parameter 'mmu_audit', which allows
 	 auditing of KVM MMU events at runtime.
 
+config KVM_PROCLOCAL
+	bool "Use process-local allocation for KVM"
+	depends on KVM && PROCLOCAL
+	---help---
+	  Use process-local memory for storing vCPU state in KVM. This
+	  option removes assets from the kernel's global direct mapping
+	  of physical memory and stores them only in the address space
+	  of the process hosting a VM.
+
+
 # OK, it's a little counter-intuitive to do this, but it puts it neatly under
 # the virtualization menu.
 source drivers/vhost/Kconfig
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index cb202c238de2..af66b93902e5 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -41,6 +41,7 @@
 #include <linux/file.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
+#include <linux/proclocal.h>
 
 #include <asm/apic.h>
 #include <asm/perf_event.h>
@@ -190,9 +191,20 @@ static u32 msrpm_offsets[MSRPM_OFFSETS] __read_mostly;
  */
 static uint64_t osvw_len = 4, osvw_status;
 
+#ifdef CONFIG_KVM_PROCLOCAL
+struct vcpu_svm_hidden {
+	struct { /* mimic topology in vcpu_svm: */
+		struct kvm_vcpu_arch_hidden arch;
+	} vcpu;
+};
+#endif
+
 struct vcpu_svm {
 	struct kvm_vcpu vcpu;
 	struct vmcb *vmcb;
+#ifdef CONFIG_KVM_PROCLOCAL
+	struct vcpu_svm_hidden *hidden;
+#endif
 	unsigned long vmcb_pa;
 	struct svm_cpu_data *svm_data;
 	uint64_t asid_generation;
@@ -2129,9 +2141,18 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
 		goto out;
 	}
 
+#ifdef CONFIG_KVM_PROCLOCAL
+	svm->hidden = kzalloc_proclocal(sizeof(struct vcpu_svm_hidden));
+	if (!svm->hidden) {
+		err = -ENOMEM;
+		goto free_svm;
+	}
+	svm->vcpu.arch.hidden = &svm->hidden->vcpu.arch;
+#endif
+
 	err = kvm_vcpu_init(&svm->vcpu, kvm, id);
 	if (err)
-		goto free_svm;
+		goto free_hidden;
 
 	err = -ENOMEM;
 	page = alloc_page(GFP_KERNEL);
@@ -2187,7 +2208,11 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
 	__free_page(page);
 uninit:
 	kvm_vcpu_uninit(&svm->vcpu);
+free_hidden:
+#ifdef CONFIG_KVM_PROCLOCAL
+	kfree_proclocal(svm->hidden);
 free_svm:
+#endif
 	kmem_cache_free(kvm_vcpu_cache, svm);
 out:
 	return ERR_PTR(err);
@@ -2205,6 +2230,16 @@ static void svm_free_vcpu(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 
+#ifdef CONFIG_KVM_PROCLOCAL
+	/*
+	 * note that the hidden vCPU state in a process-local allocation is
+	 * already cleaned up, because a process's mm is torn down before files
+	 * are closed. make any access in the cleanup code very visible.
+	 */
+	svm->hidden = (struct vcpu_svm_hidden *)POISON_POINTER_DELTA;
+	svm->vcpu.arch.hidden = (struct kvm_vcpu_arch_hidden *)POISON_POINTER_DELTA;
+#endif
+
 	/*
 	 * The vmcb page can be recycled, causing a false negative in
 	 * svm_vcpu_load(). So, ensure that no logical CPU has this
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index f9a4faf2d1bc..6f59a6ad7835 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -37,6 +37,8 @@
 #include <linux/hrtimer.h>
 #include <linux/frame.h>
 #include <linux/nospec.h>
+#include <linux/proclocal.h>
+
 #include "kvm_cache_regs.h"
 #include "x86.h"
 
@@ -975,8 +977,19 @@ struct vmx_msrs {
 	struct vmx_msr_entry	val[NR_AUTOLOAD_MSRS];
 };
 
+#ifdef CONFIG_KVM_PROCLOCAL
+struct vcpu_vmx_hidden {
+	struct { /* mimic topology in vcpu_svm: */
+		struct kvm_vcpu_arch_hidden arch;
+	} vcpu;
+};
+#endif
+
 struct vcpu_vmx {
 	struct kvm_vcpu       vcpu;
+#ifdef CONFIG_KVM_PROCLOCAL
+	struct vcpu_vmx_hidden *hidden;
+#endif
 	unsigned long         host_rsp;
 	u8                    fail;
 	u8		      msr_bitmap_mode;
@@ -11756,6 +11769,16 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
 
+#ifdef CONFIG_KVM_PROCLOCAL
+	/*
+	 * note that the hidden vCPU state in a process-local allocation is
+	 * already cleaned up, because a process's mm is torn down before files
+	 * are closed. make any access in the cleanup code very visible.
+	 */
+	vmx->hidden = (struct vcpu_vmx_hidden *)POISON_POINTER_DELTA;
+	vmx->vcpu.arch.hidden = (struct kvm_vcpu_arch_hidden *)POISON_POINTER_DELTA;
+#endif
+
 	if (enable_pml)
 		vmx_destroy_pml_buffer(vmx);
 	free_vpid(vmx->vpid);
@@ -11777,11 +11800,20 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	if (!vmx)
 		return ERR_PTR(-ENOMEM);
 
+#ifdef CONFIG_KVM_PROCLOCAL
+	vmx->hidden = kzalloc_proclocal(sizeof(struct vcpu_vmx_hidden));
+	if (!vmx->hidden) {
+		err = -ENOMEM;
+		goto free_vcpu;
+	}
+	vmx->vcpu.arch.hidden = &vmx->hidden->vcpu.arch;
+#endif
+
 	vmx->vpid = allocate_vpid();
 
 	err = kvm_vcpu_init(&vmx->vcpu, kvm, id);
 	if (err)
-		goto free_vcpu;
+		goto free_hidden;
 
 	err = -ENOMEM;
 
@@ -11868,7 +11900,11 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
 	vmx_destroy_pml_buffer(vmx);
 uninit_vcpu:
 	kvm_vcpu_uninit(&vmx->vcpu);
+free_hidden:
+#ifdef CONFIG_KVM_PROCLOCAL
+	kfree_proclocal(vmx->hidden);
 free_vcpu:
+#endif
 	free_vpid(vmx->vpid);
 	kmem_cache_free(kvm_vcpu_cache, vmx);
 	return ERR_PTR(err);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 371d98422631..2cfb96ca8cc8 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9309,6 +9309,11 @@ void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
 	free_page((unsigned long)vcpu->arch.pio_data);
 	if (!lapic_in_kernel(vcpu))
 		static_key_slow_dec(&kvm_no_apic_vcpu);
+	/*
+	 * note that the hidden vCPU state in a process-local allocation is
+	 * already cleaned up at this point, because a process's mm is torn down
+	 * before files are closed.
+	 */
 }
 
 void kvm_arch_sched_in(struct kvm_vcpu *vcpu, int cpu)
-- 
2.21.0

