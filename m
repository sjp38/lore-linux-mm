Date: Mon, 13 Sep 2004 20:19:40 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <20040913231940.GC23588@logos.cnet>
References: <20040913215753.GA23119@logos.cnet> <66880000.1095120205@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <66880000.1095120205@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2004 at 05:03:25PM -0700, Martin J. Bligh wrote:
> > The truncate VM functions use pagevec's for operation batching, but they mark
> > the pagevec used to hold being-truncated-pages as "cache hot". 
> > 
> > There is nothing which indicates such pages are likely to be "cache hot" - the
> > following patch marks being-truncated-pages as cold instead. 
> 
> Are they coming from the reclaim path? looks at a glance like they are,
> in which case cold would definitely be correct. 

No - its from the truncate() path? They might have come from the reclaim path when 
they were allocated and mapped.

> > BTW Martin, I'm wondering on a few performance points about the per_cpu_page lists, 
> > as we talked on chat before. Here they are:
> > 
> > - I wonder if the size of the lists are optimal. They might be too big to fit into the caches.
> 
> Doesn't really matter that much if they are over-sized, it doesn't do all
> that much harm, but it would be better if we sized it off the CPUs actual
> cache size. Does anyone know a consistent way to get that across arches?
>  
> > - Making the allocation policy FIFO should drastically increase the chances "hot" pages
> > are handed to the allocator. AFAIK the policy now is LIFO.
> 
> It should definitely have been FIFO to start with ... at least that was
> the intent. free_hot_cold_page is doing list_add between head and head->next, buffered_rmqueue is doing list_del from the head, AFAICS, so it should work.

Oh yes correct.

                        page = list_entry(pcp->list.next, struct page, lru);

I missed that "next".

> > - When we we hit the high per_cpu_pages watermark, which can easily happen,
> > further hot pages being freed are send down to the SLAB manager, until 
> > the pcp count goes below the high watermark. Meaning that during this period 
> > the hot/cold logic goes down the drain.
> 
> Well, we should be freeing off the BACK end of the FIFO stack into the page
> allocator - I haven't checked it but that was the intent.

static void fastcall free_hot_cold_page(struct page *page, int cold)
{
...
        if (pcp->count >= pcp->high)
                pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list, 0);

So when we hit the high watermark, "hotter" pages are sent back to SLAB. 
I dont think this is optimal, wonder if moving pages at the end of the pcp
to SLAB and moving the being-freed-page to start of pcp (so to be processed 
as "hottest") will make a difference.

AFAICS its the best thing to do wrt better cache usage.

> > But the main point of the pcp lists, which is to avoid locking AFAIK, 
> > is not affected by the issues I describe.
> 
> Well, it's both - they both had a fairly significant effect, IIRC.

Do you have the numbers at the time you wrote the it?

Thanks for your comments guys!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
