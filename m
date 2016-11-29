Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260ED6B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:56:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so241628723pfb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:56:59 -0800 (PST)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id q4si29357358plb.201.2016.11.28.19.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 19:56:58 -0800 (PST)
Received: by mail-pg0-x235.google.com with SMTP id p66so64437215pga.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:56:57 -0800 (PST)
Date: Mon, 28 Nov 2016 19:56:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv4] shmem: avoid huge pages for small files
In-Reply-To: <20161114140957.GA9950@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1611281840000.3299@eggly.anvils>
References: <20161021185103.117938-1-kirill.shutemov@linux.intel.com> <20161021224629.tnwuvruhblkg22qj@black.fi.intel.com> <alpine.LSU.2.11.1611071433340.1384@eggly.anvils> <20161110162540.GA12743@node.shutemov.name> <alpine.LSU.2.11.1611111247580.9200@eggly.anvils>
 <20161114140957.GA9950@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Nov 2016, Kirill A. Shutemov wrote:
> On Fri, Nov 11, 2016 at 01:41:11PM -0800, Hugh Dickins wrote:
> > 
> > Certainly the new condition is easier to understand than the old condition:
> > which is a plus, even though it's hackish (I do dislike hobbling the first
> > extent, when it's an incomplete last extent which deserves to be hobbled -
> > easier said than implemented of course).
> 
> Well, it's just heuristic that I found useful. I don't see a reason to
> make more complex if it works.

You like it because it allocates huge pages to some extents,
but not to all extents.  I dislike it because it allocates
huge pages to the wrong extents.

You did much the same three or four years ago, in your THP-on-ramfs
series: I admired your resourcefulness, in getting the little files
to fit in memory; but it was not a solution I wanted to see again.

Consider copying a 2097153-byte file into such a filesystem: the first
2MB would be allocated with 4kB pages, the final byte with a 2MB page;
but it looks like I already pointed that out, and we just disagree.

This patch does not convince me at all: I expect you will come up with
some better strategy in a month or two, and I'd rather wait for that
than keep messing around with what we have.  But if you can persuade
the filesystem guys that this heuristic would be a sensible mount
option for them, then in the end I shall not want tmpfs to diverge.

> 
> > But isn't the new condition (with its ||) always weaker than the old
> > condition (with its &&)?  Whereas I thought you were trying to change
> > it to be less keen to allocate hugepages, not more.
> 
> I tried to make it less keen to allocate hugepages comparing to
> huge=always.
> 
> Current huge=within_size is fairly restrictive: we don't allocate huge
> pages to grow the file. For shmem, it means we would allocate huge pages
> if user did truncate(2) to set file size, before touching data in it
> (shared memory APIs do this). This policy would be more useful for
> filesystem with backing storage.
> 
> The patch relaxes condition: only require file size >= HPAGE_PMD_SIZE.
> 
> > What the condition ought to say, I don't know: I got too confused,
> > and depressed by my confusion, so I'm just handing it back to you.
> > 
> > And then there's the SHMEM_HUGE_WITHIN_SIZE case in shmem_huge_enabled()
> > (for khugepaged), which you have explicitly not changed in this patch:
> > looks strange to me, is it doing the right thing?
> 
> I missed that.
> 
> -----8<-----
> From b2158fdd8523e3e35a548857a1cb02fe6bcd1ea4 Mon Sep 17 00:00:00 2001
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
> This would cover most of the cases where huge pages causes slowdown
> comparing to small pages.
> 
> Later we can consider huge=within_size as the default for tmpfs.

I'm sceptical of that, and I do not think this implementation will
make a sensible default.

> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/transhuge.txt |  8 ++++++--
>  mm/shmem.c                     | 12 +++---------
>  2 files changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 2ec6adb5a4ce..7703e9c241ca 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -206,13 +206,17 @@ You can control hugepage allocation policy in tmpfs with mount option
>  "huge=". It can have following values:
>  
>    - "always":
> -    Attempt to allocate huge pages every time we need a new page;
> +    Attempt to allocate huge pages every time we need a new page.
> +    This option can lead to significant overhead if filesystem is used to
> +    store small files.

Good, yes, that part I fully agree with.

>  
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
> index ad7813d73ea7..ef8fdadd0626 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1677,14 +1677,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  			goto alloc_huge;
>  		switch (sbinfo->huge) {
>  			loff_t i_size;
> -			pgoff_t off;
>  		case SHMEM_HUGE_NEVER:
>  			goto alloc_nohuge;
>  		case SHMEM_HUGE_WITHIN_SIZE:
> -			off = round_up(index, HPAGE_PMD_NR);
> -			i_size = round_up(i_size_read(inode), PAGE_SIZE);
> -			if (i_size >= HPAGE_PMD_SIZE &&
> -					i_size >> PAGE_SHIFT >= off)

I certainly agree that the old test is obscure: I give up and cry each
time I try to work out exactly what it does.  I wanted so much to offer
a constructive alternative before responding: how about

			if (index < round_down(i_size_read(inode),
					HPAGE_PMD_SIZE) >> PAGE_SHIFT))

Of course that does not give you any huge pages while a file is being
copied in (without a preparatory ftruncate), but it seems a more
comprehensible within_size implementation to me.

> +			i_size = i_size_read(inode);
> +			if (index >= HPAGE_PMD_NR || i_size >= HPAGE_PMD_SIZE)
>  				goto alloc_huge;
>  			/* fallthrough */
>  		case SHMEM_HUGE_ADVISE:
> @@ -3856,7 +3853,6 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	struct inode *inode = file_inode(vma->vm_file);
>  	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
>  	loff_t i_size;
> -	pgoff_t off;
>  
>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
> @@ -3868,10 +3864,8 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  		case SHMEM_HUGE_ALWAYS:
>  			return true;
>  		case SHMEM_HUGE_WITHIN_SIZE:
> -			off = round_up(vma->vm_pgoff, HPAGE_PMD_NR);
>  			i_size = round_up(i_size_read(inode), PAGE_SIZE);
> -			if (i_size >= HPAGE_PMD_SIZE &&
> -					i_size >> PAGE_SHIFT >= off)
> +			if (i_size >= HPAGE_PMD_SIZE)
>  				return true;

That's reasonable, given what you propose for shmem_getpage_gfp().
And given other conditions at the calling khugepaged end, it might
even be okay with my suggestion - I've not given it enough thought.
Or simply return true there, and let khugepaged work it out?
I am pretty sure the original condition was wrong.

>  		case SHMEM_HUGE_ADVISE:
>  			/* TODO: implement fadvise() hints */
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
