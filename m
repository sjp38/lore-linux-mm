Date: Sun, 21 Dec 2003 06:15:45 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031221141545.GK22443@holomorphy.com>
References: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Roger Luethi <rl@hellgate.ch>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 20, 2003 at 09:33:34PM -0500, Rik van Riel wrote:
> I've got an idea for a load control / memory scheduling
> policy that is inspired by the following requirements
> and data points:
> 1) wli pointed out that one of the better performing load
>    control mechanisms is one that swaps out the SMALLEST
>    process (easy to swap out, removes one process worth of
>    IO load from the system)
> 2) small processes, like root shells, should not be
>    swapped out for a long time, but should be swapped
>    back in relatively quickly
> 3) because swapping big processes in or out is a lot of
>    work, we should do that infrequently
> 4) however, once a big process is swapped out, it should
>    stay out for a long time because it greatly reduces
>    the amount of memory the system needs

I like this as it gives us a starting point for tuning and algorithmic
adjustments with a precedent. Some synthesis appears to be required for
queueing due to the fact it's not possible to integrate this with the
cpu scheduler (because threads create an essential distinction between
user execution contexts and process address spaces not present in older
kernels).

One case I would be very careful about is that of a single userspace
process meeting the demotion criteria remaining in-core. We might need
init=foo mem=bar to get into a situation of that kind with any certainty.
I've not seen this discussed anywhere. Maybe it's irrelevant.


On Sat, Dec 20, 2003 at 09:33:34PM -0500, Rik van Riel wrote:
> The swapout selection loop would be as follows:
> - calculate (rss / resident time) for every process
> - swap out the process where this value is lowest
> - remember the rss and swapout time in the task struct
> At swapin time we can do the opposite, looking at
> every process in the swapped out queue and waking up
> the process where (swap_rss / now - swap_time) is
> the smallest.
> What do you think ?

Tracking the integral of the RSS may be useful if you're after the
mean RSS over a time interval.

Also, a threshold (called K_0 in my sources) for minimum RSS before
a process becomes a candidate for eviction (or its mappings candidates
for page replacement) again was typical of policies I've seen described.
Processes with RSS's less than K_0 were called "loading tasks" there.
This seemed to be used mostly in conjunction with process-local
replacement policies.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
