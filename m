Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB918C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A46120693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A46120693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43CFB8E0007; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C7FA8E0001; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2660E8E0007; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD55D8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3so44121680pgc.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yzrqxqNHmSWXpL3l2S0eDz4sW1FjJzBY6wHraenSjV0=;
        b=ndDnv/6+waAFH4bbdRD2dZTZL6tSPL8FWFOjLWn7fVeRXwmh0vuy/4YS5+mlsWSGpa
         jYqpgKdXrSL/sBVvKPDdZoQL13GpK8GOwPLjaS/mzbzFXF0UeyM24drG2DIHNhnh0MFC
         12iE+VyiyYZSushbPD9bdg57f6SfTQclMlmZ8Y+g8/7PaRuTWT62l90in7sb02dEUFos
         NdhvZP+IPaQzBhhHE3BTodO7CzzBfmXb4qcnfeCDuT7o6nLX5Ou19Nu9k0AAZxenn3+k
         lDQeGjDlEvNMiiGvQIW4RVMUbqrIEHuHGHF99vQjMVczGhxQjPcWIj/tsTw/1k0NoOee
         GjUg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVM5m3FIkor2g6PyxU/LcHa6oPP0SdrhJ3/p2ZoirN0dhihUj5d
	vxXmb5+QM78Hmzp/YniPdlcVRvtY9jugWxLUpDiH3LBxH+Gd/Jguy7phKsrH+uTe/vyJ7el7d2k
	FzpSg0SEzMPNANzAEgAoBxLbrCIJZIgSU5+9SlRBH/swLhjrJBrwCwePiAo6oNYM=
X-Received: by 2002:a63:d04e:: with SMTP id s14mr111097544pgi.189.1564625881355;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIL0OrpNFTLnh1FysVR1dHVnb43uwyuBcQpM3VLKFBCpC3baOVBcU3p89tgHIJWhS1s/OK
X-Received: by 2002:a63:d04e:: with SMTP id s14mr111097487pgi.189.1564625880159;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625880; cv=none;
        d=google.com; s=arc-20160816;
        b=HXTXHjw4Z8D263/HU/tf2cl5wl3uxxPYqAQJjziD0HRI9QnZ5ImYO2N+VN2H+hSoib
         wTltqf1g3OHN7wnGuMc0WnczgTwdok9VMfeTKHEDI/hRXgo4YcLDkyTL45vsKJQ8UW+D
         SJ/Tl/+bqDEeipzd9YtUitRbsj/00k9Btwf8+P78LEGcw6/rqqK6x0HlcXJqNw775WMi
         vIJUIK/9h9z2DXQf9Zs6QDR63wYXmZRbej4vTGr3Ue+uD1ynNfdUsOzPbWUJ7e9Ge6tW
         e4PXBdBHAI+zHGHSK0PuTchz9EBMUUF6n7iqDZKCFl2hyjgIZ57kbPnO/KMz7Q8D1zRZ
         JblQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yzrqxqNHmSWXpL3l2S0eDz4sW1FjJzBY6wHraenSjV0=;
        b=X92Jr+AFWQN42HKIEN/oq/jx4ZKvOYNvz0GMzv6aO+meFJDUSy2FqJEH34ViV9YCuX
         PTVCtf0TD/4UQ9lNbQVJ3nxRYlUeSAx9YCam6Ll5Y1+/HHeviw56voEa2Y1CAso1q5V/
         Zk5kAH6Gx0oVgXxuDwGkwoz19Cbc/m5QMC5Bf0smh6SLKoyRP5ySup7/c0bo+RrZ59Cz
         b7Z5kTbUqkIEZvglokhN2H9Rpitd7fDOKXsSBDGl7x5LsIuszz+uOiC7YB9QN2SbzZaK
         twzZnppPP5KWUP+bkuZDbRG/QLrOtamJjPmn0qg65kvYhYpJfi7yLf7AcSILsbKaUD8a
         ZAMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id p12si57948416plq.331.2019.07.31.19.17.59
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id B13D136185C;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003bB-Ak; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lN-8Z; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 17/24] xfs: don't block kswapd in inode reclaim
Date: Thu,  1 Aug 2019 12:17:45 +1000
Message-Id: <20190801021752.4986-18-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=lu14g41xD__19t-wDHQA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

We have a number of reasons for blocking kswapd in XFS inode
reclaim, mainly all to do with the fact that memory reclaim has no
feedback mechanisms to throttle on dirty slab objects that need IO
to reclaim.

As a result, we currently throttle inode reclaim by issuing IO in
the reclaim context. The unfortunate side effect of this is that it
can cause long tail latencies in reclaim and for some workloads this
can be a problem.

Now that the shrinkers finally have a method of telling kswapd to
back off, we can start the process of making inode reclaim in XFS
non-blocking. The first thing we need to do is not block kswapd, but
so that doesn't cause immediate serious problems, make sure inode
writeback is always underway when kswapd is running.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_icache.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 0b0fd10a36d4..2fa2f8dcf86b 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1378,11 +1378,22 @@ xfs_reclaim_inodes_nr(
 	struct xfs_mount	*mp,
 	int			nr_to_scan)
 {
-	/* kick background reclaimer and push the AIL */
+	int			sync_mode = SYNC_TRYLOCK;
+
+	/* kick background reclaimer */
 	xfs_reclaim_work_queue(mp);
-	xfs_ail_push_all(mp->m_ail);
 
-	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
+	/*
+	 * For kswapd, we kick background inode writeback. For direct
+	 * reclaim, we issue and wait on inode writeback to throttle
+	 * reclaim rates and avoid shouty OOM-death.
+	 */
+	if (current_is_kswapd())
+		xfs_ail_push_all(mp->m_ail);
+	else
+		sync_mode |= SYNC_WAIT;
+
+	return xfs_reclaim_inodes_ag(mp, sync_mode, &nr_to_scan);
 }
 
 /*
-- 
2.22.0

