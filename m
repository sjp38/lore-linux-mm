Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75ECB6B0391
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 21:57:33 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id w33so78434661uaw.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 18:57:33 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id j20si2425141vkf.122.2017.03.08.18.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 18:57:32 -0800 (PST)
Date: Wed, 8 Mar 2017 21:57:25 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
Message-ID: <20170309025725.5wrszri462zipiix@thunk.org>
References: <20170305133535.6516-1-jlayton@redhat.com>
 <1488724854.2925.6.camel@redhat.com>
 <20170306230801.GA28111@linux.intel.com>
 <20170307102622.GB2578@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307102622.GB2578@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, NeilBrown <neilb@suse.com>

On Tue, Mar 07, 2017 at 11:26:22AM +0100, Jan Kara wrote:
> On a more general note (DAX is actually fine here), I find the current
> practice of clearing page dirty bits on error and reporting it just once
> problematic. It keeps the system running but data is lost and possibly
> without getting the error anywhere where it is useful. We get away with
> this because it is a rare event but it seems like a problematic behavior.
> But this is more for the discussion at LSF.

I'm actually running into this in the last day or two because some MM
folks at $WORK have been trying to push hard for GFP_NOFS removal in
ext4 (at least when we are holding some mutex/semaphore like
i_data_sem) because otherwise it's possible for the OOM killer to be
unable to kill processes because they are holding on to locks that
ext4 is holding.

I've done some initial investigation, and while it's not that hard to
remove GFP_NOFS from certain parts of the writepages() codepath (which
is where we had been are running into problems), a really, REALLY big
problem is if any_filesystem->writepages() returns ENOMEM, it causes
silent data loss, because the pages are marked clean, and so data
written using buffered writeback goes *poof*.

I confirmed this by creating a test kernel with a simple patch such
that if the ext4 file system is mounted with -o debug, there was a 1
in 16 chance that ext4_writepages will immediately return with ENOMEM
(and printk the inode number, so I knew which inodes had gotten the
ENOMEM treatment).  The result was **NOT** pretty.

What I think we should strongly consider is at the very least, special
case ENOMEM being returned by writepages() during background
writeback, and *not* mark the pages clean, and make sure the inode
stays on the dirty inode list, so we can retry the write later.  This
is especially important since the process that issued the write may
have gone away, so there might not even be a userspace process to
complain to.  By converting certain page allocations (most notably in
ext4_mb_load_buddy) from GFP_NOFS to GFP_KMALLOC, this allows us to
release the i_data_sem lock and return an error.  This should allow
allow the OOM killer to do its dirty deed, and hopefully we can retry
the writepages() for that inode later.

In the case of a data integrity sync being issued by fsync() or
umount(), we could allow ENOMEM to get returned to userspace in that
case as well.  I'm not convinced all userspace code will handle an
ENOMEM correctly or sanely, but at least they people will be (less
likely) to blame file system developers.  :-)

The real problem that's going on here, by the way, is that people are
trying to run programs in insanely tight containers, and then when the
kernel locks up, they blame the mm developers.  But if there is silent
data corruption, they will blame the fs developers instead.  And while
kernel lockups are temporary (all you have to do is let the watchdog
reboot the system :-), silent data corruption is *forever*.  So what
we really need to do is to allow the OOM killer do its work, and if
job owners are unhappy that their processes are getting OOM killed,
maybe they will be suitably incentivized to pay for more memory in
their containers....

						- Ted

P.S. Michael Hocko, apologies for not getting back to you with your
GFP_NOFS removal patches.  But the possibility of fs malfunctions that
might lead to silent data corruption is why I'm being very cautious,
and I now have rather strong confirmation that this is not just an
irrational concern on my part.  (This is also performance review
season, FAST conference was last week, and Usenix ATC program
committee reviews are due this week.  So apologies for any reply
latency.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
