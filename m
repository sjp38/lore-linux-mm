From: "Yi Feng" <yifeng@cs.umass.edu>
Subject: RE: [patch] vmsig: notify user applications of virtual memory events via real-time signals
Date: Wed, 23 Nov 2005 00:00:35 -0500
Message-ID: <000001c5efea$da132280$0b00a8c0@louise>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
In-Reply-To: <1132712991.12897.8.camel@akash.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Rohit Seth' <rohit.seth@intel.com>, 'Emery Berger' <emery@cs.umass.edu>
Cc: 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, 'Andrew Morton' <akpm@osdl.org>, 'Matthew Hertz' <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: Rohit Seth [mailto:rohit.seth@intel.com]
> Sent: Tuesday, November 22, 2005 9:30 PM
> To: Emery Berger
> Cc: Rik van Riel; Yi Feng; linux-mm@kvack.org; Andrew Morton; Matthew
> Hertz
> Subject: RE: [patch] vmsig: notify user applications of virtual
> memoryevents via real-time signals
> 
> On Tue, 2005-11-22 at 13:53 -0800, Emery Berger wrote:
> > > That seems pretty high overhead.  I wonder if it wouldn't work
> > > similarly well for the kernel to simply notify the registrered
> > > apps that memory is running low and they should garbage collect
> > > _something_, without caring which pages.
> >

The kernel overhead is low. The only space overhead is the rmap's we keep
for swapped-out pages - that's 8 bytes per swapped-out page plus the
associated radix tree structures we use for lookup. For time overhead, there
won't be any if the kernel is not swapping at all. If the kernel is
swapping, then we have to look at the rmap's of the involved pages and find
the process(es) to notify. However, this overhead is well justified because
when the system is swapping, the CPU is often under-utilized anyway.

> > Actually, it's quite important that the application know exactly which
> > page is being evicted, in order that it be "bookmarked". We found that
> > this particular aspect of the garbage collection algorithm was crucial
> > (it's in the paper).
> >
> Seems like a good idea for the notifications.
> 
> But for it to be useful for low memory conditions, I think it will
> better if kernel knew (at possibly direct reclaim time) to swap out the
> specific pages...so as to make it more cooperative between user and
> kernel.  If kernel has to first notify user app (and possibly thousands
> of them) that it is looking for free pages then it will probably be too
> late or too expensive before an application actually completes the
> operation of freeing the pages.
> 

We notify the user application of the impending eviction of a page before
the page is actually swapped out. We keep a boundary in the inactive list,
once a page slips behind the boundary and falls toward the end of the list,
we notify the user applications that this page is likely to be swapped out
soon. We made this boundary an adjustable parameter in /proc. 

When the application receives this notification and starts to process this
page, this page will stay in core (possibly for a fairly long time) because
it's been touched again. That's why we also added madvise(MADV_RELINQUISH)
to explicitly send the page to swap after the processing.


Yi Feng


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
