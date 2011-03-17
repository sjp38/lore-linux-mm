Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C49A8D0041
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 18:27:29 -0400 (EDT)
Date: Thu, 17 Mar 2011 15:25:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-Id: <20110317152545.adb55e3b.akpm@linux-foundation.org>
In-Reply-To: <4D8286F9.7050107@fiec.espol.edu.ec>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
	<20110315135334.36e29414.akpm@linux-foundation.org>
	<4D7FEDDC.3020607@fiec.espol.edu.ec>
	<20110315161926.595bdb65.akpm@linux-foundation.org>
	<4D80D65C.5040504@fiec.espol.edu.ec>
	<20110316150208.7407c375.akpm@linux-foundation.org>
	<4D827CC1.4090807@fiec.espol.edu.ec>
	<20110317144727.87a461f9.akpm@linux-foundation.org>
	<4D8286F9.7050107@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?ISO-8859-1?Q?Villac=ED=ADs?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 17 Mar 2011 17:11:05 -0500
Alex Villac____s Lasso <avillaci@fiec.espol.edu.ec> wrote:

> El 17/03/11 16:47, Andrew Morton escribi__:
> >
> > ah, the epic 12309.  https://bugzilla.kernel.org/show_bug.cgi?id=12309.
> > If you're ever wondering how much we suck, go read that one.
> >
> > I think what we're seeing in 31142 is a large amount of dirty data
> > buffered against a slow device.  Innocent processes enter page reclaim
> > and end up getting stuck trying to write to that heavily-queued and
> > slow device.
> >
> > If so, that's probably what some of the 12309 participants are seeing.
> > But there are lots of other things in that report too.
> >
> >
> > Now, the problem you're seeing in 31142 isn't really supposed to
> > happen.  In the direct-reclaim case the code will try to avoid
> > initiation of blocking I/O against a congested device, via the
> > bdi_write_congested() test in may_write_to_queue().  Although that code
> > now looks a bit busted for the order>PAGE_ALLOC_COSTLY_ORDER case,
> > whodidthat.
> >
> > However in the case of the new(ish) compaction/migration code I don't
> > think we're performing that test.  migrate_pages()->unmap_and_move()
> > will get stuck behind that large&slow IO queue if page reclaim decided
> > to pass it down sync==true, as it apparently has done.
> >
> > IOW, Mel broke it ;)
> >
> I don't quite follow. In my case, the congested device is the USB stick, but the affected processes should be reading/writing on the hard disk. What kind of queue(s) implementation results in pending writes to the USB stick interfering with I/O to the hard 
> disk? Or am I misunderstanding? I had the (possibly incorrect) impression that each block device had its own I/O queue.

Your web browser is just trying to allocate some memory.  As part of
that operation it entered the kernel's page reclaim and while scanning
for memory to free, page reclaim encountered a page which was queued
for IO.  Then page reclaim waited for the IO to complete against that
page.  So the browser got stuck.

Page reclaim normally tries to avoid this situation by not waiting on
such pages, unless the calling processes was itself involved in writing
to the page's device (stored in current->backing_dev_info).  But afaict
the new compaction/migration code forgot to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
