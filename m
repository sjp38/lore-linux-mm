Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCD46B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 15:22:55 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH v3 0/3] data integrity: Stabilize pages during writeback for ext4
In-reply-to: <20110504184644.GA23246@infradead.org>
References: <20110406232938.GF1110@tux1.beaverton.ibm.com> <20110407165700.GB7363@quack.suse.cz> <20110408203135.GH1110@tux1.beaverton.ibm.com> <20110411124229.47bc28f6@corrin.poochiereds.net> <1302543595-sup-4352@think> <1302569212.2580.13.camel@mingming-laptop> <20110412005719.GA23077@infradead.org> <1302742128.2586.274.camel@mingming-laptop> <20110422000226.GA22189@tux1.beaverton.ibm.com> <20110504173704.GE20579@tux1.beaverton.ibm.com> <20110504184644.GA23246@infradead.org>
Date: Wed, 04 May 2011 15:21:55 -0400
Message-Id: <1304536162-sup-3721@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>

Excerpts from Christoph Hellwig's message of 2011-05-04 14:46:44 -0400:
> This seems to miss out on a lot of the generic functionality like
> write_cache_pages and block_page_mkwrite and just patch it into
> the ext4 copy & paste variants.  Please make sure your patches also
> work for filesystem that use more of the generic functionality like
> xfs or ext2 (the latter one might be fun for the mmap case).

Probably after the block_commit_write in block_page_mkwrite()
Another question is, do we want to introduce a wait_on_stable_page_writeback()?

This would allow us to add a check against the bdi requesting stable
pages.

> 
> Also what's the status of btrfs?  I remembered there was one or two
> bits missing despite doing the right thing in most areas.

As far as I know btrfs is getting it right.  The only bit missing is the
one Nick Piggin pointed out where it is possible to change mmap'd O_DIRECT
memory in flight while a DIO is in progress.  Josef has a test case that
demonstrates this.

Nick had a plan to fix it, but it involved redoing the get_user_pages
api.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
