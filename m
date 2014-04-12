Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 956276B006C
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 23:22:28 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id uz6so6935271obc.41
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 20:22:27 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id rk8si9243540oeb.39.2014.04.11.20.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 20:22:26 -0700 (PDT)
Message-ID: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH v2] ipc,shm: disable shmmax and shmall by default
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 11 Apr 2014 20:22:22 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, DavidlohrBueso <davidlohr@hp.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

From: Davidlohr Bueso <davidlohr@hp.com>

The default size for shmmax is, and always has been, 32Mb.
Today, in the XXI century, it seems that this value is rather small,
making users have to increase it via sysctl, which can cause
unnecessary work and userspace application workarounds[1].

Instead of choosing yet another arbitrary value, larger than 32Mb,
this patch disables the use of both shmmax and shmall by default,
allowing users to create segments of unlimited sizes. Users and
applications that already explicitly set these values through sysctl
are left untouched, and thus does not change any of the behavior.

So a value of 0 bytes or pages, for shmmax and shmall, respectively,
implies unlimited memory, as opposed to disabling sysv shared memory.
This is safe as 0 cannot possibly be used previously as SHMMIN is
hardcoded to 1 and cannot be modified.

This change allows Linux to treat shm just as regular anonymous memory.
One important difference between them, though, is handling out-of-memory
conditions: as opposed to regular anon memory, the OOM killer will not
free the memory as it is shm, allowing users to potentially abuse this.
To overcome this situation, the shm_rmid_forced option must be enabled.

[1]: http://rhaas.blogspot.com/2012/06/absurd-shared-memory-limits.html

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
Changes from v1:
 - Respect SHMMIN even when shmmax is 0 (unlimited).
   This fixes the shmget02 test that broke in v1. (per Manfred)

 - Update changelog regarding OOM description (per Kosaki)

 include/linux/shm.h      | 2 +-
 include/uapi/linux/shm.h | 8 ++++----
 ipc/shm.c                | 6 ++++--
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 1e2cd2e..0ca06a3 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -4,7 +4,7 @@
 #include <asm/page.h>
 #include <uapi/linux/shm.h>
 
-#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
+#define SHMALL 0 /* max shm system wide (pages) */
 #include <asm/shmparam.h>
 struct shmid_kernel /* private to the kernel */
 {	
diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 78b6941..5f0ef28 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -9,14 +9,14 @@
 
 /*
  * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be increased by sysctl
+ * be increased by sysctl. By default, disable SHMMAX and SHMALL with
+ * 0 bytes, thus allowing processes to have unlimited shared memory.
  */
-
-#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
+#define SHMMAX 0		         /* max shared seg size (bytes) */
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
 #ifndef __KERNEL__
-#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
+#define SHMALL 0
 #endif
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 7645961..8630561 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -490,10 +490,12 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	int id;
 	vm_flags_t acctflag = 0;
 
-	if (size < SHMMIN || size > ns->shm_ctlmax)
+	if (size < SHMMIN ||
+	    (ns->shm_ctlmax && size > ns->shm_ctlmax))
 		return -EINVAL;
 
-	if (ns->shm_tot + numpages > ns->shm_ctlall)
+	if (ns->shm_ctlall &&
+	    ns->shm_tot + numpages > ns->shm_ctlall)
 		return -ENOSPC;
 
 	shp = ipc_rcu_alloc(sizeof(*shp));
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
