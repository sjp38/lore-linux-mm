Date: Tue, 21 Mar 2000 02:47:31 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Extensions to mincore
Message-ID: <20000321024731.C4271@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>; from Chuck Lever on Mon, Mar 20, 2000 at 02:09:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > [Aside: is there the possibility to have mincore return the "!accessed"
> > and "!dirty" bits of each page, perhaps as bits 1 and 2 of the returned
> > bytes?  I can imagine a bunch of garbage collection algorithms that
> > could make good use of those bits.  Currently some GC systems mprotect()
> > regions and unprotect them on SEGV -- simply reading the !dirty status
> > would obviously be much simpler and faster.]
> 
> you could add that; the question is how to do it while not breaking
> applications that do this:
> 
> if (!byte) {
>    page not present
> }
> 
> rather than checking the LSB specifically.

The comment says:

    The status is returned in a vector of bytes.  The least significant
    bit of each byte is 1 if the referenced page is in memory, otherwise
    it is zero.

Solaris (SunOS 5.6) extends this with:

     The settings of other bits in each character are undefined and may
     contain other information in future implementations.

So I think you're quite safe extending the information.

> i think using "dirty" instead of "!dirty" would help.

In a GC system you're looking to skip pages which are "definitely
clean".  "Definitely dirty" isn't very interesting, however "maybe
dirty" is.

Given that the default value from mincore is 0 (say for an older
kernel), it should mean "maybe dirty".  Hence !dirty.

> the "accessed" bit is only used by the shrink_mmap logic to "time out"
> a page as memory gets short; i'm not sure that's a semantic that is
> useful to a user-level garbarge collector?  and it probably isn't very
> portable.

For a garbage collector that can move objects, it has uses in suggesting
how to efficiently repack objects, to reduce the resident set size of
the process.

There are also a number of user-space paging systems (e.g. one was once
proposed for the special relocated .exe mappings in Wine), which would
benefit from this information the same was as the kernel does.

You could indicate that these values are "exact" by another bit which is
always set if you are able to provide dirty and accessed bits.  Then
the polarity doesn't really matter.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
