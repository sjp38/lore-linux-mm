Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 810CE6B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:23:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w1so70116263qtg.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:23:50 -0700 (PDT)
Received: from mail-qt0-f172.google.com (mail-qt0-f172.google.com. [209.85.216.172])
        by mx.google.com with ESMTPS id y123si9299033qkd.212.2017.06.19.09.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 09:23:49 -0700 (PDT)
Received: by mail-qt0-f172.google.com with SMTP id w1so113884889qtg.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:23:49 -0700 (PDT)
Message-ID: <1497889426.4654.7.camel@redhat.com>
Subject: Re: [PATCH v7 00/22] fs: enhanced writeback error reporting with
 errseq_t (pile #1)
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 19 Jun 2017 12:23:46 -0400
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri, 2017-06-16 at 15:34 -0400, Jeff Layton wrote:
> v7:
> ===
> This is the seventh posting of the patchset to revamp the way writeback
> errors are tracked and reported.
> 
> The main difference from the v6 posting is the removal of the
> FS_WB_ERRSEQ flag. That requires a few other incremental patches in the
> writeback code to ensure that both error tracking models are handled
> in a suitable way.
> 
> Also, a bit more cleanup of the metadata writeback codepaths, and some
> documentation updates.
> 
> Some of these patches have been posted separately, but I'm re-posting
> them here to make it clear that they're prerequisites of the later
> patches in the series.
> 
> This series is based on top of linux-next from a day or so ago. I'd like
> to have this picked up by linux-next in the near future so we can get
> some more extensive testing with it. Should I just plan to maintain a
> topic branch on top of -next and ask Stephen to pick it up?
> 
> Background:
> ===========
> The basic problem is that we have (for a very long time) tracked and
> reported writeback errors based on two flags in the address_space:
> AS_EIO and AS_ENOSPC. Those flags are cleared when they are checked,
> so only the first caller to check them is able to consume them.
> 
> That model is quite unreliable, for several related reasons:
> 
> * only the first fsync caller on the inode will see the error. In a
>   world of containerized setups, that's no longer viable. Applications
>   need to know that their writes are safely stored, and they can
>   currently miss seeing errors that they should be aware of when
>   they're not.
> 
> * there are a lot of internal callers to filemap_fdatawait* and
>   filemap_write_and_wait* that clear these errors but then never report
>   them to userland in any fashion.
> 
> * Some internal callers report writeback errors, but can do so at
>   non-sensical times. For instance, we might want to truncate a file,
>   which triggers a pagecache flush. If that writeback fails, we might
>   report that error to the truncate caller, but a subsequent fsync
>   will likely not see it.
> 
> * Some internal callers try to reset the error flags after clearing
>   them, but that's racy. Another task could check the flags between
>   those two events.
> 
> Solution:
> =========
> This patchset adds a new datatype called an errseq_t that represents a
> sequence of errors. It's a u32, with a field for a POSIX-flavor error
> and a counter, managed with atomics. We can sample that value at a
> particular point in time, and can later tell whether there have been any
> errors since that point.
> 
> That allows us to provide traditional check-and-clear fsync semantics
> on every open file description in a lightweight fashion. fsync callers
> no longer need to coordinate between one another in order to ensure
> that errors at fsync time are handled correctly.
> 
> Strategy:
> =========
> The aim with this pile is to do the minimum possible to support for
> reliable reporting of errors on fsync, without substantially changing
> the internals of the filesystems themselves.
> 
> Most of the internal calls to filemap_fdatawait are left alone, so all
> of the internal error checkers are using the same error handling they
> always have. The only real difference here is that we're better
> reporting errors at fsync.
> 
> I think that we probably will want to eventually convert all of those
> internal callers to use errseq_t based reporting, but that can be done
> in an incremental fashion in follow-on patchsets.
> 
> Testing:
> ========
> I've primarily been testing this with some new xfstests that I will post
> in a separate series. These tests use dm-error fault injection to make
> the underlying block device start throwing I/O errors, and then test the
> how the filesystem layer reports errors after that.
> 
> Jeff Layton (22):
>   fs: remove call_fsync helper function
>   buffer: use mapping_set_error instead of setting the flag
>   fs: check for writeback errors after syncing out buffers in
>     generic_file_fsync
>   buffer: set errors in mapping at the time that the error occurs
>   jbd2: don't clear and reset errors after waiting on writeback
>   mm: clear AS_EIO/AS_ENOSPC when writeback initiation fails
>   mm: don't TestClearPageError in __filemap_fdatawait_range
>   mm: clean up error handling in write_one_page
>   fs: always sync metadata in __generic_file_fsync
>   lib: add errseq_t type and infrastructure for handling it
>   fs: new infrastructure for writeback error handling and reporting
>   mm: tracepoints for writeback error events
>   mm: set both AS_EIO/AS_ENOSPC and errseq_t in mapping_set_error
>   Documentation: flesh out the section in vfs.txt on storing and
>     reporting writeback errors
>   dax: set errors in mapping when writeback fails
>   block: convert to errseq_t based writeback error tracking
>   ext4: use errseq_t based error handling for reporting data writeback
>     errors
>   fs: add f_md_wb_err field to struct file for tracking metadata errors
>   ext4: add more robust reporting of metadata writeback errors
>   ext2: convert to errseq_t based writeback error tracking
>   xfs: minimal conversion to errseq_t writeback error reporting
>   btrfs: minimal conversion to errseq_t writeback error reporting on
>     fsync
> 
>  Documentation/filesystems/vfs.txt |  43 +++++++-
>  drivers/dax/device.c              |   1 +
>  fs/block_dev.c                    |   9 +-
>  fs/btrfs/file.c                   |   7 +-
>  fs/buffer.c                       |  20 ++--
>  fs/dax.c                          |   4 +-
>  fs/ext2/dir.c                     |   8 ++
>  fs/ext2/file.c                    |  26 ++++-
>  fs/ext4/dir.c                     |   8 +-
>  fs/ext4/file.c                    |   5 +-
>  fs/ext4/fsync.c                   |  28 ++++-
>  fs/file_table.c                   |   1 +
>  fs/gfs2/lops.c                    |   2 +-
>  fs/jbd2/commit.c                  |  15 +--
>  fs/libfs.c                        |  12 +--
>  fs/open.c                         |   3 +
>  fs/sync.c                         |   2 +-
>  fs/xfs/xfs_file.c                 |  15 ++-
>  include/linux/buffer_head.h       |   1 +
>  include/linux/errseq.h            |  19 ++++
>  include/linux/fs.h                |  67 ++++++++++--
>  include/linux/pagemap.h           |  31 ++++--
>  include/trace/events/filemap.h    |  52 ++++++++++
>  ipc/shm.c                         |   2 +-
>  lib/Makefile                      |   2 +-
>  lib/errseq.c                      | 208 ++++++++++++++++++++++++++++++++++++++
>  mm/filemap.c                      | 113 +++++++++++++++++----
>  mm/page-writeback.c               |  15 ++-
>  28 files changed, 628 insertions(+), 91 deletions(-)
>  create mode 100644 include/linux/errseq.h
>  create mode 100644 lib/errseq.c
> 

If there are no major objections to this set, I'd like to have
linux-next start picking it up to get some wider testing. What's the
right vehicle for this, given that it touches stuff all over the tree?

I can see 3 potential options:

1) I could just pull these into the branch that Stephen is already
picking up for file-locks in my tree

2) I could put them into a new branch, and have Stephen pull that one in
addition to the file-locks branch

3) It could go in via someone else's tree entirely (Andrew or Al's
maybe?)

I'm fine with any of these. Anyone have thoughts?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
