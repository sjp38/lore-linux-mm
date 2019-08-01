Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0438AC32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:20:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B432C20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:20:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B432C20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65C0E8E0006; Wed, 31 Jul 2019 22:20:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60D2B8E0001; Wed, 31 Jul 2019 22:20:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D62D8E0006; Wed, 31 Jul 2019 22:20:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20CCF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:20:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p29so35895271pgm.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:20:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H9r6HEnm/MBGNjDw3DjSsFkwO7PZ7T7uA6vsfNWR2w0=;
        b=jkMPDVrK9lUbP9N1xfd7iPkPasaSWRnAL6NR/hGYVKpIRTisWtwX8pwM8199uKF03+
         vNzESxXmd2V2Oawi7+D222Psh4lUJmUbrXrsjFWr+Q3vKj8yrfOZAvHMwalmY+mOBN4C
         UEgASvPKHSC5+wO1J5rlNBUK3mKr5RXe6M6P8CXRhdTDG/QeaSXzdn6CNxABH7hkvtQU
         DbruvNGTWuWu14Aqgb4nPqBZfFI5CwN5SZ1CMw+8JI27OyQ4PIBiKmlha/dHsk7gwAVZ
         n4nDNE3Dt2Cg7dhydgacMoOcNojAuXahBxo6DUqQMT2JPy2rIDmAKc1Vt9DYr+IiNYNQ
         POxg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXfZRx0B0IZe+P1ulWflwLlK/8n45CEm6lVmmZxkfxI/4Dw4HqL
	Gi0CCJClxEHagY6P6HGh3EzweXIetrnGqWo9SlyyQevjvmcPSIQ98vCwR1K4D9NCmO8M7D6ez4M
	+KzLuKfh7iWjOUxT+JCCWTBzu3xzj1OYMAVDA9TjiByenN1n8qqjIhaz9rhvIpZs=
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr51477713pfr.28.1564626001801;
        Wed, 31 Jul 2019 19:20:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSJfZeG0it6v8Wnczo7BVqMrKuAgazMYli0MFoXJTIC0sjAQCJkz/QVCwjvzYf+LMh48Lh
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr51470605pfr.28.1564625882982;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625882; cv=none;
        d=google.com; s=arc-20160816;
        b=GzayZXOv443M2fbf9Q8hfmATXrbaJT4geLjkWEDcU2RmZikjKr2IHa1QIR3js/YhYP
         8j4eh7/dD8MBI0tJaswd3Ctnm4Kwduhoxg1JqqgNlIRs8g3acQKzCcnKJ8bp575goXvN
         z1L7bIet1aShuNP1Gxw49NlCz4TSvT37yjBGbYdyEjac9YwSDcUkYT3jtI2lk5FlSHOh
         uqBRDekVbPcuBnBE94eiQ2yYt2vJBIPQaL1vufTPrd8VJn/SdvqWNgWHFnam8Wy0JYcJ
         Uc/V58NALfOXrSB92em1W5qsB6XRovreEiQ2sNzZCD39/2Zzhi6PnN6XPJBXVLngiaIP
         TPOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=H9r6HEnm/MBGNjDw3DjSsFkwO7PZ7T7uA6vsfNWR2w0=;
        b=bZkvCZV8v8+GRfKlcC/D17eoNjkkiJL5wj7yNkj/7PI9lCpUCFls1U2VtfhuQjeDxG
         /5GdKPVD7kaQyR6wzmsazP3UR4sdPFUhjY1+FjoD2/mPhqkTxOaI1SUAVkRO6ZyWRyRD
         SuCuC0ho6IAqdhdOEemkzeMl5BQJN18eolgLzwMwtM1KwLQga1SEGZ7BWfg2j68hjyD1
         EsdrBZGPeQ/1K2LfXGZ3VEpUeQXSAbnrVE2AiaNl6IcS/I1WHRHIWAL1sxmJcP/6AOSr
         mvFhEEvaaVsvbEobq/igCZLlbSOjzrW5KfOJK3X9Fc12EwaV9m9XA0FgFgUJcjV1WdO3
         JYtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id g15si2670695pjv.54.2019.07.31.19.18.02
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A345643EC85;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003b2-6Z; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lE-44; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 14/24] xfs: tail updates only need to occur when LSN changes
Date: Thu,  1 Aug 2019 12:17:42 +1000
Message-Id: <20190801021752.4986-15-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=yAjffBypbmNlQjcpRW8A:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

We currently wake anything waiting on the log tail to move whenever
the log item at the tail of the log is removed. Historically this
was fine behaviour because there were very few items at any given
LSN. But with delayed logging, there may be thousands of items at
any given LSN, and we can't move the tail until they are all gone.

Hence if we are removing them in near tail-first order, we might be
waking up processes waiting on the tail LSN to change (e.g. log
space waiters) repeatedly without them being able to make progress.
This also occurs with the new sync push waiters, and can result in
thousands of spurious wakeups every second when under heavy direct
reclaim pressure.

To fix this, check that the tail LSN has actually changed on the
AIL before triggering wakeups. This will reduce the number of
spurious wakeups when doing bulk AIL removal and make this code much
more efficient.

XXX: occasionally get a temporary hang in xfs_ail_push_sync() with
this change - log force from log worker gets things moving again.
Only happens under extreme memory pressure - possibly push racing
with a tail update on an empty log. Needs further investigation.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_inode_item.c | 18 +++++++++++++-----
 fs/xfs/xfs_trans_ail.c  | 37 ++++++++++++++++++++++++++++---------
 fs/xfs/xfs_trans_priv.h |  4 ++--
 3 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/fs/xfs/xfs_inode_item.c b/fs/xfs/xfs_inode_item.c
index 7b942a63e992..16a7d6f752c9 100644
--- a/fs/xfs/xfs_inode_item.c
+++ b/fs/xfs/xfs_inode_item.c
@@ -731,19 +731,27 @@ xfs_iflush_done(
 	 * holding the lock before removing the inode from the AIL.
 	 */
 	if (need_ail) {
-		bool			mlip_changed = false;
+		xfs_lsn_t	tail_lsn = 0;
 
 		/* this is an opencoded batch version of xfs_trans_ail_delete */
 		spin_lock(&ailp->ail_lock);
 		list_for_each_entry(blip, &tmp, li_bio_list) {
 			if (INODE_ITEM(blip)->ili_logged &&
-			    blip->li_lsn == INODE_ITEM(blip)->ili_flush_lsn)
-				mlip_changed |= xfs_ail_delete_one(ailp, blip);
-			else {
+			    blip->li_lsn == INODE_ITEM(blip)->ili_flush_lsn) {
+				/*
+				 * xfs_ail_delete_finish() only cares about the
+				 * lsn of the first tail item removed, any others
+				 * will be at the same or higher lsn so we just
+				 * ignore them.
+				 */
+				xfs_lsn_t lsn = xfs_ail_delete_one(ailp, blip);
+				if (!tail_lsn && lsn)
+					tail_lsn = lsn;
+			} else {
 				xfs_clear_li_failed(blip);
 			}
 		}
-		xfs_ail_delete_finish(ailp, mlip_changed);
+		xfs_ail_delete_finish(ailp, tail_lsn);
 	}
 
 	/*
diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
index 9e3102179221..00d66175f41a 100644
--- a/fs/xfs/xfs_trans_ail.c
+++ b/fs/xfs/xfs_trans_ail.c
@@ -108,17 +108,25 @@ xfs_ail_next(
  * We need the AIL lock in order to get a coherent read of the lsn of the last
  * item in the AIL.
  */
+static xfs_lsn_t
+__xfs_ail_min_lsn(
+	struct xfs_ail		*ailp)
+{
+	struct xfs_log_item	*lip = xfs_ail_min(ailp);
+
+	if (lip)
+		return lip->li_lsn;
+	return 0;
+}
+
 xfs_lsn_t
 xfs_ail_min_lsn(
 	struct xfs_ail		*ailp)
 {
-	xfs_lsn_t		lsn = 0;
-	struct xfs_log_item	*lip;
+	xfs_lsn_t		lsn;
 
 	spin_lock(&ailp->ail_lock);
-	lip = xfs_ail_min(ailp);
-	if (lip)
-		lsn = lip->li_lsn;
+	lsn = __xfs_ail_min_lsn(ailp);
 	spin_unlock(&ailp->ail_lock);
 
 	return lsn;
@@ -779,12 +787,20 @@ xfs_trans_ail_update_bulk(
 	}
 }
 
-bool
+/*
+ * Delete one log item from the AIL.
+ *
+ * If this item was at the tail of the AIL, return the LSN of the log item so
+ * that we can use it to check if the LSN of the tail of the log has moved
+ * when finishing up the AIL delete process in xfs_ail_delete_finish().
+ */
+xfs_lsn_t
 xfs_ail_delete_one(
 	struct xfs_ail		*ailp,
 	struct xfs_log_item	*lip)
 {
 	struct xfs_log_item	*mlip = xfs_ail_min(ailp);
+	xfs_lsn_t		lsn = lip->li_lsn;
 
 	trace_xfs_ail_delete(lip, mlip->li_lsn, lip->li_lsn);
 	xfs_ail_delete(ailp, lip);
@@ -792,17 +808,20 @@ xfs_ail_delete_one(
 	clear_bit(XFS_LI_IN_AIL, &lip->li_flags);
 	lip->li_lsn = 0;
 
-	return mlip == lip;
+	if (mlip == lip)
+		return lsn;
+	return 0;
 }
 
 void
 xfs_ail_delete_finish(
 	struct xfs_ail		*ailp,
-	bool			do_tail_update) __releases(ailp->ail_lock)
+	xfs_lsn_t		old_lsn) __releases(ailp->ail_lock)
 {
 	struct xfs_mount	*mp = ailp->ail_mount;
 
-	if (!do_tail_update) {
+	/* if the tail lsn hasn't changed, don't do updates or wakeups. */
+	if (!old_lsn || old_lsn == __xfs_ail_min_lsn(ailp)) {
 		spin_unlock(&ailp->ail_lock);
 		return;
 	}
diff --git a/fs/xfs/xfs_trans_priv.h b/fs/xfs/xfs_trans_priv.h
index 5ab70b9b896f..db589bb7468d 100644
--- a/fs/xfs/xfs_trans_priv.h
+++ b/fs/xfs/xfs_trans_priv.h
@@ -92,8 +92,8 @@ xfs_trans_ail_update(
 	xfs_trans_ail_update_bulk(ailp, NULL, &lip, 1, lsn);
 }
 
-bool xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
-void xfs_ail_delete_finish(struct xfs_ail *ailp, bool do_tail_update)
+xfs_lsn_t xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
+void xfs_ail_delete_finish(struct xfs_ail *ailp, xfs_lsn_t old_lsn)
 			__releases(ailp->ail_lock);
 void xfs_trans_ail_delete(struct xfs_ail *ailp, struct xfs_log_item *lip,
 		int shutdown_type);
-- 
2.22.0

