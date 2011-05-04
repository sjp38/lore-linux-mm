Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2EC76B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 16:00:36 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p44Je2OS002288
	for <linux-mm@kvack.org>; Wed, 4 May 2011 15:40:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44K0XGt1364194
	for <linux-mm@kvack.org>; Wed, 4 May 2011 16:00:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44K0WlC030935
	for <linux-mm@kvack.org>; Wed, 4 May 2011 17:00:33 -0300
Date: Wed, 4 May 2011 13:00:31 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCH v3 0/3] data integrity: Stabilize pages during
	writeback for ext4
Message-ID: <20110504200031.GI20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110408203135.GH1110@tux1.beaverton.ibm.com> <20110411124229.47bc28f6@corrin.poochiereds.net> <1302543595-sup-4352@think> <1302569212.2580.13.camel@mingming-laptop> <20110412005719.GA23077@infradead.org> <1302742128.2586.274.camel@mingming-laptop> <20110422000226.GA22189@tux1.beaverton.ibm.com> <20110504173704.GE20579@tux1.beaverton.ibm.com> <20110504184644.GA23246@infradead.org> <1304536162-sup-3721@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304536162-sup-3721@think>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>

On Wed, May 04, 2011 at 03:21:55PM -0400, Chris Mason wrote:
> Excerpts from Christoph Hellwig's message of 2011-05-04 14:46:44 -0400:
> > This seems to miss out on a lot of the generic functionality like
> > write_cache_pages and block_page_mkwrite and just patch it into
> > the ext4 copy & paste variants.  Please make sure your patches also
> > work for filesystem that use more of the generic functionality like
> > xfs or ext2 (the latter one might be fun for the mmap case).
> 
> Probably after the block_commit_write in block_page_mkwrite()

Yes, I'm working on providing more generic fixes for ext3 & friends too, but
they're not really working yet, so I was posting the parts that fix ext4, since
they seem usable.

> Another question is, do we want to introduce a wait_on_stable_page_writeback()?
> 
> This would allow us to add a check against the bdi requesting stable
> pages.

Sounds like a good idea.

> > Also what's the status of btrfs?  I remembered there was one or two
> > bits missing despite doing the right thing in most areas.
> 
> As far as I know btrfs is getting it right.  The only bit missing is the
> one Nick Piggin pointed out where it is possible to change mmap'd O_DIRECT
> memory in flight while a DIO is in progress.  Josef has a test case that
> demonstrates this.
> 
> Nick had a plan to fix it, but it involved redoing the get_user_pages
> api.

I ran the same six tests A-F on btrfs and it reported -ENOSPC with 1% of the
space used, though until it did that I didn't see any checksum errors.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
