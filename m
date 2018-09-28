Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F56F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 13:01:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y8-v6so5058691pfl.11
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:01:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 8-v6si5133144pgq.120.2018.09.28.10.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 10:01:12 -0700 (PDT)
Message-ID: <459b7c5d85ef57b02985813d59f7dd3f7cc18368.camel@intel.com>
Subject: Re: [RFC PATCH v4 01/27] x86/cpufeatures: Add CPUIDs for
 Control-flow Enforcement Technology (CET)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 28 Sep 2018 09:56:32 -0700
In-Reply-To: <20180928165118.GD20768@zn.tnic>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-2-yu-cheng.yu@intel.com>
	 <20180928165118.GD20768@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-09-28 at 18:51 +0200, Borislav Petkov wrote:
> On Fri, Sep 21, 2018 at 08:03:25AM -0700, Yu-cheng Yu wrote:
> > Add CPUIDs for Control-flow Enforcement Technology (CET).
> > 
> > CPUID.(EAX=7,ECX=0):ECX[bit 7] Shadow stack
> > CPUID.(EAX=7,ECX=0):EDX[bit 20] Indirect branch tracking
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/include/asm/cpufeatures.h | 2 ++
> >  arch/x86/kernel/cpu/scattered.c    | 1 +
> >  2 files changed, 3 insertions(+)
> > 
> > diff --git a/arch/x86/include/asm/cpufeatures.h
> > b/arch/x86/include/asm/cpufeatures.h
> > index 89a048c2faec..fa69651a017e 100644
> > --- a/arch/x86/include/asm/cpufeatures.h
> > +++ b/arch/x86/include/asm/cpufeatures.h
> > @@ -221,6 +221,7 @@
> >  #define X86_FEATURE_ZEN			( 7*32+28) /* "" CPU is AMD
> > family 0x17 (Zen) */
> >  #define X86_FEATURE_L1TF_PTEINV		( 7*32+29) /* "" L1TF
> > workaround PTE inversion */
> >  #define X86_FEATURE_IBRS_ENHANCED	( 7*32+30) /* Enhanced IBRS */
> > +#define X86_FEATURE_IBT			( 7*32+31) /* Indirect
> > Branch Tracking */
> >  
> >  /* Virtualization flags: Linux defined, word 8 */
> >  #define X86_FEATURE_TPR_SHADOW		( 8*32+ 0) /* Intel TPR
> > Shadow */
> > @@ -321,6 +322,7 @@
> >  #define X86_FEATURE_PKU			(16*32+ 3) /* Protection
> > Keys for Userspace */
> >  #define X86_FEATURE_OSPKE		(16*32+ 4) /* OS Protection Keys
> > Enable */
> >  #define X86_FEATURE_AVX512_VBMI2	(16*32+ 6) /* Additional AVX512
> > Vector Bit Manipulation Instructions */
> > +#define X86_FEATURE_SHSTK		(16*32+ 7) /* Shadow Stack */
> >  #define X86_FEATURE_GFNI		(16*32+ 8) /* Galois Field New
> > Instructions */
> >  #define X86_FEATURE_VAES		(16*32+ 9) /* Vector AES */
> >  #define X86_FEATURE_VPCLMULQDQ		(16*32+10) /* Carry-Less
> > Multiplication Double Quadword */
> > diff --git a/arch/x86/kernel/cpu/scattered.c
> > b/arch/x86/kernel/cpu/scattered.c
> > index 772c219b6889..63cbb4d9938e 100644
> > --- a/arch/x86/kernel/cpu/scattered.c
> > +++ b/arch/x86/kernel/cpu/scattered.c
> > @@ -21,6 +21,7 @@ struct cpuid_bit {
> >  static const struct cpuid_bit cpuid_bits[] = {
> >  	{ X86_FEATURE_APERFMPERF,       CPUID_ECX,  0, 0x00000006, 0 },
> >  	{ X86_FEATURE_EPB,		CPUID_ECX,  3, 0x00000006, 0 },
> > +	{ X86_FEATURE_IBT,		CPUID_EDX, 20, 0x00000007, 0},
> 
> If you haven't noticed, there's already a separate leaf:
> 
> /* Intel-defined CPU features, CPUID level 0x00000007:0 (EDX), word 18 */
> 
> in arch/x86/include/asm/cpufeatures.h
> 

I will change to that one.  Thanks!

Yu-cheng
