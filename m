Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4126B3F9.90706@jp.fujitsu.com>
References: <4126B3F9.90706@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093271785.3153.754.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 23 Aug 2004 07:36:25 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-08-20 at 19:31, Hiroyuki KAMEZAWA wrote: 
> This patch removes bitmap from buddy allocator used in
> alloc_pages()/free_pages() in the kernel 2.6.8.1.

Looks very interesting.  The most mysterious thing about it that I can
think of right now would be its cache behavior.  Since struct pages are
at least 1/2 a cacheline on most architectures, you're going to dirty
quite a few more cachelines than if you were accessing a quick bitmap. 
However, if the page was recently accessed you might get *better*
cacheline performance because the struct page itself may have been
hotter than its bitmap.  

The use of page_count()==0 is a little worrisome.  There's almost
certainly some race conditions where a page can be mistaken for free
while it's page_count()==0, but before it's reached free_pages_bulk().

BTW, even if page_count()==0 isn't a valid check like you fear, you
could always steal a bit in the page->flags.  Check out 
free_pages_check() in mm/page_alloc.c for a nice summary of what state
pages have to be in before they're freed.  

I'll try and give these patches a run on a NUMA-Q today.  Those machines
are very cache-sensitive and should magnify any positive or negative
effects.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
