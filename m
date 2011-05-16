Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A00666B0024
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:49:31 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GIMXoT026383
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:22:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GInUIY088982
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:49:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GInSQf017674
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:49:29 -0300
Date: Mon, 16 May 2011 11:49:27 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
	writeback for various fses
Message-ID: <20110516184927.GM20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com> <20110510125124.GD4402@quack.suse.cz> <20110511181901.GK20579@tux1.beaverton.ibm.com> <20110512094255.GA4690@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110512094255.GA4690@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Thu, May 12, 2011 at 11:42:55AM +0200, Jan Kara wrote:
> On Wed 11-05-11 11:19:01, Darrick J. Wong wrote:
> > On Tue, May 10, 2011 at 02:51:24PM +0200, Jan Kara wrote:
> > > On Mon 09-05-11 16:03:18, Darrick J. Wong wrote:
> > > > I am still chasing down what exactly is broken in ext3.  data=writeback mode
> > > > passes with no failures.  data=ordered, however, does not pass; my current
> > > > suspicion is that jbd is calling submit_bh on data buffers but doesn't call
> > > > page_mkclean to kick the userspace programs off the page before writing it.
> > >   Yes, ext3 in data=ordered mode writes pages from
> > > journal_commit_transaction() via submit_bh() without clearing page dirty
> > > bits thus page_mkclean() is not called for these pages. Frankly, do you
> > > really want to bother with adding support for ext2 and ext3? People can use
> > > ext4 as a fs driver when they want to start using blk-integrity support.
> > > Especially ext2 patch looks really painful and just from a quick look I can
> > > see code e.g. in fs/ext2/namei.c which isn't handled by your patch yet.
> > 
> > Yeah, I agree that ext2 is ugly and ext3/jbd might be more painful.  Are there
> > any other code that wants stable pages that's already running with ext3?  In
> > this months-long discussion I've heard that encryption and raid also like
> > stable pages during writes.  Have those users been broken this whole time, or
> > have they been stabilizing pages themselves?
>   I believe part of them has been broken (e.g. raid) and part of them do
> copy-out so they were OK.

A future step might be to undo all these homegrown copy-outs?

> > I suppose we can cross the "ext3 fails horribly on DIF" bridge when someone
> > complains about it.  Possibly we could try to steer them to btrfs.
>   Well, btrfs might be a bit too advantageous for production servers but
> ext4 would be definitely viable for them.

Are there any distros that are going straight from ext3 to btrfs?

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
