Date: Tue, 04 Jan 2005 23:42:07 +0900 (JST)
Message-Id: <20050104.234207.74734492.taka@valinux.co.jp>
Subject: Re: page migration
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <41D9A7DB.2020306@sgi.com>
References: <41D99743.5000601@sgi.com>
	<1104781061.25994.19.camel@localhost>
	<41D9A7DB.2020306@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: haveblue@us.ibm.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ray,

> >>Of course, the "standalone" memory migration stuff makes most sense on NUMA, 
> >>and there is some minor interface changes there to support that (i. e. consider:
> >>
> >>migrate_onepage(page);
> >>
> >>vs
> >>
> >>migrate_onepage_node(page, node);
> >>
> >>what the latter does is to call alloc_pages_node() instead of
> >>page_cache_alloc() to get the new page.)
> > 
> > 
> > We might as well just change all of the users over to the NUMA version
> > from the start.  Having 2 different functions just causes confusion.  
> > 
> 
> Yes, especially since alloc_pages_node() is defined regardless of whether
> NUMA is defined (I've found out by some code inspection).  So in the
> non-DISCONTIGMEM cases, the node argument would just be ignored.  I'll
> put together a patch that moves the interface over to
> 
> migrate_onepage(page, node)
> 
> and fixes up the callers in the memory hotplug patches.

I also think we should rewrite page allocation in the memory migration
code, as the latest -mm tree includes NUMA aware page allocator. I guess
you should also care about mm/mempolicy.c and expand it for your purpose.
If memory migration is called after moving a process, a new page would
be allocated form a proper node automatically.

Have you checked mm/mempolicy.c?

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
