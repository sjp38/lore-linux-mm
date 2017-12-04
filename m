Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B57D6B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 02:54:46 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id q13so11399133qtb.13
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 23:54:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor4113858qke.163.2017.12.03.23.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Dec 2017 23:54:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1512335500-10889-1-git-send-email-geert@linux-m68k.org>
References: <1512335500-10889-1-git-send-email-geert@linux-m68k.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 4 Dec 2017 08:54:44 +0100
Message-ID: <CAMuHMdWdoZqaKe3J4tyedz2-2wyN7bwu8UR0ixLd=o=4YEX=Jg@mail.gmail.com>
Subject: Re: [PATCH] mm/memory.c: Mark wp_huge_pmd() inline to prevent build failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>

On Sun, Dec 3, 2017 at 10:11 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> With gcc 4.1.2:
>
>     mm/memory.o: In function `wp_huge_pmd':
>     memory.c:(.text+0x9b4): undefined reference to `do_huge_pmd_wp_page'
>
> Interestingly, wp_huge_pmd() is emitted in the assembler output, but
> never called.
>
> Apparently replacing the call to pmd_write() in __handle_mm_fault() by a
> call to the more complex pmd_access_permitted() reduced the ability of
> the compiler to remove unused code.

An alternative would be to start using #ifdefs and dummies for the
!CONFIG_TRANSPARENT_HUGEPAGE case, instead of relying on the varying degree
of ability of the various compiler versions to do dead code analysis and
elimination.

> Fix this by marking wp_huge_pmd() inline, like was done in commit
> 91a90140f9987101 ("mm/memory.c: mark create_huge_pmd() inline to prevent
> build failure") for a similar problem.
>
> Fixes: c7da82b894e9eef6 ("mm: replace pmd_write with pmd_access_permitted in fault + gup paths")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 5eb3d2524bdc2823..f4d52847ca07a414 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3831,7 +3831,7 @@ static inline int create_huge_pmd(struct vm_fault *vmf)
>         return VM_FAULT_FALLBACK;
>  }
>
> -static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
> +static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>  {
>         if (vma_is_anonymous(vmf->vma))
>                 return do_huge_pmd_wp_page(vmf, orig_pmd);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
