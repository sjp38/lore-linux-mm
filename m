Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 553D16B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 05:18:48 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so1373422eek.25
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 02:18:47 -0700 (PDT)
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
        by mx.google.com with ESMTPS id x46si39345136eea.119.2014.04.18.02.18.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 02:18:46 -0700 (PDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1395400eek.6
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 02:18:46 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to infinity
Date: Fri, 18 Apr 2014 11:18:40 +0200
Message-Id: <1397812720-5629-1-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, mtk.manpages@gmail.com

System V shared memory

a) can be abused to trigger out-of-memory conditions and the standard
   measures against out-of-memory do not work:

    - it is not possible to use setrlimit to limit the size of shm segments.

    - segments can exist without association with any processes, thus
      the oom-killer is unable to free that memory.

b) is typically used for shared information - today often multiple GB.
   (e.g. database shared buffers)

The current default is a maximum segment size of 32 MB and a maximum total
size of 8 GB. This is often too much for a) and not enough for b), which
means that lots of users must change the defaults.

This patch increases the default limits to ULONG_MAX, which is perfect for
case b). The defaults are used after boot and as the initial value for
each new namespace.

Admins/distros that need a protection against a) should reduce the limits
and/or enable shm_rmid_forced.

Further notes:
- The patch only changes the boot time default, overrides behave as before:
	# sysctl kernel/shmall=33554432
  would recreate the previous limit for SHMMAX (for the current namespace).

- Disabling sysv shm allocation is possible with:
	# sysctl kernel.shmall=0
  (not a new feature, also per-namespace)

- ULONG_MAX is not really infinity, but 18 Exabyte segment size and
  75 Zettabyte total size. This should be enough for the next few weeks.
  (assuming a 64-bit system with 4k pages)

Risks:
- The patch breaks installations that use "take current value and increase
  it a bit". [seems to exist, http://marc.info/?l=linux-mm&m=139638334330127]
  After a:
	# CUR=`sysctl -n kernel.shmmax`
	# NEW=`echo $CUR+1 | bc -l`
	# sysctl -n kernel.shmmax=$NEW
  shmmax ends up as 0, which disables shm allocations.

- There is no wrap-around protection for ns->shm_ctlall, i.e. the 75 ZB
  limit is not enforced.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Reported-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com
---
 include/linux/shm.h      | 1 -
 include/uapi/linux/shm.h | 8 +++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 1e2cd2e..b33bbeb 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -4,7 +4,6 @@
 #include <asm/page.h>
 #include <uapi/linux/shm.h>
 
-#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
 #include <asm/shmparam.h>
 struct shmid_kernel /* private to the kernel */
 {	
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 78b6941..b7370f9 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -9,15 +9,13 @@
 
 /*
  * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be increased by sysctl
+ * be modified by sysctl
  */
 
-#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
+#define SHMMAX ULONG_MAX		 /* max shared seg size (bytes) */
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
-#ifndef __KERNEL__
-#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
-#endif
+#define SHMALL ULONG_MAX		 /* max shm system wide (pages) */
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
