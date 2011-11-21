Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C0B336B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:42:45 -0500 (EST)
Date: Mon, 21 Nov 2011 19:42:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/8] readahead: replace ra->mmap_miss with ra->ra_flags
Message-ID: <20111121114239.GC8895@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.378529145@intel.com>
 <1321873467.2710.17.camel@menhir>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321873467.2710.17.camel@menhir>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi Steven,

On Mon, Nov 21, 2011 at 07:04:27PM +0800, Steven Whitehouse wrote:
> Hi,
> 
> I'm not quite sure why you copied me in to this patch, but I've had a

Yeah it's such an old patch that I've forgotten why I added CC to you ;)

> look at it and it seems ok to me. Some of the other patches in this
> series look as if they might be rather useful for the GFS2 dir readahead
> code though, so I'll be keeping an eye on developments in this area,
> 
> Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Thanks! That reminds me of the "metadata readahead". It should be
possible to do more metadata readahead in future, hence we might add a
"meta_io" column in the readahead stats file :)

Thanks,
Fengguang

> On Mon, 2011-11-21 at 17:18 +0800, Wu Fengguang wrote:
> > plain text document attachment (readahead-flags.patch)
> > Introduce a readahead flags field and embed the existing mmap_miss in it
> > (mainly to save space).
> > 
> > It will be possible to lose the flags in race conditions, however the
> > impact should be limited.  For the race to happen, there must be two
> > threads sharing the same file descriptor to be in page fault or
> > readahead at the same time.
> > 
> > Note that it has always been racy for "page faults" at the same time.
> > 
> > And if ever the race happen, we'll lose one mmap_miss++ or mmap_miss--.
> > Which may change some concrete readahead behavior, but won't really
> > impact overall I/O performance.
> > 
> > CC: Andi Kleen <andi@firstfloor.org>
> > CC: Steven Whitehouse <swhiteho@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/fs.h |   31 ++++++++++++++++++++++++++++++-
> >  mm/filemap.c       |    9 ++-------
> >  2 files changed, 32 insertions(+), 8 deletions(-)
> > 
> > --- linux-next.orig/include/linux/fs.h	2011-11-20 11:30:55.000000000 +0800
> > +++ linux-next/include/linux/fs.h	2011-11-20 11:48:53.000000000 +0800
> > @@ -945,10 +945,39 @@ struct file_ra_state {
> >  					   there are only # of pages ahead */
> >  
> >  	unsigned int ra_pages;		/* Maximum readahead window */
> > -	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
> > +	unsigned int ra_flags;
> >  	loff_t prev_pos;		/* Cache last read() position */
> >  };
> >  
> > +/* ra_flags bits */
> > +#define	READAHEAD_MMAP_MISS	0x000003ff /* cache misses for mmap access */
> > +
> > +/*
> > + * Don't do ra_flags++ directly to avoid possible overflow:
> > + * the ra fields can be accessed concurrently in a racy way.
> > + */
> > +static inline unsigned int ra_mmap_miss_inc(struct file_ra_state *ra)
> > +{
> > +	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
> > +
> > +	/* the upper bound avoids banging the cache line unnecessarily */
> > +	if (miss < READAHEAD_MMAP_MISS) {
> > +		miss++;
> > +		ra->ra_flags = miss | (ra->ra_flags & ~READAHEAD_MMAP_MISS);
> > +	}
> > +	return miss;
> > +}
> > +
> > +static inline void ra_mmap_miss_dec(struct file_ra_state *ra)
> > +{
> > +	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
> > +
> > +	if (miss) {
> > +		miss--;
> > +		ra->ra_flags = miss | (ra->ra_flags & ~READAHEAD_MMAP_MISS);
> > +	}
> > +}
> > +
> >  /*
> >   * Check if @index falls in the readahead windows.
> >   */
> > --- linux-next.orig/mm/filemap.c	2011-11-20 11:30:55.000000000 +0800
> > +++ linux-next/mm/filemap.c	2011-11-20 11:48:29.000000000 +0800
> > @@ -1597,15 +1597,11 @@ static void do_sync_mmap_readahead(struc
> >  		return;
> >  	}
> >  
> > -	/* Avoid banging the cache line if not needed */
> > -	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
> > -		ra->mmap_miss++;
> > -
> >  	/*
> >  	 * Do we miss much more than hit in this file? If so,
> >  	 * stop bothering with read-ahead. It will only hurt.
> >  	 */
> > -	if (ra->mmap_miss > MMAP_LOTSAMISS)
> > +	if (ra_mmap_miss_inc(ra) > MMAP_LOTSAMISS)
> >  		return;
> >  
> >  	/*
> > @@ -1633,8 +1629,7 @@ static void do_async_mmap_readahead(stru
> >  	/* If we don't want any read-ahead, don't bother */
> >  	if (VM_RandomReadHint(vma))
> >  		return;
> > -	if (ra->mmap_miss > 0)
> > -		ra->mmap_miss--;
> > +	ra_mmap_miss_dec(ra);
> >  	if (PageReadahead(page))
> >  		page_cache_async_readahead(mapping, ra, file,
> >  					   page, offset, ra->ra_pages);
> > 
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
