Date: Tue, 19 Feb 2008 09:00:08 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080219090008.bb6cbe2f.pj@sgi.com>
In-Reply-To: <20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<20080217084906.e1990b11.pj@sgi.com>
	<20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Kosaki-san wrote:
> Thank you for wonderful interestings comment.

You're most welcome.  The pleasure is all mine.

> you think kill the process just after swap, right?
> but unfortunately, almost user hope receive notification before swap ;-)
> because avoid swap.

There is not much my customers HPC jobs can do with notification before
swap.  Their jobs either have the main memory they need to perform the
requested calculations with the desired performance, or their job is
useless and should be killed.  Unlike the applications you describe,
my customers jobs have no way, once running, to adapt to less memory.
They can only adapt to less memory by being restarted with a different
set of resource requests to the job scheduler (the application that
manages job requests, assigns them CPU, memory and other resources,
and monitors, starts, stops and pauses jobs.)

The primary difficulty my HPC customers have is killing such jobs fast
enough, before a bad job (one that attempts to use more memory than it
signed up for) can harm the performance of other users and the rest of
the system.

I don't mind if a pages are slowly or occassionally written to swap;
but as soon as the task wants to reclaim big chunks of memory by
writing thousands of pages at once to swap, it must die, and die
before it can queue more than a handful of those pages to the swapper.

> but embedded people strongly dislike bloat code size.
> I think they never turn on CPUSET.
> 
> I hope mem_notify works fine without CPUSET.

Yes - understood and agreed - as I guessed, cpusets are not configured
in embedded systems.

> Please don't think I reject your idea.
> your proposal is large different of past our discussion

Yes - I agree that my ideas were quite different.  Please don't
hesitate to reject every one of them, like a Samurai slicing through
air with his favorite sword <grin>.

> Disagreed. that [my direct reclaim hook at mapping->a_ops->writepage()]
> is too late.

For your work, yes that hook is too late.  Agreed.

Depending on what we're trying to do:
 1) warn applications of swap coming soon (your case),
 2) show how close we are to swapping,
 3) show how much swap has happened already,
 4) kill instantly if try to swap (my hpc case),
 5) measure file i/o caused by memory pressure, or
 6) perhaps other goals,
we will need to hook different places in the kernel.

It may well be that your hooks for embedded are simply in different
places than my hooks for HPC.  If so, that's fine.

I look forward to your further thoughts.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
