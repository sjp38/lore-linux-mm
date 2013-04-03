Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 45F576B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:20:11 -0400 (EDT)
Date: Wed, 3 Apr 2013 10:20:00 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/2] mm: allow for outstanding swap writeback accounting
Message-ID: <20130403142000.GA6044@phenom.dumpdata.com>
References: <1364874612-925-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364874612-925-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, minchan@kernel.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, ngupta@vflare.org, dan.magenheimer@oracle.com, Bob Liu <bob.liu@oracle.com>

On Tue, Apr 02, 2013 at 11:50:12AM +0800, Bob Liu wrote:
> From: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> To prevent flooding the swap device with writebacks, frontswap
> backends need to count and limit the number of outstanding
> writebacks.  The incrementing of the counter can be done before
> the call to __swap_writepage().  However, the caller must receive
> a notification when the writeback completes in order to decrement
> the counter.
> 
> To achieve this functionality, this patch modifies
> __swap_writepage() to take the bio completion callback function
> as an argument.
> 
> end_swap_bio_write(), the normal bio completion function, is also
> made non-static so that code doing the accounting can call it
> after the accounting is done.

You should also say that this is a patch that does not modify the old
behavior at all. Just little prepatory plumbing work.

> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>  include/linux/swap.h |    4 +++-
>  mm/page_io.c         |    9 +++++----
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 76f6c3b..b5b12c7 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -330,7 +330,9 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct page *);
>  extern int swap_writepage(struct page *page, struct writeback_control *wbc);
> -extern int __swap_writepage(struct page *page, struct writeback_control *wbc);
> +extern void end_swap_bio_write(struct bio *bio, int err);
> +extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
> +	void (*end_write_func)(struct bio *, int));
>  extern int swap_set_page_dirty(struct page *page);
>  extern void end_swap_bio_read(struct bio *bio, int err);
>  
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 8e6bcf1..8e0e5c0 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -42,7 +42,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  	return bio;
>  }
>  
> -static void end_swap_bio_write(struct bio *bio, int err)
> +void end_swap_bio_write(struct bio *bio, int err)
>  {
>  	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
>  	struct page *page = bio->bi_io_vec[0].bv_page;
> @@ -197,12 +197,13 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>  		end_page_writeback(page);
>  		goto out;
>  	}
> -	ret = __swap_writepage(page, wbc);
> +	ret = __swap_writepage(page, wbc, end_swap_bio_write);
>  out:
>  	return ret;
>  }
>  
> -int __swap_writepage(struct page *page, struct writeback_control *wbc)
> +int __swap_writepage(struct page *page, struct writeback_control *wbc,
> +	void (*end_write_func)(struct bio *, int))

My pedantic eyes tell me that something is off here. But I am not sure if
that is my mailer or if the tabs have been converted to spaces. If they
align properly on your end (so 'struct page..' aligns with 'void ..'.)

>  {
>  	struct bio *bio;
>  	int ret = 0, rw = WRITE;
> @@ -234,7 +235,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc)
>  		return ret;
>  	}
>  
> -	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
> +	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
>  	if (bio == NULL) {
>  		set_page_dirty(page);
>  		unlock_page(page);
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
