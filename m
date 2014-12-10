Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 812246B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:33 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so1703624pdb.36
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:33 -0800 (PST)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id dg8si4230380pdb.242.2014.12.09.17.46.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:31 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id r10so1734328pdi.9
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:31 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 0/7] btrfs: implement swap file support
Date: Tue,  9 Dec 2014 17:45:41 -0800
Message-Id: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Hi, everyone,

This patch series, based on v3.18, implements support for swap files on BTRFS.
Patches 1, 3, and 4 are for the VFS folks, patch 2 is for NFS, and the rest is
all BTRFS.

The standard swap file implementation uses bmap() to get a list of physical
blocks to do I/O on. This doesn't work for BTRFS, which moves disk blocks around
as part of normal operation (COW, defragmentation, etc.).

Swap-over-NFS introduced an interface through which a filesystem can arbitrate
swap I/O through address space operations:

- swap_activate() is called by swapon() and informs the address space that the
  given file is going to be used for swap, so it should take adequate measures
  like reserving space on disk and pinning block lookup information in memory
- swap_deactivate() is used to clean up on swapoff()
- direct_IO() is used to page in and out (this no longer uses readpage as part
  of this patch series)

Patches 1-4 clean up the necessary infrastructure. There's more that can make
this better (like resurrecting kernel AIO), but that can be done as a follow-up
to the work here.

Patches 5 and 6 lay the groundwork needed for using a swap file on BTRFS, and
patch 7 implements the actual aops.

Version 3 incorporates a bunch of David Sterba's feedback, both style and design
issues. We now audit various ioctls to prevent them from interfering with swap
file operation and handle extents which can't be nocow'd.

After some discussion on the mailing list, I decided that for simplicity and
reliability, it's best to simply disallow COW files and files with shared
extents (like files with extents shared with a snapshot). From a user's
perspective, this means that a snapshotted subvolume cannot be used for a swap
file, but keeping the swap file in a separate subvolume that is never
snapshotted seems entirely reasonable to me. An alternative suggestion was to
allow swap files to be snapshotted and to do an implied COW on swap file
activation, which I was ready to implement until I realized that we can't permit
snapshotting a subvolume with an active swap file, so this creates a surprising
inconsistency for users (in my opinion).

As with before, this functionality is tenuously tested in a virtual machine with
some artificial workloads, but it "works for me". I'm pretty happy with the
results on my end, so please comment away.

Thanks!

Omar Sandoval (7):
  direct-io: don't dirty ITER_BVEC pages on read
  nfs: don't dirty ITER_BVEC pages read through direct I/O
  swap: use direct I/O for SWP_FILE swap_readpage
  vfs: update swap_{,de}activate documentation
  btrfs: prevent ioctls from interfering with a swap file
  btrfs: add EXTENT_FLAG_SWAPFILE
  btrfs: enable swap file support

 Documentation/filesystems/Locking |   7 +-
 Documentation/filesystems/vfs.txt |   7 +-
 fs/btrfs/ctree.h                  |   3 +
 fs/btrfs/disk-io.c                |   1 +
 fs/btrfs/extent_io.c              |   1 +
 fs/btrfs/extent_map.h             |   1 +
 fs/btrfs/inode.c                  | 132 ++++++++++++++++++++++++++++++++++++++
 fs/btrfs/ioctl.c                  |  35 ++++++++--
 fs/direct-io.c                    |   8 ++-
 fs/nfs/direct.c                   |   5 +-
 include/trace/events/btrfs.h      |   3 +-
 mm/page_io.c                      |  32 +++++++--
 12 files changed, 216 insertions(+), 19 deletions(-)

-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
