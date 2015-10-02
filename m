Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E71D182FA0
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 17:02:44 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so118400472pac.2
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 14:02:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pw1si19378900pbb.1.2015.10.02.14.02.44
        for <linux-mm@kvack.org>;
        Fri, 02 Oct 2015 14:02:44 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 0/3] Revert locking changes in DAX for v4.3
Date: Fri,  2 Oct 2015 15:02:29 -0600
Message-Id: <1443819752-17091-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <dchinner@redhat.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

This series reverts some recent changes to the locking scheme in DAX introduced
by these two commits:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

The list of issues in DAX after these commits (some newly introduced by the
commits, some preexisting) can be found here:
	    
https://lkml.org/lkml/2015/9/25/602

Several of these issues were preexisting, and are being addressed by moving the
locking in DAX to the filesystem.  A patch series doing this for XFS is here:

https://lkml.org/lkml/2015/10/1/180

These fixes will end up hitting v4.4, hopefully.

In the mean time the above two commits *did* introduce several deadlocks and a
null pointer issue.  I started fixing them one at a time:

https://lkml.org/lkml/2015/9/23/607
https://lkml.org/lkml/2015/9/22/668

But it soon became apparent that there were just too many corner cases.  The
current plan is to revert the locking in DAX to the old v4.2 scheme, and then
proceed with fixing the rest of the issues by moving the locking into the
various filesystems that support DAX.  Dave Chinner is working on this for XFS,
and Jan Kara has said he will help with ext4.

akpm, this series obviates my patch "dax: fix deadlock in __dax_fault()" that
is currently in the -mm tree but which I believe has not yet been sent to Linus.
Can you please just remove it from -mm?

Ross Zwisler (3):
  Revert "dax: fix NULL pointer in __dax_pmd_fault()"
  Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
  Revert "dax: fix race between simultaneous faults"

 fs/dax.c    | 83 +++++++++++++++++++++++++------------------------------------
 mm/memory.c |  2 ++
 2 files changed, 36 insertions(+), 49 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
