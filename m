Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C3F7B6B0666
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 16:06:21 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x5-v6so9223898pfn.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 13:06:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 32-v6si4700609pgu.30.2018.11.08.13.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 13:06:20 -0800 (PST)
Message-ID: <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 08 Nov 2018 13:01:05 -0800
In-Reply-To: <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-5-yu-cheng.yu@intel.com>
	 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Thu, 2018-11-08 at 12:46 -0800, Andy Lutomirski wrote:
> On Thu, Oct 11, 2018 at 8:20 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > Intel Control-flow Enforcement Technology (CET) introduces the
> > following MSRs into the XSAVES system states.
> > 
> >     IA32_U_CET (user-mode CET settings),
> >     IA32_PL3_SSP (user-mode shadow stack),
> >     IA32_PL0_SSP (kernel-mode shadow stack),
> >     IA32_PL1_SSP (ring-1 shadow stack),
> >     IA32_PL2_SSP (ring-2 shadow stack).
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/include/asm/fpu/types.h            | 22 +++++++++++++++++++++
> >  arch/x86/include/asm/fpu/xstate.h           |  4 +++-
> >  arch/x86/include/uapi/asm/processor-flags.h |  2 ++
> >  arch/x86/kernel/fpu/xstate.c                | 10 ++++++++++
> >  4 files changed, 37 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/asm/fpu/types.h
> > b/arch/x86/include/asm/fpu/types.h
> > index 202c53918ecf..e55d51d172f1 100644
> > --- a/arch/x86/include/asm/fpu/types.h
> > +++ b/arch/x86/include/asm/fpu/types.h
> > @@ -114,6 +114,9 @@ enum xfeature {
> >         XFEATURE_Hi16_ZMM,
> >         XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
> >         XFEATURE_PKRU,
> > +       XFEATURE_RESERVED,
> > +       XFEATURE_SHSTK_USER,
> > +       XFEATURE_SHSTK_KERNEL,
> > 
> >         XFEATURE_MAX,
> >  };
> > @@ -128,6 +131,8 @@ enum xfeature {
> >  #define XFEATURE_MASK_Hi16_ZMM         (1 << XFEATURE_Hi16_ZMM)
> >  #define XFEATURE_MASK_PT               (1 <<
> > XFEATURE_PT_UNIMPLEMENTED_SO_FAR)
> >  #define XFEATURE_MASK_PKRU             (1 << XFEATURE_PKRU)
> > +#define XFEATURE_MASK_SHSTK_USER       (1 << XFEATURE_SHSTK_USER)
> > +#define XFEATURE_MASK_SHSTK_KERNEL     (1 << XFEATURE_SHSTK_KERNEL)
> > 
> >  #define XFEATURE_MASK_FPSSE            (XFEATURE_MASK_FP |
> > XFEATURE_MASK_SSE)
> >  #define XFEATURE_MASK_AVX512           (XFEATURE_MASK_OPMASK \
> > @@ -229,6 +234,23 @@ struct pkru_state {
> >         u32                             pad;
> >  } __packed;
> > 
> > +/*
> > + * State component 11 is Control flow Enforcement user states
> > + */
> > +struct cet_user_state {
> > +       u64 u_cet;      /* user control flow settings */
> > +       u64 user_ssp;   /* user shadow stack pointer */
> > +} __packed;
> > +
> > +/*
> > + * State component 12 is Control flow Enforcement kernel states
> > + */
> > +struct cet_kernel_state {
> > +       u64 kernel_ssp; /* kernel shadow stack */
> > +       u64 pl1_ssp;    /* ring-1 shadow stack */
> > +       u64 pl2_ssp;    /* ring-2 shadow stack */
> > +} __packed;
> > +
> 
> Why are these __packed?  It seems like it'll generate bad code for no
> obvious purpose.

That prevents any possibility that the compiler will insert padding, although in
64-bit kernel this should not happen to either struct.  Also all xstate
components here are packed.

Yu-cheng
