Date: Thu, 17 May 2001 23:20:23 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105180620.f4I6KNd05878@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva> <200105161754.f4GHsCd73025@earth.backplane.com> <3B04BA0D.8E0CAB90@mindspring.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Terry Lambert <tlambert2@mindspring.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:I don't understand how either of those things could help
:but make overall performance worse.
:
:The problem is the program in question is seeking all
:over the place, potentially multiple times, in order
:to avoid building the table in memory itself.
:
:For many symbols, like "printf", it will hit the area
:of the library containing their addresses many, many
:times.
:
:The problem in this case is _truly_ that the program in
:question is _really_ trying to optimize its performance
:at the expense of other programs in the system.

    The linker is seeking randomly as a side effect of
    the linking algorithm.  It is not doing it on purpose to try
    to save memory.  Forcing the VM system to think it's 
    sequential causes the VM system to perform read-aheads,
    generally reducing the actual amount of physical seeking
    that must occur by increasing the size of the chunks
    read from disk.  Even if the linker's dataset is huge,
    increasing the chunk size is beneficial because linkers
    ultimately access the entire object file anyway.  Trying
    to save a few seeks is far more important then reading
    extra data and having to throw half of it away.

:The problem is what to do about this badly behaved program,
:so that the system itself doesn't spend unnecessary time
:undoing its evil, and so that other (well behaved) programs
:are not unfairly penalized.
:
:Cutler suggested a working set quota (first in VMS, later
:in NT) to deal with these programs.
:
:-- Terry

    The problem is not the resident set size, it's the
    seeking that the program is causing as a matter of
    course.  Be that as it may, the resident set size
    can be limited with the 'memoryuse' sysctl.  The system
    imposes the specified limit only when the memory
    subsystem is under pressure.

    You can also reduce the amount of random seeking the
    linker does by ordering the object modules within the
    library to forward-reference the dependancies.

					-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
