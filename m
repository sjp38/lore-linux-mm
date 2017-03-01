Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF116B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 19:06:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so31011932pfg.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:06:37 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l4si3042301plk.280.2017.02.28.16.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 16:06:36 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 0/3] Zeroing hash tables in allocator
Date: Tue, 28 Feb 2017 19:14:40 -0500
Message-Id: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org

Changes:
v1 -> v2: Reverted NG4memcpy() changes

On large machines hash tables can be many gigabytes in size and it is
inefficient to zero them in a loop without platform specific optimizations.

Using memset() provides a standard platform optimized way to zero the
memory.

Pavel Tatashin (3):
  sparc64: NG4 memset 32 bits overflow
  mm: Zeroing hash tables in allocator
  mm: Updated callers to use HASH_ZERO flag

 arch/sparc/lib/NG4memset.S          |   26 +++++++++++++-------------
 fs/dcache.c                         |   18 ++++--------------
 fs/inode.c                          |   14 ++------------
 fs/namespace.c                      |   10 ++--------
 include/linux/bootmem.h             |    1 +
 kernel/locking/qspinlock_paravirt.h |    3 ++-
 kernel/pid.c                        |    7 ++-----
 mm/page_alloc.c                     |   12 +++++++++---
 8 files changed, 35 insertions(+), 56 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
