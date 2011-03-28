Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 584C38D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 22:48:10 -0400 (EDT)
Date: Mon, 28 Mar 2011 10:44:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110328024445.GA11816@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110325134411.GA8645@localhost>
 <20110325230544.GD26932@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110325230544.GD26932@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Jan,

On Sat, Mar 26, 2011 at 07:05:44AM +0800, Jan Kara wrote:
>   Hello Fengguang,
> 
> On Fri 25-03-11 21:44:11, Wu Fengguang wrote:
> > On Wed, Mar 23, 2011 at 05:43:14AM +0800, Jan Kara wrote:
> > >   Hello Fengguang,
> > > 
> > > On Fri 18-03-11 22:30:01, Wu Fengguang wrote:
> > > > On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> > > > > 
> > > > >   Hello,
> > > > > 
> > > > >   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> > > > > is alternative approach to Fengguang's patches - much simpler I believe (only
> > > > > 300 lines added) - but obviously I does not provide so sophisticated control.
> > > > 
> > > > Well, it may be too early to claim "simplicity" as an advantage, until
> > > > you achieve the following performance/feature comparability (most of
> > > > them are not optional ones). AFAICS this work is kind of heavy lifting
> > > > that will consume a lot of time and attention. You'd better find some
> > > > more fundamental needs before go on the reworking.
> > > > 
> > > > (1)  latency
> > > > (2)  fairness
> > > > (3)  smoothness
> > > > (4)  scalability
> > > > (5)  per-task IO controller
> > > > (6)  per-cgroup IO controller (TBD)
> > > > (7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
> > > > (8)  think time compensation
> > > > (9)  backed by both theory and tests
> > > > (10) adapt pause time up on 100+ dirtiers
> > > > (11) adapt pause time down on low dirty pages 
> > > > (12) adapt to new dirty threshold/goal
> > > > (13) safeguard against dirty exceeding
> > > > (14) safeguard against device queue underflow
> > >   I think this is a misunderstanding of my goals ;). My main goal is to
> > > explore, how far we can get with a relatively simple approach to IO-less
> > > balance_dirty_pages(). I guess what I have is better than the current
> > > balance_dirty_pages() but it sure does not even try to provide all the
> > > features you try to provide.
> > 
> > OK.
> > 
> > > I'm thinking about tweaking ratelimiting logic to reduce latencies in some
> > > tests, possibly add compensation when we waited for too long in
> > > balance_dirty_pages() (e.g. because of bumpy IO completion) but that's
> > > about it...
> > > 
> > > Basically I do this so that we can compare and decide whether what my
> > > simple approach offers is OK or whether we want some more complex solution
> > > like your patches...
> > 
> > Yeah, now both results are on the website. Let's see whether they are
> > acceptable for others.
>   Yes. BTW, I think we'll discuss this at LSF so it would be beneficial if
> we both prepared a fairly short explanation of our algorithm and some
> summary of the measured results. I think it would be good to keep each of
> us below 5 minutes so that we don't bore the audience - people will ask for
> details where they are interested... What do you think?

That looks good, however I'm not able to attend LSF this year, would
you help show my slides?

> I'll try to run also your patches on my setup to see how they work :) V6
> from your website is the latest version, isn't it?

Thank you. You can run 
http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=shortlog;h=refs/heads/dirty-throttling-v6
or 
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/dirty-throttling-v6-2.6.38-rc6.patch
whatever convenient for you.

If you are ready with v3, I can also help test it out and do some
comparison on the results.

> > > > > The basic idea (implemented in the third patch) is that processes throttled
> > > > > in balance_dirty_pages() wait for enough IO to complete. The waiting is
> > > > > implemented as follows: Whenever we decide to throttle a task in
> > > > > balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> > > > > against that bdi and goes to sleep waiting to receive specified amount of page
> > > > > IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
> > > > > autotuned based on observed IO rate), accumulated page IO completions are
> > > > > distributed equally among waiting tasks.
> > > > > 
> > > > > This waiting scheme has been chosen so that waiting time in
> > > > > balance_dirty_pages() is proportional to
> > > > >   number_waited_pages * number_of_waiters.
> > > > > In particular it does not depend on the total number of pages being waited for,
> > > > > thus providing possibly a fairer results.
> > > > 
> > > > When there comes no IO completion in 1 second (normal in NFS), the
> > > > tasks will all get stuck. It is fixable based on your v2 code base
> > > > (detailed below), however will likely bring the same level of
> > > > complexity as the base bandwidth solution.
> > >   I have some plans how to account for bumpy IO completion when we wait for
> > > a long time and then get completion of much more IO than we actually need.
> > > But in case where processes use all the bandwidth and the latency of the
> > > device is high, sure they take the penalty and have to wait for a long time
> > > in balance_dirty_pages().
> > 
> > No, I don't think it's good to block for long time in
> > balance_dirty_pages(). This seems to be our biggest branch point.
>   I agree we should not block for several seconds under normal load but
> when something insane like 1000 dds is running, I don't think it's a big
> problem :)

I don't think so. The client does not care whether the server is
accepting files from 1000+ clients and its writeback algorithm does
not scale well beyond that point; it will simply notice its upload
goes slow and paused from time to time, which is rather annoying.

> And actually the NFS traces you pointed to originally seem to be different
> problem, in fact not directly related to what balance_dirty_pages() does...
> And with local filesystem the results seem to be reasonable (although there
> are some longer sleeps in your JBOD measurements I don't understand yet).

Yeah the NFS case can be improved on the FS side (for now you may just
reuse my NFS patches and focus on other generic improvements).

The JBOD issue is also beyond my understanding.

Note that XFS will also see one big IO completion per 0.5-1 seconds,
when we are to increase the write chunk size from the current 4MB to
near the bdi's write bandwidth. As illustrated by this graph:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-1dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-22-58/global_dirtied_written-500.png

> > > > > The results for different bandwidths fio load is interesting. There are 8
> > > > > threads dirtying pages at 1,2,4,..,128 MB/s rate. Due to different task
> > > > > bdi dirty limits, what happens is that three most aggresive tasks get
> > > > > throttled so they end up at bandwidths 24, 26, and 30 MB/s and the lighter
> > > > > dirtiers run unthrottled.
> > > > 
> > > > The base bandwidth based throttling can do better and provide almost
> > > > perfect fairness, because all tasks writing to one bdi derive their
> > > > own throttle bandwidth based on the same per-bdi base bandwidth. So
> > > > the heavier dirtiers will converge to equal dirty rate and weight.
> > >   So what do you consider a perfect fairness in this case and are you sure
> > > it is desirable? I was thinking about this and I'm not sure...
> > 
> > Perfect fairness could be 1, 2, 4, 8, N, N, N MB/s, where
> > 
> >         N = (write_bandwidth - 1 - 2 - 4 - 8) / 3.
> > 
> > I guess its usefulness is largely depending on the user space
> > applications.  Most of them should not be sensible to it.
>   I see, that makes some sense although it makes it advantageous to split
> heavy dirtier task into two less heavy dirtiers which is a bit strange. But
> as you say, precise results here probably do not matter much.

Right.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
