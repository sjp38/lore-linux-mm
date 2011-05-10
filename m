Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BD016B0026
	for <linux-mm@kvack.org>; Tue, 10 May 2011 08:51:28 -0400 (EDT)
Date: Tue, 10 May 2011 14:51:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510125124.GD4402@quack.suse.cz>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Mon 09-05-11 16:03:18, Darrick J. Wong wrote:
> I am still chasing down what exactly is broken in ext3.  data=writeback mode
> passes with no failures.  data=ordered, however, does not pass; my current
> suspicion is that jbd is calling submit_bh on data buffers but doesn't call
> page_mkclean to kick the userspace programs off the page before writing it.
  Yes, ext3 in data=ordered mode writes pages from
journal_commit_transaction() via submit_bh() without clearing page dirty
bits thus page_mkclean() is not called for these pages. Frankly, do you
really want to bother with adding support for ext2 and ext3? People can use
ext4 as a fs driver when they want to start using blk-integrity support.
Especially ext2 patch looks really painful and just from a quick look I can
see code e.g. in fs/ext2/namei.c which isn't handled by your patch yet.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
