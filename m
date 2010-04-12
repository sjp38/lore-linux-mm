Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3ABF76B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:07:10 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:06:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412080626.GG5656@random.random>
References: <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <20100412070811.GD5656@random.random>
 <20100412072144.GS5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412072144.GS5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 05:21:44PM +1000, Nick Piggin wrote:
> On Mon, Apr 12, 2010 at 09:08:11AM +0200, Andrea Arcangeli wrote:
> > On Mon, Apr 12, 2010 at 04:09:31PM +1000, Nick Piggin wrote:
> > > One problem is that you need to keep a lot more memory free in order
> > > for it to be reasonably effective. Another thing is that the problem
> > > of fragmentation breakdown is not just a one-shot event that fills
> > > memory with pinned objects. It is a slow degredation.
> > 
> > set_recommended_min_free_kbytes seems to not be in function of ram
> > size, 60MB aren't such a big deal.
> > 
> > > Especially when you use something like SLUB as the memory allocator
> > > which requires higher order allocations for objects which are pinned
> > > in kernel memory.
> > > 
> > > Just running a few minutes of testing with a kernel compile in the
> > > background does not show the full picture. You really need a box that
> > > has been up for days running a proper workload before you are likely
> > > to see any breakdown.
> > > 
> > > I'm sure it's horrible for planning if the RDBMS or VM boxes gradually
> > > get slower after X days of uptime. It's better to have consistent
> > > performance really, for anything except pure benchmark setups.
> > 
> > All data I provided is very real, in addition to building a ton of
> > packages and running emerge on /usr/portage I've been running all my
> > real loads. Only problem I only run it for 1 day and half, but the
> > load I kept it under was significant (surely a lot bigger inode/dentry
> > load that any hypervisor usage would ever generate).
> 
> OK, but as a solution for some kind of very specific and highly
> optimized application already like RDBMS, HPC, hypervisor or JVM,
> they could just be using hugepages themselves, couldn't they?
>
> It seems more interesting as a more general speedup for applications
> that can't afford such optimizations? (eg. the common case for
> most people)

The reality is that very few are using hugetlbfs. I guess maybe 0.1%
of KVM instances on phenom/nahlem chips are running on hugetlbfs for
example (hugetlbfs boot reservation doesn't fit the cloud where you
need all ram available in hugetlbfs and you still need 100% of unused
ram as host pagecache for VDI), despite it would provide a >=6% boosts
to all VM no matter what's running on the guest. Same goes for the
JVM, maybe 0.1% of those runs on hugetlbfs. The commercial DBMS are
the exception and they're probably closer to 99% running on hugetlbfs
(and they've to keep using hugetlbfs until we move transparent
hugepages in tmpfs). But as

So there's a ton of wasted energy in my view. Like Ingo said, the
faster they make the chips and the cheaper the RAM becomes, the more
wasted energy as result of not using hugetlbfs. There's always more
difference between cache sizes and ram sizes and also more difference
between cache speeds and ram speeds. I don't see this trend ending and
I'm not sure what is the better CPU that will make hugetlbfs worthless
and unselectable at kernel configure time on x86 arch (if you build
without generic).

And I don't think it's feasible to ship a distro where 99% of apps
that can benefit from hugepages are running with
LD_PRELOAD=libhugetlbfs.so. It has to be transparent if we want to
stop the waste.

The main reason I've always been skeptical about transparent hugepages
before I started working on this is the mess they generate on the
whole kernel. So my priority of course has been to keep it self
contained as much as possible. It kept spilling over and over until I
managed to confine it to anonymous pages and fix whole mm/.c files
with just a one liner (even the hugepage aware implementation that
Johannes did still takes advantage of split_huge_page_pmd if the
mprotect start/end isn't 2M naturally aligned, just to show how
complex it would be to do it all at once). This will allow us to reach
a solid base, and then later move to tmpfs and maybe later to
pagecache and swapcache too. Pretending the whole kernel to become
hugepage aware at once is a total mess, gup would need to return only
head pages for example and breaking hundred of drivers in just that
change. The compound_lock can be removed after you fix all those
hundred of drivers and subsystems using gup... No big deal to remove
it later, kind of you're removing the big kernel lock these days after
14 years of when it has been introduced.

Plus I did all I could to try to keep it as black and white as
possible. I think other OS are more gray in their approaches, my
priority has been to pay for RAM anywhere I could if you set
enabled=always, and to decrease as much as I could any risk of
performance regressions in any workload. These days we can afford to
lose 1G without much worry if it speedup the workload 8%, so I think
the other designs are better for old hardware RAM constrainted and not
very actual. On embedded with my patchset one should set
enabled=madvise. Ingo suggested a per-process tweak to enable it
selectively on certain apps, that is feasible too in the future (so
people won't be forced to modify binaries to add madvise if they can't
leave enabled=always).

> Yes we do have the option to reserve pages and as far as I know it
> should work, although I can't remember whether it deals with mlock.

I think that is the right route to take for who needs the
math-guarantees, and for many products it won't even be noticeable to
enforce the math guarantee. It's kind of overcommit, somebody prefers
the = 2 version and maybe they don't even notice it allows them to
allocate less memory. Others prefers to be able to allocate ram
without accounting for the unused virtual regions despite the bigger
chance to run into the oom killer (and I'm in the latter camp for both
overcommit sysctl and kernelcore= ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
