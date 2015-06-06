Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E5BC1900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:20 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so70901213pdb.1
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:20 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id r8si15140807pds.154.2015.06.06.06.38.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:19 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 1/5] ipc,shm: move BUG_ON check into shm_lock
Date: Sat,  6 Jun 2015 06:37:56 -0700
Message-Id: <1433597880-8571-2-git-send-email-dave@stgolabs.net>
In-Reply-To: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

Upon every shm_lock call, we BUG_ON if an error was returned,
indicating racing either in idr or in shm_destroy. Move this logic
into the locking.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/shm.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 6d76707..6dbac3b 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -155,8 +155,14 @@ static inline struct shmid_kernel *shm_lock(struct ipc_namespace *ns, int id)
 {
 	struct kern_ipc_perm *ipcp = ipc_lock(&shm_ids(ns), id);
 
-	if (IS_ERR(ipcp))
+	if (IS_ERR(ipcp)) {
+		/*
+		 * We raced in the idr lookup or with shm_destroy(),
+		 * either way, the ID is busted.
+		 */
+		BUG();
 		return (struct shmid_kernel *)ipcp;
+	}
 
 	return container_of(ipcp, struct shmid_kernel, shm_perm);
 }
@@ -191,7 +197,6 @@ static void shm_open(struct vm_area_struct *vma)
 	struct shmid_kernel *shp;
 
 	shp = shm_lock(sfd->ns, sfd->id);
-	BUG_ON(IS_ERR(shp));
 	shp->shm_atim = get_seconds();
 	shp->shm_lprid = task_tgid_vnr(current);
 	shp->shm_nattch++;
@@ -258,7 +263,6 @@ static void shm_close(struct vm_area_struct *vma)
 	down_write(&shm_ids(ns).rwsem);
 	/* remove from the list of attaches of the shm segment */
 	shp = shm_lock(ns, sfd->id);
-	BUG_ON(IS_ERR(shp));
 	shp->shm_lprid = task_tgid_vnr(current);
 	shp->shm_dtim = get_seconds();
 	shp->shm_nattch--;
@@ -1191,7 +1195,6 @@ out_fput:
 out_nattch:
 	down_write(&shm_ids(ns).rwsem);
 	shp = shm_lock(ns, shmid);
-	BUG_ON(IS_ERR(shp));
 	shp->shm_nattch--;
 	if (shm_may_destroy(ns, shp))
 		shm_destroy(ns, shp);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
