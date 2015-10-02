Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2440682FA0
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 16:49:56 -0400 (EDT)
Received: by qgx61 with SMTP id 61so105493066qgx.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 13:49:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n64si11907803qhb.34.2015.10.02.13.49.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 13:49:54 -0700 (PDT)
Date: Fri, 2 Oct 2015 13:49:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-Id: <20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
In-Reply-To: <20151002072522.GC30354@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
	<20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
	<20151002072522.GC30354@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri, 2 Oct 2015 09:25:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> 6afdb859b710 ("mm: do not ignore mapping_gfp_mask in page cache allocation
> paths") has caught some users of hardcoded GFP_KERNEL used in the page
> cache allocation paths.  This, however, wasn't complete and there were
> others which went unnoticed.
> 
> Dave Chinner has reported the following deadlock for xfs on loop device:
> : With the recent merge of the loop device changes, I'm now seeing
> : XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.
> :
> : The deadlocked is as follows:
> :
> : kloopd1: loop_queue_read_work
> :       xfs_file_iter_read
> :       lock XFS inode XFS_IOLOCK_SHARED (on image file)
> :       page cache read (GFP_KERNEL)
> :       radix tree alloc
> :       memory reclaim
> :       reclaim XFS inodes
> :       log force to unpin inodes
> :       <wait for log IO completion>
> :
> : xfs-cil/loop1: <does log force IO work>
> :       xlog_cil_push
> :       xlog_write
> :       <loop issuing log writes>
> :               xlog_state_get_iclog_space()
> :               <blocks due to all log buffers under write io>
> :               <waits for IO completion>
> :
> : kloopd1: loop_queue_write_work
> :       xfs_file_write_iter
> :       lock XFS inode XFS_IOLOCK_EXCL (on image file)
> :       <wait for inode to be unlocked>
> :
> : i.e. the kloopd, with it's split read and write work queues, has
> : introduced a dependency through memory reclaim. i.e. that writes
> : need to be able to progress for reads make progress.
> :
> : The problem, fundamentally, is that mpage_readpages() does a
> : GFP_KERNEL allocation, rather than paying attention to the inode's
> : mapping gfp mask, which is set to GFP_NOFS.
> :
> : The didn't used to happen, because the loop device used to issue
> : reads through the splice path and that does:
> :
> :       error = add_to_page_cache_lru(page, mapping, index,
> :                       GFP_KERNEL & mapping_gfp_mask(mapping));
> 
> This has changed by aa4d86163e4 ("block: loop: switch to VFS ITER_BVEC").
> 
> This patch changes mpage_readpage{s} to follow gfp mask set for the
> mapping.  There are, however, other places which are doing basically the
> same.
> 
> lustre:ll_dir_filler is doing GFP_KERNEL from the function which
> apparently uses GFP_NOFS for other allocations so let's make this
> consistent.
> 
> cifs:readpages_get_pages is called from cifs_readpages and
> __cifs_readpages_from_fscache called from the same path obeys mapping
> gfp.
> 
> ramfs_nommu_expand_for_mapping is hardcoding GFP_KERNEL as well
> regardless it uses mapping_gfp_mask for the page allocation.
> 
> ext4_mpage_readpages is the called from the page cache allocation path
> same as read_pages and read_cache_pages
> 
> As I've noticed in my previous post I cannot say I would be happy about
> sprinkling mapping_gfp_mask all over the place and it sounds like we
> should drop gfp_mask argument altogether and use it internally in
> __add_to_page_cache_locked that would require all the filesystems to use
> mapping gfp consistently which I am not sure is the case here.  From a
> quick glance it seems that some file system use it all the time while
> others are selective.

There's a lot of confusion here, so let's try to do some clear
thinking.

mapping_gfp_mask() describes the mask to be used for allocating this
mapping's pagecache pages.  Nothing else.  I introduced it to provide a
clean way to ensure that blockdev inode pagecache is not allocated from
highmem.

This is totally different from "I'm holding a lock so I can't do
__GFP_FS"!  __GFP_HIGHMEM and __GFP_FS are utterly unrelated concepts -
the only commonality is that they happen to be passed to callees in the
same memory word.

At present the VFS provides no way for the filesystem to specify the
allocation mode for pagecache operations.  The VFS assumes
__GFP_FS|__GFP_IO|__GFP_WAIT|etc.  mapping_gfp_mask() may *look* like
it provides a way, but it doesn't.

The way for a caller to communicate "I can't do __GFP_FS from this
particular callsite" is to pass that info in a gfp_t, in a function
call argument.  It is very wrong to put this info into
mapping_gfp_mask(), as XFS has done.  For obvious reasons: different
callsites may want different values.

One can easily envision a filesystem whose read() can allocate
pagecache with GFP_HIGHUSER but the write() needs
GFP_HIGHUSER&~__GFP_FS.  This obviously won't fly if we're (ab)using
mapping_gpf_mask() in this fashion.  Also callsites who *can* use the
stronger __GFP_FS are artificially prevented from doing so.


So.

By far the best way of addressing this bug is to fix XFS so that it can
use __GFP_FS for allocating pagecache.  It's really quite lame that the
filesystem cannot use the strongest memory allocation mode for the
largest volume of allocation.  Obviously this fix is too difficult,
otherwise it would already have been made.


The second best way of solving this bug is to pass a gfp_t into the
relevant callees, in the time-honoured manner.  That would involve
alteration of probably several address_space_operations function
pointers and lots of mind-numbing mechanical edits and bloat.


The third best way is to pass the gfp_t via the task_struct.  See
memalloc_noio_save() and memalloc_noio_restore().  This is a pretty
grubby way of passing function arguments, but I'm OK with it in this
special case, because

  a) Adding a gfp_t arg to 11 billion functions has costs of
     several forms

  b) Adding all these costs just because one filesystem is being
     weird doesn't make sense

  c) The mpage functions already have too many arguments.  Adding
     yet another is getting kinda ridiculous, and will cost more stack
     on some of our deepest paths.


The fourth best way of fixing this is a nasty short-term bodge, such a
the one you just sent ;) But if we're going to do this, it should be
the minimal bodge which fixes this deadlock.  Is it possible to come up
with a one-liner (plus suitable comment) to get us out of this mess?


Longer-term I suggest we look at generalising the memalloc_noio_foo()
stuff so as to permit callers to mask off (ie: zero) __GFP_ flags in
callees.  I have a suspicion we should have done this 15 years ago
(which is about when I started wanting to do it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
