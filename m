Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 815D96B004A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:58:21 -0400 (EDT)
Date: Wed, 18 Apr 2012 15:58:14 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120418075814.GA3809@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120418065720.GA21485@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120418065720.GA21485@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 18, 2012 at 08:57:20AM +0200, Jan Kara wrote:
> On Fri 06-04-12 02:59:34, Wu Fengguang wrote:
> ...
> > > > > Let's please keep the layering clear.  IO limitations will be applied
> > > > > at the block layer and pressure will be formed there and then
> > > > > propagated upwards eventually to the originator.  Sure, exposing the
> > > > > whole information might result in better behavior for certain
> > > > > workloads, but down the road, say, in three or five years, devices
> > > > > which can be shared without worrying too much about seeks might be
> > > > > commonplace and we could be swearing at a disgusting structural mess,
> > > > > and sadly various cgroup support seems to be a prominent source of
> > > > > such design failures.
> > > > 
> > > > Super fast storages are coming which will make us regret to make the
> > > > IO path over complex.  Spinning disks are not going away anytime soon.
> > > > I doubt Google is willing to afford the disk seek costs on its
> > > > millions of disks and has the patience to wait until switching all of
> > > > the spin disks to SSD years later (if it will ever happen).
> > > 
> > > This is new.  Let's keep the damn employer out of the discussion.
> > > While the area I work on is affected by my employment (writeback isn't
> > > even my area BTW), I'm not gonna do something adverse to upstream even
> > > if it's beneficial to google and I'm much more likely to do something
> > > which may hurt google a bit if it's gonna benefit upstream.
> > > 
> > > As for the faster / newer storage argument, that is *exactly* why we
> > > want to keep the layering proper.  Writeback works from the pressure
> > > from the IO stack.  If IO technology changes, we update the IO stack
> > > and writeback still works from the pressure.  It may need to be
> > > adjusted but the principles don't change.
> > 
> > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > It's always there doing 1:1 proportional throttling. Then you try to
> > kick in to add *double* throttling in block/cfq layer. Now the low
> > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > from its balanced state, leading to large fluctuations and program
> > stalls.  This can be avoided by telling balance_dirty_pages(): "your
> > balance goal is no longer 1:1, but 10:1". With this information
> > balance_dirty_pages() will behave right. Then there is the question:
> > if balance_dirty_pages() will work just well provided the information,
> > why bother doing the throttling at low layer and "push back" the
> > pressure all the way up?
>   Fengguang, maybe we should first agree on some basics:
>   The two main goals of balance_dirty_pages() are (and always have been
> AFAIK) to limit amount of dirty pages in memory and keep enough dirty pages
> in memory to allow for efficient writeback. Secondary goals are to also
> keep amount of dirty pages somewhat fair among bdis and processes. Agreed?

Agreed. In fact, before the IO-less change, balance_dirty_pages() had
no much explicit control over the dirty rate and fairness.

> Thus shift to trying to control *IO throughput* (or even just buffered
> write throughput) from balance_dirty_pages() is a fundamental shift in the
> goals of balance_dirty_pages(), not just some tweak (although technically,
> it might be relatively easy to do for buffered writes given the current
> implementation).

Yes, it has been a bit shift to the rate based dirty control.

> ...
> > > Well, I tried and I hope some of it got through.  I also wrote a lot
> > > of questions, mainly regarding how what you have in mind is supposed
> > > to work through what path.  Maybe I'm just not seeing what you're
> > > seeing but I just can't see where all the IOs would go through and
> > > come together.  Can you please elaborate more on that?
> > 
> > What I can see is, it looks pretty simple and nature to let
> > balance_dirty_pages() fill the gap towards a total solution :-)
> > 
> > - add direct IO accounting in some convenient point of the IO path
> >   IO submission or completion point, either is fine.
> > 
> > - change several lines of the buffered write IO controller to
> >   integrate the direct IO rate into the formula to fit the "total
> >   IO" limit
> > 
> > - in future, add more accounting as well as feedback control to make
> >   balance_dirty_pages() work with IOPS and disk time
>   Sorry Fengguang but I also think this is a wrong way to go.
> balance_dirty_pages() must primarily control the amount of dirty pages.
> Trying to bend it to control IO throughput by including direct IO and
> reads in the accounting will just make the logic even more complex than it
> already is.

Right, I have been adding too much complexity to balance_dirty_pages().
The control algorithms are pretty hard to understand and get right for
all cases.

OK, I'll post results of my experiments up to now, answer some
questions and take a comfortable break. Phooo..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
