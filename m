Date: Mon, 22 Aug 2005 19:48:22 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Preswapping
Message-ID: <20050822224822.GA8925@dmt.cnet>
References: <e692861c05081814582671a6a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e692861c05081814582671a6a3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gregory Maxwell <gmaxwell@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 18, 2005 at 05:58:57PM -0400, Gregory Maxwell wrote:
> With the ability to measure something approximating least frequently
> used inactive pages now, would it not make sense to begin more
> aggressive nonevicting preswapping?

I think that some kind of applications might benefit while others
can be hurt. One factor is whether or not there is locality.
If the accesses are very random increasing readahead might hurt?

Why don't you do some testing? The default readahead is (1 << page_cluster)

mm/swap.c
        /* Use a smaller cluster for small-memory machines */
        if (megs < 16)
                page_cluster = 2;
        else
                page_cluster = 3;

Which is 8 pages (32bytes) on machines with more than 16Mb.

The qsbench test should be pretty random (it does a quick sort on 
large amounts data). And then you could use a workload where locality
is more significant (few parallel fillmem's for example).

> For example, if the swap disks are not busy, we scan the least
> frequently used inactive pages, and write them out in nice large
> chunks. 

Yes, that could be done for every pagecache page on VM reclaim path
(and probably the pdflush path too, which controls the dirty limits
and buffer age).

And you can relatively easy find contiguous dirty pages in the per-inode
mapping via the radix tree with radix_tree_lookup_gang().

Hopefully the pages are contiguous on disk too, could discard IO 
otherwise. 

> The pages are moved to another list, but not evicted from
> memory. The normal swapping algorithm is used to decide when/if to
> actually evict these pages from memory.  If they are used prior to
> being evicted, they can be remarked active (and their blocks on swap
> marked as unused) without a disk seek.
> 
> This approach makes sense because swapping performance is often
> limited by seeks rather than disk throughput or capacity. While under
> memory pressure a system with preswapping has a substantial head start
> on other systems because it is likely that majority of the unneeded 
> pages are going to already be on disk, all that is needed is to evict
> them. Also, this process allows us to be very aggressive in what we
> write to disk so that the truly useless pages get out, but not run the
> risk of overswapping on a system with plenty of free memory.

Yes it probably helps - you should try it out.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
