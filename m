Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RIa6uP008311
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 14:36:06 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RIb6G1543618
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 12:37:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9RIa51W004985
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 12:36:06 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051027112054.10e945ae.akpm@osdl.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random>
	 <1130425212.23729.55.camel@localhost.localdomain>
	 <20051027151123.GO5091@opteron.random>
	 <20051027112054.10e945ae.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 27 Oct 2005 11:35:35 -0700
Message-Id: <1130438135.23729.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-27 at 11:20 -0700, Andrew Morton wrote:
> err, guys.
> 
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > ...
> >
> > tmpfs (the short term big need of this feature).
> > 
> > ...
> >
> > Freeing swap entries is the most important thing and at the same time
> > the most complex in the patch (that's why the previous MADV_DISCARD was
> > so simple ;).
> > 
> 
> I think there's something you're not telling us!
> 
> googling MADV_DISCARD comes up with basically nothing.  MADV_TRUNCATE comes
> up with precisely nothing.

I sent out a patch (linux-mm) for review madvise(MADV_DISCARD) to drop
the pagecache pages for shared memory segments. Andrea & Hugh commented
that - its not good enough, since:

(1) It doesn't work on shmfs, if the blocks are swapped out.
(2) it doesn't work on real filesystems and corrupts stuff (because
we are thrashing pagecache without filesystem knowledge).

> 
> Why does tmpfs need this feature?  What's the requirement here?  Please
> spill the beans ;)

I have 2 reasons (I don't know if Andrea has more uses/reasons):

(1) Our database folks want to drop parts of shared memory segments
when they see memory pressure or memory hotplug/virtualization stuff.
madvise(DONTNEED) is not really releasing the pagecache pages. So 
they want madvise(DISCARD).

(2) Jeff Dike wants to use this for UML.

> 
> 
> Comment on the patch: doing it via madvise sneakily gets around the
> problems with partial-page truncation (we don't currently have a way to
> release anything but the the tail-end of a page's blocks).
> 
> But if we start adding infrastructure of this sort people are, reasonably,
> going to want to add sys_holepunch(fd, start, len) and it's going to get
> complexer.

Please advise on what you would prefer. A small extension to madvise()
to solve few problems right now OR lets do real sys_holepunch() and
bite the bullet (even though we may not get any more users for it).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
