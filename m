Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6226B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:55:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t128so39459wmt.9
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:55:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor5762766edh.18.2018.02.14.09.55.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 09:55:51 -0800 (PST)
Date: Wed, 14 Feb 2018 20:55:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 8/9] x86/mm: Make __VIRTUAL_MASK_SHIFT dynamic
Message-ID: <20180214175548.6uxpm3bspmgqi7hs@node.shutemov.name>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
 <20180214111656.88514-9-kirill.shutemov@linux.intel.com>
 <CALCETrVafx9kZwsJrihUxKszio9rJCPZJHnWSh3QC992o=zxnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVafx9kZwsJrihUxKszio9rJCPZJHnWSh3QC992o=zxnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 14, 2018 at 05:22:58PM +0000, Andy Lutomirski wrote:
> On Wed, Feb 14, 2018 at 11:16 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > For boot-time switching between paging modes, we need to be able to
> > adjust virtual mask shifts.
> >
> > The change doesn't affect the kernel image size much:
> >
> >    text    data     bss     dec     hex filename
> > 8628892 4734340 1368064 14731296         e0c820 vmlinux.before
> > 8628966 4734340 1368064 14731370         e0c86a vmlinux.after
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/entry/entry_64.S            | 12 ++++++++++++
> >  arch/x86/include/asm/page_64_types.h |  2 +-
> >  arch/x86/mm/dump_pagetables.c        | 12 ++++++++++--
> >  arch/x86/mm/kaslr.c                  |  4 +++-
> >  4 files changed, 26 insertions(+), 4 deletions(-)
> >
> > diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
> > index cd216c9431e1..1608b13a0b36 100644
> > --- a/arch/x86/entry/entry_64.S
> > +++ b/arch/x86/entry/entry_64.S
> > @@ -260,8 +260,20 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
> >          * Change top bits to match most significant bit (47th or 56th bit
> >          * depending on paging mode) in the address.
> >          */
> > +#ifdef CONFIG_X86_5LEVEL
> > +       testl   $1, pgtable_l5_enabled(%rip)
> > +       jz      1f
> > +       shl     $(64 - 57), %rcx
> > +       sar     $(64 - 57), %rcx
> > +       jmp     2f
> > +1:
> > +       shl     $(64 - 48), %rcx
> > +       sar     $(64 - 48), %rcx
> > +2:
> > +#else
> >         shl     $(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
> >         sar     $(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
> > +#endif
> 
> Eww.
> 
> Can't this be ALTERNATIVE "shl ... sar ...", "shl ... sar ...",
> X86_FEATURE_5LEVEL or similar?

Optimization comes in a separate patch:

https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=la57/boot-switching/wip&id=015fa3576a7f2b8bd271096bb3a12b06cdc845af

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
