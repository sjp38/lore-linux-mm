Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1DD6B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 06:37:22 -0500 (EST)
Date: Wed, 30 Nov 2011 12:37:19 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] readahead: snap readahead request to EOF
Message-ID: <20111130113719.GC4541@quack.suse.cz>
References: <20111129130900.628549879@intel.com>
 <20111129131456.145362960@intel.com>
 <20111129142958.GJ5635@quack.suse.cz>
 <20111130010604.GD11147@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111130010604.GD11147@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 30-11-11 09:06:04, Wu Fengguang wrote:
> >   Hmm, wouldn't it be cleaner to do this already in ondemand_readahead()?
> > All other updates of readahead window seem to be there.
> 
> Yeah it's not that clean, however the intention is to cover the other
> call site -- mmap read-around, too.
  Ah, OK.

> > Also shouldn't we
> > take maximum readahead size into account? Reading 3/2 of max readahead
> > window seems like a relatively big deal for large files...
> 
> Good point, the max readahead size is actually a must, in order to
> prevent it expanding the readahead size for ever in the backwards
> reading case.
> 
> This limits the size expansion to 1/4 max readahead. That means, if
> the next expected readahead size will be less than 1/4 max size, it
> will be merged into the current readahead window to avoid one small IO.
> 
> The backwards reading is not special cased here because it's not
> frequent anyway.
> 
>  unsigned long ra_submit(struct file_ra_state *ra,
>  		       struct address_space *mapping, struct file *filp)
>  {
> +	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
> +	pgoff_t start = ra->start;
> +	unsigned long size = ra->size;
>  	int actual;
>  
> +	/* snap to EOF */
> +	size += min(size, ra->ra_pages / 4);
  I'd probably choose:
	size += min(size / 2, ra->ra_pages / 4);
  to increase current window only to 3/2 and not twice but I don't have a
strong opinion. Otherwise I think the code is fine now so you can add:
  Acked-by: Jan Kara <jack@suse.cz>

> +	if (start + size > eof) {
> +		ra->size = eof - start;
> +		ra->async_size = 0;
> +	}
> +
>  	actual = __do_page_cache_readahead(mapping, filp,
>  					ra->start, ra->size, ra->async_size);

									Honza
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
