Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3E756B026B
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:36:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v25so5109779pfg.14
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:36:13 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n15si3120587pgr.695.2017.12.14.08.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:36:12 -0800 (PST)
Received: from mail-it0-f47.google.com (mail-it0-f47.google.com [209.85.214.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 28B4221879
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:36:12 +0000 (UTC)
Received: by mail-it0-f47.google.com with SMTP id 68so12441502ite.4
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:36:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214120853.u2vc4x55faurkgec@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org> <alpine.DEB.2.20.1712141302540.4998@nanos>
 <20171214120853.u2vc4x55faurkgec@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:35:50 -0800
Message-ID: <CALCETrV8MAVD_4mvQQ_=E2H1CMtRm=Axutqwc9hzjqkK8NwVSQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/17] x86/ldt: Use a VMA based read only mapping
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 4:08 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Dec 14, 2017 at 01:03:37PM +0100, Thomas Gleixner wrote:
>> On Thu, 14 Dec 2017, Peter Zijlstra wrote:
>> > So here's a second posting of the VMA based LDT implementation; now without
>> > most of the crazy.
>> >
>> > I took out the write fault handler and the magic LAR touching code.
>> >
>> > Additionally there are a bunch of patches that address generic vm issue.
>> >
>> >  - gup() access control; In specific I looked at accessing !_PAGE_USER pages
>> >    because these patches rely on not being able to do that.
>> >
>> >  - special mappings; A whole bunch of mmap ops don't make sense on special
>> >    mappings so disallow them.
>> >
>> > Both things make sense independent of the rest of the series. Similarly, the
>> > patches that kill that rediculous LDT inherit on exec() are also unquestionably
>> > good.
>> >
>> > So I think at least the first 6 patches are good, irrespective of the
>> > VMA approach.
>> >
>> > On the whole VMA approach, Andy I know you hate it with a passion, but I really
>> > rather like how it ties the LDT to the process that it belongs to and it
>> > reduces the amount of 'special' pages in the whole PTI mapping.
>> >
>> > I'm not the one going to make the decision on this; but I figured I at least
>> > post a version without the obvious crap parts of the last one.
>> >
>> > Note: if we were to also disallow munmap() for special mappings (which I
>> > suppose makes perfect sense) then we could further reduce the actual LDT
>> > code (we'd no longer need the sm::close callback and related things).
>>
>> That makes a lot of sense for the other special mapping users like VDSO and
>> kprobes.
>
> Right, and while looking at that I also figured it might make sense to
> unconditionally disallow splitting special mappings.
>
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2698,6 +2698,9 @@ int do_munmap(struct mm_struct *mm, unsi
>         }
>         vma = prev ? prev->vm_next : mm->mmap;
>
> +       if (vma_is_special_mapping(vma))
> +               return -EINVAL;
> +
>         if (unlikely(uf)) {
>                 /*
>                  * If userfaultfd_unmap_prep returns an error the vmas
> @@ -3223,10 +3226,11 @@ static int special_mapping_fault(struct
>   */
>  static void special_mapping_close(struct vm_area_struct *vma)
>  {
> -       struct vm_special_mapping *sm = vma->vm_private_data;
> +}
>
> -       if (sm->close)
> -               sm->close(sm, vma);
> +static int special_mapping_split(struct vm_area_struct *vma, unsigned long addr)
> +{
> +       return -EINVAL;
>  }
>
>  static const char *special_mapping_name(struct vm_area_struct *vma)
> @@ -3252,6 +3256,7 @@ static const struct vm_operations_struct
>         .fault = special_mapping_fault,
>         .mremap = special_mapping_mremap,
>         .name = special_mapping_name,
> +       .split = special_mapping_split,
>  };
>
>  static const struct vm_operations_struct legacy_special_mapping_vmops = {

Disallowing splitting seems fine.  Disallowing munmap might not be.
Certainly CRIU relies on being able to mremap() the VDSO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
