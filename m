Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 428226B04C2
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:57:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k14so94839600qkl.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:57:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 19si24631854qkk.176.2017.07.31.11.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 11:57:19 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] mm:shm: Use new hugetlb size encoding definitions
Date: Mon, 31 Jul 2017 11:56:26 -0700
Message-Id: <1501527386-10736-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
References: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

Use the common definitions from hugetlb_encode.h header file for
encoding hugetlb size definitions in shmget system call flags.

In addition, move these definitions from the internal (kernel) to
user (uapi) header file.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/shm.h      | 17 -----------------
 include/uapi/linux/shm.h | 31 +++++++++++++++++++++++++++++--
 2 files changed, 29 insertions(+), 19 deletions(-)

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
index 1fbf24e..cf23c87 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -3,6 +3,7 @@
 
 #include <linux/ipc.h>
 #include <linux/errno.h>
+#include <asm-generic/hugetlb_encode.h>
 #ifndef __KERNEL__
 #include <unistd.h>
 #endif
@@ -40,11 +41,37 @@ struct shmid_ds {
 /* Include the definition of shmid64_ds and shminfo64 */
 #include <asm/shmbuf.h>
 
-/* permission flag for shmget */
+/*
+ * shmget() shmflg values.
+ */
+/* The bottom nine bits are the same as open(2) mode flags */
 #define SHM_R		0400	/* or S_IRUGO from <linux/stat.h> */
 #define SHM_W		0200	/* or S_IWUGO from <linux/stat.h> */
+/* Bits 9 & 10 are IPC_CREAT and IPC_EXCL */
+#define SHM_HUGETLB	04000	/* segment will use huge TLB pages */
+#define SHM_NORESERVE	010000	/* don't check for reservations */
+
+/*
+ * Huge page size encoding when SHM_HUGETLB is specified, and a huge page
+ * size other than the default is desired.  See hugetlb_encode.h
+ */
+#define SHM_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
+#define SHM_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
+
+#define SHM_HUGE_64KB	HUGETLB_FLAG_ENCODE_64KB
+#define SHM_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
+#define SHM_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
+#define SHM_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
+#define SHM_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
+#define SHM_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
+#define SHM_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
+#define SHM_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
+#define SHM_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
+#define SHM_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
 
-/* mode for attach */
+/*
+ * shmat() shmflg values
+ */
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
