Message-ID: <465BD63B.5020603@yahoo.com.au>
Date: Tue, 29 May 2007 17:28:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Is it OK for 'read' to return nuls for a file   that
 never had nuls in it?
References: <18011.51290.257450.26100@notabene.brown>	<465BCAA9.3070707@yahoo.com.au> <18011.53140.20314.43413@notabene.brown>
In-Reply-To: <18011.53140.20314.43413@notabene.brown>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Linich <plinich@cse.unsw.edu.au>, Ram Pai <linuxram@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Neil Brown wrote:
> On Tuesday May 29, nickpiggin@yahoo.com.au wrote:
> 
>>>Questions:
>>>  - Is this a problem, and should it be fixed (I think "yes").
>>
>>I think you are right.
> 
> 
> That's encouraging - thanks.
> 
> 
>>>  - Is the patch appropriate, and does it have no negative
>>>    consequences?.
>>>    (Obviously some comments should be tidied up to reflect the new
>>>    reality).
>>
>>Would it be better (and closer to following the existing logic) if
>>we sampled i_size before testing each page for uptodateness? It might
>>also cost a little less in the fastpath case of finding an uptodate
>>page.
> 
> 
> Uhm. no.
> 
> It doesn't address the issue which is that we need to check i_size
> *after* we have got hold of the page and believe it to be uptodate.

Hmm OK, I thought the logic worked for a single page but was broken for
subsequent patches... but we can readahead the first page before checking
it is uptodate, can't we? (or even if we didn't, someone else might
concurrently).

But then I think a problem remains after your patch that if the page is
partially truncated after you test that it is uptodate and resample i_size,
then the page tail can be zero filled and then you'll again get back a
nul tail from read(2), don't we? We could probably fix this beautifully by
doing a lock_page over do_generic_mapping_read... ha ha, that would be
popular.

For now I think your patch probably eliminates some classes of the bug
completely and remainder are a small race-window rather than a straight-line
bug, so it is probably the best way to go for now. I'd say
Acked-by: Nick Piggin <npiggin@suse.de>. Ram Pai I believe also worked on
similar issues with me, so I'll cc him.

Longer term, I have a few other issues with the fs layer returning non
uptodate pages to do_generic_mapping_read which could also require wider
scale rework...

> 
> And just to check, I race the test with your patch and I get a nice
> little row of "!!!!!" - it is finding zeros still.
> 
> But we could possibly remove the early checks on end_index, that
> makes sense (I've also moved the comment).
> 
> Thanks,
> NeilBrown
> 
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./mm/filemap.c |   72 ++++++++++++++++++++++-----------------------------------
>  1 file changed, 28 insertions(+), 44 deletions(-)
> 
> diff .prev/mm/filemap.c ./mm/filemap.c
> --- .prev/mm/filemap.c	2007-05-29 16:45:26.000000000 +1000
> +++ ./mm/filemap.c	2007-05-29 16:58:23.000000000 +1000
> @@ -875,13 +875,11 @@ void do_generic_mapping_read(struct addr
>  {
>  	struct inode *inode = mapping->host;
>  	unsigned long index;
> -	unsigned long end_index;
>  	unsigned long offset;
>  	unsigned long last_index;
>  	unsigned long next_index;
>  	unsigned long prev_index;
>  	unsigned int prev_offset;
> -	loff_t isize;
>  	struct page *cached_page;
>  	int error;
>  	struct file_ra_state ra = *_ra;
> @@ -894,27 +892,12 @@ void do_generic_mapping_read(struct addr
>  	last_index = (*ppos + desc->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
>  	offset = *ppos & ~PAGE_CACHE_MASK;
>  
> -	isize = i_size_read(inode);
> -	if (!isize)
> -		goto out;
> -
> -	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
>  	for (;;) {
>  		struct page *page;
> +		unsigned long end_index;
> +		loff_t isize;
>  		unsigned long nr, ret;
>  
> -		/* nr is the maximum number of bytes to copy from this page */
> -		nr = PAGE_CACHE_SIZE;
> -		if (index >= end_index) {
> -			if (index > end_index)
> -				goto out;
> -			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
> -			if (nr <= offset) {
> -				goto out;
> -			}
> -		}
> -		nr = nr - offset;
> -
>  		cond_resched();
>  		if (index == next_index)
>  			next_index = page_cache_readahead(mapping, &ra, filp,
> @@ -929,6 +912,32 @@ find_page:
>  		if (!PageUptodate(page))
>  			goto page_not_up_to_date;
>  page_ok:
> +		/*
> +		 * i_size must be checked after we know the page is Uptodate.
> +		 *
> +		 * Checking i_size after the check allows us to calculate
> +		 * the correct value for "nr", which means the zero-filled
> +		 * part of the page is not copied back to userspace (unless
> +		 * another truncate extends the file - this is desired though).
> +		 */
> +
> +		isize = i_size_read(inode);
> +		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
> +		if (unlikely(!isize || index > end_index)) {
> +			page_cache_release(page);
> +			goto out;
> +		}
> +
> +		/* nr is the maximum number of bytes to copy from this page */
> +		nr = PAGE_CACHE_SIZE;
> +		if (index == end_index) {
> +			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
> +			if (nr <= offset) {
> +				page_cache_release(page);
> +				goto out;
> +			}
> +		}
> +		nr = nr - offset;
>  
>  		/* If users can be writing to this page using arbitrary
>  		 * virtual addresses, take care about potential aliasing
> @@ -1015,31 +1024,6 @@ readpage:
>  			unlock_page(page);
>  		}
>  
> -		/*
> -		 * i_size must be checked after we have done ->readpage.
> -		 *
> -		 * Checking i_size after the readpage allows us to calculate
> -		 * the correct value for "nr", which means the zero-filled
> -		 * part of the page is not copied back to userspace (unless
> -		 * another truncate extends the file - this is desired though).
> -		 */
> -		isize = i_size_read(inode);
> -		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
> -		if (unlikely(!isize || index > end_index)) {
> -			page_cache_release(page);
> -			goto out;
> -		}
> -
> -		/* nr is the maximum number of bytes to copy from this page */
> -		nr = PAGE_CACHE_SIZE;
> -		if (index == end_index) {
> -			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
> -			if (nr <= offset) {
> -				page_cache_release(page);
> -				goto out;
> -			}
> -		}
> -		nr = nr - offset;
>  		goto page_ok;
>  
>  readpage_error:
> 


-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
