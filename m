Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BB0D96B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 14:48:15 -0400 (EDT)
Date: Wed, 4 May 2011 14:48:03 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 3/3] mm: Wait for writeback when grabbing pages to
 begin a write
Message-ID: <20110504184803.GB23246@infradead.org>
References: <20110406232938.GF1110@tux1.beaverton.ibm.com>
 <20110407165700.GB7363@quack.suse.cz>
 <20110408203135.GH1110@tux1.beaverton.ibm.com>
 <20110411124229.47bc28f6@corrin.poochiereds.net>
 <1302543595-sup-4352@think>
 <1302569212.2580.13.camel@mingming-laptop>
 <20110412005719.GA23077@infradead.org>
 <1302742128.2586.274.camel@mingming-laptop>
 <20110422000226.GA22189@tux1.beaverton.ibm.com>
 <20110504174227.GH20579@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504174227.GH20579@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, May 04, 2011 at 10:42:27AM -0700, Darrick J. Wong wrote:
> When grabbing a page for a buffered IO write, the mm should wait for writeback
> on the page to complete so that the page does not become writable during the IO
> operation.
> 
> Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
> ---
> 
>  mm/filemap.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c641edf..c22675f 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2287,8 +2287,10 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
>  		gfp_notmask = __GFP_FS;
>  repeat:
>  	page = find_lock_page(mapping, index);
> -	if (page)
> +	if (page) {
> +		wait_on_page_writeback(page);
>  		return page;
> +	}

		goto found;

>  
>  	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
>  	if (!page)
> @@ -2301,6 +2303,7 @@ repeat:
>  			goto repeat;
>  		return NULL;
>  	}

found:
> +	wait_on_page_writeback(page);
>  	return page;
>  }
>  EXPORT_SYMBOL(grab_cache_page_write_begin);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
