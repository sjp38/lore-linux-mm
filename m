Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 90FE06B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 21:59:28 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
Date: Tue, 10 May 2011 10:59:15 +0900
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
	(Darrick J. Wong's message of "Mon, 09 May 2011 16:03:18 -0700")
Message-ID: <87tyd31fkc.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

"Darrick J. Wong" <djwong@us.ibm.com> writes:

> To assess the performance impact of stable page writes, I moved to a disk that
> doesn't have DIF support so that I could measure just the impact of waiting for
> writeback.  I first ran wac with 64 threads madly scribbling on a 64k file and
> saw about a 12 percent performance decrease.  I then reran the wac program with
> 64 threads and a 64MB file and saw about the same performance numbers.  As I
> suspected, the patchset only seems to impact workloads that rewrite the same
> memory page frequently.
>
> I am still chasing down what exactly is broken in ext3.  data=writeback mode
> passes with no failures.  data=ordered, however, does not pass; my current
> suspicion is that jbd is calling submit_bh on data buffers but doesn't call
> page_mkclean to kick the userspace programs off the page before writing it.
>
> Per various comments regarding v3 of this patchset, I've integrated his
> suggestions, reworked the patch descriptions to make it clearer which ones
> touch all the filesystems and which ones are to fix remaining holes in specific
> filesystems, and expanded the scope of filesystems that got fixed.
>
> As always, questions and comments are welcome; and thank you to all the
> previous reviewers of this patchset.  I am also soliciting people's opinions on
> whether or not these patches could go upstream for .40.

I'd like to know those patches are on what state. Waiting in writeback
page makes slower, like you mentioned it (I guess it would more
noticeable if device was slower that like FAT uses). And I think
currently it doesn't help anything others for blk-integrity stuff
(without other technic, it doesn't help FS consistency)?

So, why is this locking stuff enabled always? I think it would be better
to enable only if blk-integrity stuff was enabled.

If it was more sophisticate but more complex stuff (e.g. use
copy-on-write technic for it), I would agree always enable though.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
