Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C05626B0283
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:30:50 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so28516189wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:30:50 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id e16si6738499wjz.164.2015.10.01.04.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 04:30:49 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so23759780wic.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:30:49 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:30:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, fs: Obey gfp_mapping for add_to_page_cache
Message-ID: <20151001113046.GA24077@dhcp22.suse.cz>
References: <1443193461-31402-1-git-send-email-mhocko@kernel.org>
 <20150929150246.286cc6013bce3eec170376aa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150929150246.286cc6013bce3eec170376aa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Ming Lei <ming.lei@canonical.com>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org

On Tue 29-09-15 15:02:46, Andrew Morton wrote:
> On Fri, 25 Sep 2015 17:04:21 +0200 mhocko@kernel.org wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 6afdb859b710 ("mm: do not ignore mapping_gfp_mask in page cache
> > allocation paths) has caught some users of hardcoded GFP_KERNEL
> > used in the page cache allocation paths. This, however, wasn't complete
> > and there were others which went unnoticed.
> > 
> > Dave Chinner has reported the following deadlock for xfs on loop device:
> > : With the recent merge of the loop device changes, I'm now seeing
> > : XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.
> > :
> > : The deadlocked is as follows:
> > :
> > : kloopd1: loop_queue_read_work
> > :       xfs_file_iter_read
> > :       lock XFS inode XFS_IOLOCK_SHARED (on image file)
> > :       page cache read (GFP_KERNEL)
> > :       radix tree alloc
> > :       memory reclaim
> > :       reclaim XFS inodes
> > :       log force to unpin inodes
> > :       <wait for log IO completion>
> > :
> > : xfs-cil/loop1: <does log force IO work>
> > :       xlog_cil_push
> > :       xlog_write
> > :       <loop issuing log writes>
> > :               xlog_state_get_iclog_space()
> > :               <blocks due to all log buffers under write io>
> > :               <waits for IO completion>
> > :
> > : kloopd1: loop_queue_write_work
> > :       xfs_file_write_iter
> > :       lock XFS inode XFS_IOLOCK_EXCL (on image file)
> > :       <wait for inode to be unlocked>
> > :
> > : i.e. the kloopd, with it's split read and write work queues, has
> > : introduced a dependency through memory reclaim. i.e. that writes
> > : need to be able to progress for reads make progress.
> > :
> > : The problem, fundamentally, is that mpage_readpages() does a
> > : GFP_KERNEL allocation, rather than paying attention to the inode's
> > : mapping gfp mask, which is set to GFP_NOFS.
> > :
> > : The didn't used to happen, because the loop device used to issue
> > : reads through the splice path and that does:
> > :
> > :       error = add_to_page_cache_lru(page, mapping, index,
> > :                       GFP_KERNEL & mapping_gfp_mask(mapping));
> > 
> > This has changed by aa4d86163e4 (block: loop: switch to VFS ITER_BVEC).
> 
> xfs-on-loop deadlocks since April would appear to warrant a -stable
> backport, yes?

Yeah, stable 4.1+

> > this is a rebase on top of the current mmotm
> > (2015-09-22-15-28)
> 
> So I've redone the patch against current mainline.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
