Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 22E516B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:42:49 -0400 (EDT)
Received: by wicmz13 with SMTP id mz13so60750599wic.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:42:48 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id cw1si13257682wib.15.2015.07.13.05.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 05:42:47 -0700 (PDT)
Received: by wiga1 with SMTP id a1so68269031wig.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:42:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150713122920.32C8CA4@black.fi.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
 <CALq1K=J-VqnTmgNj-pbfq8Ps-mgU3=10i0WiS2S5V37og9bMcw@mail.gmail.com> <20150713122920.32C8CA4@black.fi.intel.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 13 Jul 2015 15:42:27 +0300
Message-ID: <CALq1K=KvuUOKGpUHYAB=awyQWsEJXSNyA_C+P0VRw5cja4gq_w@mail.gmail.com>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jul 13, 2015 at 3:29 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Leon Romanovsky wrote:
>> Hi Kirill,
>>
>> On Mon, Jul 13, 2015 at 1:54 PM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> >
>> > MPX setups private anonymous mapping, but uses vma->vm_ops too.
>> > This can confuse core VM, as it relies on vm->vm_ops to distinguish
>> > file VMAs from anonymous.
>> >
>> > As result we will get SIGBUS, because handle_pte_fault() thinks it's
>> > file VMA without vm_ops->fault and it doesn't know how to handle the
>> > situation properly.
>> >
>> > Let's fix that by not setting ->vm_ops.
>> >
>> > We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
>> > flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
>> > ->vm_flags won't match.
>> >
>> > The only thing left is name of VMA. I'm not sure if it's part of ABI, or
>> > we can just drop it. The patch keep it by providing arch_vma_name() on x86.
>> >
>> > Build tested only.
>> >
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> > Cc: Andy Lutomirski <luto@amacapital.net>
>> > Cc: Thomas Gleixner <tglx@linutronix.de>
>> > ---
>> >  arch/x86/mm/mmap.c |  7 +++++++
>> >  arch/x86/mm/mpx.c  | 20 +-------------------
>> >  2 files changed, 8 insertions(+), 19 deletions(-)
>> >
>> > diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
>> > index 9d518d693b4b..844b06d67df4 100644
>> > --- a/arch/x86/mm/mmap.c
>> > +++ b/arch/x86/mm/mmap.c
>> > @@ -126,3 +126,10 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
>> >                 mm->get_unmapped_area = arch_get_unmapped_area_topdown;
>> >         }
>> >  }
>> > +
>> > +const char *arch_vma_name(struct vm_area_struct *vma)
>> > +{
>> > +       if (vma->vm_flags & VM_MPX)
>> > +               return "[mpx]";
>> > +       return NULL;
>> > +}
>>
>> I sure that I'm missing something important. This function stores
>> "[mpx]" string on this function stack and returns the pointer to that
>> address. In current flow, this address is visible and accessible,
>> however in can be a different in general case.
>
> The string is not on stack. String literals are in .rodata and caller is
> not allowed to modify it since it's "const char *".
I see, it behaves similiar to global "const char *" variable definition.
Thank you for clarification.

>
> --
>  Kirill



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
