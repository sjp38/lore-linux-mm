Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2FB4C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCADB21E6D
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kYbzKJgn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCADB21E6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 652028E0007; Mon, 22 Jul 2019 05:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 603C88E0001; Mon, 22 Jul 2019 05:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47D2B8E0007; Mon, 22 Jul 2019 05:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 143888E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:55:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so23284975pgh.11
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=2E+0J/lCQjtD6kAw5emUWCAAdpJKdW3bqRjknXhHlt0=;
        b=nqI89XIq5+Sq8x1pEqF7e5WUqFNCdXX+1m2Gt/joNkHL1EwFiZkr/i6Itd9VSiSw3l
         iaBrv52zzmBLnd5nH4b9D2zJCexWk9TRzQO+ce8JhFXi4HhraH2fsvv8PCL1mu8wQa4F
         mwRcfk7C8k2t9aHKkO2AvoDCl+dqKT1PPQySeDzUwrLrt73bg6yx8GGigH/Beg5xqNoZ
         VcQfyaQrEMB1UqJo7tqbIJ/NVlZjQH/5RFRUr0wHCCtE6FWRlexOvsWco7aGMO3StmBl
         rWVAAyi2loapGBLXpqY1EwU8EwQ6J/OVBNLP7KdgFHsyt2fR2wPDXFmTijuNZ7YAXmdk
         umgg==
X-Gm-Message-State: APjAAAWhZBuRlrvpokWbVDEkEXnRRWodchXvBhupGo1fBiHU9Xhp5TTK
	gntskS62+jUL3IkR0TDOvF7ETG6bwDxsBls+SUmC6cmigv6kwzMGWjtZwJjzc3HO+RzFS8hl3eK
	+l5IVSBGl//q8wJ1fTPrCHbvNAbIY8dIEOIs0E6yqc2xaCKLguoG0n6oSp1uSpgfUtw==
X-Received: by 2002:a65:4c4d:: with SMTP id l13mr30058150pgr.156.1563789300675;
        Mon, 22 Jul 2019 02:55:00 -0700 (PDT)
X-Received: by 2002:a65:4c4d:: with SMTP id l13mr30058075pgr.156.1563789299617;
        Mon, 22 Jul 2019 02:54:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563789299; cv=none;
        d=google.com; s=arc-20160816;
        b=gs0JzzqL6hJHGt9Dax1a9yv4f1LxTMaKdpnmErUOWu60aWZkJb4CPR0QqZy38SNj62
         0gw648ayyWD546tCtB+rl/wYjc+amVj7y7yTU8RKq7pBNTBDvBo96vB/rkyCtJUutDxe
         TM677TkrAaB1ZTzHeteARwbJ6vxqx7fk2r2klTK9aZj+7BuPnl7tSm5al5ZqGLUJQikg
         aBV7iU/4/JRzfnaXBqvHC+a1PBeRx9t38bGUQUk0cgZyOzYIDUZUWsa6/0fnamSoPu+p
         I0KlBcuCyeqLrtiS9Jv1OBI64HQvSdn8rFlx5k0nqyqVd+U7nglJtBmdsXYs5kNFDWJJ
         MMxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=2E+0J/lCQjtD6kAw5emUWCAAdpJKdW3bqRjknXhHlt0=;
        b=IcMQr9r5aX+jv1VXxPmaPGIyRAe/ItO5gOyH+/+F7ewzy0QEriyyc8rSuxk8A9qEhD
         bx/RhOeaOcyOIrmUR0yATVS7zfCtXT3S/Cj4AaCzfqq6AYroX7feMD8jkzvdXDyInMBG
         /C+++FA6colVKuULgWqCMIdC3s5CSHRikDTDK9YgMNsUgTT7fBqxrBqAv/Am4ZP/9mnR
         bPu1sdfwg3/o17Uj09bObzbkimjnMKeemCsYWBm0EL/eIpgxVR8vhivYEiHlsWcDs4iT
         DfZxrNJcwngio8NUdUjXB5G60USQTpP57YRWtppuTYqjzAhQVHmwz5zX3T3cJ5CvmCmj
         C3OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kYbzKJgn;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor47391132plg.28.2019.07.22.02.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 02:54:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kYbzKJgn;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=2E+0J/lCQjtD6kAw5emUWCAAdpJKdW3bqRjknXhHlt0=;
        b=kYbzKJgn980C35UD9pjoCrCx8MV7YiZipA4S+EwG9MErGHI6e09J6SS+0F0c1LoROX
         SFtSz9cmR06abWSjMeSaSsanizbN3CjVDvL4t8znM4TCVLBiSQlp4pBhyndPlUQEH8E/
         iWCdzJxVZSAkfzImjBEorgBr3doHCBqBNbaWo3eoVrg/XmuGoWKh1oIEpGqQlhk0GIkk
         D4OQ5q/XZxHpmq7gXeLjpERzIdbM9UXYuCJqTeFte1CRzS+U5Vw6YVAEo5vUA6k4lL6/
         Zc4NuACelKGKWG5os1nNeVeYShEEymalo0rUq9WpibICtvqiSgmq395JkI25z6KWNkUe
         xehw==
X-Google-Smtp-Source: APXvYqw/a2rT2G3RxTytYx7iAa3C2ndRqX9b0wHDaQgy6r7wb3mCvb9SjyvGwwnUX5EbR0J4L+0O9Q==
X-Received: by 2002:a17:902:694a:: with SMTP id k10mr73910519plt.255.1563789299284;
        Mon, 22 Jul 2019 02:54:59 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id r6sm30314969pgl.74.2019.07.22.02.54.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:54:58 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	David Rientjes <rientjes@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm/compaction: clear total_{migrate,free}_scanned before scanning a new zone
Date: Mon, 22 Jul 2019 05:54:35 -0400
Message-Id: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

total_{migrate,free}_scanned will be added to COMPACTMIGRATE_SCANNED and
COMPACTFREE_SCANNED in compact_zone(). We should clear them before scanning
a new zone.
In the proc triggered compaction, we forgot clearing them.

Fixes: 7f354a548d1c ("mm, compaction: add vmstats for kcompactd work")
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9ac..a109b45 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2405,8 +2405,6 @@ static void compact_node(int nid)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = -1,
-		.total_migrate_scanned = 0,
-		.total_free_scanned = 0,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 		.whole_zone = true,
@@ -2422,6 +2420,8 @@ static void compact_node(int nid)
 
 		cc.nr_freepages = 0;
 		cc.nr_migratepages = 0;
+		cc.total_migrate_scanned = 0;
+		cc.total_free_scanned = 0;
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
-- 
1.8.3.1

