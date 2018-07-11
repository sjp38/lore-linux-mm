Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7226B0008
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:59:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25-v6so17018812pfi.20
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:59:24 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j190-v6si20319012pfb.211.2018.07.11.13.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 13:59:23 -0700 (PDT)
Message-ID: <1531342544.15351.37.camel@intel.com>
Subject: Re: [RFC PATCH v2 27/27] x86/cet: Add arch_prctl functions for CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 13:55:44 -0700
In-Reply-To: <CAG48ez2cY1CPTTfDnV5yZyHVPXP787=fR1+G_D7tR5VYXdjFmQ@mail.gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-28-yu-cheng.yu@intel.com>
	 <CAG48ez2cY1CPTTfDnV5yZyHVPXP787=fR1+G_D7tR5VYXdjFmQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Wed, 2018-07-11 at 12:45 -0700, Jann Horn wrote:
> On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > arch_prctl(ARCH_CET_STATUS, unsigned long *addr)
> > A A A A Return CET feature status.
> > 
> > A A A A The parameter 'addr' is a pointer to a user buffer.
> > A A A A On returning to the caller, the kernel fills the following
> > A A A A information:
> > 
> > A A A A *addr = SHSTK/IBT status
> > A A A A *(addr + 1) = SHSTK base address
> > A A A A *(addr + 2) = SHSTK size
> > 
> > arch_prctl(ARCH_CET_DISABLE, unsigned long features)
> > A A A A Disable SHSTK and/or IBT specified in 'features'.A A Return
> > -EPERM
> > A A A A if CET is locked out.
> > 
> > arch_prctl(ARCH_CET_LOCK)
> > A A A A Lock out CET feature.
> > 
> > arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
> > A A A A Allocate a new SHSTK.
> > 
> > A A A A The parameter 'addr' is a pointer to a user buffer and
> > indicates
> > A A A A the desired SHSTK size to allocate.A A On returning to the caller
> > A A A A the buffer contains the address of the new SHSTK.
> > 
> > arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
> > A A A A Allocate an IBT legacy code bitmap if the current task does not
> > A A A A have one.
> > 
> > A A A A The parameter 'addr' is a pointer to a user buffer.
> > A A A A On returning to the caller, the kernel fills the following
> > A A A A information:
> > 
> > A A A A *addr = IBT bitmap base address
> > A A A A *(addr + 1) = IBT bitmap size
> > 
> > Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> [...]
> > 
> > diff --git a/arch/x86/kernel/cet_prctl.c
> > b/arch/x86/kernel/cet_prctl.c
> > new file mode 100644
> > index 000000000000..86bb78ae656d
> > --- /dev/null
> > +++ b/arch/x86/kernel/cet_prctl.c
> > @@ -0,0 +1,141 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +
> > +#include <linux/errno.h>
> > +#include <linux/uaccess.h>
> > +#include <linux/prctl.h>
> > +#include <linux/compat.h>
> > +#include <asm/processor.h>
> > +#include <asm/prctl.h>
> > +#include <asm/elf.h>
> > +#include <asm/elf_property.h>
> > +#include <asm/cet.h>
> > +
> > +/* See Documentation/x86/intel_cet.txt. */
> > +
> > +static int handle_get_status(unsigned long arg2)
> > +{
> > +A A A A A A A unsigned int features = 0;
> > +A A A A A A A unsigned long shstk_base, shstk_size;
> > +
> > +A A A A A A A if (current->thread.cet.shstk_enabled)
> > +A A A A A A A A A A A A A A A features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
> > +A A A A A A A if (current->thread.cet.ibt_enabled)
> > +A A A A A A A A A A A A A A A features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
> > +
> > +A A A A A A A shstk_base = current->thread.cet.shstk_base;
> > +A A A A A A A shstk_size = current->thread.cet.shstk_size;
> > +
> > +A A A A A A A if (in_ia32_syscall()) {
> > +A A A A A A A A A A A A A A A unsigned int buf[3];
> > +
> > +A A A A A A A A A A A A A A A buf[0] = features;
> > +A A A A A A A A A A A A A A A buf[1] = (unsigned int)shstk_base;
> > +A A A A A A A A A A A A A A A buf[2] = (unsigned int)shstk_size;
> > +A A A A A A A A A A A A A A A return copy_to_user((unsigned int __user *)arg2,
> > buf,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A sizeof(buf));
> > +A A A A A A A } else {
> > +A A A A A A A A A A A A A A A unsigned long buf[3];
> > +
> > +A A A A A A A A A A A A A A A buf[0] = (unsigned long)features;
> > +A A A A A A A A A A A A A A A buf[1] = shstk_base;
> > +A A A A A A A A A A A A A A A buf[2] = shstk_size;
> > +A A A A A A A A A A A A A A A return copy_to_user((unsigned long __user *)arg2,
> > buf,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A sizeof(buf));
> > +A A A A A A A }
> Other places in the kernel (e.g. the BPF subsystem) just
> unconditionally use u64 instead of unsigned long to avoid having to
> switch between different sizes. I wonder whether that would make
> sense
> here?

Yes, that simplifies the code. A I will make that change.

Yu-cheng
