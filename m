Date: Fri, 21 Mar 2003 07:06:55 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.5.65-mm2
In-Reply-To: <5.2.0.9.2.20030320194530.01985440@pop.gmx.net>
Message-ID: <Pine.LNX.4.44.0303210659530.2406-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Steven Cole <elenstev@mesatop.com>, Ed Tomlinson <tomlins@cam.org>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2003, Mike Galbraith wrote:

> This is a side effect of Ingo's (nice!) latency change methinks.  When
> you have several cpu hogs running (dbench), and they are cleaning your
> cpu's clock by using their full bandwidth to attain maximum throughput,
> and they then break up their timeslice in order to provide you with more
> responsiveness, and then their _cumulative_ sleep time between (round
> robin!) cpu hard burns is added to their sleep_avg, [...]

actually, the round-robining for finer-grained timeslices should not
impact the sleep average at all, because the roundrobin is done while the
task is still _running_, ie. the sleep average does not get impacted.
Otherwise we'd have elevated priority of simple CPU-intensive
applications, which would be Bad.

The way the sleep-average is maintained is balanced very carefully in the
O(1) scheduler. There are three states a task can be in:

 - sleeping: the sleep average increases
 - running but not executing: the sleep average stagnates
 - executing on a CPU: the sleep average decreases

ie. in the roundrobin case the tasks will neither increase, nor decrease
their sleep average - they are in essence 'frozen'. The moment they get
scheduled on a CPU for execution, their sleep average starts to decrease
again. (and once they go to sleep, their sleep average increases.)

so whatever effect you are seeing, it must be something else.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
