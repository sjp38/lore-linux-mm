Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3616B0008
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 17:20:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r81-v6so2906513pfk.11
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 14:20:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c68-v6si21580051pfa.45.2018.10.09.14.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 14:20:10 -0700 (PDT)
Message-ID: <38064485f5255aa999700d87debecbd6c7e084ba.camel@intel.com>
Subject: Re: [RFC PATCH v4 21/27] x86/cet/shstk: ELF header parsing of
 Shadow Stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 09 Oct 2018 14:15:14 -0700
In-Reply-To: <20181003232736.GI32759@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-22-yu-cheng.yu@intel.com>
	 <20181003232736.GI32759@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-10-04 at 01:27 +0200, Eugene Syromiatnikov wrote:
> On Fri, Sep 21, 2018 at 08:03:45AM -0700, Yu-cheng Yu wrote:

[...]

> > diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> > index 0d157d2a1e2a..5b5f169c5c07 100644
> > --- a/arch/x86/include/asm/elf.h
> > +++ b/arch/x86/include/asm/elf.h
> > @@ -382,4 +382,9 @@ struct va_alignment {
> >  
> >  extern struct va_alignment va_align;
> >  extern unsigned long align_vdso_addr(unsigned long);
> > +
> > +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> > +extern int arch_setup_features(void *ehdr, void *phdr, struct file *file,
> > +			       bool interp);
> > +#endif
> >  #endif /* _ASM_X86_ELF_H */
> > diff --git a/arch/x86/include/uapi/asm/elf_property.h
> > b/arch/x86/include/uapi/asm/elf_property.h
> > new file mode 100644
> > index 000000000000..af361207718c
> > --- /dev/null
> > +++ b/arch/x86/include/uapi/asm/elf_property.h
> > @@ -0,0 +1,15 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
> > +#define _UAPI_ASM_X86_ELF_PROPERTY_H
> > +
> > +/*
> > + * pr_type
> > + */
> > +#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
> > +
> > +/*
> > + * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
> > + */
> > +#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
> 
> Hm, these defeinitions aren't much different comparing to NT_*
> definitions in include/uapi/linux/elf.h, is it expected that those
> properties have to be parsed individually for each architecture?

Yes, we have NT_GNU_PROPERTY_TYPE_0 defined in include/uapi/linux/elf.h.
GNU_PROPERTY_X86_FEATURE_1_xxxx is for X86 only.

[...]

> 
> There's a lot of similar code with bpf stackmap .build-id code (commit
> v4.17-rc1~148^2~156^2~3^2~1), it might be worthy generalising some ELF
> traversal routines, since there's general need of parsing ELF property
> segments.

Only a small similarity exists.  The routine find_note_type_0() does a lot more
validation.  It appears stack_map_get_build_id() does not need that.

Yu-cheng
