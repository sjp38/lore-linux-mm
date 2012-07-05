Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7488D6B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 15:21:54 -0400 (EDT)
Received: by yenr5 with SMTP id r5so9647386yen.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 12:21:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120705104520.GA6773@latitude>
References: <4FAC200D.2080306@codeaurora.org>
	<02fc01cd2f50$5d77e4c0$1867ae40$%szyprowski@samsung.com>
	<4FAD89DC.2090307@codeaurora.org>
	<CAH+eYFBhO9P7V7Nf+yi+vFPveBks7SFKRHfkz3JOQMBKqnkkUQ@mail.gmail.com>
	<015f01cd5a95$c1525dc0$43f71940$%szyprowski@samsung.com>
	<20120705104520.GA6773@latitude>
Date: Thu, 5 Jul 2012 21:21:53 +0200
Message-ID: <CA+pa1O2veiMaNJ5M0qeion5kquCyoa2gW79G2zNqb+nbWLs_Qw@mail.gmail.com>
Subject: Re: Bad use of highmem with buffer_migrate_page?
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin@rab.in>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, linaro-mm-sig@lists.linaro.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

2012/7/5 Rabin Vincent <rabin@rab.in>:
> From 8a94126eb3aa2824866405fb78bb0b8316f8fd00 Mon Sep 17 00:00:00 2001
> From: Rabin Vincent <rabin@rab.in>
> Date: Thu, 5 Jul 2012 15:52:23 +0530
> Subject: [PATCH] mm: cma: don't replace lowmem pages with highmem
>
> The filesystem layer expects pages in the block device's mapping to not
> be in highmem (the mapping's gfp mask is set in bdget()), but CMA can
> currently replace lowmem pages with highmem pages, leading to crashes in
> filesystem code such as the one below:
>
>   Unable to handle kernel NULL pointer dereference at virtual address 00000400
>   pgd = c0c98000
>   [00000400] *pgd=00c91831, *pte=00000000, *ppte=00000000
>   Internal error: Oops: 817 [#1] PREEMPT SMP ARM
>   CPU: 0    Not tainted  (3.5.0-rc5+ #80)
>   PC is at __memzero+0x24/0x80
>   ...
>   Process fsstress (pid: 323, stack limit = 0xc0cbc2f0)
>   Backtrace:
>   [<c010e3f0>] (ext4_getblk+0x0/0x180) from [<c010e58c>] (ext4_bread+0x1c/0x98)
>   [<c010e570>] (ext4_bread+0x0/0x98) from [<c0117944>] (ext4_mkdir+0x160/0x3bc)
>    r4:c15337f0
>   [<c01177e4>] (ext4_mkdir+0x0/0x3bc) from [<c00c29e0>] (vfs_mkdir+0x8c/0x98)
>   [<c00c2954>] (vfs_mkdir+0x0/0x98) from [<c00c2a60>] (sys_mkdirat+0x74/0xac)
>    r6:00000000 r5:c152eb40 r4:000001ff r3:c14b43f0
>   [<c00c29ec>] (sys_mkdirat+0x0/0xac) from [<c00c2ab8>] (sys_mkdir+0x20/0x24)
>    r6:beccdcf0 r5:00074000 r4:beccdbbc
>   [<c00c2a98>] (sys_mkdir+0x0/0x24) from [<c000e3c0>] (ret_fast_syscall+0x0/0x30)
>
> Fix this by replacing only highmem pages with highmem.
>
> Reported-by: Laura Abbott <lauraa@codeaurora.org>
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_alloc.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..4a4f921 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5635,7 +5635,12 @@ static struct page *
>  __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
>                              int **resultp)
>  {
> -       return alloc_page(GFP_HIGHUSER_MOVABLE);
> +       gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> +
> +       if (PageHighMem(page))
> +               gfp_mask |= __GFP_HIGHMEM;
> +
> +       return alloc_page(gfp_mask);
>  }
>
>  /* [start, end) must belong to a single zone. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
