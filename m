Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC3A86B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:25:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n85so57704878pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:25:57 -0800 (PST)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id z5si33408458pgf.155.2016.11.07.15.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:17:19 -0800 (PST)
Received: by mail-pg0-x22f.google.com with SMTP id 3so9047520pgd.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:17:19 -0800 (PST)
Date: Mon, 7 Nov 2016 15:17:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
In-Reply-To: <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
Message-ID: <alpine.LSU.2.11.1611071433340.1384@eggly.anvils>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com> <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 22 Oct 2016, Kirill A. Shutemov wrote:
> 
> Huge pages are detrimental for small file: they causes noticible
> overhead on both allocation performance and memory footprint.
> 
> This patch aimed to address this issue by avoiding huge pages until file
> grown to size of huge page. This would cover most of the cases where huge
> pages causes regressions in performance.
> 
> Couple notes:
> 
>   - if shmem_enabled is set to 'force', the limit is ignored. We still
>     want to generate as many pages as possible for functional testing.
> 
>   - the limit doesn't affect khugepaged behaviour: it still can collapse
>     pages based on its settings;
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Sorry, but NAK.  I was expecting a patch to tune within_size behaviour.

> ---
>  Documentation/vm/transhuge.txt | 3 +++
>  mm/shmem.c                     | 5 +++++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 2ec6adb5a4ce..d1889c7c8c46 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -238,6 +238,9 @@ values:
>    - "force":
>      Force the huge option on for all - very useful for testing;
>  
> +To avoid overhead for small files, we don't allocate huge pages for a file
> +until it grows to size of huge pages.
> +
>  == Need of application restart ==
>  
>  The transparent_hugepage/enabled values and tmpfs mount option only affect
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..49618d2d6330 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1692,6 +1692,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  				goto alloc_huge;
>  			/* TODO: implement fadvise() hints */
>  			goto alloc_nohuge;
> +		case SHMEM_HUGE_ALWAYS:
> +			i_size = i_size_read(inode);
> +			if (index < HPAGE_PMD_NR && i_size < HPAGE_PMD_SIZE)
> +				goto alloc_nohuge;
> +			break;
>  		}
>  
>  alloc_huge:

So (eliding the SHMEM_HUGE_ADVISE case in between) you now have:

		case SHMEM_HUGE_WITHIN_SIZE:
			off = round_up(index, HPAGE_PMD_NR);
			i_size = round_up(i_size_read(inode), PAGE_SIZE);
			if (i_size >= HPAGE_PMD_SIZE &&
					i_size >> PAGE_SHIFT >= off)
				goto alloc_huge;
			goto alloc_nohuge;
		case SHMEM_HUGE_ALWAYS:
			i_size = i_size_read(inode);
			if (index < HPAGE_PMD_NR && i_size < HPAGE_PMD_SIZE)
				goto alloc_nohuge;
			goto alloc_huge;

I'll concede that those two conditions are not the same; but again you're
messing with huge=always to make it, not always, but conditional on size.

Please, keep huge=always as is: if I copy a 4MiB file into a huge tmpfs,
I got ShmemHugePages 4096 kB before, which is what I wanted.  Whereas
with this change I get only 2048 kB, just like with huge=within_size.

Treating the first extent differently is a hack, and does not respect
that this is a filesystem, on which size is likely to increase.

By all means refine the condition for huge=within_size, and by all means
warn in transhuge.txt that huge=always may tend to waste valuable huge
pages if the filesystem is used for small files without good reason
(but maybe the implementation needs to reclaim those more effectively).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
