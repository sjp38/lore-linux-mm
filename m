Date: Mon, 22 Jul 2002 14:56:53 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: alloc_pages_bulk
Message-ID: <20020722145653.D6428@redhat.com>
References: <1615040000.1027363248@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1615040000.1027363248@flay>; from Martin.Bligh@us.ibm.com on Mon, Jul 22, 2002 at 11:40:48AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2002 at 11:40:48AM -0700, Martin J. Bligh wrote:
> Below is a first cut at a bulk page allocator. This has no testing whatsoever,
> not even being compiled ... I just want to get some feedback on the approach,
> so if I get slapped, I'm less far down the path that I have to back out of.
> The __alloc_pages cleanup is also tacked on the end because I'm lazy at
> creating diff trees - sorry ;-)
> 
> Comments, opinions, abuse?

The inline for alloc_pages is wasteful: regparm on 386 allows us to pass 
3 arguments to a function without going to the stack; by making _alloc_pages 
take an additional argument which is a pointer, the stack manipulations and 
dereference add several instructions of bloat per alloc_pages inline.  Keep 
a seperate entry point around for alloc_pages to avoid this.  Also, what 
effect does this have on single page allocations for single processor and 
dual processor systems?

That said, why use an array?  You could just have alloc_pages return a linked 
list of pages.  This would allow you to make the allocation operation faster 
by doing a single snip of the portion of the list that has the required 
number of pages in the fast case.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
