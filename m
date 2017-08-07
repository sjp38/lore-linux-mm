Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8506B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 19:48:11 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id y23so6527024uah.15
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 16:48:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i68si4103061vkg.380.2017.08.07.16.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 16:48:10 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/1] Add hugetlbfs support to memfd_create()
Date: Mon,  7 Aug 2017 16:47:51 -0700
Message-Id: <1502149672-7759-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This patch came out of discussions in this e-mail thread [1].

The Oracle JVM team is developing a new garbage collection model.  This
new model requires multiple mappings of the same anonymous memory.  One
straight forward way to accomplish this is with memfd_create.  They can
use the returned fd to create multiple mappings of the same memory.

The JVM today has an option to use (static hugetlb) huge pages.  If this
option is specified, they would like to use the same garbage collection
model requiring multiple mappings to the same memory.  Using hugetlbfs,
it is possible to explicitly mount a filesystem and specify file paths
in order to get an fd that can be used for multiple mappings.  However,
this introduces additional system admin work and coordination.

Ideally they would like to get a hugetlbfs fd without requiring explicit
mounting of a filesystem.   Today, mmap and shmget can make use of
hugetlbfs without explicitly mounting a filesystem.  The patch adds this
functionality to hugetlbfs.

A new flag MFD_HUGETLB is introduced to request a hugetlbfs file.  Like
other system calls where hugetlb can be requested, the huge page size
can be encoded in the flags argument is the non-default huge page size
is desired.  hugetlbfs does not support sealing operations, therefore
specifying MFD_ALLOW_SEALING with MFD_HUGETLB will result in EINVAL.

Of course, the memfd_man page would need updating if this type of
functionality moves forward.

[1] https://lkml.org/lkml/2017/7/6/564

Mike Kravetz (1):
  mm/shmem: add hugetlbfs support to memfd_create()

 include/uapi/linux/memfd.h | 24 ++++++++++++++++++++++++
 mm/shmem.c                 | 37 +++++++++++++++++++++++++++++++------
 2 files changed, 55 insertions(+), 6 deletions(-)

-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
