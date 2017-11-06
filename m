Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E03C66B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 09:39:50 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id j83so10257497oif.7
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 06:39:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l44si5846353ota.449.2017.11.06.06.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 06:39:49 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v2 0/9] memfd: add sealing to hugetlb-backed memory
Date: Mon,  6 Nov 2017 15:39:35 +0100
Message-Id: <20171106143944.13821-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Hi,

Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
didn't add sealing support. One of the reasons to use memfd is to have
shared memory sealing when doing IPC or sharing memory with another
process with some extra safety. qemu uses shared memory & hugetables
with vhost-user (used by dpdk), so it is reasonable to use memfd
now instead for convenience and security reasons.

Thanks!

v1->v2: after Mike review,
- add "memfd-hugetlb:" prefix in memfd-test
- run fuse test on hugetlb backend memory
- rename function memfd_file_get_seals() -> memfd_file_seals_ptr()
- update commit messages
- added reviewed-by tags

RFC->v1:
- split rfc patch, after early review feedback
- added patch for memfd-test changes
- fix build with hugetlbfs disabled
- small code and commit messages improvements

Marc-AndrA(C) Lureau (9):
  shmem: unexport shmem_add_seals()/shmem_get_seals()
  shmem: rename functions that are memfd-related
  hugetlb: expose hugetlbfs_inode_info in header
  hugetlbfs: implement memfd sealing
  shmem: add sealing support to hugetlb-backed memfd
  memfd-tests: test hugetlbfs sealing
  memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
  memfd-test: move common code to a shared unit
  memfd-test: run fuse test on hugetlb backend memory

 fs/fcntl.c                                     |   2 +-
 fs/hugetlbfs/inode.c                           |  39 +++--
 include/linux/hugetlb.h                        |  11 ++
 include/linux/shmem_fs.h                       |   6 +-
 mm/shmem.c                                     |  59 ++++---
 tools/testing/selftests/memfd/Makefile         |   5 +
 tools/testing/selftests/memfd/common.c         |  45 ++++++
 tools/testing/selftests/memfd/common.h         |   9 ++
 tools/testing/selftests/memfd/fuse_test.c      |  36 +++--
 tools/testing/selftests/memfd/memfd_test.c     | 212 ++++---------------------
 tools/testing/selftests/memfd/run_fuse_test.sh |   2 +-
 tools/testing/selftests/memfd/run_tests.sh     |   1 +
 12 files changed, 195 insertions(+), 232 deletions(-)
 create mode 100644 tools/testing/selftests/memfd/common.c
 create mode 100644 tools/testing/selftests/memfd/common.h

-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
