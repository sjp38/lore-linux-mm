Date: Fri, 26 May 2000 08:59:35 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005261559.IAA89969@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

:Hi,
:
:On Fri, May 26, 2000 at 04:31:29PM +0200, Jamie Lokier wrote:
:
:> You didn't mention it, but that leaves mremap.  This is a fiddly one!
:
:Yes, we know this.  :-)
:
:> mremaps that simply expand or shrink a segment are fine by themselves.
:> mremaps that move a segment are fine by themselves.
:
:No, they are not fine.  When you move a segment, you end up with pages
:which have the same offset but are now at a different VA.  What that 
:means is that you have no way of finding out, for a given physical page,
:what the VA of all of the mappings of that page may be.  That means that
:you have no way to find all of the ptes short of scanning all the vmas
:in order.
:
:--Stephen

    Basically you have two choices:  Either track all the mappings to an
    underlying object in such a way that you can locate all the 
    potential (object,index) -> (process,va) mappings, or you can
    track the PTE's themselves as FreeBSD does with its PV entry junk.

    I personally hate the PV entry junk in FreeBSD.  It's fast, but it has
    a lot of memory overhead.

    I would not be afraid of adding appropriate linked-list fields to your
    various tracking structures to be able to locate the potential mappings
    more easily, and I'll bet dollars to donoughts that you would be able
    to refine the scheme to make it just as fast as our PV entry scheme 
    but without the overhead.

    In anycase, locating the pte's would go like this:

	* physical page candidate

	* direct knowledge of (object,index) for physical page (any given 
	  physical page exists in just one VM object.  I'm using a FreeBSD
	  style VM object as a reference here).

	* scan mapping structures linked to the object for mappings that
	  cover (index).

	* Lookup the pte associated with each such mapping (the pte may or may
	  not exist in the actual page table, depending on whether it has 
	  been faulted or not, or overloaded by another VM object layer).

	* done (you are able to locate all the pte's associated with a physical 
	  page)

    In FreeBSD, locating the pte's goes like this:

	* physical page candidate

	* (direct knowledge of (object,index) for physical page, but FreeBSD
	  doesn't use it for this particular operation).

	* scan linked list of PV's based in physical page structure.

	* each PV represents a *mapped* pte.

	(Which is a lot faster and less stressful on the cache, but which
	also eats a truely disgusting amount of memory having to have a
	PV entry structure for each pte).

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
