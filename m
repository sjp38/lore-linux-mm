Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 16D9A6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 06:33:14 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so6681958ied.28
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 03:33:13 -0700 (PDT)
Date: Thu, 18 Jul 2013 18:33:10 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/4 v6]swap: change block allocation algorithm for SSD
Message-ID: <20130718103310.GA25547@kernel.org>
References: <20130715204320.GA7925@kernel.org>
 <20130717150007.ff10504603266dc221763315@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130717150007.ff10504603266dc221763315@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Wed, Jul 17, 2013 at 03:00:07PM -0700, Andrew Morton wrote:
> On Tue, 16 Jul 2013 04:43:20 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> > I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> > CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
> > becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
> > cluster, which is very slow.
> > 
> > Here I introduced a simple algorithm to search cluster. Since we only care
> > about 256 pages cluster, we can just use a counter to track if a cluster is
> > free. Every 256 pages use one int to store the counter. If the counter of a
> > cluster is 0, the cluster is free. All free clusters will be added to a list,
> > so searching cluster is very efficient. With this, scap_swap_map() overhead
> > disappears.
> > 
> > This might help low end SD card swap too. Because if the cluster is aligned, SD
> > firmware can do flash erase more efficiently.
> > 
> > We only enable the algorithm for SSD. Hard disk swap isn't fast enough and has
> > downside with the algorithm which might introduce regression (see below).
> > 
> > The patch slightly changes which cluster is choosen. It always adds free
> > cluster to list tail. This can help wear leveling for low end SSD too. And if
> > no cluster found, the scan_swap_map() will do search from the end of last
> > cluster. So if no cluster found, the scan_swap_map() will do search from the
> > end of last free cluster, which is random. For SSD, this isn't a problem at
> > all.
> > 
> > Another downside is the cluster must be aligned to 256 pages, which will reduce
> > the chance to find a cluster. I would expect this isn't a big problem for SSD
> > because of the non-seek penality. (And this is the reason I only enable the
> > algorithm for SSD).
> 
> I have to agree with Will here - the patch adds a significant new
> design/algorithm into core MM but there wasn't even an attempt to
> describe it within the code.
> 
> The changelog provdes a reasonable overview, most notably the second
> paragraph.  Could you please find a way to flesh that part out a bit
> then integrate it into a code comment?  And yes, the major functions
> should have their own comments explaining how they serve the overall
> scheme.

Alright, I'll add more document as possible in the code instead of the change log.
 
> > --- linux.orig/include/linux/swap.h	2013-07-11 19:14:36.849910383 +0800
> > +++ linux/include/linux/swap.h	2013-07-11 19:14:38.657887654 +0800
> > @@ -182,6 +182,17 @@ enum {
> >  #define SWAP_MAP_SHMEM	0xbf	/* Owned by shmem/tmpfs, in first swap_map */
> >  
> >  /*
> > + * the data field stores next cluster if the cluster is free or cluster counter
> > + * otherwise
> > + */
> > +struct swap_cluster_info {
> > +	unsigned int data:24;
> > +	unsigned int flags:8;
> > +};
> 
> If I'm understanding it correctly, the code and data structures which
> this patch adds are all protected by swap_info_struct.lock, yes?  This
> is also worth mentioning in a comment, perhaps at the swap_cluster_info
> definition site
> 
> > +#define CLUSTER_FLAG_FREE 1 /* This cluster is free */
> > +#define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
> >
> > ...
> >
> > @@ -2117,13 +2311,28 @@ SYSCALL_DEFINE2(swapon, const char __use
> >  		error = -ENOMEM;
> >  		goto bad_swap;
> >  	}
> > +	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> > +		p->flags |= SWP_SOLIDSTATE;
> > +		/*
> > +		 * select a random position to start with to help wear leveling
> > +		 * SSD
> > +		 */
> > +		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
> > +
> > +		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
> > +			SWAPFILE_CLUSTER) * sizeof(*cluster_info));
> 
> OK, what is the upper bound on the size of this allocation?
> 
> A failure here would be bad - perhaps a list is needed, rather than a
> flat array.

Not too much. The cluster_info will be one int every 256 pages so for 1T swap
partition, we will use 4M memory. A list will waste memory and hard to use in
this case because we need get the cluster_info according to page index.

Thanks,
Shaohua 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
