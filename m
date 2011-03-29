Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06C598D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:44:26 -0400 (EDT)
Date: Tue, 29 Mar 2011 09:44:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110329014422.GA6711@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110325134411.GA8645@localhost>
 <20110325230544.GD26932@quack.suse.cz>
 <20110328024445.GA11816@localhost>
 <20110328150815.GA7184@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328150815.GA7184@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 28, 2011 at 11:08:15PM +0800, Jan Kara wrote:
> On Mon 28-03-11 10:44:45, Wu Fengguang wrote:
> > Hi Jan,
> > 
> > On Sat, Mar 26, 2011 at 07:05:44AM +0800, Jan Kara wrote:
> > >   Hello Fengguang,
> > > 
> > > On Fri 25-03-11 21:44:11, Wu Fengguang wrote:
> > > > On Wed, Mar 23, 2011 at 05:43:14AM +0800, Jan Kara wrote:
> > > > >   Hello Fengguang,
> > > > > 
> > > > > On Fri 18-03-11 22:30:01, Wu Fengguang wrote:
> > > > > > On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> > > > > > > 
> > > > > > >   Hello,
> > > > > > > 
> > > > > > >   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> > > > > > > is alternative approach to Fengguang's patches - much simpler I believe (only
> > > > > > > 300 lines added) - but obviously I does not provide so sophisticated control.
> > > > > > 
> > > > > > Well, it may be too early to claim "simplicity" as an advantage, until
> > > > > > you achieve the following performance/feature comparability (most of
> > > > > > them are not optional ones). AFAICS this work is kind of heavy lifting
> > > > > > that will consume a lot of time and attention. You'd better find some
> > > > > > more fundamental needs before go on the reworking.
> > > > > > 
> > > > > > (1)  latency
> > > > > > (2)  fairness
> > > > > > (3)  smoothness
> > > > > > (4)  scalability
> > > > > > (5)  per-task IO controller
> > > > > > (6)  per-cgroup IO controller (TBD)
> > > > > > (7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
> > > > > > (8)  think time compensation
> > > > > > (9)  backed by both theory and tests
> > > > > > (10) adapt pause time up on 100+ dirtiers
> > > > > > (11) adapt pause time down on low dirty pages 
> > > > > > (12) adapt to new dirty threshold/goal
> > > > > > (13) safeguard against dirty exceeding
> > > > > > (14) safeguard against device queue underflow
> > > > >   I think this is a misunderstanding of my goals ;). My main goal is to
> > > > > explore, how far we can get with a relatively simple approach to IO-less
> > > > > balance_dirty_pages(). I guess what I have is better than the current
> > > > > balance_dirty_pages() but it sure does not even try to provide all the
> > > > > features you try to provide.
> > > > 
> > > > OK.
> > > > 
> > > > > I'm thinking about tweaking ratelimiting logic to reduce latencies in some
> > > > > tests, possibly add compensation when we waited for too long in
> > > > > balance_dirty_pages() (e.g. because of bumpy IO completion) but that's
> > > > > about it...
> > > > > 
> > > > > Basically I do this so that we can compare and decide whether what my
> > > > > simple approach offers is OK or whether we want some more complex solution
> > > > > like your patches...
> > > > 
> > > > Yeah, now both results are on the website. Let's see whether they are
> > > > acceptable for others.
> > >   Yes. BTW, I think we'll discuss this at LSF so it would be beneficial if
> > > we both prepared a fairly short explanation of our algorithm and some
> > > summary of the measured results. I think it would be good to keep each of
> > > us below 5 minutes so that we don't bore the audience - people will ask for
> > > details where they are interested... What do you think?
> > That looks good, however I'm not able to attend LSF this year, would
> > you help show my slides?
>   Ah, that's a pity :(. If you send me a few slides I can show them, that's
> no problem. I'll also try to understand your patches in enough detail so
> that I can answer possible questinons but author is always the best to
> present his work :).

Thank you very much :)

> > > I'll try to run also your patches on my setup to see how they work :) V6
> > > from your website is the latest version, isn't it?
> > 
> > Thank you. You can run 
> > http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=shortlog;h=refs/heads/dirty-throttling-v6
> > or 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/dirty-throttling-v6-2.6.38-rc6.patch
> > whatever convenient for you.
> > 
> > If you are ready with v3, I can also help test it out and do some
> > comparison on the results.
>   I have done a couple of smaller fixes but I don't expect them to affect
> performance in the loads we use. But I'll send you the patches when I
> implement some significant change (but for that I need to reproduce the
> latencies you sometimes see first...).

OK. I can conveniently test the single disk cases. For JBOD and RAID
cases, I don't own the servers so normally have to wait for some time
before being able to carry out the tests..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
