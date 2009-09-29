Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B6A76B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 06:40:22 -0400 (EDT)
Date: Tue, 29 Sep 2009 12:02:41 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] filemap : fix the wrong offset
In-Reply-To: <1254215185-29841-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0909291129430.19216@sister.anvils>
References: <1254215185-29841-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009, Huang Shijie wrote:

> The offset should be in PAGE_CACHE_SHIFT unit, not in PAGE_SHIFT unit.
> 
> Though we do not fully implement the page cache in larger chunks,
> but in the vma_address(), all the pages do the (PAGE_CACHE_SHIFT - PAGE_SHIFT) shift,
> so do a reverse operation in filemap_fault() is needed.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Well, I expect you're right, and I won't object to this patch,
so long as you don't follow it up with a stream of like patches.

I really think this issue is better ignored.  There was a time,
seven years ago, when I cared about it, and made such corrections
in mm/shmem.c.  But we're chipping away at the tip of the iceberg
here, and it's just a waste of everybody's time for so long as
PAGE_CACHE_SIZE == PAGE_SIZE.

There have been patches experimenting with PAGE_CACHE_SIZE multiple
of PAGE_SIZE (and probably not PAGE_SIZE multiple of PAGE_CACHE_SIZE);
and I've come to the conclusion that the only sensible place for these
PAGE_CACHE_SHIFT - PAGE_SHIFT patches is in a patch which really makes
that difference.

I wish PAGE_CACHE_SIZE had never been added in the first place,
long before it was needed; but ripping it out doesn't seem quite
the right thing to do either; and likewise I leave a smattering of
PAGE_CACHE_SHIFT - PAGE_SHIFT lines in, just to remind us from time
to time that there might one day be a difference.

I know this is a very unsatisfying response: but you and I
and everyone else have better things to spend our time on.
Thinking about the difference between two things that are
always the same is rather a waste of mental energy.

Patches to make them different: that's a very different matter.
Andrew happened not to like Christoph Lameter's patches for that;
but certainly those patches were making a real difference, and
deserved all their (PAGE_CACHE_SHIFT - PAGE_SHIFT)s (if they
had any: perhaps tucked away in a conversion macro, I forget).

Hugh

> ---
>  mm/filemap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ef169f3..2d8385e 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1502,7 +1502,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	struct address_space *mapping = file->f_mapping;
>  	struct file_ra_state *ra = &file->f_ra;
>  	struct inode *inode = mapping->host;
> -	pgoff_t offset = vmf->pgoff;
> +	pgoff_t offset = vmf->pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  	struct page *page;
>  	pgoff_t size;
>  	int ret = 0;
> -- 
> 1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
