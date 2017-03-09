Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A31576B0452
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 05:47:55 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f191so111298458qka.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 02:47:55 -0800 (PST)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id r2si5371868qta.142.2017.03.09.02.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 02:47:54 -0800 (PST)
Received: by mail-qk0-f178.google.com with SMTP id p64so112559942qke.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 02:47:54 -0800 (PST)
Message-ID: <1489056471.2791.2.camel@redhat.com>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 09 Mar 2017 05:47:51 -0500
In-Reply-To: <20170309090449.GD15874@quack2.suse.cz>
References: <20170305133535.6516-1-jlayton@redhat.com>
	 <1488724854.2925.6.camel@redhat.com>
	 <20170306230801.GA28111@linux.intel.com>
	 <20170307102622.GB2578@quack2.suse.cz>
	 <20170309025725.5wrszri462zipiix@thunk.org>
	 <20170309090449.GD15874@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, NeilBrown <neilb@suse.com>

On Thu, 2017-03-09 at 10:04 +0100, Jan Kara wrote:
> On Wed 08-03-17 21:57:25, Ted Tso wrote:
> > On Tue, Mar 07, 2017 at 11:26:22AM +0100, Jan Kara wrote:
> > > On a more general note (DAX is actually fine here), I find the current
> > > practice of clearing page dirty bits on error and reporting it just once
> > > problematic. It keeps the system running but data is lost and possibly
> > > without getting the error anywhere where it is useful. We get away with
> > > this because it is a rare event but it seems like a problematic behavior.
> > > But this is more for the discussion at LSF.
> > 
> > I'm actually running into this in the last day or two because some MM
> > folks at $WORK have been trying to push hard for GFP_NOFS removal in
> > ext4 (at least when we are holding some mutex/semaphore like
> > i_data_sem) because otherwise it's possible for the OOM killer to be
> > unable to kill processes because they are holding on to locks that
> > ext4 is holding.
> > 
> > I've done some initial investigation, and while it's not that hard to
> > remove GFP_NOFS from certain parts of the writepages() codepath (which
> > is where we had been are running into problems), a really, REALLY big
> > problem is if any_filesystem->writepages() returns ENOMEM, it causes
> > silent data loss, because the pages are marked clean, and so data
> > written using buffered writeback goes *poof*.
> > 
> > I confirmed this by creating a test kernel with a simple patch such
> > that if the ext4 file system is mounted with -o debug, there was a 1
> > in 16 chance that ext4_writepages will immediately return with ENOMEM
> > (and printk the inode number, so I knew which inodes had gotten the
> > ENOMEM treatment).  The result was **NOT** pretty.
> > 
> > What I think we should strongly consider is at the very least, special
> > case ENOMEM being returned by writepages() during background
> > writeback, and *not* mark the pages clean, and make sure the inode
> > stays on the dirty inode list, so we can retry the write later.  This
> > is especially important since the process that issued the write may
> > have gone away, so there might not even be a userspace process to
> > complain to.  By converting certain page allocations (most notably in
> > ext4_mb_load_buddy) from GFP_NOFS to GFP_KMALLOC, this allows us to
> > release the i_data_sem lock and return an error.  This should allow
> > allow the OOM killer to do its dirty deed, and hopefully we can retry
> > the writepages() for that inode later.
> 
> Yeah, so if we can hope the error is transient, keeping pages dirty and
> retrying the write is definitely better option. For start we can say that
> ENOMEM, EINTR, EAGAIN, ENOSPC errors are transient, anything else means
> there's no hope of getting data to disk and so we just discard them. It
> will be somewhat rough distinction but probably better than what we have
> now.
> 
> 								Honza

I'm not sure about ENOSPC there. That's a return code that is
specifically expected to be returned by fsync. It seems like that ought
not be considered a transient error?

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
