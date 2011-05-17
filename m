Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B75156B0026
	for <linux-mm@kvack.org>; Mon, 16 May 2011 21:23:11 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4H0rk9d014983
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:53:46 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4H1N94p1101892
	for <linux-mm@kvack.org>; Mon, 16 May 2011 21:23:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4H1N8H7023310
	for <linux-mm@kvack.org>; Mon, 16 May 2011 22:23:09 -0300
Date: Mon, 16 May 2011 18:23:07 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
	writeback for various fses
Message-ID: <20110517012307.GQ20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <87hb924s2x.fsf@devron.myhome.or.jp> <20110510132953.GE4402@quack.suse.cz> <878vue4qjb.fsf@devron.myhome.or.jp> <87zkmu3b2i.fsf@devron.myhome.or.jp> <20110510145421.GJ4402@quack.suse.cz> <87zkmupmaq.fsf@devron.myhome.or.jp> <20110510162237.GM4402@quack.suse.cz> <87vcxipljj.fsf@devron.myhome.or.jp> <20110516184736.GL20579@tux1.beaverton.ibm.com> <87oc3230iu.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87oc3230iu.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Kara <jack@suse.cz>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Tue, May 17, 2011 at 04:31:37AM +0900, OGAWA Hirofumi wrote:
> "Darrick J. Wong" <djwong@us.ibm.com> writes:
> 
> >> OK. E.g. usual workload on desktop, but FS like ext2/fat.
> >
> > In the frequent rewrite case, here's what you get:
> >
> > Regular disk: (possibly garbage) write, followed by a second write to make the
> > disk reflect memory contents.
> >
> > RAID w/ shadow pages: two writes, both consistent.  Higher memory consumption.
> >
> > T10 DIF disk: disk error any time the CPU modifies a page that the disk
> > controller is DMA'ing out of memory.  I suppose one could simply retry the
> > operation if the page is dirty, but supposing memory writes are happening fast
> > enough that the retries also produce disk errors, _nothing_ ever gets written.
> >
> > With the new stable-page-writes patchset, the garbage write/disk error symptoms
> > go away since the processes block instead of creating this window where it's
> > not clear whether the disk's copy of the data is consistent.  I could turn the
> > wait_on_page_writeback calls into some sort of page migration if the
> > performance turns out to be terrible, though I'm still working on quantifying
> > the impact.  Some people pointed out that sqlite tends to write the same blocks
> > frequently, though I wonder if sqlite actually tries to write memory pages
> > while syncing them?
> >
> > One use case where I could see a serious performance hit happening is the case
> > where some app writes a bunch of memory pages, calls sync to force the dirty
> > pages to disk, and /must/ resume writing those memory pages before the sync
> > completes.  The page migration would of course help there, provided a memory
> > page can be found in less time than an I/O operation.
> >
> > Someone commented on the LWN article about this topic, claiming that he had a
> > program that couldn't afford to block on writes to mlock()'d memory.  I'm not
> > sure how to fix that program, because if memory writes never coordinate with
> > disk writes and the other threads are always writing memory, I wonder how the
> > copy on disk isn't always indeterminate.
> 
> I'm not thinking data page is special operation for doing this (at least
> logically). In other word, if you are talking about only data page, you
> shouldn't send patches for metadata with it.

Patch 7, which is the only patch that touches code under fs/fat/, only fixes
the case where the filesystem tries to modify its own metadata while writing
out the same metadata.

Patches 2 and 3, which affect only files mm/ and fs/, prevent data pages from
being modified while the same data pages are being written out.  It is not
necessary to modify any fs/fat/ code to fix the data page case, fortunately.

That said, the intent of the patch set is to prevent writes to any memory page,
regardless of type (data or metadata), while the same page is being written out.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
