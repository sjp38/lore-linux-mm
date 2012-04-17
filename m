Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 5E4D86B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 18:38:59 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so10302561pbc.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 15:38:58 -0700 (PDT)
Date: Tue, 17 Apr 2012 15:38:54 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120417223854.GG19975@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120406095934.GA10465@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hello, Fengguang.

On Fri, Apr 06, 2012 at 02:59:34AM -0700, Fengguang Wu wrote:
> Fortunately, the above gap can be easily filled judging from the
> block/cfq IO controller code. By adding some direct IO accounting
> and changing several lines of my patches to make use of the collected
> stats, the semantics of the blkio.throttle.write_bps interfaces can be
> changed from "limit for direct IO" to "limit for direct+buffered IOs".
> Ditto for blkio.weight and blkio.write_iops, as long as some
> iops/device time stats are made available to balance_dirty_pages().
> 
> It would be a fairly *easy* change. :-) It's merely adding some
> accounting code and there is no need to change the block IO
> controlling algorithm at all. I'll do the work of accounting (which
> is basically independent of the IO controlling) and use the new stats
> in balance_dirty_pages().

I don't really understand how this can work.  For hard limits, maybe,
but for proportional IO, you have to know which cgroups have IOs
before assigning the proportions, so blkcg assigning IO bandwidth
without knowing async writes simply can't work.

For example, let's say cgroups A and B have 2:8 split.  If A has IOs
on queue and B doesn't, blkcg will assign all IO bandwidth to A.  I
can't wrap my head around how writeback is gonna make use of the
resulting stats but let's say it decides it needs to put out some IOs
out for both cgroups.  What happens then?  Do all the async writes go
through the root cgroup controlled by and affecting the ratio between
rootcg and cgroup A and B?  Or do they have to be accounted as part of
cgroups A and B?  If so, what if the added bandwidth goes over the
limit?  Let's say if we implement overcharge; then, I suppose we'll
have to communicate that upwards too, right?

This is still easy.  What about hierarchical propio?  What happens
then?  You can't do hierarchical proportional allocation without
knowing how much IOs are pending for which group.  How is that
information gonna be communicated between blkcg and writeback?  Are we
gonna have two separate hierarchical proportional IO allocators?  How
is that gonna work at all?  If we're gonna have single allocator in
block layer, writeback would have to feed the amount of IOs it may
generate into the allocator, get the resulting allocation and then
issue IO and then block layer again will have to account these to the
originating cgroups.  It's just crazy.

> The only problem I can see now, is that balance_dirty_pages() works
> per-bdi and blkcg works per-device. So the two ends may not match
> nicely if the user configures lv0 on sda+sdb and lv1 on sdb+sdc where
> sdb is shared by lv0 and lv1. However it should be rare situations and
> be much more acceptable than the problems arise from the "push back"
> approach which impacts everyone.

I don't know.  What problems?  AFAICS, the biggest issue is writeback
of different inodes getting mixed resulting in poor performance, but
if you think about it, that's about the frequency of switching cgroups
and a problem which can and should be dealt with from block layer
(e.g. use larger time slice if all the pending IOs are async).

Writeback's duty is generating stream of async writes which can be
served efficiently for the *cgroup* and keeping the buffer filled as
necessary and chaining the backpressure from there to the actual
dirtier.  That's what writeback does without cgroup.  Nothing
fundamental changes with cgroup.  It's just finer grained.

> > No, no, it's not about standing in my way.  As Vivek said in the other
> > reply, it's that the "gap" that you filled was created *because*
> > writeback wasn't cgroup aware and now you're in turn filling that gap
> > by making writeback work around that "gap".  I mean, my mind boggles.
> > Doesn't yours?  I strongly believe everyone's should.
> 
> Heh. It's a hard problem indeed. I felt great pains in the IO-less
> dirty throttling work. I did a lot reasoning about it, and have in
> fact kept cgroup IO controller in mind since its early days. Now I'd
> say it's hands down for it to adapt to the gap between the total IO
> limit and what's carried out by the block IO controller.

You're not providing any valid counter arguments about the issues
being raised about the messed up design.  How is anything "hands down"
here?

> > There's where I'm confused.  How is the said split supposed to work?
> > They aren't independent.  I mean, who gets to decide what and where
> > are those decisions enforced?
> 
> Yeah it's not independent. It's about
> 
> - keep block IO cgroup untouched (in its current algorithm, for
>   throttling direct IO)
> 
> - let balance_dirty_pages() adapt to the throttling target
>   
>         buffered_write_limit = total_limit - direct_IOs

Think about proportional allocation.  You don't have a number until
you know who have pending IOs and how much.

> To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> It's always there doing 1:1 proportional throttling. Then you try to
> kick in to add *double* throttling in block/cfq layer. Now the low
> layer may enforce 10:1 throttling and push balance_dirty_pages() away
> from its balanced state, leading to large fluctuations and program
> stalls.

Just do the same 1:1 inside each cgroup.

>  This can be avoided by telling balance_dirty_pages(): "your
> balance goal is no longer 1:1, but 10:1". With this information
> balance_dirty_pages() will behave right. Then there is the question:
> if balance_dirty_pages() will work just well provided the information,
> why bother doing the throttling at low layer and "push back" the
> pressure all the way up?

Because splitting a resource into two pieces arbitrarily with
different amount of consumptions on each side and then applying the
same proportion on both doesn't mean anything?

> The balance_dirty_pages() is already deeply involved in dirty throttling.
> As you can see from this patchset, the same algorithms can be extended
> trivially to work with cgroup IO limits.
> 
> buffered write IO controller in balance_dirty_pages()
> https://lkml.org/lkml/2012/3/28/275

It is half broken thing with fundamental design flaws which can't be
corrected without complete reimplementation.  I don't know what to
say.

> In the "back pressure" scheme, memcg is a must because only it has all
> the infrastructure to track dirty pages upon which you can apply some
> dirty_limits. Don't tell me you want to account dirty pages in blkcg...

For now, per-inode tracking seems good enough.

> What I can see is, it looks pretty simple and nature to let
> balance_dirty_pages() fill the gap towards a total solution :-)
> 
> - add direct IO accounting in some convenient point of the IO path
>   IO submission or completion point, either is fine.
> 
> - change several lines of the buffered write IO controller to
>   integrate the direct IO rate into the formula to fit the "total
>   IO" limit
> 
> - in future, add more accounting as well as feedback control to make
>   balance_dirty_pages() work with IOPS and disk time

To me, you seem to be not addressing the issues I've been raising at
all and just repeating the same points again and again.  If I'm
misunderstanding something, please point out.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
