Date: Wed, 22 Mar 2000 23:45:31 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322234531.C31795@pcep-jamie.cern.ch>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org> <20000322223351.G2850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322223351.G2850@redhat.com>; from Stephen C. Tweedie on Wed, Mar 22, 2000 at 10:33:51PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > to say this another way, the page mapping binds a virtual address to a
> > page in the page cache. MADV_DONTNEED simply removes that binding.  
> > normal page aging will discover the unbound pages in the page cache and
> > remove them.  so really, MADV_DONTNEED is actually disconnected from the
> > mechanism of swapping or discarding the page's data.
> 
> Not for anonymous pages, where the pte reference is the _only_ reference
> to the page (except for swap-cached pages).  In this case, MADV_DONTNEED
> will genuinely free the page.

Doesn't this also result in a swap-cache leak, or are orphan swap-cache
pages reclaimed eventually?

> > nah, i still say a better way to handle this case is to lower malloc's
> > "use an anon map instead of the heap" threshold to 4K or 8K.  right now
> > it's 32K by default.  
> 
> No, it's much cheaper to do a MADV_DONTNEED when freeing an anonymous
> page: that way the pageout and subsequent demand-zero pagein all happen
> entirely within the page tables, without having to perform lots of
> operations on the vma tree of the process.

And it's even cheaper to do MADV_FREE so you skip demand-zeroing if
memory pressure doesn't require that.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
