Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96B796B005A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:29:12 -0400 (EDT)
Date: Mon, 31 Aug 2009 12:29:09 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831102909.GS12579@kernel.dk>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831030815.GD20822@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 30 2009, Theodore Tso wrote:
> On Sun, Aug 30, 2009 at 06:27:10PM -0400, Christoph Hellwig wrote:
> > I'm don't think tuning it on a per-filesystem basis is a good idea,
> > we had to resort to this for 2.6.30 as a quick hack, and we will ged
> > rid of it again in 2.6.31 one way or another.  I personally think we
> > should fight this cancer of per-filesystem hacks in the writeback code
> > as much as we can.  Right now people keep adding tuning hacks for
> > specific workloads there, and at least all the modern filesystems (ext4,
> > btrfs and XFS) have very similar requirements to the writeback code,
> > that is give the filesystem as much as possible to write at the same
> > time to do intelligent decisions based on that.  The VM writeback code
> > fails horribly at that right now.
> 
> Yep; and Jens' patch doesn't change that.  It is still sending writes
> out to the filesystem a piddling 1024 pages at a time.

Right, I didn't want to change too much of the logic, tuning is better
left as follow up patches. There is one change, though - where the
current logic splits ->nr_to_write between devices, with the writeback
patches each get the "full" MAX_WRITEBACK_PAGES.

> > My stance is to wait for this until about -rc2 at which points Jens'
> > code is hopefully in and we can start doing all the fine-tuning,
> > including lots of benchmarking.
> 
> Well, I've ported my patch so it applies on top of Jens' per-bdi
> patch.  It seems to be clearly needed; Jens, would you agree to add it
> to your per-bdi patch series?  We can choose a different default if
> you like, but making MAX_WRITEBACK_PAGES tunable seems to be clearly
> necessary.

I don't mind adding it, but do we really want to export the value? If we
plan on making this dynamically adaptable soon, then we'll be stuck with
some proc file that doesn't really do much. I guess by then we can leave
it as a 'maximum ever' type control, which at least would do
something...

> By the way, while I was testing my patch on top of v13 of the per-bdi
> patches, I found something *very* curious.  I did a test where ran the
> following commands on a freshly mkfs'ed ext4 filesystem:
> 
> 	dd if=/dev/zero of=test1 bs=1024k count=128
> 	dd if=/dev/zero of=test2 bs=1024k count=128
> 	sync
> 
> I traced the calls to ext4_da_writepages() using ftrace, and found this:
> 
>       flush-8:16-1829  [001]    23.416351: ext4_da_writepages: dev sdb ino 12 nr_t_write 32759 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
>       flush-8:16-1829  [000]    25.939354: ext4_da_writepages: dev sdb ino 12 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
>       flush-8:16-1829  [000]    25.939486: ext4_da_writepages: dev sdb ino 13 nr_t_write 32759 pages_skipped 0 range_start 134180864 range_end 9223372036854775807 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
>       flush-8:16-1829  [000]    27.055687: ext4_da_writepages: dev sdb ino 12 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
>       flush-8:16-1829  [000]    27.055691: ext4_da_writepages: dev sdb ino 13 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
>       flush-8:16-1829  [000]    27.878708: ext4_da_writepages: dev sdb ino 13 nr_t_write 32768 pages_skipped 0 range_start 0 range_end 0 nonblocking 0 for_kupdate 0 for_reclaim 0 for_writepages 1 range_cyclic 1
> 
> The *first* time the per-bdi code called writepages on the second file
> (test2, inode #13), range_start was 134180864 (which, curiously
> enough, is 4096*32759, which was the value of nr_to_write passed to
> ext4_da_writepages).  Given that the inode only had 32768 pages, the
> fact that apparently *some* codepath called ext4_da_writepages
> starting at logical block 32759, with nr_to_write set to 32759, seems
> very curious indeed.  That doesn't seem right at all.  It's late, so I
> won't try to trace it down now; plus which it's your code so I figure
> you can probably figure it out faster....

Interesting, needs checking up on. I've prepared a v14 patchset today,
perhaps (if you have time), you can see if it reproduces there? I'm
running some performance tests today, but will make a note to look into
this after that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
