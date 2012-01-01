Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id BB4716B0073
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:30:55 -0500 (EST)
Received: by yhgm50 with SMTP id m50so8507576yhg.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:30:54 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 2/2] sysvshm: SHM_LOCK use lru_add_drain_all_async()
Date: Sun,  1 Jan 2012 02:30:25 -0500
Message-Id: <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

shmctl also don't need synchrounous pagevec drain. This patch replace it with
lru_add_drain_all_async().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 ipc/shm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 02ecf2c..1eb25f0 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -872,8 +872,6 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 	{
 		struct file *uninitialized_var(shm_file);
 
-		lru_add_drain_all();  /* drain pagevecs to lru lists */
-
 		shp = shm_lock_check(ns, shmid);
 		if (IS_ERR(shp)) {
 			err = PTR_ERR(shp);
@@ -911,6 +909,8 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 			shp->mlock_user = NULL;
 		}
 		shm_unlock(shp);
+		/* prevent user visible mismatch of unevictable accounting */
+		lru_add_drain_all_async();
 		goto out;
 	}
 	case IPC_RMID:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
