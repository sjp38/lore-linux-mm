Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F170C3A5A7
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F96920828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F96920828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3774C6B000C; Thu, 29 Aug 2019 09:10:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EA106B000E; Thu, 29 Aug 2019 09:10:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA44C6B000D; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id BA9956B000E
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 579AF181AC9B4
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:42 +0000 (UTC)
X-FDA: 75875499924.14.sheet67_2335d54917b5f
X-HE-Tag: sheet67_2335d54917b5f
X-Filterd-Recvd-Size: 3511
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4DAE4AEFF;
	Thu, 29 Aug 2019 13:10:40 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C290B1E3BEA; Thu, 29 Aug 2019 15:10:39 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-xfs@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	Amir Goldstein <amir73il@gmail.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	<linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 3/3] xfs: Fix stale data exposure when readahead races with hole punch
Date: Thu, 29 Aug 2019 15:10:34 +0200
Message-Id: <20190829131034.10563-4-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190829131034.10563-1-jack@suse.cz>
References: <20190829131034.10563-1-jack@suse.cz>
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
 fs/xfs/xfs_file.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 28101bbc0b78..d952d5962e93 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -28,6 +28,7 @@
 #include <linux/falloc.h>
 #include <linux/backing-dev.h>
 #include <linux/mman.h>
+#include <linux/fadvise.h>
 
 static const struct vm_operations_struct xfs_file_vm_ops;
 
@@ -933,6 +934,30 @@ xfs_file_fallocate(
 	return error;
 }
 
+STATIC int
+xfs_file_fadvise(
+	struct file	*file,
+	loff_t		start,
+	loff_t		end,
+	int		advice)
+{
+	struct xfs_inode *ip = XFS_I(file_inode(file));
+	int ret;
+	int lockflags = 0;
+
+	/*
+	 * Operations creating pages in page cache need protection from hole
+	 * punching and similar ops
+	 */
+	if (advice == POSIX_FADV_WILLNEED) {
+		lockflags = XFS_IOLOCK_SHARED;
+		xfs_ilock(ip, lockflags);
+	}
+	ret = generic_fadvise(file, start, end, advice);
+	if (lockflags)
+		xfs_iunlock(ip, lockflags);
+	return ret;
+}
 
 STATIC loff_t
 xfs_file_remap_range(
@@ -1232,6 +1257,7 @@ const struct file_operations xfs_file_operations = {
 	.fsync		= xfs_file_fsync,
 	.get_unmapped_area = thp_get_unmapped_area,
 	.fallocate	= xfs_file_fallocate,
+	.fadvise	= xfs_file_fadvise,
 	.remap_file_range = xfs_file_remap_range,
 };
 
-- 
2.16.4


