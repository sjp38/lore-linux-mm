Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50521C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:29:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 964F320851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:29:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="S4RhEn+a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 964F320851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F11D8E0003; Thu,  7 Mar 2019 02:29:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8F68E0002; Thu,  7 Mar 2019 02:29:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 891478E0003; Thu,  7 Mar 2019 02:29:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBB18E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 02:29:54 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id p3so8218344wrs.7
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 23:29:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=99ZJ/CKYaQwNZTloIqgTS21/00jcr5yYa1IMXSqTgXE=;
        b=bfXBMvRAQkydJ4McX8/ArjlW8Cah5kp7UPh1eWoA82RuJzQeUk4l6JvJxyiq7j/4V4
         bk6IO5qkFaenf53S7Hbh1JNkRoABtiEX9gADwrE/iv7NlFnCvEaXW/r1sLwExskEwigu
         v0LyZ4FlUE6xcZwD8bN5e4vGEHun3zH2OxPHJ1vkcpsDXgHFAeWT+MWclHvBD2UB7JLG
         sAd0V4ofPm0qQeOJWVlpdhzZZAnMC3DW94W/2HZbRzmQe1+ILKW/lc6nEqN/HgwBp45n
         f4xJ+ERTd+GD+st1vK6tYow5VpHoi9O0oayso6NsGvzRGrXwawShAZhfwlgogG1/vDoG
         +MEw==
X-Gm-Message-State: APjAAAVnSU0UzPryQwHEDs/sp1KtB2z0EAezpBQ2cWYd/lvsBnQahbm/
	1hXDXsP9xIG0538NzMZtJMU8xZXqVFkJJcgic0A3bvtRPLPLilHd/ZANJ1PZT5Jf0nWhpAeg0yd
	FqiXs8eepPpg3PIeHRMmwXfqHl96i6CS+ZE8E/yJ/nLTIKjh8pHKwWDIal7wx5WcGlw==
X-Received: by 2002:a05:600c:2210:: with SMTP id z16mr4635365wml.57.1551943793013;
        Wed, 06 Mar 2019 23:29:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqzZenSkHGrcdfLUVS18EEZm8PKmRDLano64gLSoo8ZnxFWPG60ovnDGi646coc6YKkRnDOd
X-Received: by 2002:a05:600c:2210:: with SMTP id z16mr4635269wml.57.1551943790852;
        Wed, 06 Mar 2019 23:29:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551943790; cv=none;
        d=google.com; s=arc-20160816;
        b=V91O8wpdDZW/RsgUxC85BJjRxInzgSbJQhccPxD48PZtP492eO7d8nhfDgAjHTr9xL
         MxKox9HfKjj86vl/EEwZcmBIxbBi+QFlYBmyv+2EbLH8ENeJCLDMT3dmLPXaboeKgZqj
         IoggfymTIVOiL4flD8Z7fW1S+sTiB3qL3aTUbiuzIVHXukBJ94OnQ+NFx5RWi3v4e7Nu
         Ubf48De2NaNgp94KdFjyde3XQLKw/i9Xo5ptaoLaHOxCtzxmKQnm2AwXLFSmVedT0gdN
         Ws+jWL/RfDdtUwkahFAHuapbrmRnD0THQEMKc67DfmKnl0PlF+QjhKeZv+ZeYumh0PsS
         duUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=99ZJ/CKYaQwNZTloIqgTS21/00jcr5yYa1IMXSqTgXE=;
        b=Lmj7E+uwnw61JRSRsbeIIeD5lu+XgK6bOGWLzlmYBgS7nILEkLkfg52NA2iX7IDJ53
         J7B3+POlrS4h9hh2oVOpGomTzVVRZ21nQcMa4N7Na5s1cUv5eWASreqNv6gU8vM+K82M
         ADX9249MFYXw2KQUtZLkqfBUlqGJJeYtNGj2xf1RpuPODUaDZlCfTm+ktykSZ5WkrR7x
         JxJvLnBGTDombelb3fb6pAuTki1E0uzr3VqE56JM8LNxMvY5v3y9S7BSU79nfDYFQq8g
         F8Mnldm65HXUcUdAKwB4dCnK/q2jBDdJAB/kW3Q8PcatCHLmapM8Hn+/PsZr1zv3a200
         zh3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=S4RhEn+a;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id k6si2602758wre.173.2019.03.06.23.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 23:29:50 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=S4RhEn+a;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (unknown [IPv6:2003:ec:2f08:1c00:999d:fd9f:dba2:5ee8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 50CC31EC0354;
	Thu,  7 Mar 2019 08:29:49 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1551943789;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=99ZJ/CKYaQwNZTloIqgTS21/00jcr5yYa1IMXSqTgXE=;
	b=S4RhEn+aKrCSxNPJxZ1tAzxcuehU4/Y6S9pGPWIE19s76dEkz57jfvbkT01zrdyVzlF/+u
	oJMo05xqwDiDx8/SuecOrQ2X8c5O8Xw3fRlE4qlS2gR9WIpXu5W5weO8oS2J+WwAnhSViT
	g+jUiT/ks+d1lb0NoshDWypLe9KNZG0=
Date: Thu, 7 Mar 2019 08:29:47 +0100
From: Borislav Petkov <bp@alien8.de>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Damian Tometzki <linux_dti@icloud.com>,
	linux-integrity <linux-integrity@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	"Dock, Deneen T" <deneen.t.dock@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
Message-ID: <20190307072947.GA26566@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
 <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190211194251.GS19618@zn.tnic>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:42:51PM +0100, Borislav Petkov wrote:
> On Mon, Feb 11, 2019 at 11:27:03AM -0800, Nadav Amit wrote:
> > Is there any comment over static_cpu_has()? ;-)
> 
> Almost:
> 
> /*
>  * Static testing of CPU features.  Used the same as boot_cpu_has().
>  * These will statically patch the target code for additional
>  * performance.
>  */
> static __always_inline __pure bool _static_cpu_has(u16 bit)

Ok, I guess something like that along with converting the obvious slow
path callers to boot_cpu_has():

---
diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index ce95b8cbd229..e25d11ad7a88 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -155,9 +155,12 @@ extern void clear_cpu_cap(struct cpuinfo_x86 *c, unsigned int bit);
 #else
 
 /*
- * Static testing of CPU features.  Used the same as boot_cpu_has().
- * These will statically patch the target code for additional
- * performance.
+ * Static testing of CPU features. Used the same as boot_cpu_has(). It
+ * statically patches the target code for additional performance. Use
+ * static_cpu_has() only in fast paths, where every cycle counts. Which
+ * means that the boot_cpu_has() variant is already fast enough for the
+ * majority of cases and you should stick to using it as it is generally
+ * only two instructions: a RIP-relative MOV and a TEST.
  */
 static __always_inline __pure bool _static_cpu_has(u16 bit)
 {
diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index fa2c93cb42a2..c525b053b3b3 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -291,7 +291,7 @@ static inline void copy_xregs_to_kernel_booting(struct xregs_state *xstate)
 
 	WARN_ON(system_state != SYSTEM_BOOTING);
 
-	if (static_cpu_has(X86_FEATURE_XSAVES))
+	if (boot_cpu_has(X86_FEATURE_XSAVES))
 		XSTATE_OP(XSAVES, xstate, lmask, hmask, err);
 	else
 		XSTATE_OP(XSAVE, xstate, lmask, hmask, err);
@@ -313,7 +313,7 @@ static inline void copy_kernel_to_xregs_booting(struct xregs_state *xstate)
 
 	WARN_ON(system_state != SYSTEM_BOOTING);
 
-	if (static_cpu_has(X86_FEATURE_XSAVES))
+	if (boot_cpu_has(X86_FEATURE_XSAVES))
 		XSTATE_OP(XRSTORS, xstate, lmask, hmask, err);
 	else
 		XSTATE_OP(XRSTOR, xstate, lmask, hmask, err);
@@ -528,8 +528,7 @@ static inline void fpregs_activate(struct fpu *fpu)
  *  - switch_fpu_finish() restores the new state as
  *    necessary.
  */
-static inline void
-switch_fpu_prepare(struct fpu *old_fpu, int cpu)
+static inline void switch_fpu_prepare(struct fpu *old_fpu, int cpu)
 {
 	if (static_cpu_has(X86_FEATURE_FPU) && old_fpu->initialized) {
 		if (!copy_fpregs_to_fpstate(old_fpu))
diff --git a/arch/x86/kernel/apic/apic_numachip.c b/arch/x86/kernel/apic/apic_numachip.c
index 78778b54f904..a5464b8b6c46 100644
--- a/arch/x86/kernel/apic/apic_numachip.c
+++ b/arch/x86/kernel/apic/apic_numachip.c
@@ -175,7 +175,7 @@ static void fixup_cpu_id(struct cpuinfo_x86 *c, int node)
 	this_cpu_write(cpu_llc_id, node);
 
 	/* Account for nodes per socket in multi-core-module processors */
-	if (static_cpu_has(X86_FEATURE_NODEID_MSR)) {
+	if (boot_cpu_has(X86_FEATURE_NODEID_MSR)) {
 		rdmsrl(MSR_FAM10H_NODE_ID, val);
 		nodes = ((val >> 3) & 7) + 1;
 	}
diff --git a/arch/x86/kernel/cpu/aperfmperf.c b/arch/x86/kernel/cpu/aperfmperf.c
index 804c49493938..64d5aec24203 100644
--- a/arch/x86/kernel/cpu/aperfmperf.c
+++ b/arch/x86/kernel/cpu/aperfmperf.c
@@ -83,7 +83,7 @@ unsigned int aperfmperf_get_khz(int cpu)
 	if (!cpu_khz)
 		return 0;
 
-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
 		return 0;
 
 	aperfmperf_snapshot_cpu(cpu, ktime_get(), true);
@@ -99,7 +99,7 @@ void arch_freq_prepare_all(void)
 	if (!cpu_khz)
 		return;
 
-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
 		return;
 
 	for_each_online_cpu(cpu)
@@ -115,7 +115,7 @@ unsigned int arch_freq_get_on_cpu(int cpu)
 	if (!cpu_khz)
 		return 0;
 
-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
 		return 0;
 
 	if (aperfmperf_snapshot_cpu(cpu, ktime_get(), true))
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index cb28e98a0659..95a5faf3a6a0 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1668,7 +1668,7 @@ static void setup_getcpu(int cpu)
 	unsigned long cpudata = vdso_encode_cpunode(cpu, early_cpu_to_node(cpu));
 	struct desc_struct d = { };
 
-	if (static_cpu_has(X86_FEATURE_RDTSCP))
+	if (boot_cpu_has(X86_FEATURE_RDTSCP))
 		write_rdtscp_aux(cpudata);
 
 	/* Store CPU and node number in limit. */
diff --git a/arch/x86/kernel/cpu/mce/inject.c b/arch/x86/kernel/cpu/mce/inject.c
index 8492ef7d9015..3da9a8823e47 100644
--- a/arch/x86/kernel/cpu/mce/inject.c
+++ b/arch/x86/kernel/cpu/mce/inject.c
@@ -528,7 +528,7 @@ static void do_inject(void)
 	 * only on the node base core. Refer to D18F3x44[NbMcaToMstCpuEn] for
 	 * Fam10h and later BKDGs.
 	 */
-	if (static_cpu_has(X86_FEATURE_AMD_DCM) &&
+	if (boot_cpu_has(X86_FEATURE_AMD_DCM) &&
 	    b == 4 &&
 	    boot_cpu_data.x86 < 0x17) {
 		toggle_nb_mca_mst_cpu(amd_get_nb_id(cpu));
diff --git a/arch/x86/kernel/cpu/proc.c b/arch/x86/kernel/cpu/proc.c
index 2c8522a39ed5..cb2e49810d68 100644
--- a/arch/x86/kernel/cpu/proc.c
+++ b/arch/x86/kernel/cpu/proc.c
@@ -35,11 +35,11 @@ static void show_cpuinfo_misc(struct seq_file *m, struct cpuinfo_x86 *c)
 		   "fpu_exception\t: %s\n"
 		   "cpuid level\t: %d\n"
 		   "wp\t\t: yes\n",
-		   static_cpu_has_bug(X86_BUG_FDIV) ? "yes" : "no",
-		   static_cpu_has_bug(X86_BUG_F00F) ? "yes" : "no",
-		   static_cpu_has_bug(X86_BUG_COMA) ? "yes" : "no",
-		   static_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
-		   static_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
+		   boot_cpu_has_bug(X86_BUG_FDIV) ? "yes" : "no",
+		   boot_cpu_has_bug(X86_BUG_F00F) ? "yes" : "no",
+		   boot_cpu_has_bug(X86_BUG_COMA) ? "yes" : "no",
+		   boot_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
+		   boot_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
 		   c->cpuid_level);
 }
 #else
diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 6135ae8ce036..b2463fcb20a8 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -113,7 +113,7 @@ static void do_sanity_check(struct mm_struct *mm,
 		 * tables.
 		 */
 		WARN_ON(!had_kernel_mapping);
-		if (static_cpu_has(X86_FEATURE_PTI))
+		if (boot_cpu_has(X86_FEATURE_PTI))
 			WARN_ON(!had_user_mapping);
 	} else {
 		/*
@@ -121,7 +121,7 @@ static void do_sanity_check(struct mm_struct *mm,
 		 * Sync the pgd to the usermode tables.
 		 */
 		WARN_ON(had_kernel_mapping);
-		if (static_cpu_has(X86_FEATURE_PTI))
+		if (boot_cpu_has(X86_FEATURE_PTI))
 			WARN_ON(had_user_mapping);
 	}
 }
@@ -156,7 +156,7 @@ static void map_ldt_struct_to_user(struct mm_struct *mm)
 	k_pmd = pgd_to_pmd_walk(k_pgd, LDT_BASE_ADDR);
 	u_pmd = pgd_to_pmd_walk(u_pgd, LDT_BASE_ADDR);
 
-	if (static_cpu_has(X86_FEATURE_PTI) && !mm->context.ldt)
+	if (boot_cpu_has(X86_FEATURE_PTI) && !mm->context.ldt)
 		set_pmd(u_pmd, *k_pmd);
 }
 
@@ -181,7 +181,7 @@ static void map_ldt_struct_to_user(struct mm_struct *mm)
 {
 	pgd_t *pgd = pgd_offset(mm, LDT_BASE_ADDR);
 
-	if (static_cpu_has(X86_FEATURE_PTI) && !mm->context.ldt)
+	if (boot_cpu_has(X86_FEATURE_PTI) && !mm->context.ldt)
 		set_pgd(kernel_to_user_pgdp(pgd), *pgd);
 }
 
@@ -208,7 +208,7 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	spinlock_t *ptl;
 	int i, nr_pages;
 
-	if (!static_cpu_has(X86_FEATURE_PTI))
+	if (!boot_cpu_has(X86_FEATURE_PTI))
 		return 0;
 
 	/*
@@ -271,7 +271,7 @@ static void unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
 		return;
 
 	/* LDT map/unmap is only required for PTI */
-	if (!static_cpu_has(X86_FEATURE_PTI))
+	if (!boot_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
@@ -311,7 +311,7 @@ static void free_ldt_pgtables(struct mm_struct *mm)
 	unsigned long start = LDT_BASE_ADDR;
 	unsigned long end = LDT_END_ADDR;
 
-	if (!static_cpu_has(X86_FEATURE_PTI))
+	if (!boot_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	tlb_gather_mmu(&tlb, mm, start, end);
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index c0e0101133f3..7bbaa6baf37f 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -121,7 +121,7 @@ DEFINE_STATIC_KEY_TRUE(virt_spin_lock_key);
 
 void __init native_pv_lock_init(void)
 {
-	if (!static_cpu_has(X86_FEATURE_HYPERVISOR))
+	if (!boot_cpu_has(X86_FEATURE_HYPERVISOR))
 		static_branch_disable(&virt_spin_lock_key);
 }
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 58ac7be52c7a..16a7113e91c5 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -236,7 +236,7 @@ static int get_cpuid_mode(void)
 
 static int set_cpuid_mode(struct task_struct *task, unsigned long cpuid_enabled)
 {
-	if (!static_cpu_has(X86_FEATURE_CPUID_FAULT))
+	if (!boot_cpu_has(X86_FEATURE_CPUID_FAULT))
 		return -ENODEV;
 
 	if (cpuid_enabled)
@@ -666,7 +666,7 @@ static int prefer_mwait_c1_over_halt(const struct cpuinfo_x86 *c)
 	if (c->x86_vendor != X86_VENDOR_INTEL)
 		return 0;
 
-	if (!cpu_has(c, X86_FEATURE_MWAIT) || static_cpu_has_bug(X86_BUG_MONITOR))
+	if (!cpu_has(c, X86_FEATURE_MWAIT) || boot_cpu_has_bug(X86_BUG_MONITOR))
 		return 0;
 
 	return 1;
diff --git a/arch/x86/kernel/reboot.c b/arch/x86/kernel/reboot.c
index 725624b6c0c0..d62ebbc5ec78 100644
--- a/arch/x86/kernel/reboot.c
+++ b/arch/x86/kernel/reboot.c
@@ -108,7 +108,7 @@ void __noreturn machine_real_restart(unsigned int type)
 	write_cr3(real_mode_header->trampoline_pgd);
 
 	/* Exiting long mode will fail if CR4.PCIDE is set. */
-	if (static_cpu_has(X86_FEATURE_PCID))
+	if (boot_cpu_has(X86_FEATURE_PCID))
 		cr4_clear_bits(X86_CR4_PCIDE);
 #endif
 
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index a092b6b40c6b..6a38717d179c 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -369,7 +369,7 @@ static long do_sys_vm86(struct vm86plus_struct __user *user_vm86, bool plus)
 	preempt_disable();
 	tsk->thread.sp0 += 16;
 
-	if (static_cpu_has(X86_FEATURE_SEP)) {
+	if (boot_cpu_has(X86_FEATURE_SEP)) {
 		tsk->thread.sysenter_cs = 0;
 		refresh_sysenter_cs(&tsk->thread);
 	}
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f13a3a24d360..5ed039bf1b58 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -835,7 +835,7 @@ static void svm_init_erratum_383(void)
 	int err;
 	u64 val;
 
-	if (!static_cpu_has_bug(X86_BUG_AMD_TLB_MMATCH))
+	if (!boot_cpu_has_bug(X86_BUG_AMD_TLB_MMATCH))
 		return;
 
 	/* Use _safe variants to not break nested virtualization */
@@ -889,7 +889,7 @@ static int has_svm(void)
 static void svm_hardware_disable(void)
 {
 	/* Make sure we clean up behind us */
-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR))
+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR))
 		wrmsrl(MSR_AMD64_TSC_RATIO, TSC_RATIO_DEFAULT);
 
 	cpu_svm_disable();
@@ -931,7 +931,7 @@ static int svm_hardware_enable(void)
 
 	wrmsrl(MSR_VM_HSAVE_PA, page_to_pfn(sd->save_area) << PAGE_SHIFT);
 
-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR)) {
+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR)) {
 		wrmsrl(MSR_AMD64_TSC_RATIO, TSC_RATIO_DEFAULT);
 		__this_cpu_write(current_tsc_ratio, TSC_RATIO_DEFAULT);
 	}
@@ -2247,7 +2247,7 @@ static void svm_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 	for (i = 0; i < NR_HOST_SAVE_USER_MSRS; i++)
 		rdmsrl(host_save_user_msrs[i], svm->host_user_msrs[i]);
 
-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR)) {
+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR)) {
 		u64 tsc_ratio = vcpu->arch.tsc_scaling_ratio;
 		if (tsc_ratio != __this_cpu_read(current_tsc_ratio)) {
 			__this_cpu_write(current_tsc_ratio, tsc_ratio);
@@ -2255,7 +2255,7 @@ static void svm_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 		}
 	}
 	/* This assumes that the kernel never uses MSR_TSC_AUX */
-	if (static_cpu_has(X86_FEATURE_RDTSCP))
+	if (boot_cpu_has(X86_FEATURE_RDTSCP))
 		wrmsrl(MSR_TSC_AUX, svm->tsc_aux);
 
 	if (sd->current_vmcb != svm->vmcb) {
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 30a6bcd735ec..0ec24853a0e6 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -6553,7 +6553,7 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	if (vcpu->guest_debug & KVM_GUESTDBG_SINGLESTEP)
 		vmx_set_interrupt_shadow(vcpu, 0);
 
-	if (static_cpu_has(X86_FEATURE_PKU) &&
+	if (boot_cpu_has(X86_FEATURE_PKU) &&
 	    kvm_read_cr4_bits(vcpu, X86_CR4_PKE) &&
 	    vcpu->arch.pkru != vmx->host_pkru)
 		__write_pkru(vcpu->arch.pkru);
@@ -6633,7 +6633,7 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	 * back on host, so it is safe to read guest PKRU from current
 	 * XSAVE.
 	 */
-	if (static_cpu_has(X86_FEATURE_PKU) &&
+	if (boot_cpu_has(X86_FEATURE_PKU) &&
 	    kvm_read_cr4_bits(vcpu, X86_CR4_PKE)) {
 		vcpu->arch.pkru = __read_pkru();
 		if (vcpu->arch.pkru != vmx->host_pkru)
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index e3cdc85ce5b6..b596ac1eed1c 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -579,7 +579,7 @@ void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-	if (user && static_cpu_has(X86_FEATURE_PTI))
+	if (user && boot_cpu_has(X86_FEATURE_PTI))
 		pgd = kernel_to_user_pgdp(pgd);
 #endif
 	ptdump_walk_pgd_level_core(m, pgd, false, false);
@@ -592,7 +592,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 	pgd_t *pgd = INIT_PGD;
 
 	if (!(__supported_pte_mask & _PAGE_NX) ||
-	    !static_cpu_has(X86_FEATURE_PTI))
+	    !boot_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	pr_info("x86/mm: Checking user space page tables\n");
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7bd01709a091..3dbf440d4114 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -190,7 +190,7 @@ static void pgd_dtor(pgd_t *pgd)
  * when PTI is enabled. We need them to map the per-process LDT into the
  * user-space page-table.
  */
-#define PREALLOCATED_USER_PMDS	 (static_cpu_has(X86_FEATURE_PTI) ? \
+#define PREALLOCATED_USER_PMDS	 (boot_cpu_has(X86_FEATURE_PTI) ? \
 					KERNEL_PGD_PTRS : 0)
 #define MAX_PREALLOCATED_USER_PMDS KERNEL_PGD_PTRS
 
@@ -292,7 +292,7 @@ static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 
-	if (!static_cpu_has(X86_FEATURE_PTI))
+	if (!boot_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	pgdp = kernel_to_user_pgdp(pgdp);
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 4fee5c3003ed..8c9a54ebda60 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -626,7 +626,7 @@ void pti_set_kernel_image_nonglobal(void)
  */
 void __init pti_init(void)
 {
-	if (!static_cpu_has(X86_FEATURE_PTI))
+	if (!boot_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	pr_info("enabled\n");
diff --git a/drivers/cpufreq/amd_freq_sensitivity.c b/drivers/cpufreq/amd_freq_sensitivity.c
index 4ac7c3cf34be..6927a8c0e748 100644
--- a/drivers/cpufreq/amd_freq_sensitivity.c
+++ b/drivers/cpufreq/amd_freq_sensitivity.c
@@ -124,7 +124,7 @@ static int __init amd_freq_sensitivity_init(void)
 			PCI_DEVICE_ID_AMD_KERNCZ_SMBUS, NULL);
 
 	if (!pcidev) {
-		if (!static_cpu_has(X86_FEATURE_PROC_FEEDBACK))
+		if (!boot_cpu_has(X86_FEATURE_PROC_FEEDBACK))
 			return -ENODEV;
 	}
 
diff --git a/drivers/cpufreq/intel_pstate.c b/drivers/cpufreq/intel_pstate.c
index dd66decf2087..9bbc3dfdebe3 100644
--- a/drivers/cpufreq/intel_pstate.c
+++ b/drivers/cpufreq/intel_pstate.c
@@ -520,7 +520,7 @@ static s16 intel_pstate_get_epb(struct cpudata *cpu_data)
 	u64 epb;
 	int ret;
 
-	if (!static_cpu_has(X86_FEATURE_EPB))
+	if (!boot_cpu_has(X86_FEATURE_EPB))
 		return -ENXIO;
 
 	ret = rdmsrl_on_cpu(cpu_data->cpu, MSR_IA32_ENERGY_PERF_BIAS, &epb);
@@ -534,7 +534,7 @@ static s16 intel_pstate_get_epp(struct cpudata *cpu_data, u64 hwp_req_data)
 {
 	s16 epp;
 
-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
 		/*
 		 * When hwp_req_data is 0, means that caller didn't read
 		 * MSR_HWP_REQUEST, so need to read and get EPP.
@@ -559,7 +559,7 @@ static int intel_pstate_set_epb(int cpu, s16 pref)
 	u64 epb;
 	int ret;
 
-	if (!static_cpu_has(X86_FEATURE_EPB))
+	if (!boot_cpu_has(X86_FEATURE_EPB))
 		return -ENXIO;
 
 	ret = rdmsrl_on_cpu(cpu, MSR_IA32_ENERGY_PERF_BIAS, &epb);
@@ -607,7 +607,7 @@ static int intel_pstate_get_energy_pref_index(struct cpudata *cpu_data)
 	if (epp < 0)
 		return epp;
 
-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
 		if (epp == HWP_EPP_PERFORMANCE)
 			return 1;
 		if (epp <= HWP_EPP_BALANCE_PERFORMANCE)
@@ -616,7 +616,7 @@ static int intel_pstate_get_energy_pref_index(struct cpudata *cpu_data)
 			return 3;
 		else
 			return 4;
-	} else if (static_cpu_has(X86_FEATURE_EPB)) {
+	} else if (boot_cpu_has(X86_FEATURE_EPB)) {
 		/*
 		 * Range:
 		 *	0x00-0x03	:	Performance
@@ -644,7 +644,7 @@ static int intel_pstate_set_energy_pref_index(struct cpudata *cpu_data,
 
 	mutex_lock(&intel_pstate_limits_lock);
 
-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
 		u64 value;
 
 		ret = rdmsrl_on_cpu(cpu_data->cpu, MSR_HWP_REQUEST, &value);
@@ -819,7 +819,7 @@ static void intel_pstate_hwp_set(unsigned int cpu)
 		epp = cpu_data->epp_powersave;
 	}
 update_epp:
-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
 		value &= ~GENMASK_ULL(31, 24);
 		value |= (u64)epp << 24;
 	} else {
@@ -844,7 +844,7 @@ static void intel_pstate_hwp_force_min_perf(int cpu)
 	value |= HWP_MIN_PERF(min_perf);
 
 	/* Set EPP/EPB to min */
-	if (static_cpu_has(X86_FEATURE_HWP_EPP))
+	if (boot_cpu_has(X86_FEATURE_HWP_EPP))
 		value |= HWP_ENERGY_PERF_PREFERENCE(HWP_EPP_POWERSAVE);
 	else
 		intel_pstate_set_epb(cpu, HWP_EPP_BALANCE_POWERSAVE);
@@ -1191,7 +1191,7 @@ static void __init intel_pstate_sysfs_expose_params(void)
 static void intel_pstate_hwp_enable(struct cpudata *cpudata)
 {
 	/* First disable HWP notification interrupt as we don't process them */
-	if (static_cpu_has(X86_FEATURE_HWP_NOTIFY))
+	if (boot_cpu_has(X86_FEATURE_HWP_NOTIFY))
 		wrmsrl_on_cpu(cpudata->cpu, MSR_HWP_INTERRUPT, 0x00);
 
 	wrmsrl_on_cpu(cpudata->cpu, MSR_PM_ENABLE, 0x1);
diff --git a/drivers/cpufreq/powernow-k8.c b/drivers/cpufreq/powernow-k8.c
index fb77b39a4ce3..3c12e03fa343 100644
--- a/drivers/cpufreq/powernow-k8.c
+++ b/drivers/cpufreq/powernow-k8.c
@@ -1178,7 +1178,7 @@ static int powernowk8_init(void)
 	unsigned int i, supported_cpus = 0;
 	int ret;
 
-	if (static_cpu_has(X86_FEATURE_HW_PSTATE)) {
+	if (boot_cpu_has(X86_FEATURE_HW_PSTATE)) {
 		__request_acpi_cpufreq();
 		return -ENODEV;
 	}

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

