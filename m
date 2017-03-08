Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5DB3831FE
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 12:06:24 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so67239692pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 09:06:24 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id 68si3800712pfa.203.2017.03.08.09.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 09:06:24 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH] mm,hugetlb: compute page_size_log properly
Date: Wed,  8 Mar 2017 09:06:01 -0800
Message-Id: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

The SHM_HUGE_* stuff  was introduced in:

   42d7395feb5 (mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB)

It unnecessarily adds another layer, specific to sysv shm, without
anything special about it: the macros are identical to the MAP_HUGE_*
stuff, which in turn does correctly describe the hugepage subsystem.

One example of the problems with extra layers what this patch fixes:
mmap_pgoff() should never be using SHM_HUGE_* logic. This was
introduced by:

   091d0d55b28 (shm: fix null pointer deref when userspace specifies invalid hugepage size)

It is obviously harmless but lets just rip out the whole thing --
the shmget.2 manpage will need updating, as it should not be
describing kernel internals.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/shm.h                    | 13 -------------
 ipc/shm.c                              |  6 +++---
 mm/mmap.c                              |  2 +-
 tools/testing/selftests/vm/thuge-gen.c |  8 +-------
 4 files changed, 5 insertions(+), 24 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 429c1995d756..98fc25f9db8a 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -31,19 +31,6 @@ struct shmid_kernel /* private to the kernel */
 
 /* Bits [26:31] are reserved */
 
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
-
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr,
 	      unsigned long shmlba);
diff --git a/ipc/shm.c b/ipc/shm.c
index 7e199fa1960f..f21a2338ee39 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -491,8 +491,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 
 	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
-		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
-						& SHM_HUGE_MASK);
+		struct hstate *hs = hstate_sizelog((shmflg >> MAP_HUGE_SHIFT)
+						   & MAP_HUGE_MASK);
 		size_t hugesize;
 
 		if (!hs) {
@@ -506,7 +506,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 			acctflag = VM_NORESERVE;
 		file = hugetlb_file_setup(name, hugesize, acctflag,
 				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
-				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
+				(shmflg >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
 	} else {
 		/*
 		 * Do not allow no accounting for OVERCOMMIT_NEVER, even
diff --git a/mm/mmap.c b/mm/mmap.c
index 0718c175db8f..a1c4cefc5a38 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1369,7 +1369,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	} else if (flags & MAP_HUGETLB) {
 		struct user_struct *user = NULL;
 		struct hstate *hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) &
-						   SHM_HUGE_MASK);
+						   MAP_HUGE_MASK);
 
 		if (!hs)
 			return -EINVAL;
diff --git a/tools/testing/selftests/vm/thuge-gen.c b/tools/testing/selftests/vm/thuge-gen.c
index c87957295f74..4479015ec96a 100644
--- a/tools/testing/selftests/vm/thuge-gen.c
+++ b/tools/testing/selftests/vm/thuge-gen.c
@@ -32,12 +32,6 @@
 #define MAP_HUGE_MASK   0x3f
 #define MAP_HUGETLB	0x40000
 
-#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
-#define SHM_HUGE_SHIFT  26
-#define SHM_HUGE_MASK   0x3f
-#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
-#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
-
 #define NUM_PAGESIZES   5
 
 #define NUM_PAGES 4
@@ -243,7 +237,7 @@ int main(void)
 
 	for (i = 0; i < num_page_sizes; i++) {
 		unsigned long ps = page_sizes[i];
-		int arg = ilog2(ps) << SHM_HUGE_SHIFT;
+		int arg = ilog2(ps) << MAP_HUGE_SHIFT;
 		printf("Testing %luMB shmget with shift %x\n", ps >> 20, arg);
 		test_shmget(ps, SHM_HUGETLB | arg);
 	}
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
