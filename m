Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9278FC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BAD520840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BAD520840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zytor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7679A8E0004; Thu,  7 Mar 2019 11:54:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1008E0002; Thu,  7 Mar 2019 11:54:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592778E0004; Thu,  7 Mar 2019 11:54:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26DCE8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 11:54:06 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v125so9246946itc.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 08:54:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=/FmZIbHvzouLLk2rqdzM5ZrIJOYhCDCs96JlTJDSiOU=;
        b=F9+JONIvbnkNDSjcMnytgbO2zoQht3cakg27lqMtduV8QVAsuyOUBeOrZRd5TI0x1O
         T5FW6nYColxpsjn7YyLHOtNI/YWiTsI/5p1CRIqOBP9liTfcv0KBDHLmpeiR19gWFXWT
         v+f1wDPTdZrx2xsaPHoXhDPd8i5uyHjDmKinr3bkrTHqncSgsdbahZJg7Mn4y+w0o89X
         GGru2fd+ScfDsxbhg2nrgQ3S6DtBBulR7JPz2exP3J60OyCXsdi7RzzZyr1cwwlnXaEZ
         M500L0/yWPv3Nhj6eX84Jv4Lekbs9Td5V8K83j313jGKT/MugXqCcqPthhSmRHHKsM7e
         vGGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
X-Gm-Message-State: APjAAAW/DtXvU8CG+vZejNrNEGuMv+fLuAnRAjtNuMVCNkHdSEQzNuNz
	PB04Y0HvFdQ74Eq6GpFKRqBB9SfXhuDeTMjGutebcX5FbgXMYsrN6vzlPH8ZZgIE6/CeZt9ZE+F
	8ruQ+jZZWQD++4gKTpYAsCwQHhtriOkKi1iMwVJwgk11garbfl1/k//eesdMNTjBhnA==
X-Received: by 2002:a6b:5915:: with SMTP id n21mr7446603iob.260.1551977645883;
        Thu, 07 Mar 2019 08:54:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqzAS4Tx+JqbEToBWxdGwg4eEl2TQpVnGCuD/Ho4xR7gxvvLHMusdI7odqLb/Jl3EEs9OJ6t
X-Received: by 2002:a6b:5915:: with SMTP id n21mr7446524iob.260.1551977644338;
        Thu, 07 Mar 2019 08:54:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551977644; cv=none;
        d=google.com; s=arc-20160816;
        b=ibn+CjJIGTKrS9X5cOxeBKTgqBXcYp7LWVCs77MIXoadMcR48n46ErTt71PUdL2tuO
         K+UwIvwN16ZNqwW4GcQJ4rbNFPpkp3eeWa4wNOOU/xdZayty6pdkLZp+PozYmpHzDrOm
         4/gt7qfAY1GXcpODLKm6G7t19cJDokUPbY6mtHxuOnVF0G+8ty5XQf/WYo3AbzOh2s2q
         XhLfYWKzaEIu+mY3vJGMTFHi+89Eli5Em20Jl0qwhDxQaSGrjQKj2PEV98gt3i35JLwf
         09FrwJD1qdxttKPiINZQ7LE8Llc75zw7jQANC1RCIpFngdNFYVc5INruo0xB/iacCpG6
         cJAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date;
        bh=/FmZIbHvzouLLk2rqdzM5ZrIJOYhCDCs96JlTJDSiOU=;
        b=nXKV1f0WSk0hy9FLkmW7sFcWaptA/TzIlwNlqpv0V0J3k9Pf/j0EYvO1wqUinRuqcY
         mL4TOARcwbQ+1XzZARvWcFwjkwpmMDdM7gp9ASgsxkaKLkrOBmskOG36nOHjlmhufQnf
         6cZ1//R0/W/bNH8a99aJhGrReQwqNPDzWAvR2tq/gjGqGyhptdBwa65NC7OgQwu2Fxmo
         q2mfK+C371ldveloBwiW0vsHiD5s5XkLc9oB2XXrfM9AhVATVCGdJ28JGY6n+UdrexAQ
         3YzfN4Xio7LCkKHgtpFhEMKxi/wBefqFLg1JgZcXd/vze0ZukSXGMzQHo9zrLI/wDxl2
         CJVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id v189si2736069itd.80.2019.03.07.08.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 08:54:04 -0800 (PST)
Received-SPF: pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) client-ip=198.137.202.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hpa@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=hpa@zytor.com
Received: from [IPv6:2607:fb90:363c:d311:852d:262d:594c:4506] ([IPv6:2607:fb90:363c:d311:852d:262d:594c:4506])
	(authenticated bits=0)
	by mail.zytor.com (8.15.2/8.15.2) with ESMTPSA id x27GrdIq2261733
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO);
	Thu, 7 Mar 2019 08:53:40 -0800
Date: Thu, 07 Mar 2019 08:53:34 -0800
User-Agent: K-9 Mail for Android
In-Reply-To: <20190307072947.GA26566@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com> <20190129003422.9328-11-rick.p.edgecombe@intel.com> <20190211182956.GN19618@zn.tnic> <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com> <20190211190108.GP19618@zn.tnic> <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com> <20190211191059.GR19618@zn.tnic> <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com> <20190211194251.GS19618@zn.tnic> <20190307072947.GA26566@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules loading
To: Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>
CC: Rick Edgecombe <rick.p.edgecombe@intel.com>,
        Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
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
        Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>,
        Masami Hiramatsu <mhiramat@kernel.org>
From: hpa@zytor.com
Message-ID: <EF5F87D9-EA7B-4F92-81C4-329A89EEADFA@zytor.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On March 6, 2019 11:29:47 PM PST, Borislav Petkov <bp@alien8=2Ede> wrote:
>On Mon, Feb 11, 2019 at 08:42:51PM +0100, Borislav Petkov wrote:
>> On Mon, Feb 11, 2019 at 11:27:03AM -0800, Nadav Amit wrote:
>> > Is there any comment over static_cpu_has()? ;-)
>>=20
>> Almost:
>>=20
>> /*
>>  * Static testing of CPU features=2E  Used the same as boot_cpu_has()=
=2E
>>  * These will statically patch the target code for additional
>>  * performance=2E
>>  */
>> static __always_inline __pure bool _static_cpu_has(u16 bit)
>
>Ok, I guess something like that along with converting the obvious slow
>path callers to boot_cpu_has():
>
>---
>diff --git a/arch/x86/include/asm/cpufeature=2Eh
>b/arch/x86/include/asm/cpufeature=2Eh
>index ce95b8cbd229=2E=2Ee25d11ad7a88 100644
>--- a/arch/x86/include/asm/cpufeature=2Eh
>+++ b/arch/x86/include/asm/cpufeature=2Eh
>@@ -155,9 +155,12 @@ extern void clear_cpu_cap(struct cpuinfo_x86 *c,
>unsigned int bit);
> #else
>=20
> /*
>- * Static testing of CPU features=2E  Used the same as boot_cpu_has()=2E
>- * These will statically patch the target code for additional
>- * performance=2E
>+ * Static testing of CPU features=2E Used the same as boot_cpu_has()=2E =
It
>+ * statically patches the target code for additional performance=2E Use
>+ * static_cpu_has() only in fast paths, where every cycle counts=2E
>Which
>+ * means that the boot_cpu_has() variant is already fast enough for
>the
>+ * majority of cases and you should stick to using it as it is
>generally
>+ * only two instructions: a RIP-relative MOV and a TEST=2E
>  */
> static __always_inline __pure bool _static_cpu_has(u16 bit)
> {
>diff --git a/arch/x86/include/asm/fpu/internal=2Eh
>b/arch/x86/include/asm/fpu/internal=2Eh
>index fa2c93cb42a2=2E=2Ec525b053b3b3 100644
>--- a/arch/x86/include/asm/fpu/internal=2Eh
>+++ b/arch/x86/include/asm/fpu/internal=2Eh
>@@ -291,7 +291,7 @@ static inline void
>copy_xregs_to_kernel_booting(struct xregs_state *xstate)
>=20
> 	WARN_ON(system_state !=3D SYSTEM_BOOTING);
>=20
>-	if (static_cpu_has(X86_FEATURE_XSAVES))
>+	if (boot_cpu_has(X86_FEATURE_XSAVES))
> 		XSTATE_OP(XSAVES, xstate, lmask, hmask, err);
> 	else
> 		XSTATE_OP(XSAVE, xstate, lmask, hmask, err);
>@@ -313,7 +313,7 @@ static inline void
>copy_kernel_to_xregs_booting(struct xregs_state *xstate)
>=20
> 	WARN_ON(system_state !=3D SYSTEM_BOOTING);
>=20
>-	if (static_cpu_has(X86_FEATURE_XSAVES))
>+	if (boot_cpu_has(X86_FEATURE_XSAVES))
> 		XSTATE_OP(XRSTORS, xstate, lmask, hmask, err);
> 	else
> 		XSTATE_OP(XRSTOR, xstate, lmask, hmask, err);
>@@ -528,8 +528,7 @@ static inline void fpregs_activate(struct fpu *fpu)
>  *  - switch_fpu_finish() restores the new state as
>  *    necessary=2E
>  */
>-static inline void
>-switch_fpu_prepare(struct fpu *old_fpu, int cpu)
>+static inline void switch_fpu_prepare(struct fpu *old_fpu, int cpu)
> {
> 	if (static_cpu_has(X86_FEATURE_FPU) && old_fpu->initialized) {
> 		if (!copy_fpregs_to_fpstate(old_fpu))
>diff --git a/arch/x86/kernel/apic/apic_numachip=2Ec
>b/arch/x86/kernel/apic/apic_numachip=2Ec
>index 78778b54f904=2E=2Ea5464b8b6c46 100644
>--- a/arch/x86/kernel/apic/apic_numachip=2Ec
>+++ b/arch/x86/kernel/apic/apic_numachip=2Ec
>@@ -175,7 +175,7 @@ static void fixup_cpu_id(struct cpuinfo_x86 *c, int
>node)
> 	this_cpu_write(cpu_llc_id, node);
>=20
> 	/* Account for nodes per socket in multi-core-module processors */
>-	if (static_cpu_has(X86_FEATURE_NODEID_MSR)) {
>+	if (boot_cpu_has(X86_FEATURE_NODEID_MSR)) {
> 		rdmsrl(MSR_FAM10H_NODE_ID, val);
> 		nodes =3D ((val >> 3) & 7) + 1;
> 	}
>diff --git a/arch/x86/kernel/cpu/aperfmperf=2Ec
>b/arch/x86/kernel/cpu/aperfmperf=2Ec
>index 804c49493938=2E=2E64d5aec24203 100644
>--- a/arch/x86/kernel/cpu/aperfmperf=2Ec
>+++ b/arch/x86/kernel/cpu/aperfmperf=2Ec
>@@ -83,7 +83,7 @@ unsigned int aperfmperf_get_khz(int cpu)
> 	if (!cpu_khz)
> 		return 0;
>=20
>-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
>+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
> 		return 0;
>=20
> 	aperfmperf_snapshot_cpu(cpu, ktime_get(), true);
>@@ -99,7 +99,7 @@ void arch_freq_prepare_all(void)
> 	if (!cpu_khz)
> 		return;
>=20
>-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
>+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
> 		return;
>=20
> 	for_each_online_cpu(cpu)
>@@ -115,7 +115,7 @@ unsigned int arch_freq_get_on_cpu(int cpu)
> 	if (!cpu_khz)
> 		return 0;
>=20
>-	if (!static_cpu_has(X86_FEATURE_APERFMPERF))
>+	if (!boot_cpu_has(X86_FEATURE_APERFMPERF))
> 		return 0;
>=20
> 	if (aperfmperf_snapshot_cpu(cpu, ktime_get(), true))
>diff --git a/arch/x86/kernel/cpu/common=2Ec
>b/arch/x86/kernel/cpu/common=2Ec
>index cb28e98a0659=2E=2E95a5faf3a6a0 100644
>--- a/arch/x86/kernel/cpu/common=2Ec
>+++ b/arch/x86/kernel/cpu/common=2Ec
>@@ -1668,7 +1668,7 @@ static void setup_getcpu(int cpu)
>	unsigned long cpudata =3D vdso_encode_cpunode(cpu,
>early_cpu_to_node(cpu));
> 	struct desc_struct d =3D { };
>=20
>-	if (static_cpu_has(X86_FEATURE_RDTSCP))
>+	if (boot_cpu_has(X86_FEATURE_RDTSCP))
> 		write_rdtscp_aux(cpudata);
>=20
> 	/* Store CPU and node number in limit=2E */
>diff --git a/arch/x86/kernel/cpu/mce/inject=2Ec
>b/arch/x86/kernel/cpu/mce/inject=2Ec
>index 8492ef7d9015=2E=2E3da9a8823e47 100644
>--- a/arch/x86/kernel/cpu/mce/inject=2Ec
>+++ b/arch/x86/kernel/cpu/mce/inject=2Ec
>@@ -528,7 +528,7 @@ static void do_inject(void)
> 	 * only on the node base core=2E Refer to D18F3x44[NbMcaToMstCpuEn] for
> 	 * Fam10h and later BKDGs=2E
> 	 */
>-	if (static_cpu_has(X86_FEATURE_AMD_DCM) &&
>+	if (boot_cpu_has(X86_FEATURE_AMD_DCM) &&
> 	    b =3D=3D 4 &&
> 	    boot_cpu_data=2Ex86 < 0x17) {
> 		toggle_nb_mca_mst_cpu(amd_get_nb_id(cpu));
>diff --git a/arch/x86/kernel/cpu/proc=2Ec b/arch/x86/kernel/cpu/proc=2Ec
>index 2c8522a39ed5=2E=2Ecb2e49810d68 100644
>--- a/arch/x86/kernel/cpu/proc=2Ec
>+++ b/arch/x86/kernel/cpu/proc=2Ec
>@@ -35,11 +35,11 @@ static void show_cpuinfo_misc(struct seq_file *m,
>struct cpuinfo_x86 *c)
> 		   "fpu_exception\t: %s\n"
> 		   "cpuid level\t: %d\n"
> 		   "wp\t\t: yes\n",
>-		   static_cpu_has_bug(X86_BUG_FDIV) ? "yes" : "no",
>-		   static_cpu_has_bug(X86_BUG_F00F) ? "yes" : "no",
>-		   static_cpu_has_bug(X86_BUG_COMA) ? "yes" : "no",
>-		   static_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
>-		   static_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
>+		   boot_cpu_has_bug(X86_BUG_FDIV) ? "yes" : "no",
>+		   boot_cpu_has_bug(X86_BUG_F00F) ? "yes" : "no",
>+		   boot_cpu_has_bug(X86_BUG_COMA) ? "yes" : "no",
>+		   boot_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
>+		   boot_cpu_has(X86_FEATURE_FPU) ? "yes" : "no",
> 		   c->cpuid_level);
> }
> #else
>diff --git a/arch/x86/kernel/ldt=2Ec b/arch/x86/kernel/ldt=2Ec
>index 6135ae8ce036=2E=2Eb2463fcb20a8 100644
>--- a/arch/x86/kernel/ldt=2Ec
>+++ b/arch/x86/kernel/ldt=2Ec
>@@ -113,7 +113,7 @@ static void do_sanity_check(struct mm_struct *mm,
> 		 * tables=2E
> 		 */
> 		WARN_ON(!had_kernel_mapping);
>-		if (static_cpu_has(X86_FEATURE_PTI))
>+		if (boot_cpu_has(X86_FEATURE_PTI))
> 			WARN_ON(!had_user_mapping);
> 	} else {
> 		/*
>@@ -121,7 +121,7 @@ static void do_sanity_check(struct mm_struct *mm,
> 		 * Sync the pgd to the usermode tables=2E
> 		 */
> 		WARN_ON(had_kernel_mapping);
>-		if (static_cpu_has(X86_FEATURE_PTI))
>+		if (boot_cpu_has(X86_FEATURE_PTI))
> 			WARN_ON(had_user_mapping);
> 	}
> }
>@@ -156,7 +156,7 @@ static void map_ldt_struct_to_user(struct mm_struct
>*mm)
> 	k_pmd =3D pgd_to_pmd_walk(k_pgd, LDT_BASE_ADDR);
> 	u_pmd =3D pgd_to_pmd_walk(u_pgd, LDT_BASE_ADDR);
>=20
>-	if (static_cpu_has(X86_FEATURE_PTI) && !mm->context=2Eldt)
>+	if (boot_cpu_has(X86_FEATURE_PTI) && !mm->context=2Eldt)
> 		set_pmd(u_pmd, *k_pmd);
> }
>=20
>@@ -181,7 +181,7 @@ static void map_ldt_struct_to_user(struct mm_struct
>*mm)
> {
> 	pgd_t *pgd =3D pgd_offset(mm, LDT_BASE_ADDR);
>=20
>-	if (static_cpu_has(X86_FEATURE_PTI) && !mm->context=2Eldt)
>+	if (boot_cpu_has(X86_FEATURE_PTI) && !mm->context=2Eldt)
> 		set_pgd(kernel_to_user_pgdp(pgd), *pgd);
> }
>=20
>@@ -208,7 +208,7 @@ map_ldt_struct(struct mm_struct *mm, struct
>ldt_struct *ldt, int slot)
> 	spinlock_t *ptl;
> 	int i, nr_pages;
>=20
>-	if (!static_cpu_has(X86_FEATURE_PTI))
>+	if (!boot_cpu_has(X86_FEATURE_PTI))
> 		return 0;
>=20
> 	/*
>@@ -271,7 +271,7 @@ static void unmap_ldt_struct(struct mm_struct *mm,
>struct ldt_struct *ldt)
> 		return;
>=20
> 	/* LDT map/unmap is only required for PTI */
>-	if (!static_cpu_has(X86_FEATURE_PTI))
>+	if (!boot_cpu_has(X86_FEATURE_PTI))
> 		return;
>=20
> 	nr_pages =3D DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
>@@ -311,7 +311,7 @@ static void free_ldt_pgtables(struct mm_struct *mm)
> 	unsigned long start =3D LDT_BASE_ADDR;
> 	unsigned long end =3D LDT_END_ADDR;
>=20
>-	if (!static_cpu_has(X86_FEATURE_PTI))
>+	if (!boot_cpu_has(X86_FEATURE_PTI))
> 		return;
>=20
> 	tlb_gather_mmu(&tlb, mm, start, end);
>diff --git a/arch/x86/kernel/paravirt=2Ec b/arch/x86/kernel/paravirt=2Ec
>index c0e0101133f3=2E=2E7bbaa6baf37f 100644
>--- a/arch/x86/kernel/paravirt=2Ec
>+++ b/arch/x86/kernel/paravirt=2Ec
>@@ -121,7 +121,7 @@ DEFINE_STATIC_KEY_TRUE(virt_spin_lock_key);
>=20
> void __init native_pv_lock_init(void)
> {
>-	if (!static_cpu_has(X86_FEATURE_HYPERVISOR))
>+	if (!boot_cpu_has(X86_FEATURE_HYPERVISOR))
> 		static_branch_disable(&virt_spin_lock_key);
> }
>=20
>diff --git a/arch/x86/kernel/process=2Ec b/arch/x86/kernel/process=2Ec
>index 58ac7be52c7a=2E=2E16a7113e91c5 100644
>--- a/arch/x86/kernel/process=2Ec
>+++ b/arch/x86/kernel/process=2Ec
>@@ -236,7 +236,7 @@ static int get_cpuid_mode(void)
>=20
>static int set_cpuid_mode(struct task_struct *task, unsigned long
>cpuid_enabled)
> {
>-	if (!static_cpu_has(X86_FEATURE_CPUID_FAULT))
>+	if (!boot_cpu_has(X86_FEATURE_CPUID_FAULT))
> 		return -ENODEV;
>=20
> 	if (cpuid_enabled)
>@@ -666,7 +666,7 @@ static int prefer_mwait_c1_over_halt(const struct
>cpuinfo_x86 *c)
> 	if (c->x86_vendor !=3D X86_VENDOR_INTEL)
> 		return 0;
>=20
>-	if (!cpu_has(c, X86_FEATURE_MWAIT) ||
>static_cpu_has_bug(X86_BUG_MONITOR))
>+	if (!cpu_has(c, X86_FEATURE_MWAIT) ||
>boot_cpu_has_bug(X86_BUG_MONITOR))
> 		return 0;
>=20
> 	return 1;
>diff --git a/arch/x86/kernel/reboot=2Ec b/arch/x86/kernel/reboot=2Ec
>index 725624b6c0c0=2E=2Ed62ebbc5ec78 100644
>--- a/arch/x86/kernel/reboot=2Ec
>+++ b/arch/x86/kernel/reboot=2Ec
>@@ -108,7 +108,7 @@ void __noreturn machine_real_restart(unsigned int
>type)
> 	write_cr3(real_mode_header->trampoline_pgd);
>=20
> 	/* Exiting long mode will fail if CR4=2EPCIDE is set=2E */
>-	if (static_cpu_has(X86_FEATURE_PCID))
>+	if (boot_cpu_has(X86_FEATURE_PCID))
> 		cr4_clear_bits(X86_CR4_PCIDE);
> #endif
>=20
>diff --git a/arch/x86/kernel/vm86_32=2Ec b/arch/x86/kernel/vm86_32=2Ec
>index a092b6b40c6b=2E=2E6a38717d179c 100644
>--- a/arch/x86/kernel/vm86_32=2Ec
>+++ b/arch/x86/kernel/vm86_32=2Ec
>@@ -369,7 +369,7 @@ static long do_sys_vm86(struct vm86plus_struct
>__user *user_vm86, bool plus)
> 	preempt_disable();
> 	tsk->thread=2Esp0 +=3D 16;
>=20
>-	if (static_cpu_has(X86_FEATURE_SEP)) {
>+	if (boot_cpu_has(X86_FEATURE_SEP)) {
> 		tsk->thread=2Esysenter_cs =3D 0;
> 		refresh_sysenter_cs(&tsk->thread);
> 	}
>diff --git a/arch/x86/kvm/svm=2Ec b/arch/x86/kvm/svm=2Ec
>index f13a3a24d360=2E=2E5ed039bf1b58 100644
>--- a/arch/x86/kvm/svm=2Ec
>+++ b/arch/x86/kvm/svm=2Ec
>@@ -835,7 +835,7 @@ static void svm_init_erratum_383(void)
> 	int err;
> 	u64 val;
>=20
>-	if (!static_cpu_has_bug(X86_BUG_AMD_TLB_MMATCH))
>+	if (!boot_cpu_has_bug(X86_BUG_AMD_TLB_MMATCH))
> 		return;
>=20
> 	/* Use _safe variants to not break nested virtualization */
>@@ -889,7 +889,7 @@ static int has_svm(void)
> static void svm_hardware_disable(void)
> {
> 	/* Make sure we clean up behind us */
>-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR))
>+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR))
> 		wrmsrl(MSR_AMD64_TSC_RATIO, TSC_RATIO_DEFAULT);
>=20
> 	cpu_svm_disable();
>@@ -931,7 +931,7 @@ static int svm_hardware_enable(void)
>=20
> 	wrmsrl(MSR_VM_HSAVE_PA, page_to_pfn(sd->save_area) << PAGE_SHIFT);
>=20
>-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR)) {
>+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR)) {
> 		wrmsrl(MSR_AMD64_TSC_RATIO, TSC_RATIO_DEFAULT);
> 		__this_cpu_write(current_tsc_ratio, TSC_RATIO_DEFAULT);
> 	}
>@@ -2247,7 +2247,7 @@ static void svm_vcpu_load(struct kvm_vcpu *vcpu,
>int cpu)
> 	for (i =3D 0; i < NR_HOST_SAVE_USER_MSRS; i++)
> 		rdmsrl(host_save_user_msrs[i], svm->host_user_msrs[i]);
>=20
>-	if (static_cpu_has(X86_FEATURE_TSCRATEMSR)) {
>+	if (boot_cpu_has(X86_FEATURE_TSCRATEMSR)) {
> 		u64 tsc_ratio =3D vcpu->arch=2Etsc_scaling_ratio;
> 		if (tsc_ratio !=3D __this_cpu_read(current_tsc_ratio)) {
> 			__this_cpu_write(current_tsc_ratio, tsc_ratio);
>@@ -2255,7 +2255,7 @@ static void svm_vcpu_load(struct kvm_vcpu *vcpu,
>int cpu)
> 		}
> 	}
> 	/* This assumes that the kernel never uses MSR_TSC_AUX */
>-	if (static_cpu_has(X86_FEATURE_RDTSCP))
>+	if (boot_cpu_has(X86_FEATURE_RDTSCP))
> 		wrmsrl(MSR_TSC_AUX, svm->tsc_aux);
>=20
> 	if (sd->current_vmcb !=3D svm->vmcb) {
>diff --git a/arch/x86/kvm/vmx/vmx=2Ec b/arch/x86/kvm/vmx/vmx=2Ec
>index 30a6bcd735ec=2E=2E0ec24853a0e6 100644
>--- a/arch/x86/kvm/vmx/vmx=2Ec
>+++ b/arch/x86/kvm/vmx/vmx=2Ec
>@@ -6553,7 +6553,7 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
> 	if (vcpu->guest_debug & KVM_GUESTDBG_SINGLESTEP)
> 		vmx_set_interrupt_shadow(vcpu, 0);
>=20
>-	if (static_cpu_has(X86_FEATURE_PKU) &&
>+	if (boot_cpu_has(X86_FEATURE_PKU) &&
> 	    kvm_read_cr4_bits(vcpu, X86_CR4_PKE) &&
> 	    vcpu->arch=2Epkru !=3D vmx->host_pkru)
> 		__write_pkru(vcpu->arch=2Epkru);
>@@ -6633,7 +6633,7 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
> 	 * back on host, so it is safe to read guest PKRU from current
> 	 * XSAVE=2E
> 	 */
>-	if (static_cpu_has(X86_FEATURE_PKU) &&
>+	if (boot_cpu_has(X86_FEATURE_PKU) &&
> 	    kvm_read_cr4_bits(vcpu, X86_CR4_PKE)) {
> 		vcpu->arch=2Epkru =3D __read_pkru();
> 		if (vcpu->arch=2Epkru !=3D vmx->host_pkru)
>diff --git a/arch/x86/mm/dump_pagetables=2Ec
>b/arch/x86/mm/dump_pagetables=2Ec
>index e3cdc85ce5b6=2E=2Eb596ac1eed1c 100644
>--- a/arch/x86/mm/dump_pagetables=2Ec
>+++ b/arch/x86/mm/dump_pagetables=2Ec
>@@ -579,7 +579,7 @@ void ptdump_walk_pgd_level(struct seq_file *m,
>pgd_t *pgd)
>void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool
>user)
> {
> #ifdef CONFIG_PAGE_TABLE_ISOLATION
>-	if (user && static_cpu_has(X86_FEATURE_PTI))
>+	if (user && boot_cpu_has(X86_FEATURE_PTI))
> 		pgd =3D kernel_to_user_pgdp(pgd);
> #endif
> 	ptdump_walk_pgd_level_core(m, pgd, false, false);
>@@ -592,7 +592,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
> 	pgd_t *pgd =3D INIT_PGD;
>=20
> 	if (!(__supported_pte_mask & _PAGE_NX) ||
>-	    !static_cpu_has(X86_FEATURE_PTI))
>+	    !boot_cpu_has(X86_FEATURE_PTI))
> 		return;
>=20
> 	pr_info("x86/mm: Checking user space page tables\n");
>diff --git a/arch/x86/mm/pgtable=2Ec b/arch/x86/mm/pgtable=2Ec
>index 7bd01709a091=2E=2E3dbf440d4114 100644
>--- a/arch/x86/mm/pgtable=2Ec
>+++ b/arch/x86/mm/pgtable=2Ec
>@@ -190,7 +190,7 @@ static void pgd_dtor(pgd_t *pgd)
>* when PTI is enabled=2E We need them to map the per-process LDT into the
>  * user-space page-table=2E
>  */
>-#define PREALLOCATED_USER_PMDS	 (static_cpu_has(X86_FEATURE_PTI) ? \
>+#define PREALLOCATED_USER_PMDS	 (boot_cpu_has(X86_FEATURE_PTI) ? \
> 					KERNEL_PGD_PTRS : 0)
> #define MAX_PREALLOCATED_USER_PMDS KERNEL_PGD_PTRS
>=20
>@@ -292,7 +292,7 @@ static void pgd_mop_up_pmds(struct mm_struct *mm,
>pgd_t *pgdp)
>=20
> #ifdef CONFIG_PAGE_TABLE_ISOLATION
>=20
>-	if (!static_cpu_has(X86_FEATURE_PTI))
>+	if (!boot_cpu_has(X86_FEATURE_PTI))
> 		return;
>=20
> 	pgdp =3D kernel_to_user_pgdp(pgdp);
>diff --git a/arch/x86/mm/pti=2Ec b/arch/x86/mm/pti=2Ec
>index 4fee5c3003ed=2E=2E8c9a54ebda60 100644
>--- a/arch/x86/mm/pti=2Ec
>+++ b/arch/x86/mm/pti=2Ec
>@@ -626,7 +626,7 @@ void pti_set_kernel_image_nonglobal(void)
>  */
> void __init pti_init(void)
> {
>-	if (!static_cpu_has(X86_FEATURE_PTI))
>+	if (!boot_cpu_has(X86_FEATURE_PTI))
> 		return;
>=20
> 	pr_info("enabled\n");
>diff --git a/drivers/cpufreq/amd_freq_sensitivity=2Ec
>b/drivers/cpufreq/amd_freq_sensitivity=2Ec
>index 4ac7c3cf34be=2E=2E6927a8c0e748 100644
>--- a/drivers/cpufreq/amd_freq_sensitivity=2Ec
>+++ b/drivers/cpufreq/amd_freq_sensitivity=2Ec
>@@ -124,7 +124,7 @@ static int __init amd_freq_sensitivity_init(void)
> 			PCI_DEVICE_ID_AMD_KERNCZ_SMBUS, NULL);
>=20
> 	if (!pcidev) {
>-		if (!static_cpu_has(X86_FEATURE_PROC_FEEDBACK))
>+		if (!boot_cpu_has(X86_FEATURE_PROC_FEEDBACK))
> 			return -ENODEV;
> 	}
>=20
>diff --git a/drivers/cpufreq/intel_pstate=2Ec
>b/drivers/cpufreq/intel_pstate=2Ec
>index dd66decf2087=2E=2E9bbc3dfdebe3 100644
>--- a/drivers/cpufreq/intel_pstate=2Ec
>+++ b/drivers/cpufreq/intel_pstate=2Ec
>@@ -520,7 +520,7 @@ static s16 intel_pstate_get_epb(struct cpudata
>*cpu_data)
> 	u64 epb;
> 	int ret;
>=20
>-	if (!static_cpu_has(X86_FEATURE_EPB))
>+	if (!boot_cpu_has(X86_FEATURE_EPB))
> 		return -ENXIO;
>=20
> 	ret =3D rdmsrl_on_cpu(cpu_data->cpu, MSR_IA32_ENERGY_PERF_BIAS, &epb);
>@@ -534,7 +534,7 @@ static s16 intel_pstate_get_epp(struct cpudata
>*cpu_data, u64 hwp_req_data)
> {
> 	s16 epp;
>=20
>-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
>+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
> 		/*
> 		 * When hwp_req_data is 0, means that caller didn't read
> 		 * MSR_HWP_REQUEST, so need to read and get EPP=2E
>@@ -559,7 +559,7 @@ static int intel_pstate_set_epb(int cpu, s16 pref)
> 	u64 epb;
> 	int ret;
>=20
>-	if (!static_cpu_has(X86_FEATURE_EPB))
>+	if (!boot_cpu_has(X86_FEATURE_EPB))
> 		return -ENXIO;
>=20
> 	ret =3D rdmsrl_on_cpu(cpu, MSR_IA32_ENERGY_PERF_BIAS, &epb);
>@@ -607,7 +607,7 @@ static int
>intel_pstate_get_energy_pref_index(struct cpudata *cpu_data)
> 	if (epp < 0)
> 		return epp;
>=20
>-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
>+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
> 		if (epp =3D=3D HWP_EPP_PERFORMANCE)
> 			return 1;
> 		if (epp <=3D HWP_EPP_BALANCE_PERFORMANCE)
>@@ -616,7 +616,7 @@ static int
>intel_pstate_get_energy_pref_index(struct cpudata *cpu_data)
> 			return 3;
> 		else
> 			return 4;
>-	} else if (static_cpu_has(X86_FEATURE_EPB)) {
>+	} else if (boot_cpu_has(X86_FEATURE_EPB)) {
> 		/*
> 		 * Range:
> 		 *	0x00-0x03	:	Performance
>@@ -644,7 +644,7 @@ static int
>intel_pstate_set_energy_pref_index(struct cpudata *cpu_data,
>=20
> 	mutex_lock(&intel_pstate_limits_lock);
>=20
>-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
>+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
> 		u64 value;
>=20
> 		ret =3D rdmsrl_on_cpu(cpu_data->cpu, MSR_HWP_REQUEST, &value);
>@@ -819,7 +819,7 @@ static void intel_pstate_hwp_set(unsigned int cpu)
> 		epp =3D cpu_data->epp_powersave;
> 	}
> update_epp:
>-	if (static_cpu_has(X86_FEATURE_HWP_EPP)) {
>+	if (boot_cpu_has(X86_FEATURE_HWP_EPP)) {
> 		value &=3D ~GENMASK_ULL(31, 24);
> 		value |=3D (u64)epp << 24;
> 	} else {
>@@ -844,7 +844,7 @@ static void intel_pstate_hwp_force_min_perf(int
>cpu)
> 	value |=3D HWP_MIN_PERF(min_perf);
>=20
> 	/* Set EPP/EPB to min */
>-	if (static_cpu_has(X86_FEATURE_HWP_EPP))
>+	if (boot_cpu_has(X86_FEATURE_HWP_EPP))
> 		value |=3D HWP_ENERGY_PERF_PREFERENCE(HWP_EPP_POWERSAVE);
> 	else
> 		intel_pstate_set_epb(cpu, HWP_EPP_BALANCE_POWERSAVE);
>@@ -1191,7 +1191,7 @@ static void __init
>intel_pstate_sysfs_expose_params(void)
> static void intel_pstate_hwp_enable(struct cpudata *cpudata)
> {
>	/* First disable HWP notification interrupt as we don't process them
>*/
>-	if (static_cpu_has(X86_FEATURE_HWP_NOTIFY))
>+	if (boot_cpu_has(X86_FEATURE_HWP_NOTIFY))
> 		wrmsrl_on_cpu(cpudata->cpu, MSR_HWP_INTERRUPT, 0x00);
>=20
> 	wrmsrl_on_cpu(cpudata->cpu, MSR_PM_ENABLE, 0x1);
>diff --git a/drivers/cpufreq/powernow-k8=2Ec
>b/drivers/cpufreq/powernow-k8=2Ec
>index fb77b39a4ce3=2E=2E3c12e03fa343 100644
>--- a/drivers/cpufreq/powernow-k8=2Ec
>+++ b/drivers/cpufreq/powernow-k8=2Ec
>@@ -1178,7 +1178,7 @@ static int powernowk8_init(void)
> 	unsigned int i, supported_cpus =3D 0;
> 	int ret;
>=20
>-	if (static_cpu_has(X86_FEATURE_HW_PSTATE)) {
>+	if (boot_cpu_has(X86_FEATURE_HW_PSTATE)) {
> 		__request_acpi_cpufreq();
> 		return -ENODEV;
> 	}

I'm confused here, and as I'm on my phone on an aircraft I can't check the=
 back thread, but am I gathering that this tries to unbreak W^X during modu=
le loading by removing functions which use alternatives?

The right thing to do is to apply alternatives before the pages are marked=
 +x-w, like we do with the kernel proper during early boot, if this isn't a=
lready the case (sorry again, see above=2E)

If we *do*, what is the issue here? Although boot_cpu_has() isn't slow (it=
 should in general be possible to reduce to one testb instruction followed =
by a conditional jump)  it seems that "avoiding an alternatives slot" *shou=
ld* be a *very* weak reason, and seems to me to look like papering over som=
e other problem=2E


--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

