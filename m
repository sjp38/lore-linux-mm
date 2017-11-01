Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9607B6B026D
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:28:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y7so1926376wmd.18
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:28:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t103si1438253wrc.401.2017.11.01.15.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 15:28:21 -0700 (PDT)
Date: Wed, 1 Nov 2017 23:28:17 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 03/23] x86, kaiser: disable global pages
In-Reply-To: <dad84c59-dea1-2ad6-b0be-14809426db01@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711012321110.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223152.B5D241B2@viggo.jf.intel.com> <alpine.DEB.2.20.1711012213370.1942@nanos> <dad84c59-dea1-2ad6-b0be-14809426db01@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, 1 Nov 2017, Dave Hansen wrote:
> On 11/01/2017 02:18 PM, Thomas Gleixner wrote:
> > On Tue, 31 Oct 2017, Dave Hansen wrote:
> >> --- a/arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages	2017-10-31 15:03:49.314064402 -0700
> >> +++ b/arch/x86/include/asm/pgtable_types.h	2017-10-31 15:03:49.323064827 -0700
> >> @@ -47,7 +47,12 @@
> >>  #define _PAGE_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_ACCESSED)
> >>  #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
> >>  #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
> >> +#ifdef CONFIG_X86_GLOBAL_PAGES
> >>  #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
> >> +#else
> >> +/* We must ensure that kernel TLBs are unusable while in userspace */
> >> +#define _PAGE_GLOBAL	(_AT(pteval_t, 0))
> >> +#endif
> > 
> > What you really want to do here is to clear PAGE_GLOBAL in the
> > supported_pte_mask. probe_page_size_mask() is the proper place for that.
> 
> How does something like this look?  I just remove _PAGE_GLOBAL from the
> default __PAGE_KERNEL permissions.

That should work, but how do you bring _PAGE_GLOBAL back when kaiser is
disabled at boot/runtime?

You might want to make __PAGE_KERNEL_GLOBAL a variable, but that might be
impossible for the early ASM stuff.

> I was a bit worried that if we pull _PAGE_GLOBAL out of
> __supported_pte_mask itself, we might not be able to use it for the
> shadow entries that map the entry/exit code like Linus suggested.

Hmm. Good point.  

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
