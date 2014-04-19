Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id D489F6B0038
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:44:04 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so2334776eek.32
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:44:04 -0700 (PDT)
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
        by mx.google.com with ESMTPS id 43si44522757eei.235.2014.04.19.04.44.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:44:03 -0700 (PDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so2288523eek.23
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:44:03 -0700 (PDT)
From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 4/4] ipc/shm.c: Increase the defaults for SHMALL, SHMMAX.
Date: Sat, 19 Apr 2014 13:43:41 +0200
Message-Id: <1397907821-29319-5-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1397907821-29319-4-git-send-email-manfred@colorfullife.com>
References: <1397907821-29319-1-git-send-email-manfred@colorfullife.com>
 <1397907821-29319-2-git-send-email-manfred@colorfullife.com>
 <1397907821-29319-3-git-send-email-manfred@colorfullife.com>
 <1397907821-29319-4-git-send-email-manfred@colorfullife.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>

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

This patch increases the default limits to the supported maximum, which is
perfect for case b). The defaults are used after boot and as the initial
value for each new namespace.

Admins/distros that need a protection against a) should reduce the limits
and/or enable shm_rmid_forced.

Further notes:
- The patch only changes default, overrides behave as before:
        # sysctl kernel/shmall=33554432
  would recreate the previous limit for SHMMAX (for the current namespace).

- Disabling sysv shm allocation is possible with:
        # sysctl kernel.shmall=0
  (not a new feature, also per-namespace)

- The limits are intentionally not set to ULONG_MAX, to avoid triggering
  overflows in user space.
  [not unreasonable, see http://marc.info/?l=linux-mm&m=139638334330127]

- The the maximum segment size is set to TASK_SIZE. Segments larger than
  TASK_SIZE do not make sense, because such segments can't be mapped.

- The limit for the total memory is 256*TASK_SIZE.
  This would be 768 GB for x86-32 and 64 PB for x86-64.
  Values larger than that might make sense, but not in the next few weeks.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Reported-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com
---
 include/linux/shm.h      |  5 ++++-
 include/uapi/linux/shm.h | 10 ++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 1e2cd2e..7cafb08 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -4,7 +4,10 @@
 #include <asm/page.h>
 #include <uapi/linux/shm.h>
 
-#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
+#define SHMMAX TASK_SIZE		 /* max shared seg size (bytes) */
+#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16))
+					 /* max shm system wide (pages) */
+
 #include <asm/shmparam.h>
 struct shmid_kernel /* private to the kernel */
 {	
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 78b6941..a20bb7a 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -9,14 +9,20 @@
 
 /*
  * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be increased by sysctl
+ * be modified by sysctl
  */
 
-#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
 #ifndef __KERNEL__
+/*
+ * The real values is TASK_SIZE, which is not exported as uapi.
+ * Since this is only the boot time default, 1 GB is a sufficiently
+ * accurate approximation of TASK_SIZE.
+ */
+#define SHMMAX 0x40000000		 /* max shared seg size (bytes) */
 #define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
+					 /* max shm system wide (pages) */
 #endif
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
