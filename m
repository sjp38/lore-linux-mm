Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54A53C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0223620693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0223620693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D53A8E0005; Wed, 31 Jul 2019 22:33:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 984B58E0001; Wed, 31 Jul 2019 22:33:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875038E0005; Wed, 31 Jul 2019 22:33:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 529E88E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e33so2132792pgm.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HtwyGlZ5mvkmCyCRQYzEdXItWXLQlR6zKGaCqb0x2HY=;
        b=P2atkX1ugElBm2qfOIjwZkVDahzuU3Gtotf1uaC9vS1Srv8O2SOfRrkPiSFDM+LiDW
         nc+cmMDTz2fwlSIOOz8xyZQhSyMFpeR6/Hv91hgNcshR6fEFPqBHtWDgL4fNAkrk/1/x
         0MSWZWEQASl4A7aF6G8PPbn04syKiXpS9eDUz7HByQhw2ZT05zQydr4fZ1im5IsRWkWJ
         wBlFlTpbxW6x5u88Em9hdxuinCHyoLI3xHHBY17qC2Arg3u0PPDv64l+6534lkXgG05h
         UuswAxXA8M7yskqcac4fLoAxMUY/X+I1LxQIB1ei/XUZ0yNlTOD0A0+W7NtD3lJMCWRw
         sUqA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUl3DFbR1WM9Yft+wCuOcyjrTgzbW9OKnfb75iNq+pMpYcTKGcS
	miliLZpG7Mx8z9sCNPyZxOoLuTRstRsOVZFj1uHG82G5qgKPPkuQ3nZfiRVkCFSL0w3cnuYR/SS
	ZxRtJTohZlD5lb1ADOBzkBXB167HFGKk2at0+b5AuOfCkOZln9I/NF8pqNf8CD8I=
X-Received: by 2002:aa7:81d4:: with SMTP id c20mr50947823pfn.235.1564626806028;
        Wed, 31 Jul 2019 19:33:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwka+0Y78vQxFa9SSo7WCr3auaK73hfptXGXHyTD/DdYlae3o+avu1WmC5bzfqIkMQfn0C+
X-Received: by 2002:aa7:81d4:: with SMTP id c20mr50947747pfn.235.1564626804820;
        Wed, 31 Jul 2019 19:33:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626804; cv=none;
        d=google.com; s=arc-20160816;
        b=b+OFjgAyL7wKxXw32qVwPq4rYmNYFTEKFBSnfdHDYhGvllZuYoSzvsU00TzJV7G0dv
         8snRKD+DkzTR0ep2893kKlK89flQAKBTGmrfj3iLkDO9vnchgKBeuumdR97D/AIUZ2+R
         I1KSdgoCc6Pq9sJvUqK1Psb6eXdbhUnckA1NcHb7dGyYZNOfSw9dwMc4Madnt7znaVWi
         qBdDnjpUoZc2jHYKK/wM25g2YEghVKxpiF0+jWYSGj7GZ7m1v/Z7mk+TlBvj4ZV4U8aq
         5w+8DoTPf2tjoa9DnulnCY2wdbqt8U6ZPB0BGe3xsu/rlwjPZeNLYveO12NPEayhmzwH
         hXew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HtwyGlZ5mvkmCyCRQYzEdXItWXLQlR6zKGaCqb0x2HY=;
        b=bnU0V8bwuO/ShtftnIhEWWFB6uHs9t7eG5ytEmJalKXrgSx29urOIDw+Za4y57rqpq
         s6ulFdKGtZdcNqAK7E2+SVqWMenh24Rc5AkOodSyJj4H+WRh0zRAzL5yB1ArFhExWqqW
         ScnIc3CuTec+a69PaZ7ktSPW/Bb2+Nc06hlMmhVUHeXbSN/RFsDWb4hoit4Mhpuh5EJS
         StJ+ddzYVmWLwD1SsAfhSzBgqgH1nFf9ApUKSI+vLrvdu2bHD4+j4x7b1dhYCB7qBVZ0
         +jfVAxTh9gygyiFsXySJwHK2k3JtZEt7LhTD7BSt1KIJDS/LRsa2QmrA508tLw/wFMRM
         TlvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id w1si32978418pfn.129.2019.07.31.19.33.24
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:24 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 7C5F743DA40
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:23 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003bM-Fg; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lZ-Dr; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 21/24] xfs: remove mode from xfs_reclaim_inodes()
Date: Thu,  1 Aug 2019 12:17:49 +1000
Message-Id: <20190801021752.4986-22-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=rBCjN8xBrULXB8iKm2EA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Because it's always SYNC_WAIT now.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_icache.c | 7 +++----
 fs/xfs/xfs_icache.h | 2 +-
 fs/xfs/xfs_mount.c  | 4 ++--
 fs/xfs/xfs_super.c  | 3 +--
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 4c4c5bc12147..aaa1f840a86c 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1294,12 +1294,11 @@ xfs_reclaim_inodes_ag(
 	return freed;
 }
 
-int
+void
 xfs_reclaim_inodes(
-	xfs_mount_t	*mp,
-	int		mode)
+	struct xfs_mount	*mp)
 {
-	return xfs_reclaim_inodes_ag(mp, mode, INT_MAX);
+	xfs_reclaim_inodes_ag(mp, SYNC_WAIT, INT_MAX);
 }
 
 /*
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index 4c0d8920cc54..1c9b9edb2986 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -49,7 +49,7 @@ int xfs_iget(struct xfs_mount *mp, struct xfs_trans *tp, xfs_ino_t ino,
 struct xfs_inode * xfs_inode_alloc(struct xfs_mount *mp, xfs_ino_t ino);
 void xfs_inode_free(struct xfs_inode *ip);
 
-int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
+void xfs_reclaim_inodes(struct xfs_mount *mp);
 int xfs_reclaim_inodes_count(struct xfs_mount *mp);
 long xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
 
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index bcf8f64d1b1f..e851b9cfbabd 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -984,7 +984,7 @@ xfs_mountfs(
 	 * qm_unmount_quotas and therefore rely on qm_unmount to release the
 	 * quota inodes.
 	 */
-	xfs_reclaim_inodes(mp, SYNC_WAIT);
+	xfs_reclaim_inodes(mp);
 	xfs_health_unmount(mp);
  out_log_dealloc:
 	mp->m_flags |= XFS_MOUNT_UNMOUNTING;
@@ -1066,7 +1066,7 @@ xfs_unmountfs(
 	 * reclaim just to be sure. We can stop background inode reclaim
 	 * here as well if it is still running.
 	 */
-	xfs_reclaim_inodes(mp, SYNC_WAIT);
+	xfs_reclaim_inodes(mp);
 	xfs_health_unmount(mp);
 
 	xfs_qm_unmount(mp);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 09e41c6c1794..a59d3a21be5c 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1179,8 +1179,7 @@ xfs_quiesce_attr(
 	xfs_log_force(mp, XFS_LOG_SYNC);
 
 	/* reclaim inodes to do any IO before the freeze completes */
-	xfs_reclaim_inodes(mp, 0);
-	xfs_reclaim_inodes(mp, SYNC_WAIT);
+	xfs_reclaim_inodes(mp);
 
 	/* Push the superblock and write an unmount record */
 	error = xfs_log_sbcount(mp);
-- 
2.22.0

