Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1031D6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:01:35 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a1so5562611qkb.17
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 16:01:35 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d93si921935qkh.251.2018.01.29.16.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 16:01:34 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] restructure memfd code
Date: Mon, 29 Jan 2018 16:00:58 -0800
Message-Id: <20180130000101.7329-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

I've had these patches sitting around for a few months.  They are not
critical, but might be desirable in some unusual configurations.  They
depend on code in mmotm and linux-next that is not yet upstream, and
apply to those repos.

With the addition of memfd hugetlbfs support, we now have the situation
where memfd depends on TMPFS -or- HUGETLBFS.  Previously, memfd was only
supported on tmpfs, so it made sense that the code resides in shmem.c.

This patch series moves the memfd code to separate files (memfd.c and
memfd.h).  It creates a new config option MEMFD_CREATE that is defined
if either TMPFS or HUGETLBFS is defined.

In the current code, memfd is only functional if TMPFS is defined.  If
HUGETLFS is defined and TMPFS is not defined, then memfd functionality
will not be available for hugetlbfs.  This does not cause BUGs, just a
potential lack of desired functionality.

When this was sent as a RFC, one comment suggested combining patches 2
and 3 so that we would not have 'new unused' files between patches.  If
this is desired, I can make the change.  For me, it is easier to read
as separate patches.

Mike Kravetz (3):
  mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
  mm: memfd: split out memfd for use by multiple filesystems
  mm: memfd: remove memfd code from shmem files and use new memfd files

 fs/Kconfig               |   3 +
 fs/fcntl.c               |   2 +-
 include/linux/hugetlb.h  |  27 ++--
 include/linux/memfd.h    |  16 +++
 include/linux/shmem_fs.h |  13 --
 mm/Makefile              |   1 +
 mm/memfd.c               | 341 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c               | 323 --------------------------------------------
 8 files changed, 378 insertions(+), 348 deletions(-)
 create mode 100644 include/linux/memfd.h
 create mode 100644 mm/memfd.c

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
