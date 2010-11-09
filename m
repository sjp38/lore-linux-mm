Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1881E6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:44:27 -0500 (EST)
Date: Tue, 9 Nov 2010 14:43:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] writeback: avoid livelocking WB_SYNC_ALL writeback
Message-Id: <20101109144346.21d6a5e4.akpm@linux-foundation.org>
In-Reply-To: <20101108231727.139062518@intel.com>
References: <20101108230916.826791396@intel.com>
	<20101108231727.139062518@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 09 Nov 2010 07:09:20 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> From: Jan Kara <jack@suse.cz>
> 
> When wb_writeback() is called in WB_SYNC_ALL mode, work->nr_to_write is
> usually set to LONG_MAX. The logic in wb_writeback() then calls
> __writeback_inodes_sb() with nr_to_write == MAX_WRITEBACK_PAGES and thus
> we easily end up with negative nr_to_write after the function returns.

No, nr_to_write can only be negative if the filesystem wrote back more
pages than requested.

> wb_writeback() then decides we need another round of writeback but this
> is wrong in some cases! For example when a single large file is
> continuously dirtied, we would never finish syncing it because each pass
> would be able to write MAX_WRITEBACK_PAGES and inode dirty timestamp
> never gets updated (as inode is never completely clean).

Well we shouldn't have asked the function to write LONG_MAX pages then!

The way this used to work was to try to write back N=(total dirty pages
+ total unstable pages + various fudge factors) to each superblock.  So
each superblock will get fully written back unless someone is madly
writing to it.  If that _is_ happening then we'll write a large amount
of data to it and will then give up and move onto the next superblock.

But the "large amount of data" is constrained to a sane upper limit:
total amount of dirty memory plus fudge factors.  Increasing that sane
upper limit to an insane 2^63-1 pages will *of course* cause sync() to
livelock.

Why was that sane->insane change made?

> Fix the issue by setting nr_to_write to LONG_MAX in WB_SYNC_ALL mode. We
> do not need nr_to_write in WB_SYNC_ALL mode anyway since livelock
> avoidance is done differently for it.

Here the changelog should spell out what "done differently" means. 
Because I really am unsure what is begin referred to.

I don't really see how this patch changes anything.  For WB_SYNC_ALL
requests the code will still try to write out 2^63 pages, only it does
it all in a single writeback_inodes_wb() call.  What prevents that call
itself from getting livelocked?

Perhaps the unmentioned problem here is that each call to
writeback_inodes_wb(MAX_WRITEBACK_PAGES) will restart its walk across
the inode lists.  So instead of giving up on a being-written-to-file,
we continuously revisit it again and again and again.

Correct?  If so, please add the description.  If incorrect, please add
the description as well ;)


Root cause time: it's those damn per-sb inode lists *again*.  They're
just awful.  We need some data structure there which is more amenable
to being iterated over.  Something against which we can store cursors,
for a start.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
