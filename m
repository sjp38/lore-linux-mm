Date: Mon, 28 Jul 2008 18:13:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bugme-new] [Bug 11156] New: Old kernels copy memory faster than
 new
In-Reply-To: <20080724122642.b8ef2ac6.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0807281740580.12931@blonde.site>
References: <bug-11156-10286@http.bugzilla.kernel.org/>
 <20080724122642.b8ef2ac6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: smal.root@gmail.com
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jul 2008, Andrew Morton wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=11156
> > 
> > Kernel - 2.6.25.4(own built)
> > Copy speed - 1.7GByte/s
> > 
> > Kernel - 2.6.23.5(own built)
> > Copy speed - 43.5GByte/s
> > 
> > Steps to reproduce:
> > dd if=/dev/zero of=/dev/null bs=16M count=10000
> 
> lol.  OK, who did that?
> 
> Perhaps ZERO_PAGE changes?

Yes, the ZERO_PAGE changes: readprofile clearly shows lots of time
in clear_user() on 2.6.24 onwards, clearing each page instead of
using the ZERO_PAGE.

I see Nick has already answered this, and the bug is now closed
(guess he's on 2.6.23 whereas I'm on later ;).  I agree with him,
copying from /dev/zero to /dev/null is not an operation which
deserves VM tricks to optimize; but I wanted to add one point.

The particular awfulness of those dd rates (on machines I've
tried I see new kernels as 10 to 30 times worse than old kernels
at that test) owes a lot to the large blocksize (16M) being used.

That blocksize will not fit in the processor's memory cache, so
repeatedly clearing the pages is very slow.  Bring the blocksize
down to something that easily fits in the L2 cache, perhaps 1M or
256k, and new kernels then appear only twice(ish) as bad as old.

Nothing to be proud of, but not nearly so bad as the bs=16M case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
