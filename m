Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2839440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:41:29 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id b40so3257790qkb.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:41:29 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u4si4651736qkb.485.2017.11.08.17.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 17:41:29 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/3] restructure memfd code
Date: Wed,  8 Nov 2017 17:41:06 -0800
Message-Id: <20171109014109.21077-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

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

Another way to approach this issue would be to simply make HUGETLBFS
depend on TMPFS.

This patch series is built on top of the Marc-AndrA(C) Lureau v3 series
"memfd: add sealing to hugetlb-backed memory":
http://lkml.kernel.org/r/20171107122800.25517-1-marcandre.lureau@redhat.com

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
