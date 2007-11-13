Date: Tue, 13 Nov 2007 05:18:49 -0500
Message-Id: <200711131018.lADAInYN017695@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Mon, 12 Nov 2007 17:01:51 GMT."
             <Pine.LNX.4.64.0711121645090.14138@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Dave Hansen <haveblue@us.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0711121645090.14138@blonde.wat.veritas.com>, Hugh Dickins writes:
> On Fri, 9 Nov 2007, Erez Zadok wrote:
> > In message <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>, Hugh Dickins writes:
> > 
> > > Three, I believe you need to add a flush_dcache_page(lower_page)
> > > after the copy_highpage(lower_page): some architectures will need
> > > that to see the new data if they have lower_page mapped (though I
> > > expect it's anyway shaky ground to be accessing through the lower
> > > mount at the same time as modifying through the upper).
> > 
> > OK.
> 
> While looking into something else entirely, I realize that _here_
> you are missing a SetPageUptodate(lower_page): should go in after
> the flush_dcache_page(lower_page) I'm suggesting.  (Nick would argue
> for some kind of barrier there too, but I don't think unionfs has a
> special need to be ahead of the pack on that issue.)
> 
> Think about it:
> when find_or_create_page has created a fresh page in the cache,
> and you've just done copy_highpage to put the data into it, you
> now need to mark it as Uptodate: otherwise a subsequent vfs_read
> or whatever on the lower level will find that page !Uptodate and
> read stale data back from disk instead of what you just copied in,
> unless its dirtiness has got it written back to disk meanwhile.

Hehe.  Funny, you mention this...  A few days ago, while I was doing your other
recommended pageuptodate cleanups, I also added the same call to
SetPageUptodate(lower_page) as you suggested.  I tested that change along w/
the other changes you suggested, and they all seem to work great all the way
from my 2.6.9 backport to 2.6.24-rc2 and -mm (modulo the fact that I had to
work around or fix more non-unionfs bugs in -mm than unionfs ones to get it
to work :-)

I posted all of these patches just now.  You're CC'ed.  Hopefully Andrew can
pull from my unionfs.git branch soon.

You also reported in your previous emails some hangs/oopses while doing make
-j 20 in unionfs on top of a single tmpfs, using -mm.  After several days,
I've not been able to reproduce this w/ my latest set of patches.  If you
can send me your .config and the specs on the h/w you're using (cpus, mem,
etc.), I'll see if I can find something similar to it on my end and run the
same tests.

Cheers,
Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
