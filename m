Date: Thu, 21 Dec 2000 19:20:53 -0800 (PST)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200012220320.eBM3Kr605128@apollo.backplane.com>
Subject: Re: Interesting item came up while working on FreeBSD's pageout
 daemon
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Daniel Phillips <phillips@innominate.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

    Right.  I am going to add another addendum... let me give a little
    background first.  I've been testing the FBsd VM system with two
    extremes... on one extreme is Yahoo which tends to wind up running
    servers which collect a huge number of dirty pages that need to be
    flushed, but have lots of disk bandwidth available to flush them.
    The other extreme is a heavily loaded newsreader box which operate 
    under extreme memory pressure but has mostly clean pages.   Heavy
    load in this case means 400-600 newsreader processes on a 512MB box
    eating around 8MB/sec in new memory, but which has mostly clean pages.

    My original solution for Yahoo was to treat clean and dirty pages at
    the head of the inactive queue the same... that is, flush dirty pages
    as they were encountered in the inactive queue and free clean pages,
    with no limit on dirty page flushes.  This worked great for yahoo,
    but failed utterly with the poor news machines.  News machines that
    were running at a load of 1-2 were suddenly running at lods of 50-150.
    i.e. they began to thrash and get really sludgy.

    It took me a few days to figure out what was going on, because the
    stats from the news machines showed the pageout daemon having no
    problems... it was finding around 10,000 clean pages and 200-400
    dirty pages per pass, and flushing the 200-400 dirty pages.  That's
    a 25:1 clean:dirty ratio.

    Well, it turns out that the flushing of 200-400 dirty pages per pageout
    pass was responsible for the load blowups.  The machines had already
    been running at 100% disk load, you may recall.  Adding the additional
    write load, even at 25:1, slowed the drives down enough that suddenly
    many of the newsreader processes were blocking on disk I/O.  Hence the
    load shot through the roof.

    I tried to 'fix' the problem by saying "well, ok, so we won't flush
    dirty pages immediately, we will give them another runaround in the
    inactive queue before we flush them".  This worked for medium loads and
    I thought I was done, so I wrote my first summary message to Rik and
    Linus describing the problem and solution.

    --

    But the story continues.  It turns out that that has NOT fixed the
    problem.  The number of dirty pages being flushed went down, but
    not enough.  Newsreader machine loads still ran in the 50-100 range.
    At this point we really are talking about truely idle-but-dirty pages.
    No matter, the machines were still blowing up.

    So, to make a long story even longer, after further experiments I
    determined that it was the write-load itself blowin up the machines.
    Never mind what they were writing ... the simple *act* of writing
    anything made the HD's much less efficient then under a read-only load.
    Even limiting the number of pages flushed to a reasonable sounding
    number like 64 didn't solve the problem... the load still hovered around
    20.

    The patch I currently have under test which solves the problem is a
    combination of what I had in 4.2-release, which limited the dirty page
    flushing to 32 pages per pass, and what I have in 4.2-stable which
    has no limit.  The new patch basically does this:

	(remember pageout passes always free/flush pages from the inactive
	queue, never the active queue!)

	* Run a pageout pass with a dirty page flushing limit of 32 plus
	  give dirty inactive pages a second go-around in the inactive
	  queue.

	* If the pass succeeds we are done.

	* If the pass cannot free up enough pages (i.e. the machine happens
	  to have a huge number of dirty pages sitting around, aka the Yahoo
	  scenario), then take a second pass immediately and do not have any
	  limit whatsoever on dirty page flushes in the second pass.

    *THIS* appears to work for both extremes.  It's what I'm going to be
    committing in the next few days to FreeBSD.  BTW, years ago John Dyson 
    theorized that disk writing could have this effect on read efficiency,
    which is why FBsd originally had a 32 page dirty flush limit per pass.
    Now it all makes sense, and I've got proof that it's still a problem
    with modern systems.

						    -Matt


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
