Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E01236B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 09:11:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so3583024wms.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:11:16 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id x125si2736178wmd.163.2017.01.06.06.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 06:11:15 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u144so5289729wmu.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:11:15 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/8 v3] scope GFP_NOFS api
Date: Fri,  6 Jan 2017 15:10:59 +0100
Message-Id: <20170106141107.23953-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@suse.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>

Hi,
I have posted the previous version here [1]. Since then I've added some
reviewed bys and fixed some minor issues. I've dropped patch 2 [2] based
on Dave's request [3]. I agree that this can be done later and doing
all at once. I still think that __GFP_NOLOCKDEP should be added by this
series to make the further development easier.

There didn't seem to be any real objections and so I think we should go
and merge this and build further on top. I would like to get rid of all
explicit GFP_NOFS usage in ext4 code. I have something half baked already
and will send it later on. I also hope we can get further with the xfs
as well.

I haven't heard anything from btrfs or other filesystems guys which is a
bit unfortunate but I do not want to wait for them to much longer, they
can join the effort later on.

The patchset is based on next-20170106

Diffstat says
 fs/ext4/acl.c             |  6 +++---
 fs/ext4/extents.c         |  8 ++++----
 fs/ext4/resize.c          |  4 ++--
 fs/ext4/xattr.c           |  4 ++--
 fs/jbd2/journal.c         |  7 +++++++
 fs/jbd2/transaction.c     | 11 +++++++++++
 fs/xfs/kmem.c             | 10 +++++-----
 fs/xfs/kmem.h             |  2 +-
 fs/xfs/libxfs/xfs_btree.c |  2 +-
 fs/xfs/xfs_aops.c         |  6 +++---
 fs/xfs/xfs_buf.c          |  8 ++++----
 fs/xfs/xfs_trans.c        | 12 ++++++------
 include/linux/gfp.h       | 18 +++++++++++++++++-
 include/linux/jbd2.h      |  2 ++
 include/linux/sched.h     | 32 ++++++++++++++++++++++++++------
 kernel/locking/lockdep.c  |  6 +++++-
 lib/radix-tree.c          |  2 ++
 mm/page_alloc.c           |  8 +++++---
 mm/vmscan.c               |  6 +++---
 19 files changed, 109 insertions(+), 45 deletions(-)

Shortlog:
Michal Hocko (8):
      lockdep: allow to disable reclaim lockup detection
      xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
      mm: introduce memalloc_nofs_{save,restore} API
      xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
      jbd2: mark the transaction context with the scope GFP_NOFS context
      jbd2: make the whole kjournald2 kthread NOFS safe
      Revert "ext4: avoid deadlocks in the writeback path by using sb_getblk_gfp"
      Revert "ext4: fix wrong gfp type under transaction"

[1] http://lkml.kernel.org/r/20161215140715.12732-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20161215140715.12732-3-mhocko@kernel.org
[3] http://lkml.kernel.org/r/20161219212413.GN4326@dastard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
