Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 787D86B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 11:14:33 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so32409626pdb.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 08:14:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id cg6si5866605pad.123.2015.08.10.08.14.31
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 08:14:32 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 0/2] Recover some scalability for DAX
Date: Mon, 10 Aug 2015 18:14:22 +0300
Message-Id: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi all,

Currently, i_mmap_lock is huge bottleneck for DAX scalability as we use in
place of lock_page().

This patchset tries to recover some scalability by introducing per-mapping
range-lock. The range-lock itself is implemented by Jan Kara on top of
interval tree. It looks not so cheap, by should scale better than
exclusive i_mmap_lock.

Any comments?

Jan Kara (1):
  lib: Implement range locks

Kirill A. Shutemov (1):
  dax: use range_lock instead of i_mmap_lock

 drivers/gpu/drm/Kconfig      |  1 -
 drivers/gpu/drm/i915/Kconfig |  1 -
 fs/dax.c                     | 30 +++++++++--------
 fs/inode.c                   |  1 +
 include/linux/fs.h           |  2 ++
 include/linux/range_lock.h   | 51 +++++++++++++++++++++++++++++
 lib/Kconfig                  | 14 --------
 lib/Kconfig.debug            |  1 -
 lib/Makefile                 |  3 +-
 lib/range_lock.c             | 78 ++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                  | 35 +++++++++++++-------
 mm/rmap.c                    |  1 +
 12 files changed, 174 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/range_lock.h
 create mode 100644 lib/range_lock.c

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
