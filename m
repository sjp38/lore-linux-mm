Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id C376B6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 05:38:25 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id v1so14876398oia.9
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:38:25 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id 184si1172265oig.46.2015.02.27.02.38.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 02:38:25 -0800 (PST)
Received: by mail-oi0-f51.google.com with SMTP id g201so14845556oib.10
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:38:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424958666-18241-3-git-send-email-vbabka@suse.cz>
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz> <1424958666-18241-3-git-send-email-vbabka@suse.cz>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Fri, 27 Feb 2015 11:38:04 +0100
Message-ID: <CAHO5Pa2j=JO8D7OPYQ1MRxqXOjcZ2ATiwU-nvz=iJD34vek8uQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390 <linux-s390@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>

[CC += linux-api@]

On Thu, Feb 26, 2015 at 2:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
> mappings, even if the mapped portion does contain pages that were swapped out.
> This is because unlike private anonymous mappings, shmem does not change pte
> to swap entry, but pte_none when swapping the page out. In the smaps page
> walk, such page thus looks like it was never faulted in.
>
> This patch changes smaps_pte_entry() to determine the swap status for such
> pte_none entries for shmem mappings, similarly to how mincore_page() does it.
> Swapped out pages are thus accounted for.
>
> The accounting is arguably still not as precise as for private anonymous
> mappings, since now we will count also pages that the process in question never
> accessed, but only another process populated them and then let them become
> swapped out. I believe it is still less confusing and subtle than not showing
> any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
> performance issue for future accesses, and we cannot predict those for neither
> kind of mapping.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  Documentation/filesystems/proc.txt |  3 ++-
>  fs/proc/task_mmu.c                 | 20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index d4f56ec..8b30543 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -437,7 +437,8 @@ indicates the amount of memory currently marked as referenced or accessed.
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
>  "Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +swap. For shmem mappings, "Swap" shows how much of the mapped portion of the
> +underlying shmem object is on swap.
>
>  "VmFlags" field deserves a separate description. This member represents the kernel
>  flags associated with the particular virtual memory area in two letter encoded
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 956b75d..0410309 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -13,6 +13,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/shmem_fs.h>
>
>  #include <asm/elf.h>
>  #include <asm/uaccess.h>
> @@ -496,6 +497,25 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>                         mss->swap += PAGE_SIZE;
>                 else if (is_migration_entry(swpent))
>                         page = migration_entry_to_page(swpent);
> +       } else if (IS_ENABLED(CONFIG_SHMEM) && IS_ENABLED(CONFIG_SWAP) &&
> +                                       pte_none(*pte) && vma->vm_file) {
> +               struct address_space *mapping =
> +                       file_inode(vma->vm_file)->i_mapping;
> +
> +               /*
> +                * shmem does not use swap pte's so we have to consult
> +                * the radix tree to account for swap
> +                */
> +               if (shmem_mapping(mapping)) {
> +                       page = find_get_entry(mapping, pgoff);
> +                       if (page) {
> +                               if (radix_tree_exceptional_entry(page))
> +                                       mss->swap += PAGE_SIZE;
> +                               else
> +                                       page_cache_release(page);
> +                       }
> +                       page = NULL;
> +               }
>         }
>
>         if (!page)
> --
> 2.1.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
