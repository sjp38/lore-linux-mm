Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 862CDC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25FC72089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25FC72089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B41EC6B027D; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B19926B0282; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91CA76B027F; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF8B6B027F
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:08 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id t76so1447632wmt.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tMeBd7r74aFFlvSCeyN8aq2fvT67T10rywWkhmX3UD4=;
        b=oYzS+VWmhbnHqp2C4W0h0KXZnIkt3V/mjsPG6j5WIpELln3wAzURtMuWVhbYiH3DhO
         Xn6e20jwqDdNc9/98UBSV4bbnXZkHQsTDA6VGkev7pD+gOppei4r+nF4AZ/+mOeVL3do
         NU3Ztl+JzDfq6R6uLSd2Gd5AyhD2fBvn9Fu05SSsE9SveGpj6h8ItQloyJJiRpgU0YdJ
         ORT/CuAsDm3Yhd/fU7bz3WzNBQMftl7k+d5K8tdfmEQYCpRsr/Rej7MzdA6YxSRuSbxV
         PstpB6daj3Lz3FnHfwl7QZrWpIi6VkxPtmYO7XZ2ffHSXsmk7Kyqa/HViCiCpKyRNYut
         CbQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVFmEDvRiwxifzJ5KKJ35nCkzwsvjkbN2Yom+tS665Jr1WbgANS
	gwr3vU/W4KmPNi6Ha7MQNVREa+ttMDu/RhWyJvw+b58ZRp28Hu6s9gTCsABtHPXnnuXxiE9qjW+
	LEf4ZlO4rmyEUojLojuY/bopfwEJ+Ah2LWlzo0XN1g4refGwLBMBRmGZY8klNIqDjEw==
X-Received: by 2002:a1c:f61a:: with SMTP id w26mr12356248wmc.75.1565366467661;
        Fri, 09 Aug 2019 09:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqupk9PlUZGbWfrysMyXjcbsgvEG2I/8iDoPoRv08KasPHy2gpuvORXekxk7TSfjvQ0D5s
X-Received: by 2002:a1c:f61a:: with SMTP id w26mr12356100wmc.75.1565366466064;
        Fri, 09 Aug 2019 09:01:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366466; cv=none;
        d=google.com; s=arc-20160816;
        b=q8A7f3ZShtL124+liLejd0nC7eyvzJiUuvXGePz9ZueTPnVbPPwjW2nToJIGR7Fntj
         dBq0fPj/Ld8YJC5ZOyP2LOPoolZK/Dx90lcsVH4kEpy/Wey/H+bY7zTtgASKv7QEYyPL
         8IRDcJQxZcas4kAPGtQGTDYBA/e7ShTXc0qDL4nJG9Vl1N4npFF5J1kHyHtilq/+4lVu
         UPsbctHdqgZZJe4n3UjA92YDKB9oaTpZeXrC7GRJ803M2z/iJbg1u5A2Brl5DvcfjByc
         DgOT06eKRBXDXPaBljRo4xVioSptoZOkpWSOcapgHNJ1smDMF7w3VqhVoZwmIAwq9beC
         QF+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tMeBd7r74aFFlvSCeyN8aq2fvT67T10rywWkhmX3UD4=;
        b=CHE3DNuexqXXkNST6K8hdoB2TwiEExsKckjDHYukPD5I7r+vifOBOVMrxDe2gJ2QXm
         DWDX25gaaEEF6+1fQBlp4Kwpj0T2SerjKoryTRXNkV5OJXLwaWGKUkz3L11q++JYSsvR
         6ImEGMLZZvfatJoT4gtLW90aEyrQ1NmOujZ2mhiOCCmGAOZYekocYU8U5LIZ5MhOOt/j
         gv33WUWRbjvotRxvVj/UOMDRQUzmviGPvCRQKNQsFy/ozN2oSUHRxg65MUq/LkS9Clcv
         tI5AFRWzQM4C7mBxWpdF4sx8kufdeEB8JdGCQ4Oj84qBqlGn5d/jpExhB1hh4Mdho741
         xEjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id n25si1471040wmc.137.2019.08.09.09.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 72460305D343;
	Fri,  9 Aug 2019 19:01:05 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 2B57A305B7A0;
	Fri,  9 Aug 2019 19:01:05 +0300 (EEST)
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
	He Chen <he.chen@linux.intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [RFC PATCH v6 35/92] KVM: VMX: Add control flags for SPP enabling
Date: Fri,  9 Aug 2019 18:59:50 +0300
Message-Id: <20190809160047.8319-36-alazar@bitdefender.com>
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

From: Yang Weijiang <weijiang.yang@intel.com>

Check SPP capability in MSR_IA32_VMX_PROCBASED_CTLS2, its 23-bit
indicates SPP support. Mark SPP bit in CPU capabilities bitmap if
it's supported.

Co-developed-by: He Chen <he.chen@linux.intel.com>
Signed-off-by: He Chen <he.chen@linux.intel.com>
Co-developed-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-3-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/cpufeatures.h |  1 +
 arch/x86/include/asm/vmx.h         |  1 +
 arch/x86/kernel/cpu/intel.c        |  4 ++++
 arch/x86/kvm/vmx/capabilities.h    |  5 +++++
 arch/x86/kvm/vmx/vmx.c             | 10 ++++++++++
 5 files changed, 21 insertions(+)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 6d6122524711..183b4fd864c6 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -228,6 +228,7 @@
 #define X86_FEATURE_FLEXPRIORITY	( 8*32+ 2) /* Intel FlexPriority */
 #define X86_FEATURE_EPT			( 8*32+ 3) /* Intel Extended Page Table */
 #define X86_FEATURE_VPID		( 8*32+ 4) /* Intel Virtual Processor ID */
+#define X86_FEATURE_SPP			( 8*32+ 5) /* Intel EPT-based Sub-Page Write Protection */
 
 #define X86_FEATURE_VMMCALL		( 8*32+15) /* Prefer VMMCALL to VMCALL */
 #define X86_FEATURE_XENPV		( 8*32+16) /* "" Xen paravirtual guest */
diff --git a/arch/x86/include/asm/vmx.h b/arch/x86/include/asm/vmx.h
index 4e4133e86484..a2c9e18e0ad7 100644
--- a/arch/x86/include/asm/vmx.h
+++ b/arch/x86/include/asm/vmx.h
@@ -81,6 +81,7 @@
 #define SECONDARY_EXEC_XSAVES			0x00100000
 #define SECONDARY_EXEC_PT_USE_GPA		0x01000000
 #define SECONDARY_EXEC_MODE_BASED_EPT_EXEC	0x00400000
+#define SECONDARY_EXEC_ENABLE_SPP		0x00800000
 #define SECONDARY_EXEC_TSC_SCALING              0x02000000
 
 #define PIN_BASED_EXT_INTR_MASK                 0x00000001
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index fc3c07fe7df5..b55156ce16da 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -476,6 +476,7 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 #define X86_VMX_FEATURE_PROC_CTLS2_EPT		0x00000002
 #define X86_VMX_FEATURE_PROC_CTLS2_VPID		0x00000020
 #define x86_VMX_FEATURE_EPT_CAP_AD		0x00200000
+#define X86_VMX_FEATURE_PROC_CTLS2_SPP		0x00800000
 
 	u32 vmx_msr_low, vmx_msr_high, msr_ctl, msr_ctl2;
 	u32 msr_vpid_cap, msr_ept_cap;
@@ -486,6 +487,7 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 	clear_cpu_cap(c, X86_FEATURE_EPT);
 	clear_cpu_cap(c, X86_FEATURE_VPID);
 	clear_cpu_cap(c, X86_FEATURE_EPT_AD);
+	clear_cpu_cap(c, X86_FEATURE_SPP);
 
 	rdmsr(MSR_IA32_VMX_PROCBASED_CTLS, vmx_msr_low, vmx_msr_high);
 	msr_ctl = vmx_msr_high | vmx_msr_low;
@@ -509,6 +511,8 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 		}
 		if (msr_ctl2 & X86_VMX_FEATURE_PROC_CTLS2_VPID)
 			set_cpu_cap(c, X86_FEATURE_VPID);
+		if (msr_ctl2 & X86_VMX_FEATURE_PROC_CTLS2_SPP)
+			set_cpu_cap(c, X86_FEATURE_SPP);
 	}
 }
 
diff --git a/arch/x86/kvm/vmx/capabilities.h b/arch/x86/kvm/vmx/capabilities.h
index 854e144131c6..8221ecbf6516 100644
--- a/arch/x86/kvm/vmx/capabilities.h
+++ b/arch/x86/kvm/vmx/capabilities.h
@@ -239,6 +239,11 @@ static inline bool cpu_has_vmx_pml(void)
 	return vmcs_config.cpu_based_2nd_exec_ctrl & SECONDARY_EXEC_ENABLE_PML;
 }
 
+static inline bool cpu_has_vmx_ept_spp(void)
+{
+	return vmcs_config.cpu_based_2nd_exec_ctrl & SECONDARY_EXEC_ENABLE_SPP;
+}
+
 static inline bool vmx_xsaves_supported(void)
 {
 	return vmcs_config.cpu_based_2nd_exec_ctrl &
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 97cfd5a316f3..f94e3defd9cf 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -114,6 +114,8 @@ static u64 __read_mostly host_xss;
 bool __read_mostly enable_pml = 1;
 module_param_named(pml, enable_pml, bool, S_IRUGO);
 
+static bool __read_mostly spp_supported = 0;
+
 #define MSR_BITMAP_MODE_X2APIC		1
 #define MSR_BITMAP_MODE_X2APIC_APICV	2
 
@@ -2247,6 +2249,7 @@ static __init int setup_vmcs_config(struct vmcs_config *vmcs_conf,
 			SECONDARY_EXEC_RDSEED_EXITING |
 			SECONDARY_EXEC_RDRAND_EXITING |
 			SECONDARY_EXEC_ENABLE_PML |
+			SECONDARY_EXEC_ENABLE_SPP |
 			SECONDARY_EXEC_TSC_SCALING |
 			SECONDARY_EXEC_PT_USE_GPA |
 			SECONDARY_EXEC_PT_CONCEAL_VMX |
@@ -3901,6 +3904,9 @@ static void vmx_compute_secondary_exec_control(struct vcpu_vmx *vmx)
 	if (!enable_pml)
 		exec_control &= ~SECONDARY_EXEC_ENABLE_PML;
 
+	if (!spp_supported)
+		exec_control &= ~SECONDARY_EXEC_ENABLE_SPP;
+
 	if (vmx_xsaves_supported()) {
 		/* Exposing XSAVES only when XSAVE is exposed */
 		bool xsaves_enabled =
@@ -7570,6 +7576,10 @@ static __init int hardware_setup(void)
 	if (!cpu_has_vmx_flexpriority())
 		flexpriority_enabled = 0;
 
+	if (cpu_has_vmx_ept_spp() && enable_ept &&
+	    boot_cpu_has(X86_FEATURE_SPP))
+		spp_supported = 1;
+
 	if (!cpu_has_virtual_nmis())
 		enable_vnmi = 0;
 

