Date: Thu, 9 May 2002 10:30:23 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [RFC][PATCH] IO wait accounting
In-Reply-To: <Pine.LNX.4.44L.0205082153010.32261-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.3.96.1020509095715.7914B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2002, Rik van Riel wrote:

> the following patch implements simple IO wait accounting, with the
> following two oddities:
> 
> 1) only page fault IO is currently counted
> 2) while idle, a tick can be counted as both system time
>    and iowait time, hence IO wait time is not substracted
>    from idle time (also to ensure backwards compatability
>    with procps)
> 
> I'm doubting whether or not to change these two issues and if
> they should be changed, how should they behave instead ?

I'm delighted that someone else is looking at this as well. I've been
trying to do a similar thing to determine how well tuning disks, using the
vm of the moment, and various RAID configs perform.

I have been simply counting WaitIO ticks when there is (a) no runable
process in the system, and (b) at least one process blocked for disk i/o,
either page or program. And instead of presenting it properly I just
stuffed it in a variable and read it from kmem.

While I don't defend my data presentation (I didn't want to break any
/proc-reading tools) what I was trying to measure is how often would the
system run faster if it had faster disk. And unfortunately the answer was
that with my typical load disk is not a problem if the system has enough
memory. There is always something which wants the CPU. However, disk speed
does make a big change in responsiveness, even though the CPU stays busy. 

I think what is useful is both what I measured, idle time due to disk, and
also some responsiveness value, which would be the sum of wait time for
all processes waiting i/o (ticks times processes waiting). You can
consider if two processes waiting for 50ms is more or less desirable than
one waiting 100ms, of course.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
