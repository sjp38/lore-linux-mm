Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7F7F6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 18:32:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so19492236lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:32:46 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id g128si6381307wmd.84.2016.07.12.15.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 15:32:45 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id f126so7070271wma.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:32:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1468014494-25291-2-git-send-email-keescook@chromium.org>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org> <1468014494-25291-2-git-send-email-keescook@chromium.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 12 Jul 2016 18:32:43 -0400
Message-ID: <CAGXu5j+FJiVQr6VomDUTJjCo8OgLyg6LGhgGQQwO5verj5UC=Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] binfmt_elf: fix calculations for bss padding
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 8, 2016 at 5:48 PM, Kees Cook <keescook@chromium.org> wrote:
> A double-bug exists in the bss calculation code, where an overflow can
> happen in the "last_bss - elf_bss" calculation, but vm_brk internally
> aligns the argument, underflowing it, wrapping back around safe. We
> shouldn't depend on these bugs staying in sync, so this cleans up the bss
> padding handling to avoid the overflow.
>
> This moves the bss padzero() before the last_bss > elf_bss case, since
> the zero-filling of the ELF_PAGE should have nothing to do with the
> relationship of last_bss and elf_bss: any trailing portion should be
> zeroed, and a zero size is already handled by padzero().
>
> Then it handles the math on elf_bss vs last_bss correctly. These need
> to both be ELF_PAGE aligned to get the comparison correct, since that's
> the expected granularity of the mappings. Since elf_bss already had
> alignment-based padding happen in padzero(), the "start" of the new
> vm_brk() should be moved forward as done in the original code. However,
> since the "end" of the vm_brk() area will already become PAGE_ALIGNed in
> vm_brk() then last_bss should get aligned here to avoid hiding it as a
> side-effect.
>
> Additionally makes a cosmetic change to the initial last_bss calculation
> so it's easier to read in comparison to the load_addr calculation above it
> (i.e. the only difference is p_filesz vs p_memsz).
>
> Reported-by: Hector Marco-Gisbert <hecmargi@upv.es>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Andrew or Al, can you pick this up for -next? It doesn't depend on the
do_brk() fix (patch 2/2)...

-Kees

> ---
>  fs/binfmt_elf.c | 34 ++++++++++++++++++----------------
>  1 file changed, 18 insertions(+), 16 deletions(-)
>
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index e158b22ef32f..fe948933bcc5 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -605,28 +605,30 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>                          * Do the same thing for the memory mapping - between
>                          * elf_bss and last_bss is the bss section.
>                          */
> -                       k = load_addr + eppnt->p_memsz + eppnt->p_vaddr;
> +                       k = load_addr + eppnt->p_vaddr + eppnt->p_memsz;
>                         if (k > last_bss)
>                                 last_bss = k;
>                 }
>         }
>
> +       /*
> +        * Now fill out the bss section: first pad the last page from
> +        * the file up to the page boundary, and zero it from elf_bss
> +        * up to the end of the page.
> +        */
> +       if (padzero(elf_bss)) {
> +               error = -EFAULT;
> +               goto out;
> +       }
> +       /*
> +        * Next, align both the file and mem bss up to the page size,
> +        * since this is where elf_bss was just zeroed up to, and where
> +        * last_bss will end after the vm_brk() below.
> +        */
> +       elf_bss = ELF_PAGEALIGN(elf_bss);
> +       last_bss = ELF_PAGEALIGN(last_bss);
> +       /* Finally, if there is still more bss to allocate, do it. */
>         if (last_bss > elf_bss) {
> -               /*
> -                * Now fill out the bss section.  First pad the last page up
> -                * to the page boundary, and then perform a mmap to make sure
> -                * that there are zero-mapped pages up to and including the
> -                * last bss page.
> -                */
> -               if (padzero(elf_bss)) {
> -                       error = -EFAULT;
> -                       goto out;
> -               }
> -
> -               /* What we have mapped so far */
> -               elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
> -
> -               /* Map the last of the bss segment */
>                 error = vm_brk(elf_bss, last_bss - elf_bss);
>                 if (error)
>                         goto out;
> --
> 2.7.4
>



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
