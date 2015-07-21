Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 595236B02BB
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:46:17 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so42697504pdb.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 22:46:17 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id fx5si41063511pdb.170.2015.07.20.22.46.14
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 22:46:16 -0700 (PDT)
Date: Tue, 21 Jul 2015 15:46:12 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression 4.2-rc3] loop: xfstests xfs/073 deadlocked in low
 memory conditions
Message-ID: <20150721054612.GZ7943@dastard>
References: <20150721015934.GY7943@dastard>
 <CACVXFVMyW8SmuxPoZznemwQTnvXZLbxyoi9iYh7wK-3BdW=jbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVMyW8SmuxPoZznemwQTnvXZLbxyoi9iYh7wK-3BdW=jbQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Tue, Jul 21, 2015 at 12:05:56AM -0400, Ming Lei wrote:
> On Mon, Jul 20, 2015 at 9:59 PM, Dave Chinner <david@fromorbit.com> wrote:
> > Hi Ming,
> >
> > With the recent merge of the loop device changes, I'm now seeing
> > XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.
> >
> > The deadlocked is as follows:
> >
> > kloopd1: loop_queue_read_work
> >         xfs_file_iter_read
> >         lock XFS inode XFS_IOLOCK_SHARED (on image file)
> >         page cache read (GFP_KERNEL)
> >         radix tree alloc
> >         memory reclaim
> >         reclaim XFS inodes
> >         log force to unpin inodes
> >         <wait for log IO completion>
> >
> > xfs-cil/loop1: <does log force IO work>
> >         xlog_cil_push
> >         xlog_write
> >         <loop issuing log writes>
> >                 xlog_state_get_iclog_space()
> >                 <blocks due to all log buffers under write io>
> >                 <waits for IO completion>
> >
> > kloopd1: loop_queue_write_work
> >         xfs_file_write_iter
> >         lock XFS inode XFS_IOLOCK_EXCL (on image file)
> >         <wait for inode to be unlocked>
> >
> > [The full stack traces are below].
> >
> > i.e. the kloopd, with it's split read and write work queues, has
> > introduced a dependency through memory reclaim. i.e. that writes
> > need to be able to progress for reads make progress.
> 
> This kind of change just makes READ vs READ OR WRITE submitted
> to fs concurrently, and the use case should have been simulated from
> user space on one regular XFS file too?

Assuming the "regular XFS file" is on a normal block device (i.e.
not a loop device) then this will not deadlock as there is not
dependency on vfs level locking for log writes.

i.e. normal userspace IO path is:

userspace read
	vfs_read
	  xfs_read
	    page cache alloc (GFP_KERNEL)
	      direct reclaim
	        xfs_inode reclaim
		  log force
		    CIL push
		      <workqueue>
		        xlog_write
			  submit_bio
			    -> hardware.

And then the log IO completes, and everything continues onward.

What the loop device used to do:

userspace read
	vfs_read
	  xfs_read
	    page cache alloc (GFP_KERNEL)
	    submit_bio
	      loop device
	        splice_read (on image file)
		  xfs_splice_read
		    page cache alloc (GFP_NOFS)
		      direct reclaim
		        <skip filesystem reclaim>
		      submit_bio
		        -> hardware.

And when the read Io completes, everything moves onwards.

What the loop device now does:

userspace read
	vfs_read
	  xfs_read
	    page cache alloc (GFP_KERNEL)
	    submit_bio
	      loop device
	        <workqueue>
	        vfs_read (on image file)
		  xfs_read
		    page cache alloc (GFP_KERNEL)
		      direct reclaim
			xfs_inode reclaim
			  log force
			    CIL push
			      <workqueue>
				xlog_write
				  submit_bio
				    loop device
				    <workqueue>
				      vfs_write (on image file)
				        xfs_write
					  <deadlock on image file lock>


> > The problem, fundamentally, is that mpage_readpages() does a
> > GFP_KERNEL allocation, rather than paying attention to the inode's
> > mapping gfp mask, which is set to GFP_NOFS.
> 
> That looks the root cause, and I guess the issue is just triggered
> after commit aa4d86163e4(block: loop: switch to VFS ITER_BVEC)
> which changes splice to bvec iterator.

Yup - you are the unfortunate person who has wandered into the
minefield I'd been telling people about for quite some time. :(

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
