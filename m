Date: Mon, 27 Mar 2000 08:14:34 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: kswapd
In-Reply-To: <200003270800.AAA65612@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003270807260.1745-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: riel@nl.linux.org, Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Mon, 27 Mar 2000, Kanoj Sarcar wrote:
> 
> This is my reasoning: Rik's patch makes it so that before kswapd 
> undertakes heavy weight work, it yields the cpu ... then it checks
> whether it has to do the work (via zone_wake_kswapd). This is the
> only difference over pre3.

No, there's another difference: pre3 will loop forever, even if there is
nothing to do - until something comes up that needs scheduling. Basically,
the pre3 loop boils down to

	do {
		/* not interesting */
	} while (!tsk->need_resched);

when there is enough memory.

Which obviously causes excessive CPU to be wasted.

NOTE! The "obviously" is a bit strong. What happens is that kswapd is only
woken up when needed, so most of the time it is sleeping. It's only when
it is woken up and when it has done its work when the loop turns into a
CPU-burner, but it can easily mean that kswapd will just spend CPU time
for no good reason until its time-slice is exhausted.

So think of the bug as "kswapd will waste the final part of its timeslice
doing nothing useful".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
