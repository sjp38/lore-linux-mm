Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 762A06B0029
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:29:58 -0400 (EDT)
Date: Tue, 10 May 2011 15:29:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510132953.GE4402@quack.suse.cz>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <87tyd31fkc.fsf@devron.myhome.or.jp>
 <20110510123819.GB4402@quack.suse.cz>
 <87hb924s2x.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87hb924s2x.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Tue 10-05-11 22:12:54, OGAWA Hirofumi wrote:
> Jan Kara <jack@suse.cz> writes:
> 
> >> I'd like to know those patches are on what state. Waiting in writeback
> >> page makes slower, like you mentioned it (I guess it would more
> >> noticeable if device was slower that like FAT uses). And I think
> >> currently it doesn't help anything others for blk-integrity stuff
> >> (without other technic, it doesn't help FS consistency)?
> >> 
> >> So, why is this locking stuff enabled always? I think it would be better
> >> to enable only if blk-integrity stuff was enabled.
> >> 
> >> If it was more sophisticate but more complex stuff (e.g. use
> >> copy-on-write technic for it), I would agree always enable though.
> >   Well, also software RAID generally needs this feature (so that parity
> > information / mirror can be properly kept in sync). Not that I'd advocate
> > that this feature must be always enabled, it's just that there are also
> > other users besides blk-integrity.
> 
> I see. So many block layer stuff sounds like broken on corner case? If
> so, I more feel this approach should be temporary workaround, and should
> use another less-blocking approach.
  Not many but some... The alternative to less blocking approach is to do
copy-out before a page is submitted for IO (or various middle ground
alternatives of doing sometimes copyout, sometimes blocking...). That costs
some performance as well. We talked about it at LSF and the approach
Darrick is implementing was considered the least intrusive. There's really
no way to fix these corner cases and keep performance. But indeed a plain
SATA drive or a USB stick don't need stable pages so they wouldn't need to
pay the cost. So it would be beneficial if the underlying block device
propagated whether it needs stable writes or not and filesystem could turn
on stable pages accordingly.

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
