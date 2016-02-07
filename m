Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f173.google.com (mail-yw0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1B6830B2
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 14:13:53 -0500 (EST)
Received: by mail-yw0-f173.google.com with SMTP id u200so10075299ywf.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 11:13:53 -0800 (PST)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id e82si6888709ybh.194.2016.02.07.11.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 11:13:52 -0800 (PST)
Received: by mail-yw0-x235.google.com with SMTP id h129so88781003ywb.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 11:13:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
	<1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
Date: Sun, 7 Feb 2016 11:13:51 -0800
Message-ID: <CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, jmoyer <jmoyer@redhat.com>

On Sat, Feb 6, 2016 at 11:19 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> Previously calls to dax_writeback_mapping_range() for all DAX filesystems
> (ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
> dax_writeback_mapping_range() needs a struct block_device, and it used to
> get that from inode->i_sb->s_bdev.  This is correct for normal inodes
> mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> block devices and for XFS real-time files.
>
> Instead, call dax_writeback_mapping_range() directly from the filesystem or
> raw block device fsync/msync code so that they can supply us with a valid
> block device.
>
> It should be noted that this will reduce the number of calls to
> dax_writeback_mapping_range() because filemap_write_and_wait_range() is
> called in the various filesystems for operations other than just
> fsync/msync.  Both ext4 & XFS call filemap_write_and_wait_range() outside
> of ->fsync for hole punch, truncate, and block relocation
> (xfs_shift_file_space() && ext4_collapse_range()/ext4_insert_range()).
>
> I don't believe that these extra flushes are necessary in the DAX case.  In
> the page cache case when we have dirty data in the page cache, that data
> will be actively lost if we evict a dirty page cache page without flushing
> it to media first.  For DAX, though, the data will remain consistent with
> the physical address to which it was written regardless of whether it's in
> the processor cache or not - really the only reason I see to flush is in
> response to a fsync or msync so that our data is durable on media in case
> of a power loss.  The case where we could throw dirty data out of the page
> cache and essentially lose writes simply doesn't exist.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/block_dev.c      |  7 +++++++
>  fs/dax.c            |  5 ++---
>  fs/ext2/file.c      | 10 ++++++++++
>  fs/ext4/fsync.c     | 10 +++++++++-
>  fs/xfs/xfs_file.c   | 12 ++++++++++--
>  include/linux/dax.h |  4 ++--
>  mm/filemap.c        |  6 ------
>  7 files changed, 40 insertions(+), 14 deletions(-)

This sprinkling of dax specific fixups outside of vm_operations_struct
routines still has me thinking that we are going in the wrong
direction for fsync/msync support.

If an application is both unaware of DAX and doing mmap I/O it is
better served by the page cache where writeback is durable by default.
We expect DAX-aware applications to assume responsibility for cpu
cache management [1].  Making DAX mmap semantics explicit opt-in
solves not only durability support, but also the current problem that
DAX gets silently disabled leaving an app to wonder if it really got a
direct mapping. DAX also silently picks pud, pmd, or pte mappings
which is information an application would really like to know at map
time.

The proposal: make applications explicitly request DAX semantics with
a new MAP_DAX flag and fail if DAX is unavailable.  Document that a
successful MAP_DAX request mandates that the application assumes
responsibility for cpu cache management.  Require that all
applications that mmap the file agree on MAP_DAX.  This also solves
the future problem of DAX support on virtually tagged cache
architectures where it is difficult for the kernel to know what alias
addresses need flushing.

[1]: https://github.com/pmem/nvml

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
