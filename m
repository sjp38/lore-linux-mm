Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82F2F6B0062
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:47:46 -0400 (EDT)
Date: Mon, 31 Aug 2009 12:47:49 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831104748.GT12579@kernel.dk>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu> <20090831102909.GS12579@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831102909.GS12579@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31 2009, Jens Axboe wrote:
> > I traced the calls to ext4_da_writepages() using ftrace, and found this:
> > 
> >       flush-8:16-1829  [001]    23.416351: ext4_da_writepages: dev sdb ino 12 nr_t_write 32759 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> >       flush-8:16-1829  [000]    25.939354: ext4_da_writepages: dev sdb ino 12 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> >       flush-8:16-1829  [000]    25.939486: ext4_da_writepages: dev sdb ino 13 nr_t_write 32759 pages_skipped 0 range_start 134180864 range_end 9223372036854775807 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> >       flush-8:16-1829  [000]    27.055687: ext4_da_writepages: dev sdb ino 12 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> >       flush-8:16-1829  [000]    27.055691: ext4_da_writepages: dev sdb ino 13 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> >       flush-8:16-1829  [000]    27.878708: ext4_da_writepages: dev sdb ino 13 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> > 
> > The *first* time the per-bdi code called writepages on the second file
> > (test2, inode #13), range_start was 134180864 (which, curiously
> > enough, is 4096*32759, which was the value of nr_to_write passed to
> > ext4_da_writepages).  Given that the inode only had 32768 pages, the
> > fact that apparently *some* codepath called ext4_da_writepages
> > starting at logical block 32759, with nr_to_write set to 32759, seems
> > very curious indeed.  That doesn't seem right at all.  It's late, so I
> > won't try to trace it down now; plus which it's your code so I figure
> > you can probably figure it out faster....
> 
> Interesting, needs checking up on. I've prepared a v14 patchset today,
> perhaps (if you have time), you can see if it reproduces there? I'm
> running some performance tests today, but will make a note to look into
> this after that.

It's because ext4 writepages sets ->range_start and wb_writeback() is
range cyclic, then the next iteration will have the previous end point
as the starting point. Looks like we need to clear ->range_start in
wb_writeback(), the better place is probably to do that in
fs/fs-writeback.c:generic_sync_wb_inodes() right after the
writeback_single_inode() call. This, btw, should be no different than
the current code, weird/correct or not :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
