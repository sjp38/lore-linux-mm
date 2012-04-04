Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 100A06B00FF
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 15:34:02 -0400 (EDT)
Received: by dakh32 with SMTP id h32so789650dak.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 12:34:01 -0700 (PDT)
Date: Wed, 4 Apr 2012 12:33:55 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404175124.GA8931@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hey, Fengguang.

On Wed, Apr 04, 2012 at 10:51:24AM -0700, Fengguang Wu wrote:
> Yeah it should be trivial to apply the balance_dirty_pages()
> throttling algorithm to the read/direct IOs. However up to now I don't
> see much added value to *duplicate* the current block IO controller
> functionalities, assuming the current users and developers are happy
> with it.

Heh, trust me.  It's half broken and people ain't happy.  I get that
your algorithm can be updatd to consider all IOs and I believe that
but what I don't get is how would such information get to writeback
and in turn how writeback would enforce the result on reads and direct
IOs.  Through what path?  Will all reads and direct IOs travel through
balance_dirty_pages() even direct IOs on raw block devices?  Or would
the writeback algorithm take the configuration from cfq, apply the
algorithm and give back the limits to enforce to cfq?  If the latter,
isn't that at least somewhat messed up?

> I did the buffered write IO controller mainly to fill the gap.  If I
> happen to stand in your way, sorry that's not my initial intention.

No, no, it's not about standing in my way.  As Vivek said in the other
reply, it's that the "gap" that you filled was created *because*
writeback wasn't cgroup aware and now you're in turn filling that gap
by making writeback work around that "gap".  I mean, my mind boggles.
Doesn't yours?  I strongly believe everyone's should.

> It's a pity and surprise that Google as a big user does not buy in
> this simple solution. You may prefer more comprehensive controls which
> may not be easily achievable with the simple scheme. However the
> complexities and overheads involved in throttling the flusher IOs
> really upsets me. 

Heh, believe it or not, I'm not really wearing google hat on this
subject and google's writeback people may have completely different
opinions on the subject than mine.  In fact, I'm not even sure how
much "work" time I'll be able to assign to this.  :(

> The sweet split point would be for balance_dirty_pages() to do cgroup
> aware buffered write throttling and leave other IOs to the current
> blkcg. For this to work well as a total solution for end users, I hope
> we can cooperate and figure out ways for the two throttling entities
> to work well with each other.

There's where I'm confused.  How is the said split supposed to work?
They aren't independent.  I mean, who gets to decide what and where
are those decisions enforced?

> What I'm interested is, what's Google and other users' use schemes in
> practice. What's their desired interfaces. Whether and how the
> combined bdp+blkcg throttling can fulfill the goals.

I'm not too privy of mm and writeback in google and even if so I
probably shouldn't talk too much about it.  Confidentiality and all.
That said, I have the general feeling that goog already figured out
how to at least work around the existing implementation and would be
able to continue no matter how upstream development fans out.

That said, wearing the cgroup maintainer and general kernel
contributor hat, I'd really like to avoid another design mess up.

> > Let's please keep the layering clear.  IO limitations will be applied
> > at the block layer and pressure will be formed there and then
> > propagated upwards eventually to the originator.  Sure, exposing the
> > whole information might result in better behavior for certain
> > workloads, but down the road, say, in three or five years, devices
> > which can be shared without worrying too much about seeks might be
> > commonplace and we could be swearing at a disgusting structural mess,
> > and sadly various cgroup support seems to be a prominent source of
> > such design failures.
> 
> Super fast storages are coming which will make us regret to make the
> IO path over complex.  Spinning disks are not going away anytime soon.
> I doubt Google is willing to afford the disk seek costs on its
> millions of disks and has the patience to wait until switching all of
> the spin disks to SSD years later (if it will ever happen).

This is new.  Let's keep the damn employer out of the discussion.
While the area I work on is affected by my employment (writeback isn't
even my area BTW), I'm not gonna do something adverse to upstream even
if it's beneficial to google and I'm much more likely to do something
which may hurt google a bit if it's gonna benefit upstream.

As for the faster / newer storage argument, that is *exactly* why we
want to keep the layering proper.  Writeback works from the pressure
from the IO stack.  If IO technology changes, we update the IO stack
and writeback still works from the pressure.  It may need to be
adjusted but the principles don't change.

> It's obvious that your below proposal involves a lot of complexities,
> overheads, and will hurt performance. It basically involves

Hmmm... that's not the impression I got from the discussion.
According to Jan, applying the current writeback logic to cgroup'fied
bdi shouldn't be too complex, no?

> - running concurrent flusher threads for cgroups, which adds back the
>   disk seeks and lock contentions. And still has problems with sync
>   and shared inodes.

I agree this is an actual concern but if the user wants to split one
spindle to multiple resource domains, there's gonna be considerable
amount of overhead no matter what.  If you want to improve how block
layer handles the split, you're welcome to dive into the block layer,
where the split is made, and improve it.

> - splitting device queue for cgroups, possibly scaling up the pool of
>   writeback pages (and locked pages in the case of stable pages) which
>   could stall random processes in the system

Sure, it'll take up more buffering and memory but that's the overhead
of the cgroup business.  I want it to be less intrusive at the cost of
somewhat more resource consumption.  ie. I don't want writeback logic
itself deeply involved in block IO cgroup enforcement even if that
means somewhat less efficient resource usage.

> - the mess of metadata handling

Does throttling from writeback actually solve this problem?  What
about fsync()?  Does that already go through balance_dirty_pages()?

> - unnecessarily coupled with memcg, in order to take advantage of the
>   per-memcg dirty limits for balance_dirty_pages() to actually convert
>   the "pushed back" dirty pages pressure into lowered dirty rate. Why
>   the hell the users *have to* setup memcg (suffering from all the
>   inconvenience and overheads) in order to do IO throttling?  Please,
>   this is really ugly! And the "back pressure" may constantly push the
>   memcg dirty pages to the limits. I'm not going to support *miss use*
>   of per-memcg dirty limits like this!

Writeback sits between blkcg and memcg and it indeed can be hairy to
consider both sides especially given the current sorry complex state
of cgroup and I can see why it would seem tempting to add a separate
controller or at least knobs to support that.  That said, I *think*
given that memcg controls all other memory parameters it probably
would make most sense giving that parameter to memcg too.  I don't
think this is really relevant to this discussion tho.  Who owns
dirty_limits is a separate issue.

> I cannot believe you would keep overlooking all the problems without
> good reasons. Please do tell us the reasons that matter.

Well, I tried and I hope some of it got through.  I also wrote a lot
of questions, mainly regarding how what you have in mind is supposed
to work through what path.  Maybe I'm just not seeing what you're
seeing but I just can't see where all the IOs would go through and
come together.  Can you please elaborate more on that?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
