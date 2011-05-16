Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF6C96B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:31:54 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <87tyd31fkc.fsf@devron.myhome.or.jp>
	<20110510123819.GB4402@quack.suse.cz>
	<87hb924s2x.fsf@devron.myhome.or.jp>
	<20110510132953.GE4402@quack.suse.cz>
	<878vue4qjb.fsf@devron.myhome.or.jp>
	<87zkmu3b2i.fsf@devron.myhome.or.jp>
	<20110510145421.GJ4402@quack.suse.cz>
	<87zkmupmaq.fsf@devron.myhome.or.jp>
	<20110510162237.GM4402@quack.suse.cz>
	<87vcxipljj.fsf@devron.myhome.or.jp>
	<20110516184736.GL20579@tux1.beaverton.ibm.com>
Date: Tue, 17 May 2011 04:31:37 +0900
In-Reply-To: <20110516184736.GL20579@tux1.beaverton.ibm.com> (Darrick
	J. Wong's message of "Mon, 16 May 2011 11:47:36 -0700")
Message-ID: <87oc3230iu.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: djwong@us.ibm.com
Cc: Jan Kara <jack@suse.cz>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

"Darrick J. Wong" <djwong@us.ibm.com> writes:

>> OK. E.g. usual workload on desktop, but FS like ext2/fat.
>
> In the frequent rewrite case, here's what you get:
>
> Regular disk: (possibly garbage) write, followed by a second write to make the
> disk reflect memory contents.
>
> RAID w/ shadow pages: two writes, both consistent.  Higher memory consumption.
>
> T10 DIF disk: disk error any time the CPU modifies a page that the disk
> controller is DMA'ing out of memory.  I suppose one could simply retry the
> operation if the page is dirty, but supposing memory writes are happening fast
> enough that the retries also produce disk errors, _nothing_ ever gets written.
>
> With the new stable-page-writes patchset, the garbage write/disk error symptoms
> go away since the processes block instead of creating this window where it's
> not clear whether the disk's copy of the data is consistent.  I could turn the
> wait_on_page_writeback calls into some sort of page migration if the
> performance turns out to be terrible, though I'm still working on quantifying
> the impact.  Some people pointed out that sqlite tends to write the same blocks
> frequently, though I wonder if sqlite actually tries to write memory pages
> while syncing them?
>
> One use case where I could see a serious performance hit happening is the case
> where some app writes a bunch of memory pages, calls sync to force the dirty
> pages to disk, and /must/ resume writing those memory pages before the sync
> completes.  The page migration would of course help there, provided a memory
> page can be found in less time than an I/O operation.
>
> Someone commented on the LWN article about this topic, claiming that he had a
> program that couldn't afford to block on writes to mlock()'d memory.  I'm not
> sure how to fix that program, because if memory writes never coordinate with
> disk writes and the other threads are always writing memory, I wonder how the
> copy on disk isn't always indeterminate.

I'm not thinking data page is special operation for doing this (at least
logically). In other word, if you are talking about only data page, you
shouldn't send patches for metadata with it.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
