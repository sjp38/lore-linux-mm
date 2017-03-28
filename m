Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9EB6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 13:54:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v21so110802925pgo.22
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 10:54:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p5si4764202pgk.146.2017.03.28.10.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 10:54:10 -0700 (PDT)
Date: Tue, 28 Mar 2017 10:54:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170328175408.GD7838@bombadil.infradead.org>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328165513.GC27446@linux-80c1.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Tue, Mar 28, 2017 at 09:55:13AM -0700, Davidlohr Bueso wrote:
> Do we have any consensus here? Keeping SHM_HUGE_* is currently
> winning 2-1. If there are in fact users out there computing the
> value manually, then I am ok with keeping it and properly exporting
> it. Michal?

Well, let's see what it looks like to do that.  I went down the rabbit
hole trying to understand why some of the SHM_ flags had the same value
as each other until I realised some of them were internal flags, some
were flags to shmat() and others were flags to shmget().  Hopefully I
disambiguated them nicely in this patch.  I also added 8MB and 16GB sizes.
Any more architectures with a pet favourite huge/giant page size we
should add convenience defines for?

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 04e881829625..cd95243efd1a 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -24,26 +24,13 @@ struct shmid_kernel /* private to the kernel */
 	struct list_head	shm_clist;	/* list by creator */
 };
 
-/* shm_mode upper byte flags */
-#define	SHM_DEST	01000	/* segment will be destroyed on last detach */
-#define SHM_LOCKED      02000   /* segment will not be swapped */
-#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
-#define SHM_NORESERVE   010000  /* don't check for reservations */
-
-/* Bits [26:31] are reserved */
-
 /*
- * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
- * This gives us 6 bits, which is enough until someone invents 128 bit address
- * spaces.
- *
- * Assume these are all power of twos.
- * When 0 use the default page size.
+ * These flags are used internally; they cannot be specified by the user.
+ * They are masked off in newseg().  These values are used by IPC_CREAT
+ * and IPC_EXCL when calling shmget().
  */
-#define SHM_HUGE_SHIFT  26
-#define SHM_HUGE_MASK   0x3f
-#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
-#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
+#define	SHM_DEST	01000	/* segment will be destroyed on last detach */
+#define SHM_LOCKED      02000   /* segment will not be swapped */
 
 #ifdef CONFIG_SYSVIPC
 struct sysv_shm {
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 1fbf24ea37fd..44b36cb228d7 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -40,15 +40,34 @@ struct shmid_ds {
 /* Include the definition of shmid64_ds and shminfo64 */
 #include <asm/shmbuf.h>
 
-/* permission flag for shmget */
+/* shmget() shmflg values. */
+/* The bottom nine bits are the same as open(2) mode flags */
 #define SHM_R		0400	/* or S_IRUGO from <linux/stat.h> */
 #define SHM_W		0200	/* or S_IWUGO from <linux/stat.h> */
+/* Bits 9 & 10 are IPC_CREAT and IPC_EXCL */
+#define SHM_HUGETLB     (1 << 11) /* segment will use huge TLB pages */
+#define SHM_NORESERVE   (1 << 12) /* don't check for reservations */
 
-/* mode for attach */
-#define	SHM_RDONLY	010000	/* read-only access */
-#define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
-#define	SHM_REMAP	040000	/* take-over region on attach */
-#define	SHM_EXEC	0100000	/* execution access */
+/*
+ * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
+ * This gives us 6 bits, which is enough until someone invents 128 bit address
+ * spaces.  These match MAP_HUGE_SHIFT and MAP_HUGE_MASK.
+ *
+ * Assume these are all powers of two.
+ * When 0 use the default page size.
+ */
+#define SHM_HUGE_SHIFT	26
+#define SHM_HUGE_MASK	0x3f
+#define SHM_HUGE_2MB	(21 << SHM_HUGE_SHIFT)
+#define SHM_HUGE_8MB	(23 << SHM_HUGE_SHIFT)
+#define SHM_HUGE_1GB	(30 << SHM_HUGE_SHIFT)
+#define SHM_HUGE_16GB	(34 << SHM_HUGE_SHIFT)
+
+/* shmat() shmflg values */
+#define	SHM_RDONLY	(1 << 12) /* read-only access */
+#define	SHM_RND		(1 << 13) /* round attach address to SHMLBA boundary */
+#define	SHM_REMAP	(1 << 14) /* take-over region on attach */
+#define	SHM_EXEC	(1 << 15) /* execution access */
 
 /* super user shmctl commands */
 #define SHM_LOCK 	11
diff --git a/mm/mmap.c b/mm/mmap.c
index 499b988b1639..40b29aca18c1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1479,7 +1479,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		struct user_struct *user = NULL;
 		struct hstate *hs;
 
-		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & SHM_HUGE_MASK);
+		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
 		if (!hs)
 			return -EINVAL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
