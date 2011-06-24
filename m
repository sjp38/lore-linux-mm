Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0FE900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 02:12:04 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2007218pzk.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 23:11:59 -0700 (PDT)
Message-ID: <4E042A84.5010204@vflare.org>
Date: Thu, 23 Jun 2011 23:11:16 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com>
In-Reply-To: <4E023F61.8080904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

Hi Seth,

On 06/22/2011 12:15 PM, Seth Jennings wrote:

>
> The real problem here is compressing pages of size x and storing them in
> a pool that has "chunks", if you will, also of size x, where allocations
> can't span multiple chunks. Ideally, I'd like to address this issue by
> expanding the size of the xvmalloc pool chunks from one page to four
> pages (I can explain why four is a good number, just didn't want to make
> this note too long).
>
> After a little playing around, I've found this isn't entirely trivial to
> do because of the memory mapping implications; more specifically the use
> of kmap/kunamp in the xvmalloc and zcache layers. I've looked into using
> vmap to map multiple pages into a linear address space, but it seems
> like there is a lot of memory overhead in doing that.
>
> Do you have any feedback on this issue or suggestion solution?
>

xvmalloc fragmentation issue has been reported by several zram users and 
quite some time back I started working on a new allocator (xcfmalloc) 
which potentially solves many of these issues. However, all of the 
details are currently on paper and I'm sure actual implementation will 
bring a lot of surprises.

Currently, xvmalloc wastes memory due to:
  - No compaction support: Each page can store chunks of any size which 
makes compaction really hard to implement.
  - Use of 0-order pages only: This was enforced to avoid memory 
allocation failures. As Dan pointed out, any higher order allocation is 
almost guaranteed to fail under memory pressure.

To solve these issues, xcfmalloc:
  - Supports compaction: Its size class based (like SLAB) which, among 
other things, simplifies compaction.
  - Supports higher order pages using little trickery:

For 64-bit systems, we can simply use vmalloc(16k or 64k) pages and 
never bother unmapping them. This is expensive (how much?) in terms of 
both CPU and memory but easy to implement.

But on 32-bit (almost all "embedded" devices), this ofcourse cannot be 
done. For this case, the plan is to create a "vpage" abstraction which 
can be treated as usual higher-order page.

vpage abstraction:
  - Allocate 0-order pages and maintain them in an array
  - Allow a chunk to cross at most one 4K (or whatever is the native 
PAGE_SIZE) page boundary. This limits maximum allocation size to 4K but 
simplifies mapping logic.
  - A vpage is assigned a specific size class just like usual SLAB. This 
will simplify compaction.
  - xcfmalloc() will return a object handle instead of a direct pointer.
  - Provide xcfmalloc_{map,unmap}() which will handle the case where a 
chunk spans two pages. It will map the pages using kmap_atomic() and 
thus user will be expected to unmap them soon.
  - Allow vpage to be "partially freed" i.e. empty 4K pages can be freed 
individually if completely empty.

Much of this vpage functionality seems to be already present in mainline 
as "flexible arrays"[1]

For scalability, we can simply go for per-cpu lists and use Hoard[2] 
like design to bound fragmentation associated with such per-cpu slabs.

Unfortunately, I'm currently too loaded to work on this, atleast for 
next 2 months (internship) but would be glad to contribute if someone is 
willing to work on this.

[1] http://lxr.linux.no/linux+v2.6.39/Documentation/flexible-arrays.txt
[2] Hoard allocator: 
http://www.cs.umass.edu/~emery/pubs/berger-asplos2000.pdf

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
