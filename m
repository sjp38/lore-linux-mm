Subject: Re: [RFC] start_aggressive_readahead
From: Stephen Lord <lord@sgi.com>
In-Reply-To: <3D405428.7EC4B715@zip.com.au>
References: <20020725181059.A25857@lst.de>
	<Pine.LNX.4.44L.0207251343180.8815-100000@duckman.distro.conectiva>
	<3D405428.7EC4B715@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 26 Jul 2002 15:14:13 -0500
Message-Id: <1027714455.1727.9.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-25 at 14:40, Andrew Morton wrote:
> Rik van Riel wrote:
> > 
> > On Thu, 25 Jul 2002, Christoph Hellwig wrote:
> > 
> > > This function (start_aggressive_readahead()) checks whether all zones
> > > of the given gfp mask have lots of free pages.
> > 
> > Seems a bit silly since ideally we wouldn't reclaim cache memory
> > until we're low on physical memory.
> > 
> 
> Yes, I would question its worth also.
> 
> 
> What it boils down to is:  which pages are we, in the immediate future,
> more likely to use?  Pages which are at the tail of the inactive list,
> or pages which are in the file's readahead window?
> 
> I'd say the latter, so readahead should just go and do reclaim.
> 

The interesting thing is that tuning metadata readahead using
this function does indeed improve performance under heavy memory
load. It seems we end up pushing more useful things out of
memory than the metadata we read in. Andrew, you talked about
a GFP flag which would mean only return memory if there was
some available which was already free and clean. The best
approach might be to use that flag in this scenario and skip
the readahead if no memory is returned.

For the record, this is not just used for directory readahead,
but for any btree structured metadata in xfs.

Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
