Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 63D2B6B004D
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 06:04:36 -0400 (EDT)
Date: Fri, 6 Apr 2012 02:59:34 -0700
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120406095934.GA10465@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hi Tejun,

On Wed, Apr 04, 2012 at 12:33:55PM -0700, Tejun Heo wrote:
> Hey, Fengguang.
> 
> On Wed, Apr 04, 2012 at 10:51:24AM -0700, Fengguang Wu wrote:
> > Yeah it should be trivial to apply the balance_dirty_pages()
> > throttling algorithm to the read/direct IOs. However up to now I don't
> > see much added value to *duplicate* the current block IO controller
> > functionalities, assuming the current users and developers are happy
> > with it.
> 
> Heh, trust me.  It's half broken and people ain't happy.  I get that

Yeah, although the balance_dirty_pages() IO controller for buffered
writes looks perfect in itself, it's not enough to meet user demands.

The user expectation should be: hey, please throttle *all* IOs from
this cgroup to this amount, either in absolute bps/iops limits or in
some proportional weight value (or both, whatever the lower takes
effect).  And if necessary, he may request further limits/weights for
each type of IO inside the cgroup.

Now the blkio cgroup supports direct IO and the balance_dirty_pages()
IO controller supports buffered writes. They are providing
limits/weights for either direct IO or buffered writes, which is fine
if it's pure direct IO or pure buffered write. For the common mixed
IO workloads, it's obviously not enough.

Fortunately, the above gap can be easily filled judging from the
block/cfq IO controller code. By adding some direct IO accounting
and changing several lines of my patches to make use of the collected
stats, the semantics of the blkio.throttle.write_bps interfaces can be
changed from "limit for direct IO" to "limit for direct+buffered IOs".
Ditto for blkio.weight and blkio.write_iops, as long as some
iops/device time stats are made available to balance_dirty_pages().

It would be a fairly *easy* change. :-) It's merely adding some
accounting code and there is no need to change the block IO
controlling algorithm at all. I'll do the work of accounting (which
is basically independent of the IO controlling) and use the new stats
in balance_dirty_pages().

The only problem I can see now, is that balance_dirty_pages() works
per-bdi and blkcg works per-device. So the two ends may not match
nicely if the user configures lv0 on sda+sdb and lv1 on sdb+sdc where
sdb is shared by lv0 and lv1. However it should be rare situations and
be much more acceptable than the problems arise from the "push back"
approach which impacts everyone.

> your algorithm can be updatd to consider all IOs and I believe that
> but what I don't get is how would such information get to writeback
> and in turn how writeback would enforce the result on reads and direct
> IOs.  Through what path?  Will all reads and direct IOs travel through
> balance_dirty_pages() even direct IOs on raw block devices?  Or would
> the writeback algorithm take the configuration from cfq, apply the
> algorithm and give back the limits to enforce to cfq?  If the latter,
> isn't that at least somewhat messed up?

cfq is working well and don't need any modifications. Let's just make
balance_dirty_pages() cgroup aware and fill the gap of the current
block IO controller.

If the balance_dirty_pages() throttling algorithms will ever be
applied to read and direct IOs, it would be for NFS, CIFS etc. Even
for them, there may be better throttling choices. For example, Trond
mentioned the RPC layer to me during the summit.

> > I did the buffered write IO controller mainly to fill the gap.  If I
> > happen to stand in your way, sorry that's not my initial intention.
> 
> No, no, it's not about standing in my way.  As Vivek said in the other
> reply, it's that the "gap" that you filled was created *because*
> writeback wasn't cgroup aware and now you're in turn filling that gap
> by making writeback work around that "gap".  I mean, my mind boggles.
> Doesn't yours?  I strongly believe everyone's should.

Heh. It's a hard problem indeed. I felt great pains in the IO-less
dirty throttling work. I did a lot reasoning about it, and have in
fact kept cgroup IO controller in mind since its early days. Now I'd
say it's hands down for it to adapt to the gap between the total IO
limit and what's carried out by the block IO controller.

> > It's a pity and surprise that Google as a big user does not buy in
> > this simple solution. You may prefer more comprehensive controls which
> > may not be easily achievable with the simple scheme. However the
> > complexities and overheads involved in throttling the flusher IOs
> > really upsets me. 
> 
> Heh, believe it or not, I'm not really wearing google hat on this
> subject and google's writeback people may have completely different
> opinions on the subject than mine.  In fact, I'm not even sure how
> much "work" time I'll be able to assign to this.  :(

OK, understand.

> > The sweet split point would be for balance_dirty_pages() to do cgroup
> > aware buffered write throttling and leave other IOs to the current
> > blkcg. For this to work well as a total solution for end users, I hope
> > we can cooperate and figure out ways for the two throttling entities
> > to work well with each other.
> 
> There's where I'm confused.  How is the said split supposed to work?
> They aren't independent.  I mean, who gets to decide what and where
> are those decisions enforced?

Yeah it's not independent. It's about

- keep block IO cgroup untouched (in its current algorithm, for
  throttling direct IO)

- let balance_dirty_pages() adapt to the throttling target
  
        buffered_write_limit = total_limit - direct_IOs

> > What I'm interested is, what's Google and other users' use schemes in
> > practice. What's their desired interfaces. Whether and how the
> > combined bdp+blkcg throttling can fulfill the goals.
> 
> I'm not too privy of mm and writeback in google and even if so I
> probably shouldn't talk too much about it.  Confidentiality and all.
> That said, I have the general feeling that goog already figured out
> how to at least work around the existing implementation and would be
> able to continue no matter how upstream development fans out.
> 
> That said, wearing the cgroup maintainer and general kernel
> contributor hat, I'd really like to avoid another design mess up.

To me it looks a pretty clean split and find it to be an easy
solution (after sorting it out the hard way). I'll show the code and
test results after some time.

> > > Let's please keep the layering clear.  IO limitations will be applied
> > > at the block layer and pressure will be formed there and then
> > > propagated upwards eventually to the originator.  Sure, exposing the
> > > whole information might result in better behavior for certain
> > > workloads, but down the road, say, in three or five years, devices
> > > which can be shared without worrying too much about seeks might be
> > > commonplace and we could be swearing at a disgusting structural mess,
> > > and sadly various cgroup support seems to be a prominent source of
> > > such design failures.
> > 
> > Super fast storages are coming which will make us regret to make the
> > IO path over complex.  Spinning disks are not going away anytime soon.
> > I doubt Google is willing to afford the disk seek costs on its
> > millions of disks and has the patience to wait until switching all of
> > the spin disks to SSD years later (if it will ever happen).
> 
> This is new.  Let's keep the damn employer out of the discussion.
> While the area I work on is affected by my employment (writeback isn't
> even my area BTW), I'm not gonna do something adverse to upstream even
> if it's beneficial to google and I'm much more likely to do something
> which may hurt google a bit if it's gonna benefit upstream.
> 
> As for the faster / newer storage argument, that is *exactly* why we
> want to keep the layering proper.  Writeback works from the pressure
> from the IO stack.  If IO technology changes, we update the IO stack
> and writeback still works from the pressure.  It may need to be
> adjusted but the principles don't change.

To me, balance_dirty_pages() is *the* proper layer for buffered writes.
It's always there doing 1:1 proportional throttling. Then you try to
kick in to add *double* throttling in block/cfq layer. Now the low
layer may enforce 10:1 throttling and push balance_dirty_pages() away
from its balanced state, leading to large fluctuations and program
stalls.  This can be avoided by telling balance_dirty_pages(): "your
balance goal is no longer 1:1, but 10:1". With this information
balance_dirty_pages() will behave right. Then there is the question:
if balance_dirty_pages() will work just well provided the information,
why bother doing the throttling at low layer and "push back" the
pressure all the way up?

> > It's obvious that your below proposal involves a lot of complexities,
> > overheads, and will hurt performance. It basically involves
> 
> Hmmm... that's not the impression I got from the discussion.
> According to Jan, applying the current writeback logic to cgroup'fied
> bdi shouldn't be too complex, no?

In the sense of "avoidable" complexity :-)

> > - running concurrent flusher threads for cgroups, which adds back the
> >   disk seeks and lock contentions. And still has problems with sync
> >   and shared inodes.
> 
> I agree this is an actual concern but if the user wants to split one
> spindle to multiple resource domains, there's gonna be considerable
> amount of overhead no matter what.  If you want to improve how block
> layer handles the split, you're welcome to dive into the block layer,
> where the split is made, and improve it.
> 
> > - splitting device queue for cgroups, possibly scaling up the pool of
> >   writeback pages (and locked pages in the case of stable pages) which
> >   could stall random processes in the system
> 
> Sure, it'll take up more buffering and memory but that's the overhead
> of the cgroup business.  I want it to be less intrusive at the cost of
> somewhat more resource consumption.  ie. I don't want writeback logic
> itself deeply involved in block IO cgroup enforcement even if that
> means somewhat less efficient resource usage.

The balance_dirty_pages() is already deeply involved in dirty throttling.
As you can see from this patchset, the same algorithms can be extended
trivially to work with cgroup IO limits.

buffered write IO controller in balance_dirty_pages()
https://lkml.org/lkml/2012/3/28/275

It does not require forking off the flusher threads and splitting up
the IO queue at all.

> > - the mess of metadata handling
> 
> Does throttling from writeback actually solve this problem?  What
> about fsync()?  Does that already go through balance_dirty_pages()?

balance_dirty_pages() does throttling at safe points outside of fs
transactions/locks.

fsync() only submits IO for already dirtied pages and won't be
throttled by balance_dirty_pages(). Throttling happens at earlier
times when the task is dirtying the pages.

> > - unnecessarily coupled with memcg, in order to take advantage of the
> >   per-memcg dirty limits for balance_dirty_pages() to actually convert
> >   the "pushed back" dirty pages pressure into lowered dirty rate. Why
> >   the hell the users *have to* setup memcg (suffering from all the
> >   inconvenience and overheads) in order to do IO throttling?  Please,
> >   this is really ugly! And the "back pressure" may constantly push the
> >   memcg dirty pages to the limits. I'm not going to support *miss use*
> >   of per-memcg dirty limits like this!
> 
> Writeback sits between blkcg and memcg and it indeed can be hairy to
> consider both sides especially given the current sorry complex state
> of cgroup and I can see why it would seem tempting to add a separate
> controller or at least knobs to support that.  That said, I *think*
> given that memcg controls all other memory parameters it probably
> would make most sense giving that parameter to memcg too.  I don't
> think this is really relevant to this discussion tho.  Who owns
> dirty_limits is a separate issue.

In the "back pressure" scheme, memcg is a must because only it has all
the infrastructure to track dirty pages upon which you can apply some
dirty_limits. Don't tell me you want to account dirty pages in blkcg...

> > I cannot believe you would keep overlooking all the problems without
> > good reasons. Please do tell us the reasons that matter.
> 
> Well, I tried and I hope some of it got through.  I also wrote a lot
> of questions, mainly regarding how what you have in mind is supposed
> to work through what path.  Maybe I'm just not seeing what you're
> seeing but I just can't see where all the IOs would go through and
> come together.  Can you please elaborate more on that?

What I can see is, it looks pretty simple and nature to let
balance_dirty_pages() fill the gap towards a total solution :-)

- add direct IO accounting in some convenient point of the IO path
  IO submission or completion point, either is fine.

- change several lines of the buffered write IO controller to
  integrate the direct IO rate into the formula to fit the "total
  IO" limit

- in future, add more accounting as well as feedback control to make
  balance_dirty_pages() work with IOPS and disk time

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
