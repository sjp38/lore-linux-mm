Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4526FC28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 066E020874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 066E020874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EA6A6B0277; Wed,  5 Jun 2019 21:45:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34EC96B0278; Wed,  5 Jun 2019 21:45:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12D516B0279; Wed,  5 Jun 2019 21:45:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C09896B0277
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bc12so531221plb.0
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uFdusVjodyy3c8noCcKp53JvnCAvA92nCht7AL33MbQ=;
        b=EOfmlVCII2cQhr55KY8EBBTTC81F0sZqWcwLrBPQ1ylQt9iOsAc6NeVG5ukmuBE+rS
         3hyR2hjXAGddoSbUq0zDLdZbBk/1jo3/AXkC1P0fNXdly2Tc4PmKjjbcFW0Zsy+vRUs5
         dF2M3sVeLZQoB9GWm3+g2VdT8+lexUwskXOyOtAdln6NrClTPXmNzVEaifpYH3ASZr1C
         PcvkdwNOztwD/fjEnonXmZoDtUT0F4qU9ZmLZBHMai4duhq8PiTyzKZEM9vnkeKLSF5e
         //NQOohyWZaNEFXl0sh7IyKjlt9M6dOPUXpFNp6UFAOKKmmf1IPOxwANMidVenRYRitz
         YTfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWwLLrBCeQMvAHEdS2xFWKJQLwsuqgwQ/3e0kSE1vbWj2G8h1NW
	CRCmm23TZvfX1CHn9UyiTxXUpFBYmAkWHwor+L2c9D+WYS75G9Edfs7k9LP5GgucM1KJDaTjpT2
	aGIWmG87jtFA7eAGCf1sY+hU9SenT5dmdfRJQO+44WI6lVGyEhh4aLIsEY4CJANIBCg==
X-Received: by 2002:a63:1b07:: with SMTP id b7mr791320pgb.289.1559785525435;
        Wed, 05 Jun 2019 18:45:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ8cNK8tcJ9HrLjJ/JPLTou+5E9DovZl9WsXQFko8OJ+nE/Z4Azr/fE1gCQuUzu6h1YHdp
X-Received: by 2002:a63:1b07:: with SMTP id b7mr791283pgb.289.1559785524590;
        Wed, 05 Jun 2019 18:45:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785524; cv=none;
        d=google.com; s=arc-20160816;
        b=W/jsblF+zKTSKLyUqfRO+y3Fr8UYAF4nI/P3buapiJ+lDNBvFBLMMMYPdfP84oGBkv
         GRaqaKaxUG5WpNiEuJOKTE0FRxDbCkZGDaM4MzqdrobMLc7mO1HMYs+xCoTJVXRUcnSm
         DRGk0sa7E9IYEW49JvoXwxdnBNJ3krG9QnugrlYLcboIQeIiATBjtQMjkwWhZaiAk4iD
         Ldzp4/ueEY/2NU076LzwARtRTlQvwxp87ByL5EcCCPXXcIWp7+Gl9kbMp47PXmOKXxy5
         6UqzxLnQ+hWofXyDXYSQqvfobJi3BzzvarvnUALUqgA7R/tp9Ivzfv8Z6sNXNU0vtHz7
         1rbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=uFdusVjodyy3c8noCcKp53JvnCAvA92nCht7AL33MbQ=;
        b=vrk88l/TqtsOEQCBrHxnCaCN65SnD6evIura5//YiKArnixcf7BBApCKud7+cN1Xft
         7lKdm7Rx3cyZmzvby9jdyVP1rM0jGG3u2ApKJHgHNcpocj65ww32hKkz7q40zVyTv9hl
         fvLjR27wSFRV1+Qatg6pcwOiQk21WU/JLGRLm4YWcaAcyzlGwpAoacDKQxYdcfKOVpEx
         DNDKEk8RgGQHgZkYmXPA9N/CyzsI657kNUN3Jj+swuKytdnqKnTK7CTXKiZ56o9pSE7c
         nCBV2fsV+wpEfE/OZb6GFQcEl1/z0qxsyQevO6u8BSw4MABkuckzoHAUu37TZx/kiNYH
         x0Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 71si254942plf.156.2019.06.05.18.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:23 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:22 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 08/10] fs/xfs: Teach xfs to use new dax_layout_busy_page()
Date: Wed,  5 Jun 2019 18:45:41 -0700
Message-Id: <20190606014544.8339-9-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
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
index ebddf911644c..350eb5546d36 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -300,7 +300,11 @@ xfs_file_aio_write_checks(
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
 
@@ -740,14 +744,15 @@ xfs_wait_dax_page(
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
 
@@ -761,6 +766,8 @@ int
 xfs_break_layouts(
 	struct inode		*inode,
 	uint			*iolock,
+	loff_t                   off,
+	loff_t                   len,
 	enum layout_break_reason reason)
 {
 	bool			retry;
@@ -772,7 +779,7 @@ xfs_break_layouts(
 		retry = false;
 		switch (reason) {
 		case BREAK_UNMAP:
-			error = xfs_break_dax_layouts(inode, &retry);
+			error = xfs_break_dax_layouts(inode, &retry, off, len);
 			if (error || retry)
 				break;
 			/* fall through */
@@ -814,7 +821,7 @@ xfs_file_fallocate(
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
index d7dfc13f30f5..a702e44a63b8 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -605,6 +605,7 @@ xfs_ioc_space(
 	enum xfs_prealloc_flags	flags = 0;
 	uint			iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
 	int			error;
+	loff_t                  break_length;
 
 	if (inode->i_flags & (S_IMMUTABLE|S_APPEND))
 		return -EPERM;
@@ -625,9 +626,6 @@ xfs_ioc_space(
 		return error;
 
 	xfs_ilock(ip, iolock);
-	error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
-	if (error)
-		goto out_unlock;
 
 	switch (bf->l_whence) {
 	case 0: /*SEEK_SET*/
@@ -673,6 +671,17 @@ xfs_ioc_space(
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
index 74047bd0c1ae..5529bc7a516b 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -1052,10 +1052,16 @@ xfs_vn_setattr(
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

