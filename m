Date: Thu, 1 Apr 2004 08:02:22 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: msync() behaviour broken for MS_ASYNC, revert patch?
In-Reply-To: <1080834032.2626.94.camel@sisko.scot.redhat.com>
Message-ID: <Pine.LNX.4.58.0404010750100.1116@ppc970.osdl.org>
References: <1080771361.1991.73.camel@sisko.scot.redhat.com>
 <Pine.LNX.4.58.0403311433240.1116@ppc970.osdl.org>
 <1080776487.1991.113.camel@sisko.scot.redhat.com>
 <Pine.LNX.4.58.0403311550040.1116@ppc970.osdl.org>
 <1080834032.2626.94.camel@sisko.scot.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 1 Apr 2004, Stephen C. Tweedie wrote:
> 
> So it appears that on Solaris, MS_ASYNC is kicking off instant IO, but
> is not waiting for existing IO to complete first.

A much more likely schenario is that Solaris is really doing the same
thing we are, but it _also_ ends up opportunistically trying to put the
resultant pages on the IO queues if possible (ie do a "write-ahead": start
writeout if that doesn't imply blocking).

We could probably do that too, it seems easy enough. A 
"TestSetPageLocked()" along with setting the BIO_RW_AHEAD flag. The only 
problem is that I don't think we really have support for doing write-ahead 
(ie we clear the page "dirty" bit too early, so if the write gets 
cancelled due to the IO queues being full, the dirty bit gets lost.

So we don't want to go there for now, but it's something to keep in mind, 
perhaps. 
		
> Worse, it doesn't seem to be implemented consistently either.  I've been
> trying on a few other Unixen while writing this.  First on a Tru64 box,
> and it is _not_ kicking off any IO at all for MS_ASYNC, except for the
> 30-second regular sync.  The same appears to be true on FreeBSD.  And on
> HP-UX, things go in the other direction: the performance of MS_ASYNC is
> identical to MS_SYNC, both in terms of observed disk IO during the sync
> and the overall rate of the msync loop.

If you check HP-UX, make sure it's a recent one. HPUX has historically 
been just too broken for words when it comes to mmap() (ie some _really_ 
strange semantics, like not being able to unmap partial mappings etc).

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
