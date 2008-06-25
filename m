Date: Wed, 25 Jun 2008 16:10:54 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: generic_file_splice_read() issues
Message-ID: <20080625141054.GB20851@kernel.dk>
References: <E1KBVRu-0005y4-1i@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KBVRu-0005y4-1i@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25 2008, Miklos Szeredi wrote:
> | 	error = 0;
> | 	while (spd.nr_pages < nr_pages) {
> | 		/*
> | 		 * Page could be there, find_get_pages_contig() breaks on
> | 		 * the first hole.
> | 		 */
> | 		page = find_get_page(mapping, index);
> | 		if (!page) {
> | 			/*
> | 			 * page didn't exist, allocate one.
> | 			 */
> | 			page = page_cache_alloc_cold(mapping);
> | 			if (!page)
> 
> error = -ENOMEM?

Looks like it, indeed.

> | 				break;
> | 
> | 			error = add_to_page_cache_lru(page, mapping, index,
> | 						mapping_gfp_mask(mapping));
> | 			if (unlikely(error)) {
> | 				page_cache_release(page);
> | 				if (error == -EEXIST)
> 
> error = 0?  It may not matter, but leaving error as EEXIST is
> confusing at best (and coupled with the above missing ENOMEM could
> result in really weird errors for splice() ;).

Lets move the error assignment inside that loop, ala

-       error = 0;
        while (spd.nr_pages < nr_pages) {
+               error = 0;

But yes, that also looks like a bug. Good spotting!

> | 
> | 			/*
> | 			 * need to read in the page
> | 			 */
> | 			error = mapping->a_ops->readpage(in, page);
> | 			if (unlikely(error)) {
> | 				/*
> | 				 * We really should re-lookup the page here,
> | 				 * but it complicates things a lot. Instead
> | 				 * lets just do what we already stored, and
> | 				 * we'll get it the next time we are called.
> | 				 */
> | 				if (error == AOP_TRUNCATED_PAGE)
> | 					error = 0;
> 
> This may also cause similar issues as the invalidatation race.  I'd
> think it would be better not to be sloppy here.

Perhaps we can abstract that bit out into a small helper function, tied
in with your previous patch.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
