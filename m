Date: Wed, 4 Oct 2000 18:08:53 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200010050108.SAA83892@apollo.backplane.com>
Subject: Re: TODO list for new VM  (oct 2000)
References: <Pine.LNX.4.21.0010021531360.22539-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.redhat.com, linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

    My experience with FreeBSD's asynchronous paging
    is that you have to carefully limit the number of
    I/O's you queue at once.  Or, more specifically, you
    have to limit the seeking load the async pageouts
    place on the system.

    The performance curve from the point of user processes 
    in the system looks like a bell, while the paging
    performance looks like a log curve (increased performance
    with diminishing returns)... if you queue too few
    pages (degenerate into synchronous paging), you have low
    paging performance and high user process performance,
    but you can't clean pages fast enough in a heavily loaded
    system.  If you queue too many pages at once, you have
    high paging performance (but with diminishing returns)
    and low user process performance due to the seeking
    load you've placed on the disk.  Excessive seeking
    from pageouts will ruin the disk's performance from
    the point of view of other processes in the system.

    FreeBSD has a sysctl variable called vm.max_page_launder
    which limits the number of pages the pageout daemon
    will queue to I/O at once.  The default is 32.   Numbers
    between 16 and 32 were found to fit the sweet spot of
    the curve the best.  Numbers lower then 16 reduced
    system performance because potentially contiguous pageouts
    would get split (causing more seeking rather then less when
    mixed with I/O initiated from user processes), and numbers
    higher then 32 reduced user process performance due to the
    additional seeking from the queued pageouts.

    The sysadmin can adjust the value to effectively give
    paging more or less priority.  A smaller number reduces
    paging performance but increasing system performance
    for other processes (though anything less then 4 will
    reduce performance for everyone).  A higher number
    increases paging performance at the cost of system
    performance for other processes.  Virtually all FreeBSD
    installations that I know about leave the sysctl variable
    alone.

    Note that the performance bell holds true whether you
    sort disk requests or not, the whole bell simply moves up
    or down on the graph.

    There are a number of things that can be done to mitigate
    the seeking issue, which I discussed with Rik a few months
    ago.  The jist of it, though, is that there is a trade-off
    between page-in and page-out performance based on how you
    try to cluster swap allocation.  FreeBSD clusters swap
    allocations to optimize page-out performance at the cost
    of page-in performance and that seems to work very
    well under heavy system loads.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
