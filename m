Date: Fri, 21 Jan 2000 02:12:46 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001210109141.3969-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001210152350.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:
> On Thu, 20 Jan 2000, Rik van Riel wrote:
> >On Thu, 20 Jan 2000, Andrea Arcangeli wrote:
> >
> >> There's a limit of max swap request, after that a wait_on_page
> >> will trigger I/O. So you'll only decrease performance by doing so
> >> as far I can tell.
> >
> >Not really. We want to get the I/O done and we don't want
> >to wait until the queue fills up.
> 
> The bank gives us 32 pages of credit. We don't need to get the I/O
> on them. We have a credit that we can use to optimze the I/O.

We must clean up those 32 pages because we also use them
for swapin readaround.

> >> > 			tsk->state = TASK_INTERRUPTIBLE;
> >> >-			schedule_timeout(10*HZ);
> >> >+			schedule_timeout(HZ);
> >> 
> >> I used 10 sec because if you run oom into kswapd it means you
> >> can't hardly do anything within kswapd in the next 10 seconds.
> >
> >OOM is not the normal state the system is in. You really want
> 
> And infact such schedule_timeout(10*HZ) will happen _only_ when
> you are OOM.

Hmmm, you're right. It's even worse than I thought...

Once we've reached free_pages.high, kswapd will sleep
and not wake up again until we've reached an emergency
situation. And when we are in an even worse emergency
kswapd will bloody SLEEP for 10 seconds!

How much more braindead can it get?
I'll make a new version of the patch
in a moment...

> >kswapd to do some work in the background (allowing user programs
> >to allocate their bits of memory without stalling).
> 
> This should be accomplished by a pre-wakeup once the high
> watermark triggers. The HZ polling that is just doing is only for
> atomic allocations. To parallelize memory freeing a polling with
> HZ frequency is too slow.

We want kswapd to free memory before we reach an emergency
situation. That is, if nr_free_pages < freepages.high,
kswapd should free a few pages. We should check that every
second or so...

> >> If instead atomic allocations caused oom and kswapd failed then
> >> you should give up for some time as well since you know all memory
> >> is not freeable and so only a __free_pages will release memory.
> >
> >In the OOM case we'll have to kill a process. Stalling the
> >system forever is not a solution.
> 
> The system is not stalled. atomic stuff that doesn't need to alloc
> memory will continue to run. It will then complete and release
> memory later.

You hope. And even if it does, that's no excuse for stopping
kswapd for such a long time. We need kswapd to continue
background scanning because the `OOM' might just as well be
caused by our inability to unmap process pages that are in
heavy use...

> >> > 	wake_up_interruptible(&kswapd_wait);
> >> >-	if (gfp_mask & __GFP_WAIT)
> >> >+	if ((gfp_mask & __GFP_WAIT) && (nr_free_pages < (freepages.low - 4)))
> >> > 		retval = do_try_to_free_pages(gfp_mask);
> >> 
> >> -4 make no sense as ".low" could be as well set to 3 and
> >> theorically the system should remains stable.
> >
> >It does make sense in reality. Please read the explanation
> >I sent with the patch. I agree that somewhere halfway
> >freepages.low and freepages.min would be better, but there
> >is no need to complicate the calculation...
> 
> The calc is a linear scale 1/3 2/3 3/3. The difference between 512
> and 508 is zero in RL.

It's not about that. The 4 extra pages allow us to let the
process continue _immediately_ to let kswapd handle the dirty
work later on.

This is a Good Thing(tm) in a lot of situations since it
allows us to defer the page freeing until after we pushed
that HTML document out the door (do the page freeing in
what would otherwise have been idle time).

> >If kswapd can keep up, there's no need at all to slow down
> >processes, not even hogs. If kswapd can't keep up then we'll
> 
> If you don't want to slow down not-hogs-processes, you must make
> sure that who is allocating memory will block. If kswapd will be
> the only blocking the system will trash because the hog will
> continue to run.

`Who is allocating memory' is _not_ always the memory hog.
If there's a memory hog in the system, smaller (often
sleeping, interactive) processes will be swapped out. The
hog is using its memory (otherwise it wouldn't be considered
a hog) so it will have less of a chance of being swapped out.

Your idea will punish the wrong processes!

> >start stalling processes (just 5 allocations further away,
> >_and_ kswapd will have been started by that time and have had
> >the time to do something).
> 
> That's not a matter of swapout but of shrink_mmap. See my previous
> point about a pre-wakeup when the high watermark triggers. When
> swap is involved instead kswapd won't help anymore IMHO.

A shrink_mmap() will cost time (especially on 2.2), you want
to do that _later_, when the system is idle again.
FYI, non-idle systems are in the minority by far.

> >I consider the absense of the third boundary a HUGE bug
> >in current 2.2 VM. You need three boundaries:
> >
> >- min:  below this boundary only ATOMIC (and GFP_HIGH?)
> >        allocations can be done
> >- low:  below this boundary we start swapping agressively
> >- high: below this boundary we start background swapping
> >        (once a second, without impact on processes), above
> >        this boundary we stop swapping
> >
> >Current (2-border) code makes for bursty swap behaviour,
> >poor handling of kernel allocations (see the complaints
> >Alan got about systems which ran OOM on atomic allocations).
> 
> I missed Alan problems (probably they are hided by the l-k heavy
> traffic).

Systems ran out of memory for network buffers. This is
because kswapd isn't woken up early enough (pre-scanning
pages in the background _will_ make it easier to free
something in an emergency too, we'll have scanned memory
more often and have unmapped/cleaned more pages).

> high is just implemented in your way. The once a second is not
> enough for RL, you need a pre-wakeup if you want to take try to
> pre-free memory. And the pre-wakeup won't help in the swap case.

The pre-wakeup is triggered in part by the `-4' thing
and partly disfunctional because kswapd in 2.2 is more
braindead than I thought before :(

> the need of low and min make no sense to me. You may be more happy
> to know that all three freepages values in /proc are used for
> something but for your machine it will make no differences. Micro
> tuning make no sense to me. Only tuning that make differences in
> RL make sense to me.

The `micro tuning' _does_ make sense in real life. When
there are only a few allocations/second, kswapd can free
memory in the background, in idle time. This allows all
allocations to continue without stalling.

> >There is a good reason why there is a difference between
> >background swapping and agressive swapping, why there is
> >a separate swapout daemon, etc...
> 
> The separate swapout daemon is there only for allowing the system
> to free cache and userspace memory for atomic allocations. It has
> nothing to do with aggressive or not aggressive swapping.

Yes it has. It is clearly visible that it works that
way and the use of idle time for freeing helps for a
lot of types of system load.

> The only difference between high and low prio allocation is that
> high prio allocation are not triggered by an userspace action.
> Thus they'd better complete trying to allocate memory even if we
> are low on memory. low prio allocation are triggered by userspace
> so we want to fail ASAP if userspace triggered an oom. It has
> nothing to do with performance and it has not to do with the
> selection if somebody should stall or not.

True in a theoretical way. In practice `fast failing'
and `we can wait a little longer to see if things clear
up' are equal. So are `this must succeed' and `don't
hang around, continue'.

> If you are planning to change the current semantics of the GFP_*
> variables please work on 2.3.x only.

You have silently changed the semantics of various
things in the VM subsystem in 2.2. I'd like to
change it back to something that works.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
