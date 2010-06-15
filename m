Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB3E6B024E
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:25:56 -0400 (EDT)
Date: Tue, 15 Jun 2010 11:25:26 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615152526.GA3468@infradead.org>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615150850.GF28052@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 05:08:50PM +0200, Andrea Arcangeli wrote:
> On Tue, Jun 15, 2010 at 10:43:42AM -0400, Christoph Hellwig wrote:
> > Other callers of ->writepage are fine because they come from a
> > controlled environment with relatively little stack usage.  The problem
> > with direct reclaim is that we splice multiple stack hogs ontop of each
> > other.
> 
> It's not like we're doing a stack recursive algorithm in kernel. These
> have to be "controlled hogs", so we must have space to run 4/5 of them
> on top of each other, that's the whole point.

We're not doing a full recursion.  We're splicing a codepath that
normally could use the full stack (fs writeback / block I/O) into
a random other code path that could use the full stack, and add
some quite stack heavy allocator / reclaim code inbetween.

> 
> I'm aware the ->writepage can run on any alloc_pages, but frankly I
> don't see a whole lot of difference between regular kernel code paths
> or msync. Sure they can be at higher stack usage, but not like with
> only 1000bytes left.

msync does not use any significant amount of stack:

0xc01f53b3 sys_msync [vmlinux]:				40
0xc022b165 vfs_fsync [vmlinux]:				12
0xc022b053 vfs_fsync_range [vmlinux]:			24
0xc01d7e63 filemap_write_and_wait_range [vmlinux]:	28
0xc01d7df3 __filemap_fdatawrite_range [vmlinux]:	56

and then we alredy enter ->writepages.  Direct reclaim on the other
hand can happen from context that already is say 4 or 6 kilobytes
into stack usage.  And the callchain from kmalloc() into ->writepage
alone adds another 0.7k of stack usage.  There's not much left for
the filesystem after this.

> If you don't throttle against kswapd, or if even kswapd can't turn a
> dirty page into a clean one, you can get oom false positives. Anything
> is better than that. (provided you've proper stack instrumentation to
> notice when there is risk of a stack overflow, it's ages I never seen
> a stack overflow debug detector report)

I've never seen the stack overflow detector trigger on this, but I've
seen lots of real life stack overflows on the mailing lists.  End
users don't run with it enabled normally, and most testing workloads
don't seem to hit direct reclaim enough to actually trigger this
reproducibly.

> Also note, there's nothing that prevents us from switching the stack
> to something else the moment we enter direct reclaim. It doesn't need
> to be physically contiguous. Just allocate a couple of 4k pages and
> switch to them every time a new hog starts in VM context. The only
> real complexity is in the stack unwind but if irqstack can cope with
> it sure stack unwind can cope with more "special" stacks too.

Which is a lot more complicated than loading off the page cleaning
from direct reclaim to dedicated threads - be that the flusher threads
or kswapd.

> Ignoring ->writepage on VM invocations at best can only hide VM
> inefficiencies with the downside of breaking the VM in corner cases
> with heavy VM pressure.

It allows the system to survive in case direct reclaim is called instead
of crashing with a stack overflow.  And at least in my testing the
VM seems to cope rather well with not beeing able to write out
filesystem pages from direct reclaim.  That doesn't mean that this
behaviour can't be further improved on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
