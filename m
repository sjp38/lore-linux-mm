Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6CA076B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 21:26:28 -0500 (EST)
Date: Wed, 10 Nov 2010 10:26:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: avoid livelocking WB_SYNC_ALL writeback
Message-ID: <20101110022624.GA5167@localhost>
References: <20101108230916.826791396@intel.com>
 <20101108231727.139062518@intel.com>
 <20101109144346.21d6a5e4.akpm@linux-foundation.org>
 <20101109231840.GC11214@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109231840.GC11214@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 07:18:40AM +0800, Jan Kara wrote:
> On Tue 09-11-10 14:43:46, Andrew Morton wrote:

> > I don't really see how this patch changes anything.  For WB_SYNC_ALL
> > requests the code will still try to write out 2^63 pages, only it does
> > it all in a single writeback_inodes_wb() call.  What prevents that call

Sorry sync() works on one super block after another, so it's some
__writeback_inodes_sb() call. I'll update the comment.

> > itself from getting livelocked?

__writeback_inodes_sb() livelock is prevented by

- working on a finite set of files by doing queue_io() once at the beginning
- working on a finite set of pages by PAGECACHE_TAG_TOWRITE page tagging

>   I'm referring to the livelock avoidance using page tagging. Fengguang
> actually added a note about this into a comment in the code but it's not
> in the changelog. And you're right it should be here.

OK, I'll add the above to changelog.

> > Perhaps the unmentioned problem here is that each call to
> > writeback_inodes_wb(MAX_WRITEBACK_PAGES) will restart its walk across
> > the inode lists.  So instead of giving up on a being-written-to-file,
> > we continuously revisit it again and again and again.
> > 
> > Correct?  If so, please add the description.  If incorrect, please add
> > the description as well ;)
>   Yes, that's the problem.

writeback_inodes_wb(MAX_WRITEBACK_PAGES) will put the not full written
inode to head of b_more_io, and pick up the next inode from tail of
b_io next time it is called. Here the tail of b_io serves as the
cursor.

         b_io             b_more_io
        |----------------|-----------------|
        ^head            ^cursor           ^tail

> > Root cause time: it's those damn per-sb inode lists *again*.  They're
> > just awful.  We need some data structure there which is more amenable
> > to being iterated over.  Something against which we can store cursors,
> > for a start.
>   This would be definitely nice. But in this particular case, since we have
> that page tagging livelock avoidance, we can just do all we need in a one
> big sweep so we are OK.

The main problem of list_head is the awkward superblock walks in
move_expired_inodes(). It may take inode_lock for too long time.

It helps to break up b_dirty into a rb-tree. That will make
redirty_tail() more straightforward, too.

> Suggestion for the new changelog:
> When wb_writeback() is called in WB_SYNC_ALL mode, work->nr_to_write is
> usually set to LONG_MAX. The logic in wb_writeback() then calls
> __writeback_inodes_sb() with nr_to_write == MAX_WRITEBACK_PAGES and

> we easily end up with negative nr_to_write after the function returns.
> This is because write_cache_pages() does not stop writing when
> nr_to_write drops to zero in WB_SYNC_ALL mode.

It will return with (nr_to_write <=0) regardless of the
write_cache_pages() trick to ignore nr_to_write. So I changed the
above to:

        we easily end up with non-positive nr_to_write after the function
        returns, if the inode has more than MAX_WRITEBACK_PAGES dirty pages
        at the moment.

Others look good. I'll repost the series with updated changelog.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
