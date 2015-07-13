Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C87DC6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:29:54 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so224985060pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:29:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pd1si28242043pdb.79.2015.07.13.05.29.53
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 05:29:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CALq1K=J-VqnTmgNj-pbfq8Ps-mgU3=10i0WiS2S5V37og9bMcw@mail.gmail.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
 <CALq1K=J-VqnTmgNj-pbfq8Ps-mgU3=10i0WiS2S5V37og9bMcw@mail.gmail.com>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Content-Transfer-Encoding: 7bit
Message-Id: <20150713122920.32C8CA4@black.fi.intel.com>
Date: Mon, 13 Jul 2015 15:29:20 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

Leon Romanovsky wrote:
> Hi Kirill,
> 
> On Mon, Jul 13, 2015 at 1:54 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > MPX setups private anonymous mapping, but uses vma->vm_ops too.
> > This can confuse core VM, as it relies on vm->vm_ops to distinguish
> > file VMAs from anonymous.
> >
> > As result we will get SIGBUS, because handle_pte_fault() thinks it's
> > file VMA without vm_ops->fault and it doesn't know how to handle the
> > situation properly.
> >
> > Let's fix that by not setting ->vm_ops.
> >
> > We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> > flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> > ->vm_flags won't match.
> >
> > The only thing left is name of VMA. I'm not sure if it's part of ABI, or
> > we can just drop it. The patch keep it by providing arch_vma_name() on x86.
> >
> > Build tested only.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Andy Lutomirski <luto@amacapital.net>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >  arch/x86/mm/mmap.c |  7 +++++++
> >  arch/x86/mm/mpx.c  | 20 +-------------------
> >  2 files changed, 8 insertions(+), 19 deletions(-)
> >
> > diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> > index 9d518d693b4b..844b06d67df4 100644
> > --- a/arch/x86/mm/mmap.c
> > +++ b/arch/x86/mm/mmap.c
> > @@ -126,3 +126,10 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
> >                 mm->get_unmapped_area = arch_get_unmapped_area_topdown;
> >         }
> >  }
> > +
> > +const char *arch_vma_name(struct vm_area_struct *vma)
> > +{
> > +       if (vma->vm_flags & VM_MPX)
> > +               return "[mpx]";
> > +       return NULL;
> > +}
> 
> I sure that I'm missing something important. This function stores
> "[mpx]" string on this function stack and returns the pointer to that
> address. In current flow, this address is visible and accessible,
> however in can be a different in general case.

The string is not on stack. String literals are in .rodata and caller is
not allowed to modify it since it's "const char *".

-- 
 Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
