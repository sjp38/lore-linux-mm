Date: Mon, 12 Nov 2007 17:01:51 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200711090605.lA965B1S024066@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0711121645090.14138@blonde.wat.veritas.com>
References: <200711090605.lA965B1S024066@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Dave Hansen <haveblue@us.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Erez Zadok wrote:
> In message <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>, Hugh Dickins writes:
> 
> > Three, I believe you need to add a flush_dcache_page(lower_page)
> > after the copy_highpage(lower_page): some architectures will need
> > that to see the new data if they have lower_page mapped (though I
> > expect it's anyway shaky ground to be accessing through the lower
> > mount at the same time as modifying through the upper).
> 
> OK.

While looking into something else entirely, I realize that _here_
you are missing a SetPageUptodate(lower_page): should go in after
the flush_dcache_page(lower_page) I'm suggesting.  (Nick would argue
for some kind of barrier there too, but I don't think unionfs has a
special need to be ahead of the pack on that issue.)

Think about it:
when find_or_create_page has created a fresh page in the cache,
and you've just done copy_highpage to put the data into it, you
now need to mark it as Uptodate: otherwise a subsequent vfs_read
or whatever on the lower level will find that page !Uptodate and
read stale data back from disk instead of what you just copied in,
unless its dirtiness has got it written back to disk meanwhile.

Odd that that hasn't been noticed at all: I guess it may be hard
to get testing to reclaim lower/upper pages in such a way as to
test out such paths thoroughly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
