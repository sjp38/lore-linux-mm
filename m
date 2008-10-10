Date: Fri, 10 Oct 2008 12:34:56 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010163456.GA7484@infradead.org>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org> <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit> <20081010140535.GD16353@mit.edu> <20081010140829.GA7983@infradead.org> <20081010155447.GA14628@skywalker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010155447.GA14628@skywalker>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Theodore Tso <tytso@mit.edu>, Steven Whitehouse <steve@chygwyn.com>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 09:24:47PM +0530, Aneesh Kumar K.V wrote:
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index bd91987..7599af2 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -63,6 +63,8 @@ struct writeback_control {
>  	unsigned for_writepages:1;	/* This is a writepages() call */
>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>  	unsigned more_io:1;		/* more io to be dispatched */
> +	/* flags which control the write_cache_pages behaviour */
> +	int writeback_flags;

As Ted already said please follow the bitfields style already used.

> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -876,11 +876,18 @@ int write_cache_pages(struct address_space *mapping,
>  	pgoff_t end;		/* Inclusive */
>  	int scanned = 0;
>  	int range_whole = 0;
> +	int flags = wbc->writeback_flags;
> +	long *nr_to_write, count;
>  
>  	if (wbc->nonblocking && bdi_write_congested(bdi)) {
>  		wbc->encountered_congestion = 1;
>  		return 0;
>  	}
> +	if (flags & WB_NO_NRWRITE_UPDATE) {
> +		count  = wbc->nr_to_write;
> +		nr_to_write = &count;
> +	} else
> +		nr_to_write = &wbc->nr_to_write;

I think we'd be better off always using a local variable and updating
wbc->nr_to_write again before the exit for the !WB_NO_NRWRITE_UPDATE
case.

> -	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
> +	if ((wbc->range_cyclic ||
> +			(range_whole && wbc->nr_to_write > 0)) && 
> +			(flags & ~WB_NO_INDEX_UPDATE)) {
>  		mapping->writeback_index = index;

The conditional looks rather odd, what about:

	if (!wbc->no_index_update &&
	    (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))

Also I wonder what this is for.  Do you want what Chris did in his
original patch in ext4 code, or is there another reason to not update
the writeback_index sometimes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
