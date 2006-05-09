Date: Tue, 9 May 2006 09:24:36 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] Break out memory initialisation code from page_alloc.c
 to mem_init.c
In-Reply-To: <445FF4B3.7020101@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0605090853270.27481@skynet.skynet.ie>
References: <20060508141030.26912.93090.sendpatchset@skynet>
 <20060508141231.26912.52976.sendpatchset@skynet> <445FF4B3.7020101@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, davej@codemonkey.org.uk, tony.luck@intel.com, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 May 2006, Nick Piggin wrote:

> Mel Gorman wrote:
>
>> page_alloc.c contains a large amount of memory initialisation code. This 
>> patch
>> breaks out the initialisation code to a separate file to make page_alloc.c
>> a bit easier to read.
>> 
>
> I realise this is at the wrong end of your queue, but if you _can_ easily
> break it out and submit it first, it would be a nice cleanup and would help
> shrink your main patchset.
>

The split-out potentially affects 10 other patches currently in -mm and is 
a merge headache for Andrew. My current understanding is that he wants to 
drop patch 6/6 until a later time. I guess this would be still true if the 
patch was at the other end of the queue.

> Also, we're recently having some problems with architectures not aligning
> zones correctly. Would it make sense to add these sorts of sanity checks,
> and possibly forcing alignment corrections into your generic code?
>

Yes, it is easy to force alignment corrections into the generic code. From 
that thread, there was this comment from Andy Whitcroft and your response;

> >1) check the alignment of the zones matches the implied alignment
> > constraints and correct it as we go.
> Yes. And preferably have checks in the generic page allocator setup
> code, so we can do something sane if the arch code gets it wrong.

With this patchset, it is trivial to move the start of highmem during 
setup. free_area_init_nodes() is passed the PFN each zone starts at by the 
architecture. If one wanted to force HIGHMEM to aligned, the 
arch_max_high_pfn value could be rounded down to MAX_ORDER alignment in 
free_area_init_nodes() before it calls free_area_init_node(). It doesn't 
matter if the PFN is in a hole. From there, an aligned mem_map should be 
allocated and memmap_init() will set the correct zone flags.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
