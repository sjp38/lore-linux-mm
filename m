Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l17Kec5S018083
	for <linux-mm@kvack.org>; Wed, 7 Feb 2007 15:40:38 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l17KeWAd252248
	for <linux-mm@kvack.org>; Wed, 7 Feb 2007 13:40:32 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l17KeWx2004602
	for <linux-mm@kvack.org>; Wed, 7 Feb 2007 13:40:32 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH] Define the shmem_inode_info flags directly
Date: Wed, 07 Feb 2007 12:40:30 -0800
Message-Id: <20070207204030.30615.77294.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew: This is a pretty basic and obvious cleanup IMO.  How about a ride in
-mm?

Defining flags in terms of other flags is always confusing.  Give them literal
values instead of defining them in terms of VM_flags.  While we're at it, move
them to a header file in preparation for the introduction of a
SHMEM_HUGETLB flag.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 include/linux/shmem_fs.h |    4 ++++
 mm/shmem.c               |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index f3c5189..3ea0b6e 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -8,6 +8,10 @@
 
 #define SHMEM_NR_DIRECT 16
 
+/* These info->flags are used to handle pagein/truncate races efficiently */
+#define SHMEM_PAGEIN	0x00000001
+#define SHMEM_TRUNCATE	0x00000002
+
 struct shmem_inode_info {
 	spinlock_t		lock;
 	unsigned long		flags;
diff --git a/mm/shmem.c b/mm/shmem.c
index 70da7a0..a9bdb0d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -66,10 +66,6 @@
 
 #define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
 
-/* info->flags needs VM_flags to handle pagein/truncate races efficiently */
-#define SHMEM_PAGEIN	 VM_READ
-#define SHMEM_TRUNCATE	 VM_WRITE
-
 /* Definition to limit shmem_truncate's steps between cond_rescheds */
 #define LATENCY_LIMIT	 64
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
