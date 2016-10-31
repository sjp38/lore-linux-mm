Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C01256B029E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 18:36:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i128so77663095wme.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 15:36:19 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id m1si27179465wmm.23.2016.10.31.15.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 15:36:18 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id t79so76975675wmt.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 15:36:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1477949533-2509-1-git-send-email-jann@thejh.net>
References: <1477949533-2509-1-git-send-email-jann@thejh.net>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 31 Oct 2016 15:36:17 -0700
Message-ID: <CAGXu5j+vgxJSEKFcLtGYDEEogo0944pUaxZ2sZ2xfstvzWYVxw@mail.gmail.com>
Subject: Re: [PATCH] swapfile: fix memory corruption via malformed swapfile
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jerome Marchand <jmarchan@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 31, 2016 at 2:32 PM, Jann Horn <jann@thejh.net> wrote:
> When root activates a swap partition whose header has the wrong endianness,
> nr_badpages elements of badpages are swabbed before nr_badpages has been
> checked, leading to a buffer overrun of up to 8GB.
>
> This normally is not a security issue because it can only be exploited by
> root (more specifically, a process with CAP_SYS_ADMIN or the ability to
> modify a swap file/partition), and such a process can already e.g. modify
> swapped-out memory of any other userspace process on the system.
>
> Testcase for reproducing the bug (must be run as root, should crash your
> kernel):
> =================
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/swap.h>
> #include <limits.h>
> #include <err.h>
> #include <string.h>
> #include <stdio.h>
>
> #define PAGE_SIZE 4096
> #define __u32 unsigned int
>
>
> // from include/linux/swap.h
> union swap_header {
>   struct {
>     char reserved[PAGE_SIZE - 10];
>     char magic[10];     /* SWAP-SPACE or SWAPSPACE2 */
>   } magic;
>   struct {
>     char    bootbits[1024]; /* Space for disklabel etc. */
>     __u32   version;
>     __u32   last_page;
>     __u32   nr_badpages;
>     unsigned char sws_uuid[16];
>     unsigned char sws_volume[16];
>     __u32   padding[117];
>     __u32   badpages[1];
>   } info;
> };
>
> int main(void) {
>   char file[] = "/tmp/swapfile.XXXXXX";
>   int file_fd = mkstemp(file);
>   if (file_fd == -1)
>     err(1, "mkstemp");
>   if (ftruncate(file_fd, PAGE_SIZE))
>     err(1, "ftruncate");
>   union swap_header swap_header = {
>     .info = {
>       .version = __builtin_bswap32(1),
>       .nr_badpages = __builtin_bswap32(INT_MAX)
>     }
>   };
>   memcpy(swap_header.magic.magic, "SWAPSPACE2", 10);
>   if (write(file_fd, &swap_header, sizeof(swap_header)) !=
>       sizeof(swap_header))
>     err(1, "write");
>
>   // not because the attack needs it, just in case you forgot to
>   // sync yourself before crashing your machine
>   sync();
>
>   // now die
>   if (swapon(file, 0))
>     err(1, "swapon");
>   puts("huh, we survived");
>   if (swapoff(file))
>     err(1, "swapoff");
>   unlink(file);
> }
> =================
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jann@thejh.net>
> ---
>  mm/swapfile.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2210de290b54..f30438970cd1 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2224,6 +2224,8 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
>                 swab32s(&swap_header->info.version);
>                 swab32s(&swap_header->info.last_page);
>                 swab32s(&swap_header->info.nr_badpages);
> +               if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
> +                       return 0;
>                 for (i = 0; i < swap_header->info.nr_badpages; i++)
>                         swab32s(&swap_header->info.badpages[i]);
>         }
> --
> 2.1.4
>

Eww. Nice find. :) At least it's only init_ns CAP_SYS_ADMIN. :P

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
