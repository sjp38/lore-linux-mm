Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58FF36B03AB
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:28:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g67so1410963qka.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:28:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w7si390612qkc.209.2017.07.17.15.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 15:28:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/3] mm: shm: Use new hugetlb size encoding definitions
Date: Mon, 17 Jul 2017 15:28:01 -0700
Message-Id: <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>

Use the common definitions from hugetlb_encode.h header file for
encoding hugetlb size definitions in shmget system call flags.  In
addition, move these definitions to the from the internal to user
(uapi) header file.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/shm.h      | 17 -----------------
 include/uapi/linux/shm.h | 23 +++++++++++++++++++++--
 2 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 04e8818..d56285a 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -27,23 +27,6 @@ struct shmid_kernel /* private to the kernel */
 /* shm_mode upper byte flags */
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
-#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
-#define SHM_NORESERVE   010000  /* don't check for reservations */
-
-/* Bits [26:31] are reserved */
-
-/*
- * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
- */
-#define SHM_HUGE_SHIFT  26
-#define SHM_HUGE_MASK   0x3f
-#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
-#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
 
 #ifdef CONFIG_SYSVIPC
 struct sysv_shm {
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 1fbf24e..329bc17 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -3,6 +3,7 @@
 
 #include <linux/ipc.h>
 #include <linux/errno.h>
+#include <asm-generic/hugetlb_encode.h>
 #ifndef __KERNEL__
 #include <unistd.h>
 #endif
@@ -40,11 +41,29 @@ struct shmid_ds {
 /* Include the definition of shmid64_ds and shminfo64 */
 #include <asm/shmbuf.h>
 
-/* permission flag for shmget */
+/* shmget() shmflg values. */
+/* The bottom nine bits are the same as open(2) mode flags */
 #define SHM_R		0400	/* or S_IRUGO from <linux/stat.h> */
 #define SHM_W		0200	/* or S_IWUGO from <linux/stat.h> */
+/* Bits 9 & 10 are IPC_CREAT and IPC_EXCL */
+#define SHM_HUGETLB	04000	/* segment will use huge TLB pages */
+#define	SHM_NORESERVE	010000	/* don't check for reservations */
 
-/* mode for attach */
+/*
+ * Huge page size encoding when SHM_HUGETLB is specified, and a huge page
+ * size other than the default is desired.  See hugetlb_encode.h
+ */
+#define SHM_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
+#define SHM_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
+#define MAP_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
+#define MAP_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
+#define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
+#define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
+#define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
+#define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
+#define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE__16GB
+
+/* shmat() shmflg values */
 #define	SHM_RDONLY	010000	/* read-only access */
 #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
 #define	SHM_REMAP	040000	/* take-over region on attach */
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
