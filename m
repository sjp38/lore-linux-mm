Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDCC7C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A226F208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A226F208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B38D6B000E; Fri,  9 Aug 2019 18:58:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2666D6B0010; Fri,  9 Aug 2019 18:58:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0902D6B0266; Fri,  9 Aug 2019 18:58:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27566B000E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so62398255pfv.18
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uJ/R3P593pjHSZ6lTtczPp3JUX+mJ6ABiFQkwj+ghMo=;
        b=pJdeGRUNvGk7roUKMGVmnO2YLCzpmfCRgVE2M92utt8zfOWyaa/5sQf1jsHwoL97mb
         LOCWyHm3p7Ze7JEYX0Qm2UIDNsPf9L7a3/gSAv1U/0QkX6wF1EFdYWtBGuLzeIZ/Der8
         v4lNdZqh3uW8sPq4XSJBHuvRzZQ/rEtrd8SEoDUKH9Hu3PfrZ/0o27nAXpzaA/wSwThw
         9fyDgoHH0G77ELdbGOIDB6vB8tUs9eNJmPJqVd3QwImB9kY504YLYwqPtiygGXWAXbXa
         wFejKue7yfT+R4JQ25XOMKOQjP2+U2nOKXq4/HtwZgJkcI+09hAizih2hAewVTPtnYBI
         OWCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWF9Ue7Vpxd8gSa6GpaCDlOvhiHwM/GAWr1/TfUhST4KryYpCve
	jZC5pEWWlV/8xigxLrLIcQqlreljgeEthvgu9ypDZ2N/jx7qP/T9geqP/E/OKFAL+38wZ12R1I/
	f0wC9lPI7JO//FF0h/fP516PswZ/+PmvQxKq96TKEVcibGIZGUW/IJZhVchFfUzn7/w==
X-Received: by 2002:a17:902:543:: with SMTP id 61mr21258203plf.20.1565391532453;
        Fri, 09 Aug 2019 15:58:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmDr9/VOkhWV8OfKbExnl/Bz43bTAwgfdh5049LxK6blO8y0t3cK+nf5v7aRDQ98f3X5ZR
X-Received: by 2002:a17:902:543:: with SMTP id 61mr21258164plf.20.1565391531559;
        Fri, 09 Aug 2019 15:58:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391531; cv=none;
        d=google.com; s=arc-20160816;
        b=r3cRg2TVt6tx+FwWfMoTyrYmtf9GyW8ug2ZkqQVPhDrGK9OhzZu5jtWQnPnVaLrQP9
         FYGsv7ymha5QO4So55bOyAl457l+qrFois3B84xl8ZEXI5jwZeIScHd5CuU9Z2/rt05X
         GJVvvrSnJtiFGQ361D2E4Tim3EXgEwMNNcnGQaOonNkIGbKuufI2DfgezjHCze5bRgiA
         RDw/FyuKySRZptmR7HMvYt+7zCdbHyEb3mch1FtrLiLHDP+OeG5YBGCOHegaFOpBspc0
         lBQNDtvfTN14KLa3Kq8MqsuY9fi8HQ7QEZpAoYK2X/B3hj8+Ej14c1HAz43uxX8Sgv+J
         fULQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uJ/R3P593pjHSZ6lTtczPp3JUX+mJ6ABiFQkwj+ghMo=;
        b=tAy97Kpk8Rb3StzxkvF9sCP5fsor6iQY4jrheODZomUC5XyO18DfF/MS4UqLMDLMLl
         vdy2PpHc5dze5Q4uDv+nJJKHacOenz83qH+5YQ6Eadcn1x88hGD0cM4WdldIIrZicQ4G
         AjwGY1VyhkZTphXwjWw4IoO0d/MlprAgpOrZ43wyK4cQnH83hhDksyyJqTGx1qlNlzHo
         hlk2Xo+GuBiE3deYnHNtMziBlYxPJ6LaBIRIpqzAbCUrBbSd8auKZ8BXZHbHSOZnhVQ7
         o1JY9I1FgpA+tFBZJ3bckmaCM80eDSKKjReh+ceRm4aaZYjFBGSBYc7h9axHfaAqzqLF
         +/Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i64si56920667pge.307.2019.08.09.15.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:51 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="166136395"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:50 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 07/19] fs/xfs: Teach xfs to use new dax_layout_busy_page()
Date: Fri,  9 Aug 2019 15:58:21 -0700
Message-Id: <20190809225833.6657-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

dax_layout_busy_page() can now operate on a sub-range of the
address_space provided.

Have xfs specify the sub range to dax_layout_busy_page()

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/xfs/xfs_file.c  | 19 +++++++++++++------
 fs/xfs/xfs_inode.h |  5 +++--
 fs/xfs/xfs_ioctl.c | 15 ++++++++++++---
 fs/xfs/xfs_iops.c  | 14 ++++++++++----
 4 files changed, 38 insertions(+), 15 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 8f8d478f9ec6..447571e3cb02 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -295,7 +295,11 @@ xfs_file_aio_write_checks(
 	if (error <= 0)
 		return error;
 
-	error = xfs_break_layouts(inode, iolock, BREAK_WRITE);
+	/*
+	 * BREAK_WRITE ignores offset/len tuple just specify the whole file
+	 * (0 - ULONG_MAX to be safe.
+	 */
+	error = xfs_break_layouts(inode, iolock, 0, ULONG_MAX, BREAK_WRITE);
 	if (error)
 		return error;
 
@@ -734,14 +738,15 @@ xfs_wait_dax_page(
 static int
 xfs_break_dax_layouts(
 	struct inode		*inode,
-	bool			*retry)
+	bool			*retry,
+	loff_t                   off,
+	loff_t                   len)
 {
 	struct page		*page;
 
 	ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
 
-	/* We default to the "whole file" */
-	page = dax_layout_busy_page(inode->i_mapping, 0, ULONG_MAX);
+	page = dax_layout_busy_page(inode->i_mapping, off, len);
 	if (!page)
 		return 0;
 
@@ -755,6 +760,8 @@ int
 xfs_break_layouts(
 	struct inode		*inode,
 	uint			*iolock,
+	loff_t                   off,
+	loff_t                   len,
 	enum layout_break_reason reason)
 {
 	bool			retry;
@@ -766,7 +773,7 @@ xfs_break_layouts(
 		retry = false;
 		switch (reason) {
 		case BREAK_UNMAP:
-			error = xfs_break_dax_layouts(inode, &retry);
+			error = xfs_break_dax_layouts(inode, &retry, off, len);
 			if (error || retry)
 				break;
 			/* fall through */
@@ -808,7 +815,7 @@ xfs_file_fallocate(
 		return -EOPNOTSUPP;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
+	error = xfs_break_layouts(inode, &iolock, offset, len, BREAK_UNMAP);
 	if (error)
 		goto out_unlock;
 
diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
index 558173f95a03..1b0948f5267c 100644
--- a/fs/xfs/xfs_inode.h
+++ b/fs/xfs/xfs_inode.h
@@ -475,8 +475,9 @@ enum xfs_prealloc_flags {
 
 int	xfs_update_prealloc_flags(struct xfs_inode *ip,
 				  enum xfs_prealloc_flags flags);
-int	xfs_break_layouts(struct inode *inode, uint *iolock,
-		enum layout_break_reason reason);
+int xfs_break_layouts(struct inode *inode, uint *iolock,
+		      loff_t off, loff_t len,
+		      enum layout_break_reason reason);
 
 /* from xfs_iops.c */
 extern void xfs_setup_inode(struct xfs_inode *ip);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 6f7848cd5527..3897b88080bd 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -597,6 +597,7 @@ xfs_ioc_space(
 	enum xfs_prealloc_flags	flags = 0;
 	uint			iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 	int			error;
+	loff_t                  break_length;
 
 	if (inode->i_flags & (S_IMMUTABLE|S_APPEND))
 		return -EPERM;
@@ -617,9 +618,6 @@ xfs_ioc_space(
 		return error;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
-	if (error)
-		goto out_unlock;
 
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
@@ -665,6 +663,17 @@ xfs_ioc_space(
 		goto out_unlock;
 	}
 
+	/* break layout for the whole file if len ends up 0 */
+	if (bf->l_len == 0)
+		break_length = ULONG_MAX;
+	else
+		break_length = bf->l_len;
+
+	error = xfs_break_layouts(inode, &iolock, bf->l_start, break_length,
+				  BREAK_UNMAP);
+	if (error)
+		goto out_unlock;
+
 	switch (cmd) {
 	case XFS_IOC_ZERO_RANGE:
 		flags |= XFS_PREALLOC_SET;
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index ff3c1fae5357..f0de5486f6c1 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -1042,10 +1042,16 @@ xfs_vn_setattr(
 		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
 		iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 
-		error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
-		if (error) {
-			xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
-			return error;
+		if (iattr->ia_size < inode->i_size) {
+			loff_t                  off = iattr->ia_size;
+			loff_t                  len = inode->i_size - iattr->ia_size;
+
+			error = xfs_break_layouts(inode, &iolock, off, len,
+						  BREAK_UNMAP);
+			if (error) {
+				xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
+				return error;
+			}
 		}
 
 		error = xfs_vn_setattr_size(dentry, iattr);
-- 
2.20.1

