Date: Mon, 22 Dec 2003 00:55:42 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031221235541.GA22896@k3.hellgate.ch>
References: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Dec 2003 21:33:34 -0500, Rik van Riel wrote:
> I've got an idea for a load control / memory scheduling
> policy that is inspired by the following requirements
> and data points:

It is my understanding that wli is interested in load control because
he knows this Russian guy who puts an insane load on his box. Do you
have friends in Russia as well? Isn't there _anybody_ interested in
the fact that 2.6 performance completely breaks down under a light
overload where 2.4 doesn't and where load control would be more of a
problem than a solution? Heck, I even showed that you don't have to give
up physical scanning to get most of the pageout performance back! Oh,
and btw: Did I overlook this problem on akpm's should/must fix lists,
or is it missing for a reason?

I can't help but think of the man who looks for his keys not where he
lost them but near the lamp post, where the light is. While I agree
that working on load control is a lot more fun, it is _pageout_ that
has been completely borked in 2.6 and there is no way in hell load
control can fix that. Load control trades latency for throughput and
makes sense for some situations after pageout tuning has been exhausted,
which is not true at all for Linux 2.6.

I hate to be a pest but I am still entirely unconvinced that load control
is what 2.6 needs at this point. Maybe I should make that ceterum censeo
a sig.

That said, here's my take:

> 1) wli pointed out that one of the better performing load
>    control mechanisms is one that swaps out the SMALLEST
>    process (easy to swap out, removes one process worth of
>    IO load from the system)

According to wli this strategy was 15% better than random selection in
terms of throughput / CPU usage. Those 15% may well be quite solid for
transaction based systems, but typical Linux systems and workloads are
different animals and it doesn't seem safe to rely on those numbers here.
Also, on modern servers/workstations with load control, latency will
become a much bigger problem than +/- 15% throughput could ever be.

Bottom line: We would have to benchmark various criteria anyway and
chosing the smallest process is arguably quite arbitrary. The best I
could say about it is that for all we know it's as good as any other
policy.

> 2) small processes, like root shells, should not be
>    swapped out for a long time, but should be swapped
>    back in relatively quickly
> 
> 3) because swapping big processes in or out is a lot of
>    work, we should do that infrequently
> 
> 4) however, once a big process is swapped out, it should
>    stay out for a long time because it greatly reduces
>    the amount of memory the system needs
> 
> The swapout selection loop would be as follows:
> - calculate (rss / resident time) for every process
> - swap out the process where this value is lowest
> - remember the rss and swapout time in the task struct
> 
> At swapin time we can do the opposite, looking at
> every process in the swapped out queue and waking up
> the process where (swap_rss / now - swap_time) is
> the smallest.

If I understand your description correctly, you'll probably stun sshd
early on, because it will have accrued an impressive resident time.
If the user starts a fat GUI administration tool to study/fix the load
problem, it will likely hit the sack as well and stay there for a long
time. IOW, you will help some users and quite possibly make things worse
for others.

Of course I don't claim your selection algorithm is any worse than mine,
but I doubt it is much better. It is hard to get right -- looks like
the OOM killer all over again.

As for the implementation: An overload situation that is grave enough
to make load control worthwhile should be a rare event. I didn't think
I could justify growing the task struct even further for that. So when
I wanted to save some state (like RSS at stunning time), I kept it in
local variables where the processes hit the wait queue. I didn't use
it for global comparisons like what you are suggesting, but even that
is possible with some extra effort. And at the time load control is
kicking in, we've got plenty of CPU cycles to spend on extra efforts.

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
