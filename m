Date: Wed, 10 May 2000 22:10:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <yttog6doq1m.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005102204370.1155-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "James H. Cloos Jr." <cloos@jhcloos.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 11 May 2000, Juan J. Quintela wrote:
>
>         I have done my normal mmap002 test and this goes slower than
> ever, it takes something like 3m50 seconds to complete, (pre7-8 2m50,
> andrea classzone 2m8, and 2.2.15 1m55 for reference).

Note that the mmap002 test is avery bad performance test.

Why?

Because it's a classic "walk a large array in order" test, which means
that the worst possible order to page things out in is LRU.

So toreally speed up mmap002, the best approach is to try to be as non-LRU
as possible, which is obviously the wrong thing to do in real life. So in
that sense optimizing mmap002 is a _bad_ thing.

What I found interesting was how the non-waiting version seemed to have
the actual _disk_ throughput a lot higher. That's much harder to measure,
and I don't have good numbers for it, the best I can say is that it causes
my ncr SCSI controller to complain about too deep queueing depths, which
is a sure sign that we're driving the IO layer hard. Which is a good
thingwhen you measure how efficiently you page things in and out..

But don't look at wall-clock times for mmap002. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
