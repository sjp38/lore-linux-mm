Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEE496B0069
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:07:31 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so18737511wjc.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:31 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id o64si8189710wmi.143.2017.02.06.06.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:07:28 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u63so22141624wmu.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:28 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6 v4] scope GFP_NOFS api
Date: Mon,  6 Feb 2017 15:07:12 +0100
Message-Id: <20170206140718.16222-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Brian Foster <bfoster@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

Hi,
I have posted the previous version here [1]. There are no real changes
in the implementation since then. Few acks added and one new user of
memalloc_noio_flags (in alloc_contig_range) converted. I have decided
to drop the last two ext4 related patches. One of them will be picked up
by Ted [2] and the other one will probably need more time to settle down.
I believe it is OK as is but let's not block the whole thing just because
of it.

There didn't seem to be any real objections and so I think we should
go and merge this to mmotm tree and target the next merge window. The
risk of regressions is really small because we do not remove any real
GFP_NOFS users yet.

I hope to get ext4 parts resolved in the follow up patches as well as
pull other filesystems in. There is still a lot work to do but having
the infrastructure in place should be very useful already.

The patchset is based on next-20170206

Diffstat says
 fs/jbd2/journal.c         |  7 +++++++
 fs/jbd2/transaction.c     | 11 +++++++++++
 fs/xfs/kmem.c             | 12 ++++++------
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
 mm/page_alloc.c           | 10 ++++++----
 mm/vmscan.c               |  6 +++---
 15 files changed, 100 insertions(+), 36 deletions(-)

Shortlog:
Michal Hocko (6):
      lockdep: allow to disable reclaim lockup detection
      xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
      mm: introduce memalloc_nofs_{save,restore} API
      xfs: use memalloc_nofs_{save,restore} instead of memalloc_noio*
      jbd2: mark the transaction context with the scope GFP_NOFS context
      jbd2: make the whole kjournald2 kthread NOFS safe

[1] http://lkml.kernel.org/r/20170106141107.23953-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170117030118.727jqyamjhojzajb@thunk.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
