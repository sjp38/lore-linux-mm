Date: Wed, 22 Mar 2000 22:33:51 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322223351.G2850@redhat.com>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org>; from cel@monkey.org on Wed, Mar 22, 2000 at 04:39:12PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Jamie Lokier <jamie.lokier@cern.ch>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 04:39:12PM -0500, Chuck Lever wrote:
> 
> in fact, i'd say it is safe in general to lower DEFAULT_MMAP_THRESHOLD to
> the system page size.  that way you'd get closer to the behavior you're
> after, and you'd also win a much bigger effective heap size when
> allocating large objects, because you can only allocate up to 960M of a
> process's address space with sbrk().

You can use MADV_DONTNEED to reclaim demand-zero pages below sbrk()
even without using memory map in the first place, and I understand that
recent versions of glibc will resort to extending the heap with mmap()
automatically once sbrk() reaches its limit.  So, I don't think that
decreasing DEFAULT_MMAP_THRESHOLD really gains that much.
> 
> to say this another way, the page mapping binds a virtual address to a
> page in the page cache. MADV_DONTNEED simply removes that binding.  
> normal page aging will discover the unbound pages in the page cache and
> remove them.  so really, MADV_DONTNEED is actually disconnected from the
> mechanism of swapping or discarding the page's data.

Not for anonymous pages, where the pte reference is the _only_ reference
to the page (except for swap-cached pages).  In this case, MADV_DONTNEED
will genuinely free the page.

> nah, i still say a better way to handle this case is to lower malloc's
> "use an anon map instead of the heap" threshold to 4K or 8K.  right now
> it's 32K by default.  

No, it's much cheaper to do a MADV_DONTNEED when freeing an anonymous
page: that way the pageout and subsequent demand-zero pagein all happen
entirely within the page tables, without having to perform lots of
operations on the vma tree of the process.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
