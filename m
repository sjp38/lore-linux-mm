Date: Mon, 22 Jul 2002 00:08:00 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: [PATCH 2/2] move slab pages to the lru, for 2.5.27
In-Reply-To: <20020721213131.GA919@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0207212340530.13407-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Jul 2002, William Lee Irwin III wrote:

> Can you test this to verify that reclamation is actually done? 

Looks like it is.  I have a script that does slocate, loads monstrous 
blank images into gimp, manipulates it to drive the machine to swap, 
performs a 'find' to test and make sure we haven't evicted slab pages too 
readily, loads some addn'l applications and performs a few dbench runs. 
The apps are killed in lifo order to see if the page aging works.  
Afterwards, the find is performed again to see if any of the slabs are 
still cached. 

vmstat is running through the entire test, and /proc/[mem,slab]info are 
saved very occasionally. 

I ran the test on 2.5.27-rmap and 2.5.27-rmap-slablru to test 
pte_chain reclaim and to see if the slablru patch causes measurable 
slowdowns due to more LRU list traffic.  It apparently doesn't:

Time to completion:
2.5.27:			203 sec
2.5.27-rmap: 		205 sec
2.5.27-rmap-slablru:	205 sec

Swapouts during test:
2.5.27: 		30092 kB
2.5.27-rmap: 		43520 kB
2.5.27-rmap-slablru:	40948 kB

Swapins during test:
2.5.27: 		13364 kB
2.5.27-rmap: 		8616 kB
2.5.27-rmap-slablru: 	8452 kB

Slab reclaim looks sane for the slablru kernel throughout the test.  In 
particular, here's the pte_chain pool entries through the test from 
/proc/slabinfo:

pte_chain          20061  21294      8   60   63    1
pte_chain          20061  21294      8   60   63    1
pte_chain          20822  24336      8   65   72    1
pte_chain          21563  24336      8   65   72    1
pte_chain          19921  23660      8   70   70    1
pte_chain          18501  23660      8   63   70    1
pte_chain          18483  22984      8   63   68    1


Not very dramatic in this example since this was a pretty mild load, but 
it does seem to work.

Craig Kulesa
Steward Obs.
Univ. of Arizona

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
