Date: Sun, 8 Jun 2008 23:10:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-Id: <20080608231053.31cfcfeb.akpm@linux-foundation.org>
In-Reply-To: <20080608205629.5b519110@bree.surriel.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
	<20080608193420.2a9cc030@bree.surriel.com>
	<20080608165434.67c87e5c.akpm@linux-foundation.org>
	<20080608205629.5b519110@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 20:56:29 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Sun, 8 Jun 2008 16:54:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Sun, 8 Jun 2008 19:34:20 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
> > > Please let me know which direction I should take, so I can fix
> > > up the patch set accordingly.
> > 
> > I'm getting rather wobbly about all of this.
> > 
> > This is, afair, by far the most intrusive and high-risk change we've
> > looked at doing since 2.5.x, for small values of x.
> 
> Nowhere near as intrusive or risky as eg. the timer changes that went
> in a few releases ago.

Well.  Intrusiveness doesn't matter much.  But no, you're dead wrong -
this stuff is far more risky than timer changes.  Because things like
the timer changes are trivial to detect errors in - it either works or
it doesn't.

Whereas reclaim problems can take *years* to identify and are often
very hard for the programmers to understand, reproduce and diagnose.

> > I mean, it's taken many years of work to get reclaim into its current
> > state (and the reduction in reported problems will in part be due to
> > the quadrupling-odd of memory over that time).
> 
> Actually, memory is now getting so large that the current code no
> longer works right.  On machines 16GB and up, we have discovered
> really pathetic behaviour by the VM currently upstream.
> 
> Things like the VM scanning over the (locked) shared memory segment
> over and over and over again, to get at the 1GB of freeable pagecache
> memory in the system.

Earlier discussion about removing these pages from ALL LRUs reached a
quite detailed stage, but nobody seemed to finish any code.

>  Or the system scanning over all anonymous
> memory over and over again, despite the fact that there is no more
> swap space left.

We shouldn't rewrite core VM to cater for incorrectly configured
systems.

> With heavy anonymous memory workloads, Linux can stall for minutes
> once memory runs low and something needs to be swapped out, because
> pretty much all memory is anonymous and everything has the referenced
> bit set.  We have seen systems with 128GB of RAM hang overnight, once
> every CPU got wedged in the pageout scanning code.  Typically the VM
> decides on a first page to swap out in 2-3 minutes though, and then
> it will start several gigabytes of swap IO at once...
> 
> Definately not acceptable behaviour.

I see handwavy non-bug-reports loosely associated with a vast pile of
code and vague expressions of hope that one will fix the other.

Where's the meat in this, Rik?  This is engineering.

Do you or do you not have a test case which demonstrates this problem? 
It doesn't sound terribly hard.  Where are the before-and-after test
results?

> > And we're now proposing radical changes which again will take years to sort
> > out, all on behalf of a small number of workloads upon a minority of 64-bit
> > machines which themselves are a minority of the Linux base.
> 
> Hardware gets larger.  4 years ago few people cared about systems
> with more than 4GB of memory, but nowadays people have that in their
> desktops.
> 
> > And it will take longer to get those problems sorted out if 32-bt
> > machines aren't even compiing the new code in.
> 
> 32 bit systems will still get the file/anon LRU split.  The only
> thing that is 64 bit only in the current patch set is keeping the
> unevictable pages off of the LRU lists.
> 
> This means that balancing between file and anon eviction will be
> the same on 32 and 64 bit systems and things should get sorted out
> on both systems at the same time.
> 
> > Are all of thse changes really justified?
> 
> People with large Linux servers are experiencing system stalls
> of several minutes, or at worst complete livelocks, with the
> current VM.
> 
> I believe that those issues need to be fixed.

I'd love to see hard evidence that they have been.  And that doesn't
mean getting palmed off on wikis and random blog pages.

Also, it is incumbent upon us to consider the other design proposals,
such as removing anon pages from the LRUs, removing mlocked pages from
the LRUs.

> After discussing this for a long time with Larry Woodman,
> Lee Schermerhorn and others, I am convinced that they can
> not be fixed by putting a bandaid on the current code.
> 
> After all, the fundamental problem often is that the file backed
> and mem/swap backed pages are on the same LRU.

That actually isn't a fundamental problem.

It _becomes_ a problem because we try to treat the two types of pages
differently.

Stupid question: did anyone try setting swappiness=100?  What happened?

> Think of a case that is becoming more and more common: a database
> server with 128GB of RAM, 2GB of (hardly ever used) swap, 80GB of
> locked shared memory segment, 30GB of other anonymous memory and
> 5GB of page cache.
> 
> Do you think it is reasonable for the VM to have to scan over
> 110GB of essentially unevictable memory, just to get at the 5GB
> of page cache?

Well for starters that system was grossly misconfigured.  It is
incumbent upon you, in your design document (that thing we call a
changelog) to justify why the VM design needs to be altered to cater
for such misconfigured systems.  It just drives me up the wall having
to engage in a 20-email discussion to be able to squeeze these little
revelations out.  Only to have them lost again later.

Secondly, I expect that removal of mlocked pages from the LRU (as was
discussed a year or two ago and perhaps implemented by Andrea) along
with swappiness=100 might be get us towards a fix.  Don't know.

> > Because I guess we should have a think about alternative approaches.
> 
> We have.  We failed to come up with anything that avoids the
> problem without actually fixing the fundamental issues.

Unless I missed it, none of your patch descriptions even attempt to
describe these fundamental issues.  It's all buried in 20-deep email
threads.

> If you have an idea, please let us know.

I see no fundamental reason why we need to put mlocked or SHM_LOCKED
pages onto a VM LRU at all.

One cause of problms is that we attempt to prioritise anon pages over
file-backed pagecache.  And we prioritise mmapped pages, which your patches
don't address, do they?  Stopping doing that would, I expect, prevent a
range of these problems.  It would introduce others, probably.

> Otherwise, please give us a chance to shake things out in -mm.

-mm isn't a very useful testing place any more, I'm afraid.  The
patches would be better off in linux-next, but then they would screw up
all the other pending MM patches, and it's probably a bit early for
getting them into linux-next.

Once I get sections of -mm feeding into linux-next, things will be better.

> I will prepare kernel RPMs for Fedora so users in the community can
> easily test these patches too, and help find scenarios where these
> patches do not perform as well as what the current kernel has.
> 
> I have time to track down and fix any issues that people find.

That helps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
