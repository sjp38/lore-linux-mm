Date: Mon, 22 Jul 2002 13:05:11 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: alloc_pages_bulk
Message-ID: <1620750000.1027368311@flay>
In-Reply-To: <20020722145653.D6428@redhat.com>
References: <1615040000.1027363248@flay> <20020722145653.D6428@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@zip.com.au>, Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The inline for alloc_pages is wasteful: 

if I understand what you're hitting on here, that was already an inline - I didn't
do that - if the order is static, which it would be most times, that all just dissappears
into a call to _alloc_pages. If we ripped that out, and turned _alloc_pages into
alloc_pages, we'd lose that.

> regparm on 386 allows us to pass 
> 3 arguments to a function without going to the stack; by making _alloc_pages 
> take an additional argument which is a pointer, the stack manipulations and 
> dereference add several instructions of bloat per alloc_pages inline.  Keep 

OK, now that I can understand.

> a seperate entry point around for alloc_pages to avoid this.  Also, what 
> effect does this have on single page allocations for single processor and 
> dual processor systems?

Unmeasured, though it will obviously need to be.
 
> That said, why use an array?  You could just have alloc_pages return a linked 
> list of pages.  This would allow you to make the allocation operation faster 
> by doing a single snip of the portion of the list that has the required 
> number of pages in the fast case.

By doing the mem allocation for that stuff in the top level alloc pages, it's
just a local that gets freed before exit. If I allocate it lower down, I have to
find some way to track and free it that gets messy. The reason I pushed it
so high up was to avoid code duplication (see the NUMA version of _alloc_pages), 
and I though the cost would be trivial. But as you've pointed out, I've crossed
the line onto the stack, which is obviously bad ... time for me to think things over
again. 

Glad I mailed it out before getting too carried away - thanks very much for the
feedback ;-) I think I reorganised numa.c:_alloc_pages enough during the process
that the code duplication issue may be totally moot ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
