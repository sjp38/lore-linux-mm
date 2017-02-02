Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00E6C6B0266
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 10:43:38 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so23072012pfb.6
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 07:43:37 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id j184si17898401pge.121.2017.02.02.07.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 07:43:36 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH] ipc/shm: Fix shmat mmap nil-page protection
Date: Thu,  2 Feb 2017 07:43:15 -0800
Message-Id: <1486050195-18629-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Davidlohr Bueso <dbueso@suse.de>

The issue is described here, with a nice testcase:

    https://bugzilla.kernel.org/show_bug.cgi?id=192931

The problem is that shmat() calls do_mmap_pgoff() with MAP_FIXED, and
the address rounded down to 0. For the regular mmap case, the protection
mentioned above is that the kernel gets to generate the address --
arch_get_unmapped_area() will always check for MAP_FIXED and return
that address. So by the time we do security_mmap_addr(0) things get
funky for shmat().

The testcase itself shows that while a regular user crashes, root will
not have a problem attaching a nil-page. There are two possible fixes
to this. The first, and which this patch does, is to simply allow root
to crash as well -- this is also regular mmap behavior, ie when hacking
up the testcase and adding mmap(... |MAP_FIXED). While this approach is
the safer option, the second alternative is to ignore SHM_RND if the
rounded address is 0, thus only having MAP_SHARED flags. This makes
the behavior of shmat() identical to the mmap() case. The downside of
this is obviously user visible, but does make sense in that it maintains
semantics after the round-down wrt 0 address and mmap.

Passes shm related ltp tests.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/shm.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 81203e8ba013..7512b4fecff4 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1091,8 +1091,8 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
  * "raddr" thing points to kernel space, and there has to be a wrapper around
  * this.
  */
-long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
-	      unsigned long shmlba)
+long do_shmat(int shmid, char __user *shmaddr, int shmflg,
+	      ulong *raddr, unsigned long shmlba)
 {
 	struct shmid_kernel *shp;
 	unsigned long addr;
@@ -1113,8 +1113,13 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		goto out;
 	else if ((addr = (ulong)shmaddr)) {
 		if (addr & (shmlba - 1)) {
-			if (shmflg & SHM_RND)
-				addr &= ~(shmlba - 1);	   /* round down */
+			/*
+			 * Round down to the nearest multiple of shmlba.
+			 * For sane do_mmap_pgoff() parameters, avoid
+			 * round downs that trigger nil-page and MAP_FIXED.
+			 */
+			if ((shmflg & SHM_RND) && addr >= shmlba)
+				addr &= ~(shmlba - 1);
 			else
 #ifndef __ARCH_FORCE_SHMLBA
 				if (addr & ~PAGE_MASK)
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
