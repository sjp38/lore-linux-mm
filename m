Date: Tue, 2 Dec 2008 16:47:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/9] swapfile: change discard pgoff_t to sector_t
Message-Id: <20081202164732.1d6d0997.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0812010028040.10131@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
	<Pine.LNX.4.64.0811252140230.17555@blonde.site>
	<Pine.LNX.4.64.0811252145190.20455@blonde.site>
	<Pine.LNX.4.64.0812010028040.10131@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: dwmw2@infradead.org, jens.axboe@oracle.com, matthew@wil.cx, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008 00:29:41 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Change pgoff_t nr_blocks in discard_swap() and discard_swap_cluster() to
> sector_t: given the constraints on swap offsets (in particular, the 5 bits
> of swap type accommodated in the same unsigned long), pgoff_t was actually
> safe as is, but it certainly looked worrying when shifted left.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> To follow 9/9 swapfile-swap-allocation-cycle-if-nonrot.patch
> 
>  mm/swapfile.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- swapfile9/mm/swapfile.c	2008-11-26 12:19:00.000000000 +0000
> +++ swapfile10/mm/swapfile.c	2008-11-28 20:36:44.000000000 +0000
> @@ -96,7 +96,7 @@ static int discard_swap(struct swap_info
>  
>  	list_for_each_entry(se, &si->extent_list, list) {
>  		sector_t start_block = se->start_block << (PAGE_SHIFT - 9);
> -		pgoff_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);
> +		sector_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);

but, but, that didn't change anything?  se->nr_pages must be cast to
sector_t?

>  		if (se->start_page == 0) {
>  			/* Do not discard the swap header page! */
> @@ -133,7 +133,7 @@ static void discard_swap_cluster(struct 
>  		    start_page < se->start_page + se->nr_pages) {
>  			pgoff_t offset = start_page - se->start_page;
>  			sector_t start_block = se->start_block + offset;
> -			pgoff_t nr_blocks = se->nr_pages - offset;
> +			sector_t nr_blocks = se->nr_pages - offset;
>  
>  			if (nr_blocks > nr_pages)
>  				nr_blocks = nr_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
