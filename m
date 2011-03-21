Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC30B8D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 21:58:47 -0400 (EDT)
Date: Sun, 20 Mar 2011 18:55:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-Id: <20110320185532.08394018.akpm@linux-foundation.org>
In-Reply-To: <20110321122018.6306d067@lilo>
References: <20110315143547.1b233cd4@lilo>
	<20110315161623.4099664b.akpm@linux-foundation.org>
	<20110317154026.61ddd925@lilo>
	<20110317125427.eebbfb51.akpm@linux-foundation.org>
	<20110321122018.6306d067@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 21 Mar 2011 12:20:18 +1030 Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> On Thu, 17 Mar 2011 12:54:27 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 17 Mar 2011 15:40:26 +1030
> > Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> > 
> > > > Thinking out loud: if we had a way in which a process can add and
> > > > remove a local anonymous page into pagecache then other processes
> > > > could access that page via mmap.  If both processes map the file
> > > > with a nonlinear vma they they can happily sit there flipping
> > > > pages into and out of the shared mmap at arbitrary file offsets.
> > > > The details might get hairy ;) We wouldn't want all the regular
> > > > mmap semantics of
> > > 
> > > Yea, its the complexity of trying to do it that way that eventually
> > > lead me to implementing it via a syscall and get_user_pages
> > > instead, trying to keep things as simple as possible.
> > 
> > The pagecache trick potentially gives zero-copy access, whereas the
> > proposed code is single-copy.  Although the expected benefits of that
> > may not be so great due to TLB manipulation overheads.
> > 
> > I worry that one day someone will come along and implement the
> > pagecache trick, then we're stuck with obsolete code which we have to
> > maintain for ever.
> 
> Perhaps I don't understand what you're saying correctly but I think that
> one problem with the zero copy page flipping approach is that there
> is no guarantee with the data that the MPI apps want to send 
> resides in a page or pages all by itself.

Well.  The applications could of course be changed.  But if the
applications are changeable then they could be changed to use
MAP_SHARED memory sharing and we wouldn't be having this discussion,
yes?

(Why can't the applications be changed to use existing shared memory
capabilities, btw?)

But yes, I'm assuming that it will be acceptable for the sending app to
expose some memory (up to PAGE_SIZE-1) below and above the actual
payload which is to be transferred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
