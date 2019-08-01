Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E3BDC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A904216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A904216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B951D8E0013; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF16C8E0010; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5A58E0010; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 181258E0013
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so38616311plr.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V39/0ng5LXkVVjEqqVCsyTSaMoXb9Ngx16S1ome9wGo=;
        b=peAmaSEsW5E7y+bZQCMk7xCyccjdoVIt6HE2xseijxHrROMcYLS35Jgk6ZhkXzSlA5
         tkrbx4XXNGRhCbi2DG8TRUUFfinCNhOLM5ERS3C5KlI1lqj6i59HycWXN3RRcpe5axEt
         +n1y1kUEOOloYkjGLbA9WUECqKZ+C8XlrrWkliblyeVEN1kGaAq5t0p9iSH88+KdTz0H
         EQmEbmpCpWy61Vz58Xx0b03P1nwQHDbnZiqZOKJGQbPU+QfkvbsA+HlP/BURpF6+ywYJ
         xLXJwJqle/nf+l71XgoRCoZpJCYtmeGqKnHCFxOCPdJSbRwDRnnFzF8l6LSjx8aEgi5e
         WqQg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXYOtDccpFcy1OjKFISoVJv8iO5eN1/yrQyJSst9bpuCB/4Kd4f
	pG6rxIpXZOmmSsKiYFkggejL9loHnuUa8q1U7X6F8ymREqXJ8cKnMi0zAmdzb1GEIiNlcrEQpGo
	BWL7NmKqzjRLJjEVRvVQsROhWAN3djxnfGr77vC2rLRmqZ4bd4JFmmbgERoSDYNg=
X-Received: by 2002:a17:90a:d814:: with SMTP id a20mr5928658pjv.48.1564625891743;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBAabfNZtMuqNKPU0vbRg2mU3vSH+X5mfFfGU3PV6XFyZbVQcipoU2k3LEnoNomA6kaJAg
X-Received: by 2002:a17:90a:d814:: with SMTP id a20mr5928165pjv.48.1564625882442;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625882; cv=none;
        d=google.com; s=arc-20160816;
        b=i53RIeJFg9YoBoT2M4+wi+4oyxEGl1Cl02J63O8UwytIC3pc1Egizimr5bNLfV3OJP
         eMT68ug21NSxR62d7Hjcyi9xF5P/jxmFf89UVnP4le7zTnrDqIny3+HCGN93Ngq2qUIs
         kUSj9OzPlqmsLPRPsW9W6J6ZQuMcosHs/Z9gFJrDxiBYwDP32Uz79DJTONyW3+TTRwPb
         ghxhoHQOt4f2VeHWcjeYSLcjTqI/yFjicra9iA/2DNHNfYnI0pZ4epo1K01r29gQySNG
         Q0NrnANAg5g4yRO2pyU9nIhf6IlL3YG5qU3WK6NwGtMOGn6E/Dxt5+oF4pStZ9x3EeUZ
         YURw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=V39/0ng5LXkVVjEqqVCsyTSaMoXb9Ngx16S1ome9wGo=;
        b=rVLLFGnmeEFj4hfgoFCGtHFCBdiZY7/To8dR9JAgeA/fUdMInZIxp7S7RI1fi7Nj7s
         Mxgq95pfuUzaOMkV87t5k06cmIJw4JqSSmCpYtW60HOdh/BlwIA9X02Z1nOOWWC2toMp
         6VEOkeBPLhxrMOpYXqBnt7sdia+cBTumx/y8BnFJjlBA9oN8TmvngcRoe9ncz2rDBnCn
         6To9TrZfeCNiRciB10ebd2/tBrO6IA7H5qbjZox2xwS6lAn5Sukjdez7fTZjd3tkFH67
         nOevrFhr+IyTupqw1CEAFAGCPzSV0fhJLmZvCcZAw9prJ2lpaI3oRt6CIXC2z4AontiU
         gQOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id c1si30277329plr.405.2019.07.31.19.18.02
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id B0DF8361820;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003bG-DM; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lT-BB; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 19/24] xfs: kill background reclaim work
Date: Thu,  1 Aug 2019 12:17:47 +1000
Message-Id: <20190801021752.4986-20-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=1xoyCpcK-Ekt5S4qF2sA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

This function is now entirely done by kswapd, so we don't need the
worker thread to do async reclaim anymore.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_icache.c | 44 --------------------------------------------
 fs/xfs/xfs_icache.h |  2 --
 fs/xfs/xfs_mount.c  |  2 --
 fs/xfs/xfs_mount.h  |  2 --
 fs/xfs/xfs_super.c  | 11 +----------
 5 files changed, 1 insertion(+), 60 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index e6b9030875b9..0bd4420a7e16 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -138,44 +138,6 @@ xfs_inode_free(
 	__xfs_inode_free(ip);
 }
 
-/*
- * Queue a new inode reclaim pass if there are reclaimable inodes and there
- * isn't a reclaim pass already in progress. By default it runs every 5s based
- * on the xfs periodic sync default of 30s. Perhaps this should have it's own
- * tunable, but that can be done if this method proves to be ineffective or too
- * aggressive.
- */
-static void
-xfs_reclaim_work_queue(
-	struct xfs_mount        *mp)
-{
-
-	rcu_read_lock();
-	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_RECLAIM_TAG)) {
-		queue_delayed_work(mp->m_reclaim_workqueue, &mp->m_reclaim_work,
-			msecs_to_jiffies(xfs_syncd_centisecs / 6 * 10));
-	}
-	rcu_read_unlock();
-}
-
-/*
- * This is a fast pass over the inode cache to try to get reclaim moving on as
- * many inodes as possible in a short period of time. It kicks itself every few
- * seconds, as well as being kicked by the inode cache shrinker when memory
- * goes low. It scans as quickly as possible avoiding locked inodes or those
- * already being flushed, and once done schedules a future pass.
- */
-void
-xfs_reclaim_worker(
-	struct work_struct *work)
-{
-	struct xfs_mount *mp = container_of(to_delayed_work(work),
-					struct xfs_mount, m_reclaim_work);
-
-	xfs_reclaim_inodes(mp, SYNC_TRYLOCK);
-	xfs_reclaim_work_queue(mp);
-}
-
 static void
 xfs_perag_set_reclaim_tag(
 	struct xfs_perag	*pag)
@@ -192,9 +154,6 @@ xfs_perag_set_reclaim_tag(
 			   XFS_ICI_RECLAIM_TAG);
 	spin_unlock(&mp->m_perag_lock);
 
-	/* schedule periodic background inode reclaim */
-	xfs_reclaim_work_queue(mp);
-
 	trace_xfs_perag_set_reclaim(mp, pag->pag_agno, -1, _RET_IP_);
 }
 
@@ -1393,9 +1352,6 @@ xfs_reclaim_inodes_nr(
 {
 	int			sync_mode = SYNC_TRYLOCK;
 
-	/* kick background reclaimer */
-	xfs_reclaim_work_queue(mp);
-
 	/*
 	 * For kswapd, we kick background inode writeback. For direct
 	 * reclaim, we issue and wait on inode writeback to throttle
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index 48f1fd2bb6ad..4c0d8920cc54 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -49,8 +49,6 @@ int xfs_iget(struct xfs_mount *mp, struct xfs_trans *tp, xfs_ino_t ino,
 struct xfs_inode * xfs_inode_alloc(struct xfs_mount *mp, xfs_ino_t ino);
 void xfs_inode_free(struct xfs_inode *ip);
 
-void xfs_reclaim_worker(struct work_struct *work);
-
 int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
 int xfs_reclaim_inodes_count(struct xfs_mount *mp);
 long xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index 322da6909290..a1805021c92f 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -988,7 +988,6 @@ xfs_mountfs(
 	 * qm_unmount_quotas and therefore rely on qm_unmount to release the
 	 * quota inodes.
 	 */
-	cancel_delayed_work_sync(&mp->m_reclaim_work);
 	xfs_reclaim_inodes(mp, SYNC_WAIT);
 	xfs_health_unmount(mp);
  out_log_dealloc:
@@ -1071,7 +1070,6 @@ xfs_unmountfs(
 	 * reclaim just to be sure. We can stop background inode reclaim
 	 * here as well if it is still running.
 	 */
-	cancel_delayed_work_sync(&mp->m_reclaim_work);
 	xfs_reclaim_inodes(mp, SYNC_WAIT);
 	xfs_health_unmount(mp);
 
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index fdb60e09a9c5..f0cc952ad527 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -165,7 +165,6 @@ typedef struct xfs_mount {
 	uint			m_chsize;	/* size of next field */
 	atomic_t		m_active_trans;	/* number trans frozen */
 	struct xfs_mru_cache	*m_filestream;  /* per-mount filestream data */
-	struct delayed_work	m_reclaim_work;	/* background inode reclaim */
 	struct delayed_work	m_eofblocks_work; /* background eof blocks
 						     trimming */
 	struct delayed_work	m_cowblocks_work; /* background cow blocks
@@ -182,7 +181,6 @@ typedef struct xfs_mount {
 	struct workqueue_struct *m_buf_workqueue;
 	struct workqueue_struct	*m_unwritten_workqueue;
 	struct workqueue_struct	*m_cil_workqueue;
-	struct workqueue_struct	*m_reclaim_workqueue;
 	struct workqueue_struct *m_eofblocks_workqueue;
 	struct workqueue_struct	*m_sync_workqueue;
 
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 67b59815d0df..09e41c6c1794 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -822,15 +822,10 @@ xfs_init_mount_workqueues(
 	if (!mp->m_cil_workqueue)
 		goto out_destroy_unwritten;
 
-	mp->m_reclaim_workqueue = alloc_workqueue("xfs-reclaim/%s",
-			WQ_MEM_RECLAIM|WQ_FREEZABLE, 0, mp->m_fsname);
-	if (!mp->m_reclaim_workqueue)
-		goto out_destroy_cil;
-
 	mp->m_eofblocks_workqueue = alloc_workqueue("xfs-eofblocks/%s",
 			WQ_MEM_RECLAIM|WQ_FREEZABLE, 0, mp->m_fsname);
 	if (!mp->m_eofblocks_workqueue)
-		goto out_destroy_reclaim;
+		goto out_destroy_cil;
 
 	mp->m_sync_workqueue = alloc_workqueue("xfs-sync/%s", WQ_FREEZABLE, 0,
 					       mp->m_fsname);
@@ -841,8 +836,6 @@ xfs_init_mount_workqueues(
 
 out_destroy_eofb:
 	destroy_workqueue(mp->m_eofblocks_workqueue);
-out_destroy_reclaim:
-	destroy_workqueue(mp->m_reclaim_workqueue);
 out_destroy_cil:
 	destroy_workqueue(mp->m_cil_workqueue);
 out_destroy_unwritten:
@@ -859,7 +852,6 @@ xfs_destroy_mount_workqueues(
 {
 	destroy_workqueue(mp->m_sync_workqueue);
 	destroy_workqueue(mp->m_eofblocks_workqueue);
-	destroy_workqueue(mp->m_reclaim_workqueue);
 	destroy_workqueue(mp->m_cil_workqueue);
 	destroy_workqueue(mp->m_unwritten_workqueue);
 	destroy_workqueue(mp->m_buf_workqueue);
@@ -1557,7 +1549,6 @@ xfs_mount_alloc(
 	spin_lock_init(&mp->m_perag_lock);
 	mutex_init(&mp->m_growlock);
 	atomic_set(&mp->m_active_trans, 0);
-	INIT_DELAYED_WORK(&mp->m_reclaim_work, xfs_reclaim_worker);
 	INIT_DELAYED_WORK(&mp->m_eofblocks_work, xfs_eofblocks_worker);
 	INIT_DELAYED_WORK(&mp->m_cowblocks_work, xfs_cowblocks_worker);
 	mp->m_kobj.kobject.kset = xfs_kset;
-- 
2.22.0

