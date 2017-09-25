Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29D866B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:14:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so15443703pff.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:14:25 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 142si4752383pgg.395.2017.09.25.16.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:14:24 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 0/7] re-enable XFS per-inode DAX
Date: Mon, 25 Sep 2017 17:13:57 -0600
Message-Id: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

This series does the work needed to safely re-enable the XFS per-inode DAX
flag.  This includes fixes to make use of the DAX inode flag more safe and
consistent, fixes to the read and write I/O path locking to make S_DAX
transitions safe, and some code that prevents the DAX inode flag from
transitioning when any mappings are set up.

This series has passed my fstests regression testing both with and without
DAX, and it also passes Christoph's regression test for the inode flag:

https://www.spinics.net/lists/linux-xfs/msg10124.html

My goal is to get feedback on this approach and on the XFS implementation,
and then to do a similar implementation for ext4 based on my previous ext4
DAX inode flag patches:

https://patchwork.kernel.org/patch/9939743/

These patches apply cleanly to v4.14-rc2.

Ross Zwisler (7):
  xfs: always use DAX if mount option is used
  xfs: validate bdev support for DAX inode flag
  xfs: protect S_DAX transitions in XFS read path
  xfs: protect S_DAX transitions in XFS write path
  xfs: introduce xfs_is_dax_state_changing
  mm, fs: introduce file_operations->post_mmap()
  xfs: re-enable XFS per-inode DAX

 fs/xfs/xfs_file.c  | 172 ++++++++++++++++++++++-------------------------------
 fs/xfs/xfs_ioctl.c |  47 ++++++++++++---
 include/linux/fs.h |   1 +
 mm/mmap.c          |   2 +
 4 files changed, 114 insertions(+), 108 deletions(-)

-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
