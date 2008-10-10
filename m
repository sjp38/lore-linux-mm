Date: Fri, 10 Oct 2008 12:10:54 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010161053.GF16353@mit.edu>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org> <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit> <20081010140535.GD16353@mit.edu> <20081010140829.GA7983@infradead.org> <20081010155447.GA14628@skywalker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010155447.GA14628@skywalker>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Steven Whitehouse <steve@chygwyn.com>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 09:24:47PM +0530, Aneesh Kumar K.V wrote:
> On Fri, Oct 10, 2008 at 10:08:29AM -0400, Christoph Hellwig wrote:
> > On Fri, Oct 10, 2008 at 10:05:35AM -0400, Theodore Tso wrote:
> > > 3) A version which (optionally via a flag in the wbc structure)
> > > instructs write_cache_pages() to not pursue those updates.  This has
> > > not been written yet.
> > 
> > This one sounds best to me (although we'd have to actualy see it..)
> 
> something like  the below ?
> 
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
>  };

I don't see a definition for WB_NO_NRWRITE_UPDATE and
WB_NO_INDEX_UPDATE in your patch?

Given the structure seems to be using bitfields for all of the other
fields, why not do this instead?

	unsigned no_nrwrite_update:1;
	unsigned no_index_update:1;

Personally, I'm old school, and prefer using an int flag field and
using #define's for flags, but the rest of the structure is using
bitfields for flags, and it's probably better to be consistent...
	

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
