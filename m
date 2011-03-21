Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 131868D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 22:15:34 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2L2FVNx003349
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:15:31 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2L2FVu41347606
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:15:31 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2L2FVWA025272
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:15:31 +1100
Date: Mon, 21 Mar 2011 12:45:32 +1030
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-ID: <20110321124532.252f51b2@lilo>
In-Reply-To: <20110320185532.08394018.akpm@linux-foundation.org>
References: <20110315143547.1b233cd4@lilo>
	<20110315161623.4099664b.akpm@linux-foundation.org>
	<20110317154026.61ddd925@lilo>
	<20110317125427.eebbfb51.akpm@linux-foundation.org>
	<20110321122018.6306d067@lilo>
	<20110320185532.08394018.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, 20 Mar 2011 18:55:32 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> > > The pagecache trick potentially gives zero-copy access, whereas
> > > the proposed code is single-copy.  Although the expected benefits
> > > of that may not be so great due to TLB manipulation overheads.
> > > 
> > > I worry that one day someone will come along and implement the
> > > pagecache trick, then we're stuck with obsolete code which we
> > > have to maintain for ever.
> > 
> > Perhaps I don't understand what you're saying correctly but I think
> > that one problem with the zero copy page flipping approach is that
> > there is no guarantee with the data that the MPI apps want to send 
> > resides in a page or pages all by itself.
> 
> Well.  The applications could of course be changed.  But if the
> applications are changeable then they could be changed to use
> MAP_SHARED memory sharing and we wouldn't be having this discussion,
> yes?
> 
> (Why can't the applications be changed to use existing shared memory
> capabilities, btw?)

An MPI application commonly doesn't know in advance when allocating
memory if the data it will eventually be sending will be to a local
node or remote node process.  It will depend on the configuration of the
cluster that you run the application on and parameters when you start
it up (eg how many processes per node to start etc), and exactly how
the program ends up executing.

So short of allocating everything to be shared memory just in case you
want intranode communication we can't use shared memory
cooperatively like that to reduce copies. Shared memory *is*
often used for intranode communication, but in a copy-in to shared
memory on the sender and copy-out on the receiver side.

We did originally do some early hacking on hpcc where we did allocate
everything from a shared memory pool just to see what sort of
theoretical gain we could have from a single-copy model, but its not a
solution we can use in general.

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
