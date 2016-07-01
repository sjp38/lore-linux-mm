Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 899E3828E4
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:30:58 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id j65so73978148vkg.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:30:58 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id u142si1629310vkb.121.2016.07.01.09.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 09:30:57 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id m127so100234677vkb.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:30:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160701092300.GD4593@pd.tnic>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001210.AA77B917@viggo.jf.intel.com>
 <20160701092300.GD4593@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 1 Jul 2016 09:30:37 -0700
Message-ID: <CALCETrV+uq4fcgmUK_u6_Tu6Ex3FrYM0fQjDbjwy5KZ8f8OuHg@mail.gmail.com>
Subject: Re: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Michal Hocko <mhocko@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave@sr71.net>

On Jul 1, 2016 2:23 AM, "Borislav Petkov" <bp@alien8.de> wrote:
>
> On Thu, Jun 30, 2016 at 05:12:10PM -0700, Dave Hansen wrote:
> >
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> > epufeatures.h currently defines X86_BUG(9) twice on 32-bit:
> >
> >       #define X86_BUG_NULL_SEG        X86_BUG(9) /* Nulling a selector preserves the base */
> >       ...
> >       #ifdef CONFIG_X86_32
> >       #define X86_BUG_ESPFIX          X86_BUG(9) /* "" IRET to 16-bit SS corrupts ESP/RSP high bits */
> >       #endif
> >
> > I think what happened was that this added the X86_BUG_ESPFIX, but
> > in an #ifdef below most of the bugs:
> >
> >       [58a5aac5] x86/entry/32: Introduce and use X86_BUG_ESPFIX instead of paravirt_enabled
> >
> > Then this came along and added X86_BUG_NULL_SEG, but collided
> > with the earlier one that did the bug below the main block
> > defining all the X86_BUG()s.
> >
> >       [7a5d6704] x86/cpu: Probe the behavior of nulling out a segment at boot time
> >
> > Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> > Acked-by: Andy Lutomirski <luto@kernel.org>
> > Cc: stable@vger.kernel.org
> > ---
> >
> >  b/arch/x86/include/asm/cpufeatures.h |    6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> > diff -puN arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros arch/x86/include/asm/cpufeatures.h
> > --- a/arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros      2016-06-30 17:10:41.215185869 -0700
> > +++ b/arch/x86/include/asm/cpufeatures.h      2016-06-30 17:10:41.218186005 -0700
> > @@ -301,10 +301,6 @@
> >  #define X86_BUG_FXSAVE_LEAK  X86_BUG(6) /* FXSAVE leaks FOP/FIP/FOP */
> >  #define X86_BUG_CLFLUSH_MONITOR      X86_BUG(7) /* AAI65, CLFLUSH required before MONITOR */
> >  #define X86_BUG_SYSRET_SS_ATTRS      X86_BUG(8) /* SYSRET doesn't fix up SS attrs */
> > -#define X86_BUG_NULL_SEG     X86_BUG(9) /* Nulling a selector preserves the base */
> > -#define X86_BUG_SWAPGS_FENCE X86_BUG(10) /* SWAPGS without input dep on GS */
> > -
> > -
> >  #ifdef CONFIG_X86_32
> >  /*
> >   * 64-bit kernels don't use X86_BUG_ESPFIX.  Make the define conditional
>
> So I'd remove the "#ifdef CONFIG_X86_32" ifdeffery too and make that bit
> unconditional - so what, we have enough free bits. But I'd leave the
> comment to still avoid the confusion :)
>

I put the ifdef there to prevent anyone from accidentally using it in
a 64-bit code path, not to save a bit.  We could put in the middle of
the list to make the mistake much less likely to be repeated, I
suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
