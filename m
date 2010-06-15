Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 997376B0251
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 11:45:49 -0400 (EDT)
Date: Tue, 15 Jun 2010 17:45:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615154516.GG28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615152526.GA3468@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615152526.GA3468@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 11:25:26AM -0400, Christoph Hellwig wrote:
> hand can happen from context that already is say 4 or 6 kilobytes
> into stack usage.  And the callchain from kmalloc() into ->writepage

Mel's stack trace of 5k was still not realistic as it doesn't call
writepage there. I was just asking the 6k example vs msync.

Plus shrink dcache/inodes may also invoke I/O and end up with all
those hogs.

> I've never seen the stack overflow detector trigger on this, but I've
> seen lots of real life stack overflows on the mailing lists.  End
> users don't run with it enabled normally, and most testing workloads
> don't seem to hit direct reclaim enough to actually trigger this
> reproducibly.

How do you know it's a stack overflow if it's not the stack overflow
detector firing before the fact, could be bad ram too, usually?

> Which is a lot more complicated than loading off the page cleaning
> from direct reclaim to dedicated threads - be that the flusher threads
> or kswapd.

More complicated for sure. But surely I like that more than vetoing
->writepage from VM context, especially if it's a fs decision. fs
shouldn't decide that.

> It allows the system to survive in case direct reclaim is called instead
> of crashing with a stack overflow.  And at least in my testing the
> VM seems to cope rather well with not beeing able to write out
> filesystem pages from direct reclaim.  That doesn't mean that this
> behaviour can't be further improved on.

Agreed. Surely it seems to work ok for me too, but it may hide VM
issues, it makes the VM less reliable against potential false positive
OOM, and it's better if we just teach the VM to switch stack before
invoking the freeing methods, so it automatically solves dcache/icache
collection ending up writing data etc...

Then if we don't want to call ->writepage we won't do it for other
reasons, but we can solve this in a generic and reliable way that
covers not just ->writepage but all source I/O, including swapout over
iscsi, vfs etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
