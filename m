Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C14316B02BE
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:59:05 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so108029489wib.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:59:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si25688520wjz.12.2015.07.21.01.59.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 01:59:03 -0700 (PDT)
Date: Tue, 21 Jul 2015 10:58:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [regression 4.2-rc3] loop: xfstests xfs/073 deadlocked in low
 memory conditions
Message-ID: <20150721085859.GG11967@dhcp22.suse.cz>
References: <20150721015934.GY7943@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150721015934.GY7943@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ming Lei <ming.lei@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org

[CCing more people from a potentially affected fs - the reference to the 
 email thread is: http://marc.info/?l=linux-mm&m=143744398020147&w=2]

On Tue 21-07-15 11:59:34, Dave Chinner wrote:
> Hi Ming,
> 
> With the recent merge of the loop device changes, I'm now seeing
> XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.
> 
> The deadlocked is as follows:
> 
> kloopd1: loop_queue_read_work
> 	xfs_file_iter_read
> 	lock XFS inode XFS_IOLOCK_SHARED (on image file)
> 	page cache read (GFP_KERNEL)
> 	radix tree alloc
> 	memory reclaim
> 	reclaim XFS inodes
> 	log force to unpin inodes
> 	<wait for log IO completion>
> 
> xfs-cil/loop1: <does log force IO work>
> 	xlog_cil_push
> 	xlog_write
> 	<loop issuing log writes>
> 		xlog_state_get_iclog_space()
> 		<blocks due to all log buffers under write io>
> 		<waits for IO completion>
> 
> kloopd1: loop_queue_write_work
> 	xfs_file_write_iter
> 	lock XFS inode XFS_IOLOCK_EXCL (on image file)
> 	<wait for inode to be unlocked>
> 
> [The full stack traces are below].
> 
> i.e. the kloopd, with it's split read and write work queues, has
> introduced a dependency through memory reclaim. i.e. that writes
> need to be able to progress for reads make progress.
> 
> The problem, fundamentally, is that mpage_readpages() does a
> GFP_KERNEL allocation, rather than paying attention to the inode's
> mapping gfp mask, which is set to GFP_NOFS.
> 
> The didn't used to happen, because the loop device used to issue
> reads through the splice path and that does:
> 
> 	error = add_to_page_cache_lru(page, mapping, index,
> 			GFP_KERNEL & mapping_gfp_mask(mapping));
> 
> i.e. it pays attention to the allocation context placed on the
> inode and so is doing GFP_NOFS allocations here and avoiding the
> recursion problem.
> 
> [ CC'd Michal Hocko and the mm list because it's a clear exaple of
> why ignoring the mapping gfp mask on any page cache allocation is
> a landmine waiting to be tripped over. ]

Thank you for CCing me. I haven't noticed this one when checking for
other similar hardcoded GFP_KERNEL users (6afdb859b710 ("mm: do not
ignore mapping_gfp_mask in page cache allocation paths")). And there
seem to be more of them now that I am looking closer.

I am not sure what to do about fs/nfs/dir.c:nfs_symlink which doesn't
require GFP_NOFS or mapping gfp mask for other allocations in the same
context.

What do you think about this preliminary (and untested) patch? I cannot
say I would be happy about sprinkling mapping_gfp_mask all over the place
and it sounds like we should drop gfp_mask argument altogether and
use it internally in __add_to_page_cache_locked that would require all
the filesystems to use mapping gfp consistently which I am not sure is
the case here. From a quick glance it seems that some file system use
it all the time while others are selective.
---
