Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB6D6B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:43:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y138so31283380wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 05:43:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d139si11838748wmd.16.2016.10.24.05.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 05:43:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o81so9635075wma.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 05:43:39 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:43:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
Message-ID: <20161024124337.GA17103@dhcp22.suse.cz>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com>
 <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 22-10-16 01:46:29, Kirill A. Shutemov wrote:
> On Fri, Oct 21, 2016 at 09:51:03PM +0300, Kirill A. Shutemov wrote:
> > +		case SHEME_HUGE_ALWAYS:
> 
> Oops. Forgot to commit the fixup :-/
> 
> >From 79b0a3bf4503225d0e6ba553b8496f0c4d55514e Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 17 Oct 2016 14:44:47 +0300
> Subject: [PATCHv4] shmem: avoid huge pages for small files
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

Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
>  Kirill A. Shutemov

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
