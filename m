Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A60BC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBC7020693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBC7020693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BC348E0014; Wed, 31 Jul 2019 22:33:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3450D8E0001; Wed, 31 Jul 2019 22:33:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BF568E0014; Wed, 31 Jul 2019 22:33:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCB9C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m17so35209305pgh.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=287LQY5tp7/cYuhQjYxuyZcufgwsCxICwLQam0MRGFg=;
        b=IFENZEcVRQPDX5NmkNv7mZMbiww8/Yihz7/LMk4/jAQgB5/OfiFAHmADY6e26eMEYF
         QWB9TbqASSD4P79LHyEqP/KtWSh5UFcAzvaVeoi/YDAsYPNmCmAfCxFe5GRFncsc+z41
         WsOEXZJa+OMthcl2wUJZa/KBESBpMmOHYrvOBqbWHUJgIhVc3EzFQRNfSBft+C3jOMxV
         oJt0M+03dbJcZQX6DWSc7AEHhgAaM2Ewh0zMKX+AYY+cmAYlsFz5D24hSSlkev47DX48
         i0qcbFSz5lwxd+txWdo9rta+gW3qpeKAjICW+bEzzmge3xQ7ReFhdiYRZVIq+GVxm97r
         QIwQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUtyE0Oj+IwrDFt0rUXMKG53l0H4sYtt62drpgkg9TBwzH3O0ML
	AVtFqoBZYlPld5Ipmbf4DWI8b4mrLiu5436XTqaXJ+Hq02LAb/llNifh61vjnrzD7QB1/P2080f
	ETECNxMWE/FQr3loCTJOrwiXEF6orhuq+0r9KICfmcwktADm86bY/js7PEBHKwR8=
X-Received: by 2002:a17:90a:2244:: with SMTP id c62mr6132172pje.29.1564626816524;
        Wed, 31 Jul 2019 19:33:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWUP1QvVABqqbLcqYX4oW9sfiVTOpKdXzW9aaL4KfxgxeygljBfNAJiTZWcJfNhWj5v3C9
X-Received: by 2002:a17:90a:2244:: with SMTP id c62mr6132097pje.29.1564626815186;
        Wed, 31 Jul 2019 19:33:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626815; cv=none;
        d=google.com; s=arc-20160816;
        b=Iw+epKs2OKC//V1hOn99c2IR6uQEGI4gYT2sO2nMIocOD9PaRSYpkEFW/jEXsmbd3f
         uYVLlaOvWUwwdvtkNK5c+uftiICTuAHHsJKAuXwmz0gX9M46CJUdUItKH2nTEajKUiBL
         kgw8S6d6nZcdthFp1jzi64/G4p2Bi6a4BtxXIPw92hT1QbqTtYmysIjR50HEkAOBWp4d
         zgFvg3lGZoDIxhE6D3DZhPGVk4oBEoLh0685ollOmpRrAtn1OAiQaXa7oYsvdDfst480
         KN8dWE58Ik8Vfc7RVBx7OJQ7NIW9MHXt54Z9W+assJkrBJ5Xx1IUUf7ecaUGyI4HQ/td
         B84Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=287LQY5tp7/cYuhQjYxuyZcufgwsCxICwLQam0MRGFg=;
        b=XYrGsTI0eHMd5sq2LG3gMCe8POHyELAq4C5UIwR+ElnrlYMaQKCxyK/VeZeWM2gMVE
         4UcjKpyp4ZCqyjw0Pxtjm5NwFsIc7GLzko7wp6yrBO+I0yvcaEsAIPuUcvMUh5wfklcY
         gUdtB1P9y+HFVFAyF/GKtfXU7jLT9bCXyzyMcE/VV6SH2/WSKc36E6COMxgCGmYgzA1u
         CTa0JUI2/T1VQ0BcYI8oA8xGNm4j6MGk77STg2tQq3cYdEmz+A0YT9Osvi/ZkWIcbmJ/
         c8EuaHYgjmR2TSu+Q71bLipmuZ2ER2/CM/Y5s/2zIEdC2rWRnhjbjKVscpaZlV2LMhny
         N06g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id 32si9387372plh.154.2019.07.31.19.33.34
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:35 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id C9846361EED
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:33 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003az-4z; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lB-2Z; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 13/24] xfs: synchronous AIL pushing
Date: Thu,  1 Aug 2019 12:17:41 +1000
Message-Id: <20190801021752.4986-14-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=PhaVPwl61JEQPYHB4h0A:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Provide an interface to push the AIL to a target LSN and wait for
the tail of the log to move past that LSN. This is used to wait for
all items older than a specific LSN to either be cleaned (written
back) or relogged to a higher LSN in the AIL. The primary use for
this is to allow IO free inode reclaim throttling.

Factor the common AIL deletion code that does all the wakeups into a
helper so we only have one copy of this somewhat tricky code to
interface with all the wakeups necessary when the LSN of the log
tail changes.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_inode_item.c | 12 +------
 fs/xfs/xfs_trans_ail.c  | 69 +++++++++++++++++++++++++++++++++--------
 fs/xfs/xfs_trans_priv.h |  6 +++-
 3 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/fs/xfs/xfs_inode_item.c b/fs/xfs/xfs_inode_item.c
index c9a502eed204..7b942a63e992 100644
--- a/fs/xfs/xfs_inode_item.c
+++ b/fs/xfs/xfs_inode_item.c
@@ -743,17 +743,7 @@ xfs_iflush_done(
 				xfs_clear_li_failed(blip);
 			}
 		}
-
-		if (mlip_changed) {
-			if (!XFS_FORCED_SHUTDOWN(ailp->ail_mount))
-				xlog_assign_tail_lsn_locked(ailp->ail_mount);
-			if (list_empty(&ailp->ail_head))
-				wake_up_all(&ailp->ail_empty);
-		}
-		spin_unlock(&ailp->ail_lock);
-
-		if (mlip_changed)
-			xfs_log_space_wake(ailp->ail_mount);
+		xfs_ail_delete_finish(ailp, mlip_changed);
 	}
 
 	/*
diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
index 6ccfd75d3c24..9e3102179221 100644
--- a/fs/xfs/xfs_trans_ail.c
+++ b/fs/xfs/xfs_trans_ail.c
@@ -654,6 +654,37 @@ xfs_ail_push_all(
 		xfs_ail_push(ailp, threshold_lsn);
 }
 
+/*
+ * Push the AIL to a specific lsn and wait for it to complete.
+ */
+void
+xfs_ail_push_sync(
+	struct xfs_ail		*ailp,
+	xfs_lsn_t		threshold_lsn)
+{
+	struct xfs_log_item	*lip;
+	DEFINE_WAIT(wait);
+
+	spin_lock(&ailp->ail_lock);
+	while ((lip = xfs_ail_min(ailp)) != NULL) {
+		prepare_to_wait(&ailp->ail_push, &wait, TASK_UNINTERRUPTIBLE);
+		if (XFS_FORCED_SHUTDOWN(ailp->ail_mount) ||
+		    XFS_LSN_CMP(threshold_lsn, lip->li_lsn) <= 0)
+			break;
+		/* XXX: cmpxchg? */
+		while (XFS_LSN_CMP(threshold_lsn, ailp->ail_target) > 0)
+			xfs_trans_ail_copy_lsn(ailp, &ailp->ail_target, &threshold_lsn);
+		wake_up_process(ailp->ail_task);
+		spin_unlock(&ailp->ail_lock);
+		schedule();
+		spin_lock(&ailp->ail_lock);
+	}
+	spin_unlock(&ailp->ail_lock);
+
+	finish_wait(&ailp->ail_push, &wait);
+}
+
+
 /*
  * Push out all items in the AIL immediately and wait until the AIL is empty.
  */
@@ -764,6 +795,28 @@ xfs_ail_delete_one(
 	return mlip == lip;
 }
 
+void
+xfs_ail_delete_finish(
+	struct xfs_ail		*ailp,
+	bool			do_tail_update) __releases(ailp->ail_lock)
+{
+	struct xfs_mount	*mp = ailp->ail_mount;
+
+	if (!do_tail_update) {
+		spin_unlock(&ailp->ail_lock);
+		return;
+	}
+
+	if (!XFS_FORCED_SHUTDOWN(mp))
+		xlog_assign_tail_lsn_locked(mp);
+
+	wake_up_all(&ailp->ail_push);
+	if (list_empty(&ailp->ail_head))
+		wake_up_all(&ailp->ail_empty);
+	spin_unlock(&ailp->ail_lock);
+	xfs_log_space_wake(mp);
+}
+
 /**
  * Remove a log items from the AIL
  *
@@ -789,10 +842,9 @@ void
 xfs_trans_ail_delete(
 	struct xfs_ail		*ailp,
 	struct xfs_log_item	*lip,
-	int			shutdown_type) __releases(ailp->ail_lock)
+	int			shutdown_type)
 {
 	struct xfs_mount	*mp = ailp->ail_mount;
-	bool			mlip_changed;
 
 	if (!test_bit(XFS_LI_IN_AIL, &lip->li_flags)) {
 		spin_unlock(&ailp->ail_lock);
@@ -805,17 +857,7 @@ xfs_trans_ail_delete(
 		return;
 	}
 
-	mlip_changed = xfs_ail_delete_one(ailp, lip);
-	if (mlip_changed) {
-		if (!XFS_FORCED_SHUTDOWN(mp))
-			xlog_assign_tail_lsn_locked(mp);
-		if (list_empty(&ailp->ail_head))
-			wake_up_all(&ailp->ail_empty);
-	}
-
-	spin_unlock(&ailp->ail_lock);
-	if (mlip_changed)
-		xfs_log_space_wake(ailp->ail_mount);
+	xfs_ail_delete_finish(ailp, xfs_ail_delete_one(ailp, lip));
 }
 
 int
@@ -834,6 +876,7 @@ xfs_trans_ail_init(
 	spin_lock_init(&ailp->ail_lock);
 	INIT_LIST_HEAD(&ailp->ail_buf_list);
 	init_waitqueue_head(&ailp->ail_empty);
+	init_waitqueue_head(&ailp->ail_push);
 
 	ailp->ail_task = kthread_run(xfsaild, ailp, "xfsaild/%s",
 			ailp->ail_mount->m_fsname);
diff --git a/fs/xfs/xfs_trans_priv.h b/fs/xfs/xfs_trans_priv.h
index 2e073c1c4614..5ab70b9b896f 100644
--- a/fs/xfs/xfs_trans_priv.h
+++ b/fs/xfs/xfs_trans_priv.h
@@ -61,6 +61,7 @@ struct xfs_ail {
 	int			ail_log_flush;
 	struct list_head	ail_buf_list;
 	wait_queue_head_t	ail_empty;
+	wait_queue_head_t	ail_push;
 };
 
 /*
@@ -92,8 +93,10 @@ xfs_trans_ail_update(
 }
 
 bool xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
+void xfs_ail_delete_finish(struct xfs_ail *ailp, bool do_tail_update)
+			__releases(ailp->ail_lock);
 void xfs_trans_ail_delete(struct xfs_ail *ailp, struct xfs_log_item *lip,
-		int shutdown_type) __releases(ailp->ail_lock);
+		int shutdown_type);
 
 static inline void
 xfs_trans_ail_remove(
@@ -111,6 +114,7 @@ xfs_trans_ail_remove(
 }
 
 void			xfs_ail_push(struct xfs_ail *, xfs_lsn_t);
+void			xfs_ail_push_sync(struct xfs_ail *, xfs_lsn_t);
 void			xfs_ail_push_all(struct xfs_ail *);
 void			xfs_ail_push_all_sync(struct xfs_ail *);
 struct xfs_log_item	*xfs_ail_min(struct xfs_ail  *ailp);
-- 
2.22.0

