Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0575C6B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 19:05:44 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id l2-v6so4969146ybk.17
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 16:05:44 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h10-v6si245091ybm.832.2018.04.09.16.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 16:05:42 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 2/3] mm/shmem: update file sealing comments and file checking
Date: Mon,  9 Apr 2018 16:05:04 -0700
Message-Id: <20180409230505.18953-3-mike.kravetz@oracle.com>
In-Reply-To: <20180409230505.18953-1-mike.kravetz@oracle.com>
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In preparation for memfd code restucture, update comments dealing
with file sealing to indicate that tmpfs and hugetlbfs are the
supported filesystems.  Also, change file pointer checks in
memfd_file_seals_ptr to use defined routines instead of directly
referencing file_operation structs.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/shmem.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index c7bad16fe884..be20fc388dcb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2734,11 +2734,11 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 static unsigned int *memfd_file_seals_ptr(struct file *file)
 {
-	if (file->f_op == &shmem_file_operations)
+	if (shmem_file(file))
 		return &SHMEM_I(file_inode(file))->seals;
 
 #ifdef CONFIG_HUGETLBFS
-	if (file->f_op == &hugetlbfs_file_operations)
+	if (is_file_hugepages(file))
 		return &HUGETLBFS_I(file_inode(file))->seals;
 #endif
 
@@ -2758,16 +2758,17 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 
 	/*
 	 * SEALING
-	 * Sealing allows multiple parties to share a shmem-file but restrict
-	 * access to a specific subset of file operations. Seals can only be
-	 * added, but never removed. This way, mutually untrusted parties can
-	 * share common memory regions with a well-defined policy. A malicious
-	 * peer can thus never perform unwanted operations on a shared object.
+	 * Sealing allows multiple parties to share a tmpfs or hugetlbfs file
+	 * but restrict access to a specific subset of file operations. Seals
+	 * can only be added, but never removed. This way, mutually untrusted
+	 * parties can share common memory regions with a well-defined policy.
+	 * A malicious peer can thus never perform unwanted operations on a
+	 * shared object.
 	 *
-	 * Seals are only supported on special shmem-files and always affect
-	 * the whole underlying inode. Once a seal is set, it may prevent some
-	 * kinds of access to the file. Currently, the following seals are
-	 * defined:
+	 * Seals are only supported on special tmpfs or hugetlbfs files and
+	 * always affect the whole underlying inode. Once a seal is set, it
+	 * may prevent some kinds of access to the file. Currently, the
+	 * following seals are defined:
 	 *   SEAL_SEAL: Prevent further seals from being set on this file
 	 *   SEAL_SHRINK: Prevent the file from shrinking
 	 *   SEAL_GROW: Prevent the file from growing
@@ -2781,9 +2782,9 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 	 * added.
 	 *
 	 * Semantics of sealing are only defined on volatile files. Only
-	 * anonymous shmem files support sealing. More importantly, seals are
-	 * never written to disk. Therefore, there's no plan to support it on
-	 * other file types.
+	 * anonymous tmpfs and hugetlbfs files support sealing. More
+	 * importantly, seals are never written to disk. Therefore, there's
+	 * no plan to support it on other file types.
 	 */
 
 	if (!(file->f_mode & FMODE_WRITE))
-- 
2.13.6
