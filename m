Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C07A36B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 09:30:04 -0500 (EST)
Date: Tue, 29 Nov 2011 15:29:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] readahead: snap readahead request to EOF
Message-ID: <20111129142958.GJ5635@quack.suse.cz>
References: <20111129130900.628549879@intel.com>
 <20111129131456.145362960@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129131456.145362960@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 29-11-11 21:09:02, Wu Fengguang wrote:
> If the file size is 20kb and readahead request is [0, 16kb),
> it's better to expand the readahead request to [0, 20kb), which will
> likely save one followup I/O for [16kb, 20kb).
> 
> If the readahead request already covers EOF, trimm it down to EOF.
> Also don't set the PG_readahead mark to avoid an unnecessary future
> invocation of the readahead code.
> 
> This special handling looks worthwhile because small to medium sized
> files are pretty common.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/readahead.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> --- linux-next.orig/mm/readahead.c	2011-11-29 11:28:56.000000000 +0800
> +++ linux-next/mm/readahead.c	2011-11-29 11:29:05.000000000 +0800
> @@ -251,8 +251,16 @@ unsigned long max_sane_readahead(unsigne
>  unsigned long ra_submit(struct file_ra_state *ra,
>  		       struct address_space *mapping, struct file *filp)
>  {
> +	pgoff_t eof = ((i_size_read(mapping->host)-1) >> PAGE_CACHE_SHIFT) + 1;
> +	pgoff_t start = ra->start;
>  	int actual;
>  
> +	/* snap to EOF */
> +	if (start + ra->size + ra->size / 2 > eof) {
> +		ra->size = eof - start;
> +		ra->async_size = 0;
> +	}
> +
>  	actual = __do_page_cache_readahead(mapping, filp,
>  					ra->start, ra->size, ra->async_size);
  Hmm, wouldn't it be cleaner to do this already in ondemand_readahead()?
All other updates of readahead window seem to be there. Also shouldn't we
take maximum readahead size into account? Reading 3/2 of max readahead
window seems like a relatively big deal for large files...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
