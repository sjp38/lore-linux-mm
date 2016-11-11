Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 463B76B02DB
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 16:41:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c4so16409706pfb.7
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 13:41:23 -0800 (PST)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id sj7si10268976pac.5.2016.11.11.13.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 13:41:22 -0800 (PST)
Received: by mail-pg0-x235.google.com with SMTP id 3so17128868pgd.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 13:41:22 -0800 (PST)
Date: Fri, 11 Nov 2016 13:41:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
In-Reply-To: <20161110162540.GA12743@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1611111247580.9200@eggly.anvils>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com> <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com> <alpine.LSU.2.11.1611071433340.1384@eggly.anvils> <20161110162540.GA12743@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 10 Nov 2016, Kirill A. Shutemov wrote:
> On Mon, Nov 07, 2016 at 03:17:11PM -0800, Hugh Dickins wrote:
> 
> > Treating the first extent differently is a hack, and does not respect
> > that this is a filesystem, on which size is likely to increase.
> > 
> > By all means refine the condition for huge=within_size, and by all means
> > warn in transhuge.txt that huge=always may tend to waste valuable huge
> > pages if the filesystem is used for small files without good reason
> 
> Would it be okay, if I just replace huge=within_size logic with what I
> proposed here for huge=always?

In principle yes, that would be fine with me: I just don't care very
much about this option, since we do not force "huge=always" on anyone,
so everyone is free to use it where it's useful, and not where it's not.

But perhaps your aim is to have "huge=within_size" set by default on /tmp,
and so not behave badly there: I'd never aimed for that, and I'm a bit
sceptical about it, but if you can get good enough behaviour out of it
for that, I won't stand in your way.

> 
> That's not what I intended initially for this option, but...
> 
> > (but maybe the implementation needs to reclaim those more effectively).
> 
> It's more about cost of allocation than memory pressure.

Regarding that issue, I think you should reconsider the GFP flags used
in shmem_alloc_hugepage().  GFP flags, and compaction latency avoidance,
have been moving targets over the last year, and I've not rechecked;
but I got the impression that your GFP flags are still asking for the
compaction stalls that are now deprecated on the anon THP fault path?
I repeat, I've not rechecked that before writing, maybe it's a libel!

> 
> -----8<-----
> 
> From 287ab05c09bfd49c7356ca74b6fea36d8131edaf Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 17 Oct 2016 14:44:47 +0300
> Subject: [PATCH] shmem: avoid huge pages for small files
> 
> Huge pages are detrimental for small file: they causes noticible
> overhead on both allocation performance and memory footprint.
> 
> This patch aimed to address this issue by avoiding huge pages until
> file grown to size of huge page if the filesystem mounted with
> huge=within_size option.
> 
> This would cover most of the cases where huge pages causes regressions
> in performance.

It's not a regression if "huge=always" is worse than "huge=never" in
some cases: just cases where it's better not to mount "huge=always".

> 
> The limit doesn't affect khugepaged behaviour: it still can collapse
> pages based on its settings.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/transhuge.txt | 7 ++++++-
>  mm/shmem.c                     | 6 ++----
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 2ec6adb5a4ce..14c911c56f4a 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -208,11 +208,16 @@ You can control hugepage allocation policy in tmpfs with mount option
>    - "always":
>      Attempt to allocate huge pages every time we need a new page;
>  

Nit: please change the semi-colon to full-stop, and delete the blank line.

> +    This option can lead to significant overhead if filesystem is used to
> +    store small files.
> +
>    - "never":
>      Do not allocate huge pages;
>  
>    - "within_size":
> -    Only allocate huge page if it will be fully within i_size.
> +    Only allocate huge page if size of the file more than size of huge
> +    page. This helps to avoid overhead for small files.
> +
>      Also respect fadvise()/madvise() hints;
>  
>    - "advise:
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..3589d36c7c63 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1681,10 +1681,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  		case SHMEM_HUGE_NEVER:
>  			goto alloc_nohuge;
>  		case SHMEM_HUGE_WITHIN_SIZE:
> -			off = round_up(index, HPAGE_PMD_NR);
> -			i_size = round_up(i_size_read(inode), PAGE_SIZE);
> -			if (i_size >= HPAGE_PMD_SIZE &&
> -					i_size >> PAGE_SHIFT >= off)
> +			i_size = i_size_read(inode);
> +			if (index >= HPAGE_PMD_NR || i_size >= HPAGE_PMD_SIZE)
>  				goto alloc_huge;

I said fine in principle above, but when I look at this, I'm puzzled.

Certainly the new condition is easier to understand than the old condition:
which is a plus, even though it's hackish (I do dislike hobbling the first
extent, when it's an incomplete last extent which deserves to be hobbled -
easier said than implemented of course).

But isn't the new condition (with its ||) always weaker than the old
condition (with its &&)?  Whereas I thought you were trying to change
it to be less keen to allocate hugepages, not more.

What the condition ought to say, I don't know: I got too confused,
and depressed by my confusion, so I'm just handing it back to you.

And then there's the SHMEM_HUGE_WITHIN_SIZE case in shmem_huge_enabled()
(for khugepaged), which you have explicitly not changed in this patch:
looks strange to me, is it doing the right thing?

>  			/* fallthrough */
>  		case SHMEM_HUGE_ADVISE:
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
