Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 110546B0035
	for <linux-mm@kvack.org>; Tue, 10 May 2011 10:54:24 -0400 (EDT)
Date: Tue, 10 May 2011 16:54:21 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510145421.GJ4402@quack.suse.cz>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <87tyd31fkc.fsf@devron.myhome.or.jp>
 <20110510123819.GB4402@quack.suse.cz>
 <87hb924s2x.fsf@devron.myhome.or.jp>
 <20110510132953.GE4402@quack.suse.cz>
 <878vue4qjb.fsf@devron.myhome.or.jp>
 <87zkmu3b2i.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zkmu3b2i.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Tue 10-05-11 23:05:41, OGAWA Hirofumi wrote:
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
> 
> > Jan Kara <jack@suse.cz> writes:
> >
> >>> I see. So many block layer stuff sounds like broken on corner case? If
> >>> so, I more feel this approach should be temporary workaround, and should
> >>> use another less-blocking approach.
> >>   Not many but some... The alternative to less blocking approach is to do
> >> copy-out before a page is submitted for IO (or various middle ground
> >> alternatives of doing sometimes copyout, sometimes blocking...). That costs
> >> some performance as well. We talked about it at LSF and the approach
> >> Darrick is implementing was considered the least intrusive. There's really
> >> no way to fix these corner cases and keep performance.
> >
> > You already considered, to copy only if page was writeback (like
> > copy-on-write). I.e. if page is on I/O, copy, then switch the page for
> > writing new data.
> 
> missed question mark in here.
> 
> Did you already consider, to copy only if page was writeback (like
> copy-on-write)? I.e. if page is on I/O, copy, then switch the page for
> writing new data.
  Yes, that was considered as well. We'd have to essentially migrate the
page that is under writeback and should be written to. You are going to pay
the cost of page allocation, copy, increased memory & cache pressure.
Depending on your backing storage and workload this may or may not be better
than waiting for IO...

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
