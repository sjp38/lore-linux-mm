Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECAD16B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:07:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so11184949wmf.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:50 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id n1si2670436wme.119.2016.12.15.06.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 06:07:49 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id he10so9970903wjc.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:49 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/9 v2] scope GFP_NOFS api
Date: Thu, 15 Dec 2016 15:07:06 +0100
Message-Id: <20161215140715.12732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>

Hi,
I have posted the previous version here [1]. Since then I have added a
support to suppress reclaim lockdep warnings (__GFP_NOLOCKDEP) to allow
removing GFP_NOFS usage motivated by the lockdep false positives. On top
of that I've tried to convert few KM_NOFS usages to use the new flag in
the xfs code base. This would need a review from somebody familiar with
xfs of course.

Then I've added the new scope API to the jbd/ext transaction code +
reverted some explicit GFP_NOFS usages which are covered by the scope one
now. This also needs a deep review from ext developers. I have some more
patches which remove more explicit GFP_NOFS users but that is not really
ready yet. I would really appreciate if developers for other filesystems
joined me here as well. Maybe ext parts can help to show how to start.
Especially btrfs which uses GFP_NOFS a lot (and not with a good reason
in many cases I suspect).

The patchset is based on linux-next (next-20161214).

I think the GFP_NOIO should be seeing the same clean up but that is not
a part of this patchset.

Any feedback is highly appreciated of course.

Diffstat says
 fs/ext4/acl.c                |  6 +++---
 fs/ext4/extents.c            |  8 ++++----
 fs/ext4/resize.c             |  4 ++--
 fs/ext4/xattr.c              |  4 ++--
 fs/jbd2/journal.c            |  7 +++++++
 fs/jbd2/transaction.c        | 11 +++++++++++
 fs/xfs/kmem.c                | 10 +++++-----
 fs/xfs/kmem.h                |  6 +++++-
 fs/xfs/libxfs/xfs_btree.c    |  2 +-
 fs/xfs/libxfs/xfs_da_btree.c |  4 ++--
 fs/xfs/xfs_aops.c            |  6 +++---
 fs/xfs/xfs_buf.c             | 10 +++++-----
 fs/xfs/xfs_dir2_readdir.c    |  2 +-
 fs/xfs/xfs_trans.c           | 12 ++++++------
 include/linux/gfp.h          | 18 +++++++++++++++++-
 include/linux/jbd2.h         |  2 ++
 include/linux/sched.h        | 32 ++++++++++++++++++++++++++------
 kernel/locking/lockdep.c     |  6 +++++-
 lib/radix-tree.c             |  2 ++
 mm/page_alloc.c              |  8 +++++---
 mm/vmscan.c                  |  6 +++---
 21 files changed, 117 insertions(+), 49 deletions(-)

Shortlog:
Michal Hocko (9):
      lockdep: allow to disable reclaim lockup detection
      xfs: introduce and use KM_NOLOCKDEP to silence reclaim lockdep false positives
      xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
      mm: introduce memalloc_nofs_{save,restore} API
      xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
      jbd2: mark the transaction context with the scope GFP_NOFS context
      jbd2: make the whole kjournald2 kthread NOFS safe
      Revert "ext4: avoid deadlocks in the writeback path by using sb_getblk_gfp"
      Revert "ext4: fix wrong gfp type under transaction"


[1] http://lkml.kernel.org/r/1461671772-1269-1-git-send-email-mhocko@kernel.org


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
