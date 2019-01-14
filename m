Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D80C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 08:53:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F04420659
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 08:53:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F04420659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169BF8E0003; Mon, 14 Jan 2019 03:53:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117058E0002; Mon, 14 Jan 2019 03:53:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21F68E0003; Mon, 14 Jan 2019 03:53:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B227A8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 03:53:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so8661839edr.21
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 00:53:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=8PXnpI1n+nt7o+3stMAN9ou5aftK8y+l8P9Y1mAnsr4=;
        b=K7mD5YiOhrFzc/8Ao1FP2R8eUTxQTj8apdrRMGl74HXP9TZ+OPPUsnYO/kdkv5YmOB
         9hb9HIeVLcsqwV1BJenPeuFLPMDVzwdrNl3t6JzaLppUe6UsBpb+IvAt1+VBJuV09KZR
         i5Nup/ZV79cJsgd+q4wjWlrZluxYD0TMiZav8qzQroeL3NgaLaBxUmU6Hv1suhUvu5Og
         ziRUzrNlmwNVRAtw5M+Ukly5s7buPjcFNh7I4dKIt0ftNC2cEWJIOff4jTlzHpw1gbV2
         +pBBeX47mzpVcXS+ZTRgEcHsxdM8mpFYQbPDt1ACArsOkzN3iMZlKIk8IX+Da+nwCjUe
         FKlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUukdoXXLxG4hgeDBPO3aVlH+RaRaT3pcuax71nMxHkZT0lW5xU1MY
	l4vGH5dnic9Q7dZqNYsiSti0cQ0JjVD906V/G6ntJsk9jZJkaH82YkZceTVkQP/WlhtrY/xqr3L
	oNvNlEBr5GHwv4nl6G/xE2CW++pQJxtRAXOJfWO8ASgWW5zlHN/Zyomt4JzWauSQzUg==
X-Received: by 2002:a50:903c:: with SMTP id b57mr22876839eda.161.1547456029204;
        Mon, 14 Jan 2019 00:53:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4kXKyfqSbgvRkCxYR9Z15zznv5uZ5+3enCuPfw/wFrbcSNu2COL10Ry6S0cRAZHbCSMu7Q
X-Received: by 2002:a50:903c:: with SMTP id b57mr22876786eda.161.1547456027952;
        Mon, 14 Jan 2019 00:53:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547456027; cv=none;
        d=google.com; s=arc-20160816;
        b=WIc/ju0H2KRax1Bm9qhW/H5oDS+crFKcj/rjFKb7MmOLaC/00QEAtcCsGreEct5xsY
         yhC7afBXdLu4mAe09R2knU8VcPkpbkdEzrMSv4nxj3W+fhwD2/NqgsxIynWFqBzc+JoT
         pgFF5pvk/4DqnSpNEZ4mDhr9DkpoJoHrsvouOId82dq1kC2yEWDW6dWKZCRkebxUF/Ad
         yR1/jSTUYVAHW+e6hBAF1NIBWJkHr62romAjOyr7e/ufYHTs9DBX2SxUDEfYwpeKp1Eb
         bDkGlSgz/ftNcnlBCCCo/j52R7vwSl72gfheviXLqAzivKsHcQga7KrLUz8d3tEIw5/U
         rWRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=8PXnpI1n+nt7o+3stMAN9ou5aftK8y+l8P9Y1mAnsr4=;
        b=M41FCqNzbBPwnV/Y5aYgM2jeoof6pG4zbJBlDDxNpPVFhpBCQA4dkM0vbOV1WLFnn/
         YWJlrqOA0xmhzU/Hbrd8S/zbcKWnd8giS4473sZUSbT+PMaCLQzlDT66hHT/PtESGvh5
         msrNireTkIbY+OYAMHfxxhonHFGz/tyhmGcH2Euy6D9cJgSnbYIq1E9OXib4rUZ4X1VX
         rWFfCmm4ZpYvUF1A8nht2G1e2fyJ+40pTCXqiBSj+XiRb/QpWWUUCs7p/7sR9a38W/lC
         wKqpA8e7dB2fC9bPZ9dkH4Ygjd6wxUMep/pSgdkIx/lur+lyYS7wljXIo+QKtA90wI+m
         damQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19-v6si623031ejd.292.2019.01.14.00.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 00:53:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 278D1AC24;
	Mon, 14 Jan 2019 08:53:47 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E0E7E1E157A; Mon, 14 Jan 2019 09:53:46 +0100 (CET)
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	<linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>,
	Jan Kara <jack@suse.cz>
Subject: [PATCH] vfs: Avoid softlockups in drop_pagecache_sb()
Date: Mon, 14 Jan 2019 09:53:43 +0100
Message-Id: <20190114085343.15011-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190114085343.yadRcp5VZa2RXgdRFw-QphE-Uu6_GYE2asK52Fo1m4A@z>

When superblock has lots of inodes without any pagecache (like is the
case for /proc), drop_pagecache_sb() will iterate through all of them
without dropping sb->s_inode_list_lock which can lead to softlockups
(one of our customers hit this).

Fix the problem by going to the slow path and doing cond_resched() in
case the process needs rescheduling.

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/drop_caches.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Andrew, can you please merge this patch? Thanks!

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 82377017130f..d31b6c72b476 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -21,8 +21,13 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 	spin_lock(&sb->s_inode_list_lock);
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
 		spin_lock(&inode->i_lock);
+		/*
+		 * We must skip inodes in unusual state. We may also skip
+		 * inodes without pages but we deliberately won't in case
+		 * we need to reschedule to avoid softlockups.
+		 */
 		if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
-		    (inode->i_mapping->nrpages == 0)) {
+		    (inode->i_mapping->nrpages == 0 && !need_resched())) {
 			spin_unlock(&inode->i_lock);
 			continue;
 		}
@@ -30,6 +35,7 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&sb->s_inode_list_lock);
 
+		cond_resched();
 		invalidate_mapping_pages(inode->i_mapping, 0, -1);
 		iput(toput_inode);
 		toput_inode = inode;
-- 
2.16.4

