Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA28027
	for <linux-mm@kvack.org>; Sun, 17 Jan 1999 18:57:09 -0500
Date: Mon, 18 Jan 1999 00:47:07 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990116160536.328A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990118001901.263A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Kalle Andersson <kalle@sslug.dk>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jan 1999, Andrea Arcangeli wrote:

> With the bug fixed it seems really rock solid. It would be interesting
> making performance comparison with kernels that are swapping out in
> swap_out() (e.g. clean pre7). I am not sure it's a win (but I'm sure it's

Even if rock solid my PG_dirty implementation is been a lose. This because
swapping out from shrink_mmap() was causing not ordered write to disk. So
even if the process userspace was ordered in the swap, it was async
written not-ordered. This was harming a _lot_ swapout performances... 
There's also the point that shrink_mmap() is so highly/default used that
stalling in it many times (if unlucky due many consecutive dirty swap
cache pages to sync to disk) was not the best. So I dropped the
shrink_mmap()-swapout idea completly. 

But I had new ideas that here has improved things a _lot_.

Steve could you try the image test over this new patch against pre7 clean?

Also you Kelle, could you try my new arca-vm-24 on your 16Mbyte machine? I
think that you'll be very happy ;).

Note, arca-vm-24 is tunable:

/proc/sys/vm/pager has 5 entry:

6       10       32      32      2048

The first is the lower priority that try_to_free_pages() uses. The most
this value is high, the lower will be the starting priority, and this will
result in more swapping. 6 is a rasonable value. If the system swap too
much even if not low on memory you could decrease this value to 4 for
example.

The second value is the max percentage of cache in the system that we take
even if we are very low on memory (the system should autobalance close to
that percentage after some time). The `cache' is intended as
cache+buffers.

The third is the number of pages we free every time a process try to
reclaim memory but when the system is low on memory. 32 pages at time is a
safe value.  Incresing this value will cause the process that get stuck
in the freeing memory path to stall for more time (so it could harm
iteractive performances).

The fourth is the cluster size on the swap space. pre7 set it to 512
pages, but I checked that it's a _lose_. 32 is/was a good value.

The fifth number is the number of pages that we allow to run async at the
same time (when the limit is reached we'll wait for I/O completation).
pre7 set this value to 32 but that value is a _bottleneck_ for some
rasonable fast system. Increasing too much this value could cause the
system to have too much page in fly to disk at one time and so it could
risk to go out of memory (if the freepages.min is too low, note I never
tried arca-mv-24 on verylow memory and I don't know if it's reproducible).
That never happens here and 2048 is something like infinite. But I am
running with freepages.min = 255 because I have 128Mbyte of RAM. So if
arca-vm-24 will kill random processes on your system (search for Out of
memory messages in `dmesg`) the first thing you should try is:

echo 6 10 32 32 32 >/proc/sys/vm/pager

this way you'll return to clean pre7 from this point of view.

begin 664 2.2.0-pre7-arca-VM-24.gz
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
+XOX/]0H@'H9Q````
`
end

Comments?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
