Date: Thu, 9 Oct 2008 16:41:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] approach to pull writepage out of reclaim
Message-ID: <20081009144103.GE9941@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Just got bored of looking at other things, and started coding up the first
step to remove writepage from vmscan.

Actually, I lied slightly at kernel summit when I said we should be able to do
this easily and that it doesn't matter if filesystems today return immediately.
Higher order targetted page reclaim really does want to clean *this page*.
Fortunately it is going to be most important for swap (anonymous pages) because
file pages have much lower dirty thresholds.

However, we probably do want filesystems to be able to support this more
easily. The lock_page problem is a hard one *if* we assume writepage off the
LRU is an important fastpath. However, if we only ever run it for higher
order reclaim, then we're in a better position to handle it. The problem is
that we don't have a reference on the inode, so we can't dereference
page->mapping. The solution we can do is to lock the page, take a ref to
the inode, unlock the page, then call writepage (which would then lock the
page etc). So: slower, but with some effort it becomes a slowpath anyway.

So. Firstly, what I'm looking at is doing swap writeout from pdflush. This
patch does that (working in concept, but pdflush and background writeout
from dirty inode list isn't really up to the task, might scrap it and do the
writeout from kswap). But writeout from radix-tree should actually be able to
give better swapout pattern than LRU writepage as well.

My plan is to get this idea working, so writepage from pageout becomes a
slowpath.

Then fix the inode reference problem in vmscan.

Then change the calling convention of writepage to accept an unlocked page (at
the same time, don't clean the page before calling it. that's so stupid it
upsets me, and it really actually isn't much filesystem churn to fix).

Then perhaps look at removing direct calls to ->writepage() except in wrappers
such as generic_writepages, because at this point ->writepages should be
able to substitute. This is a relatively small step; more important are the
previous things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
