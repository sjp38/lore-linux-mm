Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80DC48D003B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 23:30:45 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <87hb924s2x.fsf@devron.myhome.or.jp>
	<20110510132953.GE4402@quack.suse.cz>
	<878vue4qjb.fsf@devron.myhome.or.jp>
	<87zkmu3b2i.fsf@devron.myhome.or.jp>
	<20110510145421.GJ4402@quack.suse.cz>
	<87zkmupmaq.fsf@devron.myhome.or.jp>
	<20110510162237.GM4402@quack.suse.cz>
	<87vcxipljj.fsf@devron.myhome.or.jp>
	<20110516184736.GL20579@tux1.beaverton.ibm.com>
	<87oc3230iu.fsf@devron.myhome.or.jp>
	<20110517012307.GQ20579@tux1.beaverton.ibm.com>
Date: Tue, 17 May 2011 12:30:33 +0900
In-Reply-To: <20110517012307.GQ20579@tux1.beaverton.ibm.com> (Darrick
	J. Wong's message of "Mon, 16 May 2011 18:23:07 -0700")
Message-ID: <87hb8u2ecm.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: djwong@us.ibm.com
Cc: Jan Kara <jack@suse.cz>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

"Darrick J. Wong" <djwong@us.ibm.com> writes:

>> > With the new stable-page-writes patchset, the garbage write/disk
>> > error symptoms
>> > go away since the processes block instead of creating this window where it's
>> > not clear whether the disk's copy of the data is consistent.  I
>> > could turn the
>> > wait_on_page_writeback calls into some sort of page migration if the
>> > performance turns out to be terrible, though I'm still working on
>> > quantifying
>> > the impact.  Some people pointed out that sqlite tends to write
>> > the same blocks
>> > frequently, though I wonder if sqlite actually tries to write memory pages
>> > while syncing them?
>> >
>> > One use case where I could see a serious performance hit happening
>> > is the case
>> > where some app writes a bunch of memory pages, calls sync to force the dirty
>> > pages to disk, and /must/ resume writing those memory pages before the sync
>> > completes.  The page migration would of course help there, provided a memory
>> > page can be found in less time than an I/O operation.

[...]

>> I'm not thinking data page is special operation for doing this (at least
>> logically). In other word, if you are talking about only data page, you
>> shouldn't send patches for metadata with it.
>
> Patch 7, which is the only patch that touches code under fs/fat/, only fixes
> the case where the filesystem tries to modify its own metadata while writing
> out the same metadata.
>
> Patches 2 and 3, which affect only files mm/ and fs/, prevent data pages from
> being modified while the same data pages are being written out.  It is not
> necessary to modify any fs/fat/ code to fix the data page case, fortunately.
>
> That said, the intent of the patch set is to prevent writes to any memory page,
> regardless of type (data or metadata), while the same page is being written out.

Yes. I understand it though, performance analysis (and looks like
approach) can be quite difference with data page. The metadata depends
on FS, and it can be much more hit depends on FS state, not simple like
data page.

And if you changed only overwrite case, I already mentioned though,
which one makes sure to prevent reallocated metadata case for FAT?

What about metadata operations performance impact? Even if FS was low
free blocks state, performance impact is small? And read can be the
cause of atime update, don't matter (now relatime is default though)?
Although FAT specific, what about fragmented case (i.e. modify multiple
FAT table blocks even if sequential write)?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
