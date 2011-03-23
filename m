Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B31738D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 19:07:18 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
In-Reply-To: <20110323125213.69a7a914@lilo>
References: <20110315143547.1b233cd4@lilo> <20110315161623.4099664b.akpm@linux-foundation.org> <20110317154026.61ddd925@lilo> <20110317125427.eebbfb51.akpm@linux-foundation.org> <20110321122018.6306d067@lilo> <20110320185532.08394018.akpm@linux-foundation.org> <20110323125213.69a7a914@lilo>
Date: Thu, 24 Mar 2011 09:20:41 +1030
Message-ID: <877hbpcuym.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 23 Mar 2011 12:52:13 +1030, Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> On Sun, 20 Mar 2011 18:55:32 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon, 21 Mar 2011 12:20:18 +1030 Christopher Yeoh
> > <cyeoh@au1.ibm.com> wrote:
> > 
> > > On Thu, 17 Mar 2011 12:54:27 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > On Thu, 17 Mar 2011 15:40:26 +1030
> > > > Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> > > > 
> > > > > > Thinking out loud: if we had a way in which a process can add
> > > > > > and remove a local anonymous page into pagecache then other
> > > > > > processes could access that page via mmap.  If both processes
> > > > > > map the file with a nonlinear vma they they can happily sit
> > > > > > there flipping pages into and out of the shared mmap at
> > > > > > arbitrary file offsets. The details might get hairy ;) We
> > > > > > wouldn't want all the regular mmap semantics of
> > > > > 
> > > > > Yea, its the complexity of trying to do it that way that
> > > > > eventually lead me to implementing it via a syscall and
> > > > > get_user_pages instead, trying to keep things as simple as
> > > > > possible.
> > > > 
> > > > The pagecache trick potentially gives zero-copy access, whereas
> > > > the proposed code is single-copy.  Although the expected benefits
> > > > of that may not be so great due to TLB manipulation overheads.
> > > > 
> > > > I worry that one day someone will come along and implement the
> > > > pagecache trick, then we're stuck with obsolete code which we
> > > > have to maintain for ever.

Since this is for MPI (ie. message passing), they really want copy
semantics.  If they didn't want copy semantics, they could just
MAP_SHARED some memory and away they go...

You don't want to implement copy semantics with page-flipping; you would
need to COW the outgoing pages, so you end up copying *and* trapping.

If you are allowed to replace "sent" pages with zeroed ones or something
then you don't have to COW.  Yet even if your messages were a few MB,
it's still not clear you'd win; in a NUMA world you're better off
copying into a local page and then working on it.

Copying just isn't that bad when it's cache-hot on the sender and you
are about to use it on the receiver, as MPI tends to be.  And it's damn
simple.

But we should be able to benchmark an approximation to the page-flipping
approach anyway, by not copying the data and doing the appropriate tlb
flushes in the system call.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
