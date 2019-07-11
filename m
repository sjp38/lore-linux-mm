Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A95EC74A57
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21DDF21670
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21DDF21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 861D48E00C0; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C07A8E0032; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63A2C8E00BF; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14DC18E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so4750908edc.6
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NajLKKyXyleKQwtS3hq9FmbF1SSJAJnGnJ4XCzpHh5c=;
        b=gcJC+WilTfTjJzMzpsuDL7dSvZYnlPQ8ltG5EqxxIE0E/ftbfWm98XeOHDC7qXCkdw
         kaIVdm1XRpDeLs0mSNGIyFOrXH6Oo8x5x1xfZ2VR50Ot9HaysWp3HNY+cJXCKZgulUBx
         hin9dEBPs4NwIWO11Cl0QsnNEOTjazYe4zG1sT8fyvxAbXyTnyam9Mjt9NYpehoSPm87
         khbc6cq7yKnbt1KDCKnv3CtPwhmPzcvw0X+uSwT/DNnkcJZT5+jSWOh/lASCvOcFOANy
         w+mLDPPnmo4wiMxObTTzZE1QAbNRI+5VaGyRGIkb6va0d7UecMuBd3t3WDQvkGDDol3F
         TrvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXxybuyHDk3C4aSDqfa1GwVMnsodaY4lNPn0FFQsBTbfafX7wgg
	AO3T9R2uH1of38++asBEwL1HeC8IASh684SP+IvOrmxBVezTE3cSgcOqp5QcOLcPfqEjFUhFUEb
	Rx3sBEBglUFJMYsKhRcVjE93LEnFd3GP5QtYB5pVPzMenBZJWfSTNjS5JagBIgjCVrA==
X-Received: by 2002:aa7:c393:: with SMTP id k19mr3698897edq.76.1562853618641;
        Thu, 11 Jul 2019 07:00:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnBFAkWUIdxIwpjPDbazNnZVB2Hig0nbqo4rq5t7+plKEmNKg5livLJVYawPIMYvPKUazd
X-Received: by 2002:aa7:c393:: with SMTP id k19mr3698774edq.76.1562853617675;
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562853617; cv=none;
        d=google.com; s=arc-20160816;
        b=QGt/tmLOPBo7ntV3qrFFyFsSkVkKBG8f2ulpgd/6I1EIRJiRGQKG+lqzSLR/lz8yXv
         NDuX4+bp0naoCHcxXj7mu9yF+f/9fHPlTnTZdLVD8ovYLvC9mIHS3XZ4dPV5tImqx89w
         yaaOq8VWbWPZ/uclFJhxKNrH7YP0N5xfp5VF8ohVUD2jLkRG6Pr3ZMq+fTQoO1DF0WKR
         m2FsBs2PlATFtCYBGkyP0FZSypM2N66zydAcSiU9gXo9iCLEGrhWvDj5t67+G15IBZI+
         Mkm9OFja3+idEy1yKVAiH7bXM1cbNY4LbsQZlDcj5fCo4so+V7wCnweJOhFim35r+WjH
         Ep1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NajLKKyXyleKQwtS3hq9FmbF1SSJAJnGnJ4XCzpHh5c=;
        b=rAFVMwBFB+RJfYT5sxa19qRMcaYyawWlqcaNqhoMyonMsQiRKXFgfdy+bMdH3JgDuv
         YPNE1LZSyVcq8eluTp3LGO23AFQU4T9z5LDcfHidhVy3iWw4x9LBPV8iQ+zp1dfMP53i
         lbA/fCykS8T+V4f/znMyLLLeIBImVlkhSSb3iftUPJRw5La1NALr3SjucXZrm3eWswWV
         eudj08penpx4RSmSBlnae5vvgXJO5LmiIbiVvCWSQzP++XJ4fZpl7B96UuuV/ndriYlB
         NXmrZD5AXzGa4k0MbWYTIukoeR4h6yKqM6AU7OfOmdje0D0yP9TbjxdwGsxrcHbHVYH0
         0q4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x16si3490826edb.209.2019.07.11.07.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3AB4AF57;
	Thu, 11 Jul 2019 14:00:16 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 2E77A1E43CE; Thu, 11 Jul 2019 16:00:16 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	<linux-xfs@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 3/3] xfs: Fix stale data exposure when readahead races with hole punch
Date: Thu, 11 Jul 2019 16:00:12 +0200
Message-Id: <20190711140012.1671-4-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190711140012.1671-1-jack@suse.cz>
References: <20190711140012.1671-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hole puching currently evicts pages from page cache and then goes on to
remove blocks from the inode. This happens under both XFS_IOLOCK_EXCL
and XFS_MMAPLOCK_EXCL which provides appropriate serialization with
racing reads or page faults. However there is currently nothing that
prevents readahead triggered by fadvise() or madvise() from racing with
the hole punch and instantiating page cache page after hole punching has
evicted page cache in xfs_flush_unmap_range() but before it has removed
blocks from the inode. This page cache page will be mapping soon to be
freed block and that can lead to returning stale data to userspace or
even filesystem corruption.

Fix the problem by protecting handling of readahead requests by
XFS_IOLOCK_SHARED similarly as we protect reads.

CC: stable@vger.kernel.org
Link: https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/
Reported-by: Amir Goldstein <amir73il@gmail.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/xfs/xfs_file.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 76748255f843..88fe3dbb3ba2 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -33,6 +33,7 @@
 #include <linux/pagevec.h>
 #include <linux/backing-dev.h>
 #include <linux/mman.h>
+#include <linux/fadvise.h>
 
 static const struct vm_operations_struct xfs_file_vm_ops;
 
@@ -939,6 +940,24 @@ xfs_file_fallocate(
 	return error;
 }
 
+STATIC int
+xfs_file_fadvise(
+	struct file *file,
+	loff_t start,
+	loff_t end,
+	int advice)
+{
+	struct xfs_inode *ip = XFS_I(file_inode(file));
+	int ret;
+
+	/* Readahead needs protection from hole punching and similar ops */
+	if (advice == POSIX_FADV_WILLNEED)
+		xfs_ilock(ip, XFS_IOLOCK_SHARED);
+	ret = generic_fadvise(file, start, end, advice);
+	if (advice == POSIX_FADV_WILLNEED)
+		xfs_iunlock(ip, XFS_IOLOCK_SHARED);
+	return ret;
+}
 
 STATIC loff_t
 xfs_file_remap_range(
@@ -1235,6 +1254,7 @@ const struct file_operations xfs_file_operations = {
 	.fsync		= xfs_file_fsync,
 	.get_unmapped_area = thp_get_unmapped_area,
 	.fallocate	= xfs_file_fallocate,
+	.fadvise	= xfs_file_fadvise,
 	.remap_file_range = xfs_file_remap_range,
 };
 
-- 
2.16.4

