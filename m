Date: Tue, 14 Mar 2006 19:24:43 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page migration: Fail with error if swap not setup
Message-Id: <20060314192443.0d121e73.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> Currently the migration of anonymous pages will silently fail if no swap 
> is setup.

Why?

I mean, if something tries to allocate a swap page and that fails then the
error should be propagated back.  That's race-free.

> This patch makes page migration functions check for available 
> swap and fail with -ENODEV if no swap space is available.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.16-rc6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.16-rc6.orig/mm/mempolicy.c	2006-03-14 16:31:15.000000000 -0800
> +++ linux-2.6.16-rc6/mm/mempolicy.c	2006-03-14 17:25:09.000000000 -0800
> @@ -330,9 +330,14 @@ check_range(struct mm_struct *mm, unsign
>  	int err;
>  	struct vm_area_struct *first, *vma, *prev;
>  
> -	/* Clear the LRU lists so pages can be isolated */
> -	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +		/* Must have available swap entries for migration */
> +		if (nr_swap_pages <=0)

(ObCodingStyleWhine)

> +			return ERR_PTR(-ENODEV);
> +
> +		/* Clear the LRU lists so pages can be isolated */
>  		lru_add_drain_all();
> +	}
>  

Whereas this appears to be racy...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
