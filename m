Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA09363
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 17:54:18 -0500
Date: Mon, 4 Jan 1999 23:43:26 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <m0zxI6a-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990104232934.270D-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 1999, Alan Cox wrote:

> Its performance properties are very interesting however. They do seem to suggest
> kswapd should be more of a last resort. 

Steve said me now that the image test runs not fast as in arca-3 (the one
before inserting my new swap_out() smart weight code), but here there are
no dubits. My latest patch double performances under swap here and every
thing is _far_ more fluid (I tried only on 128Mbyte of RAM though). I go
to the cinema in the menatime and I tried again now with the same
results... 

Just to allow everyone to see the difference (and to tell me if eventually
I am missing something of magic ;) here is the bench I am using:

#include <stdio.h>
#include <time.h>

main()
{
	char *p[160];
	int i, j;
	int count;
	time_t start,stop;
	for (j=0; j<160; j++)
	{
		p[j] = (char *) malloc(1000000);
	}
	for (count=0;count<2000;count++)
	{
		start = time(NULL);
		for (j=0; j<160; j++)
		{
			for (i=0; i<1000000; i++)
				p[j][i] = 0;
		}
		stop = time(NULL);
		if (count)
			printf("elapsed %u\n", stop-start);
		fflush(stdout);
	}
}

The number 160 menas that the benchmark will tell you the time in sec it
takes to dirtify 160 mbyte of virtual memory in loop. It now runs in 54
sec (against 100 before) and I am writing this in the meantime without see
differences with an idle system (I couldn't open pine and sort some huge
folder without any kind of slowdown under the same conditions before). My
I/O is _slowww__ I have _everything_ in a IDE 6mbyte/sec disk and the seek
time is really a pain (note it's the HD that is slowww, I like IDE ;). 

I am going to revert everything except the new things that caused the
benchmark to double performances and the system to go far more fluid, to
arca-vm-3 (that it's reported to be the fastest vm out there by steve
under misc swapping usage (the image test)). I probably leave the
swap_out() smart weight code since it's really needed on low memory even
if it seems that the swapout weight is causing a bit of slowdown probably
because it's not tuned right now.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
