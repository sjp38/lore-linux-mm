Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3177C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 697D020693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 697D020693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859908E0009; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80AA28E0003; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722D88E0009; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8768E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u21so44607424pfn.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BzhfXa/iboA3E/3IPDss6+/2NOPohkvU8uRRmFcfAOU=;
        b=oWEZqXI7GMeSo/dSkW1A17QbGM19H7HNGSbz13DXXvkENDs31ntgbTljM2KuLnUXOy
         qsjEFH5Op2pyfhkRP+SgAKh6lz7j+Qwy5dTBgSx2OSt0OEu5iS19rjVdxdOqNQTHFYRD
         H+nHvW9I45hDVYdompArjD4YZqnRbvpCumzzelK4ZbJ5Y9EIlHCOs5g4ifXe/F6uvnrF
         ++XTluDSbp/UfPkMEV+zL6gq/YOvGgKYMK78022IPv5TRtwi+UHAl6+yViSNKeTwZsmh
         DUf1yy+Iz1MDrGH8m8DP91ci03+3qBkoL1zLaFXJzhaXCnYRg8UemGWGONrfZDwCucLG
         Q1Ug==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVf2FthXudEc8Mx7XYZemniS/2CBqPXY7py9Nrw0PIwVrSKk4vq
	qQHvyfvg0a/u+JkciZUXErahpRodRnRxL6KXousifPUIqE8PVM/RCnEi5LRMkdZztWDOHtcOmEz
	KdUcvpsUB5Akwd6AfSry+js0PenNzxRHu+/mZrpLqi55AFzQX+vu4lD79gSs+FFo=
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr5890963pjo.94.1564625882767;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJC/w1T8rGRnbRZ52WGTjQlihEZXksLh4d6XZcidHtebfgB7lSh5vpPsch2YxLhz0D8EiD
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr5890887pjo.94.1564625881570;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=W7ctdoOeHFVmNXWAaagup5YIpogS1/pKZrkiC4p3dMAvh2V0i+z4g+LFncujVJ/+m4
         nmwdeD/C0PVVS0MyrHRJFSZprHt6SW/UNm/qgGb1os5nAQnI3SFgV3G8vVY3+7qLdGSN
         uoSYf0GIJ8wbtuW6bWSYTqZFCvLFmOMO3TjhhA6VwBPK8OzL0oETwQ9ZHyOmrOs74Ccz
         M7U5B8jwbKwQhvpfAXC09shd1BTUEiwuoepnQCz1mX3nSK9OiJFzlJ4y4GXpECu2w8z9
         BiVRFJn4/gIw2Dsi3eQjFRAFVRrqHgPxI79SVYsgZjdykGFZMFUAkiHK6QFiz67HYsbM
         FXWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BzhfXa/iboA3E/3IPDss6+/2NOPohkvU8uRRmFcfAOU=;
        b=CGkpab8KjlJBD/JNEZVvij9uLUxKMgHm7CkKPjRNhV8H2BeryP/q4nDJkHzrvm2oLY
         qAl2hRa+S5QW56ul+t5jli+O8ybYnLQ9TjIAVrXw5s4ICLd9T1vPs0IeKcdSsdt6iTxp
         ja4JtgK+//bhxjuNOuncpdsig+rgQQEIHVzVibT3T0BHA++370MgpKwJtrwKH17SdD3C
         JjyvP/SGZBzoqs2YWN0Kk8pQJnO/fDw5YmT+pgOvRap5gmUd/kmpMF1NmMdYE6sOfKef
         8U6xVWKe9EDJkxO+flJhXfYfXBROVQnaxJ/KPkf/2oDBbq0xeYKjIjDV/ZAL+ENGxw/u
         5YUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id s17si32487844pfc.237.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id B150F361934;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003bE-CP; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lQ-9o; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 18/24] xfs: reduce kswapd blocking on inode locking.
Date: Thu,  1 Aug 2019 12:17:46 +1000
Message-Id: <20190801021752.4986-19-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=KE6An8oM74Ymw0apzXAA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

When doing async node reclaiming, we grab a batch of inodes that we
are likely able to reclaim and ignore those that are already
flushing. However, when we actually go to reclaim them, the first
thing we do is lock the inode. If we are racing with something
else reclaiming the inode or flushing it because it is dirty,
we block on the inode lock. Hence we can still block kswapd here.

Further, if we flush an inode, we also cluster all the other dirty
inodes in that cluster into the same IO, flush locking them all.
However, if the workload is operating on sequential inodes (e.g.
created by a tarball extraction) most of these inodes will be
sequntial in the cache and so in the same batch
we've already grabbed for reclaim scanning.

As a result, it is common for all the inodes in the batch to be
dirty and it is common for the first inode flushed to also flush all
the inodes in the reclaim batch. In which case, they are now all
going to be flush locked and we do not want to block on them.

Hence, for async reclaim (SYNC_TRYLOCK) make sure we always use
trylock semantics and abort reclaim of an inode as quickly as we can
without blocking kswapd.

Found via tracing and finding big batches of repeated lock/unlock
runs on inodes that we just flushed by write clustering during
reclaim.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_icache.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 2fa2f8dcf86b..e6b9030875b9 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1104,11 +1104,23 @@ xfs_reclaim_inode(
 
 restart:
 	error = 0;
-	xfs_ilock(ip, XFS_ILOCK_EXCL);
-	if (!xfs_iflock_nowait(ip)) {
-		if (!(sync_mode & SYNC_WAIT))
+	/*
+	 * Don't try to flush the inode if another inode in this cluster has
+	 * already flushed it after we did the initial checks in
+	 * xfs_reclaim_inode_grab().
+	 */
+	if (sync_mode & SYNC_TRYLOCK) {
+		if (!xfs_ilock_nowait(ip, XFS_ILOCK_EXCL))
 			goto out;
-		xfs_iflock(ip);
+		if (!xfs_iflock_nowait(ip))
+			goto out_unlock;
+	} else {
+		xfs_ilock(ip, XFS_ILOCK_EXCL);
+		if (!xfs_iflock_nowait(ip)) {
+			if (!(sync_mode & SYNC_WAIT))
+				goto out_unlock;
+			xfs_iflock(ip);
+		}
 	}
 
 	if (XFS_FORCED_SHUTDOWN(ip->i_mount)) {
@@ -1215,9 +1227,10 @@ xfs_reclaim_inode(
 
 out_ifunlock:
 	xfs_ifunlock(ip);
+out_unlock:
+	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 out:
 	xfs_iflags_clear(ip, XFS_IRECLAIM);
-	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 	/*
 	 * We could return -EAGAIN here to make reclaim rescan the inode tree in
 	 * a short while. However, this just burns CPU time scanning the tree
-- 
2.22.0

