Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B846900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:25 -0400 (EDT)
Received: by payr10 with SMTP id r10so66844198pay.1
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:25 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id gb10si15174110pac.36.2015.06.06.06.38.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:21 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 4/5] ipc,sysv: make return -EIDRM when racing with RMID consistent
Date: Sat,  6 Jun 2015 06:37:59 -0700
Message-Id: <1433597880-8571-5-git-send-email-dave@stgolabs.net>
In-Reply-To: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

The ipc_lock helper is used by all forms of sysv ipc to acquire
the ipc object's spinlock. Upon error (bogus identifier), we
always return -EINVAL, whether the problem be in the idr path or
because we raced with a task performing RMID. For the later,
however, all ipc related manpages, state the that for:

       EIDRM  <ID> points to a removed identifier.

And return:

       EINVAL Invalid <ID> value, or unaligned, etc.

Which (EINVAL) should only return once the ipc resource is deleted.
For all types of ipc this is done immediately upon a RMID command.
However, shared memory behaves slightly different as it can merely
mark a segment for deletion, and delay the actual freeing until
there are no more active consumers. Per shmctl(IPC_RMID) manpage:

""
Mark  the  segment to be destroyed.  The segment will only actually
be destroyed after the last process detaches it (i.e., when the
shm_nattch member of the associated structure shmid_ds is zero).
""

Unlike ipc_lock, paths that behave "correctly", at least per the
manpage, involve controlling the ipc resource via *ctl(), doing
the exact same validity check as ipc_lock after right acquiring
the spinlock:

	if (!ipc_valid_object()) {
		err = -EIDRM;
		goto out_unlock;
	}

Thus make ipc_lock consistent with the rest of ipc code and return
-EIDRM in ipc_lock when !ipc_valid_object().

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/util.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/ipc/util.c b/ipc/util.c
index adb8f89..15e750d 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -586,19 +586,22 @@ struct kern_ipc_perm *ipc_lock(struct ipc_ids *ids, int id)
 	rcu_read_lock();
 	out = ipc_obtain_object_idr(ids, id);
 	if (IS_ERR(out))
-		goto err1;
+		goto err;
 
 	spin_lock(&out->lock);
 
-	/* ipc_rmid() may have already freed the ID while ipc_lock
-	 * was spinning: here verify that the structure is still valid
+	/*
+	 * ipc_rmid() may have already freed the ID while ipc_lock()
+	 * was spinning: here verify that the structure is still valid.
+	 * Upon races with RMID, return -EIDRM, thus indicating that
+	 * the ID points to a removed identifier.
 	 */
 	if (ipc_valid_object(out))
 		return out;
 
 	spin_unlock(&out->lock);
-	out = ERR_PTR(-EINVAL);
-err1:
+	out = ERR_PTR(-EIDRM);
+err:
 	rcu_read_unlock();
 	return out;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
