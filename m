Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id BAA04750
	for <linux-mm@kvack.org>; Sun, 4 Jun 2000 01:40:23 +0100
Subject: Long time spent in swap_out &co
From: "John Fremlin" <vii@penguinpowered.com>
Date: 04 Jun 2000 01:40:19 +0100
Message-ID: <m2snuuz3bg.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I had a look at vmscan.c and noticed that the swap_out process
selection procedure looks suboptimal (this is 2.4.0-test1-ac7 with
Rik's mm patch rev 3). If I make a mistake, please correct it gently
(I am a clueless newbie).

        (a) The entire list of processes is scanned through each time
        at least once. (Slow, and holding a lock.)

        (b) The biggest rss is chosen. Admittedly the swap_cnt
        heuristics help a bit but it means that a large process that
        is on touching its pages will keep distracting attention from
        more smaller processes that may or may not be more wasteful.

Suggestions

        Guess a reasonable minimum size process to look at (say, twice
        the average of the first couple of size_cnts) so the entire
        list isn't scanned through so often and different processes
        will be targeted first when all the size_cnts are reset.

        Are we just dealing with the running processes? (If not, why
        not first try to swap out the sleeping ones?)

        Or, target processes with fewest page faults.

        [I'm basically unconvinced of the idea of size_cnt]

Hard evidence

        I set up a lot of processes to run, more than my box can
        handle and a large proportion of SysReq-Ps had EIPs in
        swap_out. (Waiting for lock? Not checked).

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
