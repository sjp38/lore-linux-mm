Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 91C276B024A
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:09:21 -0400 (EDT)
Date: Tue, 15 Jun 2010 17:08:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615150850.GF28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615144342.GA3339@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 10:43:42AM -0400, Christoph Hellwig wrote:
> Other callers of ->writepage are fine because they come from a
> controlled environment with relatively little stack usage.  The problem
> with direct reclaim is that we splice multiple stack hogs ontop of each
> other.

It's not like we're doing a stack recursive algorithm in kernel. These
have to be "controlled hogs", so we must have space to run 4/5 of them
on top of each other, that's the whole point.

I'm aware the ->writepage can run on any alloc_pages, but frankly I
don't see a whole lot of difference between regular kernel code paths
or msync. Sure they can be at higher stack usage, but not like with
only 1000bytes left.

> And seriously, if the VM isn't stopped from calling ->writepage from
> reclaim context we FS people will simply ignore any ->writepage from
> reclaim context.  Been there, done that and never again.
> 
> Just wondering, what filesystems do your hugepage testing systems use?
> If it's any of the ext4/btrfs/xfs above you're already seeing the
> filesystem refuse ->writepage from both kswapd and direct reclaim,
> so Mel's series will allow us to reclaim pages from more contexts
> than before.

fs ignoring ->writepage during memory pressure (even from kswapd) is
broken, this is not up to the fs to decide. I'm using ext4 on most of
my testing, it works ok, but it doesn't make it right (if fact if
performance declines without that hack, it may prove VM needs fixing,
it doesn't justify the hack).

If you don't throttle against kswapd, or if even kswapd can't turn a
dirty page into a clean one, you can get oom false positives. Anything
is better than that. (provided you've proper stack instrumentation to
notice when there is risk of a stack overflow, it's ages I never seen
a stack overflow debug detector report)

The irq stack must be enabled and this isn't about direct reclaim but
about irqs in general and their potential nesting with softirq calls
too.

Also note, there's nothing that prevents us from switching the stack
to something else the moment we enter direct reclaim. It doesn't need
to be physically contiguous. Just allocate a couple of 4k pages and
switch to them every time a new hog starts in VM context. The only
real complexity is in the stack unwind but if irqstack can cope with
it sure stack unwind can cope with more "special" stacks too.

Ignoring ->writepage on VM invocations at best can only hide VM
inefficiencies with the downside of breaking the VM in corner cases
with heavy VM pressure.

Crippling down the kernel by vetoing ->writepage to me looks very
wrong, but I'd be totally supportive of a "special" writepage stack or
special iscsi stack etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
