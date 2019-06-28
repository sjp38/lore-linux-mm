Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F9F8C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 329392063F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:37:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pBjv0y1S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 329392063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D91408E0003; Fri, 28 Jun 2019 14:37:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D42308E0002; Fri, 28 Jun 2019 14:37:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C09C48E0003; Fri, 28 Jun 2019 14:37:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f77.google.com (mail-yw1-f77.google.com [209.85.161.77])
	by kanga.kvack.org (Postfix) with ESMTP id 9B73C8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:37:19 -0400 (EDT)
Received: by mail-yw1-f77.google.com with SMTP id b63so10001066ywc.12
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:37:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=O3xegD6OiDT7CYvuWXxJjj2lv59PMA3CjktcEglMT6c=;
        b=OjD7SkEsqM6/28oAW31FcIxeoBEav40ThGjcx9nOA4rOEBu81/jUJ0QbjbfxATx0Qu
         gmiM0+VqOpCCnn9DXeK3fvYQjV1nXdyizPnbwbo+a2yhxyM6fT/h3tAHC9VNLrTkYwUt
         eILotlRUTkM4OZGwJwGflrgtr4A3UfSMX0o13uMfJJuWaJMtSjABknEBryIU2JixUIBL
         rd4ijloXkQvo+Rj/Ws35YU27x/a7CuzQgkSJmCXz6njhtBoqHGGL92OFOIEdZYrA5Tqj
         9GN/6RL2GIiGQM31+nOvJT5r+gPDIx06rL54vpgAdMzpYWDLDwR6HbJTYV/DuddoqnEg
         LCrg==
X-Gm-Message-State: APjAAAV+PJpPmcRQ5shjVnq8rGa83+0uEvu072z7hXJPcEeq73sPQhXw
	dPXIYhXhKVkXk0F9XmqQBWfphOsO+IYMNpauUU87r573RWDaD4EGS9o9rRnL5nHLcJ+e9+B+/KF
	vtRiKtfWfZ/WEA/vaIHMH/sBKRhkCVShAwJQVvhKzqncaJc16sly91xhsTpLlbl6ALA==
X-Received: by 2002:a25:61ce:: with SMTP id v197mr3063469ybb.109.1561747039389;
        Fri, 28 Jun 2019 11:37:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybviCP7yP4JJKXZQNISBhuwUEE3RnYBWMu4+6MXo5hd17NeYHTvZPNeKSB7Tabq5OMRhGb
X-Received: by 2002:a25:61ce:: with SMTP id v197mr3063426ybb.109.1561747038511;
        Fri, 28 Jun 2019 11:37:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561747038; cv=none;
        d=google.com; s=arc-20160816;
        b=Wlu17lf9RtvQMQNtRsAPQUEy6zefPs4nz0kSG/3pSoLTG2X8vMCiVjBolX4aN+T402
         uKigjG0+6SH+CsiORuNLW24qL3UMq2uM8z9e6Kj66pm3b/zb1YReOauYVBDejkGccX1p
         UEXmADLaOPgHETEOqbs9P6eHbcCwP4/HPD+bg27GDZTHj2I7cyTTMZGzXmb7haRZLLbK
         M1qdekjXjfyfJdDS452YyVbN65YA4jY1qLEIy0i3gSD8JFGdt46w8f4AvHhnS+aS2Drs
         17XM4Mjqbeu85MZjBFFL15+175Bb17+wNYfN7sQ5DKHQa9GHy7TkhSlx5u63SwBWWFcd
         Qvtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=O3xegD6OiDT7CYvuWXxJjj2lv59PMA3CjktcEglMT6c=;
        b=WMlIeGS+jTd5xyK2WN7wc6zTCNumHYF9YbKyPr1C7MfKSJTTwL7lT7+KN304NXVBqZ
         hWFyKfngO6CPAy1RZj8g4jIaGQpzAom8hzOKXfOmwOlyQkAw/hARkx7iETOiOY3Wcjvk
         ol71ymDGsAmPnhcFtNYXYIbjBkrP0kbVQWu103sF5bmdUHq9nJyN41qs2bSWhkVqBnpq
         8bsnnLAenU3MYYJNFY5GQjdJZB31lOG5boSldxG0XIeemhK3b/KVdMDa3PlFq0xB9Pon
         HPRlge9pttWTo1MFEnHyVsTCO/VyWeL0q/Bw+2xRBI3y2mOFKs4NfvH3Y1ykRj09Unl3
         YaJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pBjv0y1S;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z124si1243257yba.58.2019.06.28.11.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:37:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pBjv0y1S;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIZrgg116051;
	Fri, 28 Jun 2019 18:37:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=O3xegD6OiDT7CYvuWXxJjj2lv59PMA3CjktcEglMT6c=;
 b=pBjv0y1SN47tvWrJ59lGt95PbfTTcZyMo9tTZrwAQL+MKNQI4cQR1e3KUF4ZjX6TmQXZ
 7fjAp5KNwNlrmQE8bFZ5Mtp6Ur83C4iOF3g41nLAjrgtjNTT9OMudTKl25Pzx5EC6Sp/
 VxGLjm8WAc/tteHJnZ565nHN8j5W0lueTaPVyfE1fK2HAHC0cvuGLTA/Uxt/ht5MjO0z
 jNNOa/AMQsWH9qGigPS4x+VIrXc0q1GoaD59PUQetqOon/6SHWDztzFuxDWr7fJOVHCm
 MRUq+5/EFMA4sIYD7vqAXm0IVx7/aanhJbJ8Sl2GQu5MJjUMqHRiuVbkgORgpat3rs1Y 6g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t9cyqxyse-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:37:06 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYqWe152199;
	Fri, 28 Jun 2019 18:35:05 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6w235t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 28 Jun 2019 18:35:05 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5SIZ4ue152605;
	Fri, 28 Jun 2019 18:35:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t9p6w2359-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:04 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5SIZ2qU029171;
	Fri, 28 Jun 2019 18:35:02 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:35:02 -0700
Subject: [PATCH 3/4] vfs: flush and wait for io when setting the immutable
 flag via FSSETXATTR
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Fri, 28 Jun 2019 11:34:59 -0700
Message-ID: <156174689965.1557469.9018924813461417576.stgit@magnolia>
In-Reply-To: <156174687561.1557469.7505651950825460767.stgit@magnolia>
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

When we're using FS_IOC_FSSETXATTR to set the immutable flag on a file,
we need to ensure that userspace can't continue to write the file after
the file becomes immutable.  To make that happen, we have to flush all
the dirty pagecache pages to disk to ensure that we can fail a page
fault on a mmap'd region, wait for pending directio to complete, and
hope the caller locked out any new writes by holding the inode lock.

XFS has more complex locking than other FSSETXATTR implementations so we
have to keep the checking and preparation code in different functions.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/btrfs/ioctl.c   |    2 +
 fs/ext4/ioctl.c    |    2 +
 fs/f2fs/file.c     |    2 +
 fs/inode.c         |   31 +++++++++++++++++++++++
 fs/xfs/xfs_ioctl.c |   71 +++++++++++++++++++++++++++++++++++++++-------------
 include/linux/fs.h |    3 ++
 6 files changed, 90 insertions(+), 21 deletions(-)


diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 3cd66efdb99d..aeffe3fd99c4 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -420,7 +420,7 @@ static int btrfs_ioctl_fssetxattr(struct file *file, void __user *arg)
 
 	simple_fill_fsxattr(&old_fa,
 			    btrfs_inode_flags_to_xflags(binode->flags));
-	ret = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+	ret = vfs_ioc_fssetxattr_prepare(inode, &old_fa, &fa);
 	if (ret)
 		goto out_unlock;
 
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 566dfac28b3f..69810e59f89a 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1109,7 +1109,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 
 		inode_lock(inode);
 		ext4_fill_fsxattr(inode, &old_fa);
-		err = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+		err = vfs_ioc_fssetxattr_prepare(inode, &old_fa, &fa);
 		if (err)
 			goto out;
 		flags = (ei->i_flags & ~EXT4_FL_XFLAG_VISIBLE) |
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 8799468724f9..b47f22eb483e 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -2825,7 +2825,7 @@ static int f2fs_ioc_fssetxattr(struct file *filp, unsigned long arg)
 	inode_lock(inode);
 
 	f2fs_fill_fsxattr(inode, &old_fa);
-	err = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+	err = vfs_ioc_fssetxattr_prepare(inode, &old_fa, &fa);
 	if (err)
 		goto out;
 	flags = (fi->i_flags & ~F2FS_FL_XFLAG_VISIBLE) |
diff --git a/fs/inode.c b/fs/inode.c
index 65a412af3ffb..cf07378e5731 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2293,3 +2293,34 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 	return 0;
 }
 EXPORT_SYMBOL(vfs_ioc_fssetxattr_check);
+
+/*
+ * Generic function to check FS_IOC_FSSETXATTR values and reject any invalid
+ * configurations.  If none are found, flush all pending IO and dirty mappings
+ * before setting S_IMMUTABLE on an inode.  If the flush fails we'll clear the
+ * flag before returning error.
+ *
+ * Note: the caller must hold whatever locks are necessary to block any other
+ * threads from starting a write to the file.
+ */
+int vfs_ioc_fssetxattr_prepare(struct inode *inode,
+			       const struct fsxattr *old_fa,
+			       struct fsxattr *fa)
+{
+	int ret;
+
+	ret = vfs_ioc_fssetxattr_check(inode, old_fa, fa);
+	if (ret)
+		return ret;
+
+	if (!S_ISREG(inode->i_mode) || IS_IMMUTABLE(inode) ||
+	    !(fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
+		return 0;
+
+	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
+	ret = inode_drain_writes(inode);
+	if (ret)
+		inode_set_flags(inode, 0, S_IMMUTABLE);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_ioc_fssetxattr_prepare);
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index fe29aa61293c..552f18554c48 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1057,6 +1057,30 @@ xfs_ioctl_setattr_xflags(
 	return 0;
 }
 
+/*
+ * If we're setting immutable on a regular file, we need to prevent new writes.
+ * Once we've done that, we must wait for all the other writes to complete.
+ *
+ * The caller must use @join_flags to release the locks which are held on @ip
+ * regardless of return value.
+ */
+static int
+xfs_ioctl_setattr_drain_writes(
+	struct xfs_inode	*ip,
+	const struct fsxattr	*fa,
+	int			*join_flags)
+{
+	struct inode		*inode = VFS_I(ip);
+
+	if (!S_ISREG(inode->i_mode) || !(fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
+		return 0;
+
+	*join_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
+	xfs_ilock(ip, *join_flags);
+
+	return inode_drain_writes(inode);
+}
+
 /*
  * If we are changing DAX flags, we have to ensure the file is clean and any
  * cached objects in the address space are invalidated and removed. This
@@ -1064,6 +1088,9 @@ xfs_ioctl_setattr_xflags(
  * operation. The locks need to be held until the transaction has been committed
  * so that the cache invalidation is atomic with respect to the DAX flag
  * manipulation.
+ *
+ * The caller must use @join_flags to release the locks which are held on @ip
+ * regardless of return value.
  */
 static int
 xfs_ioctl_setattr_dax_invalidate(
@@ -1075,8 +1102,6 @@ xfs_ioctl_setattr_dax_invalidate(
 	struct super_block	*sb = inode->i_sb;
 	int			error;
 
-	*join_flags = 0;
-
 	/*
 	 * It is only valid to set the DAX flag on regular files and
 	 * directories on filesystems where the block size is equal to the page
@@ -1102,21 +1127,15 @@ xfs_ioctl_setattr_dax_invalidate(
 		return 0;
 
 	/* lock, flush and invalidate mapping in preparation for flag change */
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
-	error = filemap_write_and_wait(inode->i_mapping);
-	if (error)
-		goto out_unlock;
-	error = invalidate_inode_pages2(inode->i_mapping);
-	if (error)
-		goto out_unlock;
-
-	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
-	return 0;
-
-out_unlock:
-	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
-	return error;
+	if (*join_flags == 0) {
+		*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
+		xfs_ilock(ip, *join_flags);
+		error = filemap_write_and_wait(inode->i_mapping);
+		if (error)
+			return error;
+	}
 
+	return invalidate_inode_pages2(inode->i_mapping);
 }
 
 /*
@@ -1325,6 +1344,12 @@ xfs_ioctl_setattr(
 			return code;
 	}
 
+	code = xfs_ioctl_setattr_drain_writes(ip, fa, &join_flags);
+	if (code) {
+		xfs_iunlock(ip, join_flags);
+		goto error_free_dquots;
+	}
+
 	/*
 	 * Changing DAX config may require inode locking for mapping
 	 * invalidation. These need to be held all the way to transaction commit
@@ -1333,8 +1358,10 @@ xfs_ioctl_setattr(
 	 * appropriately.
 	 */
 	code = xfs_ioctl_setattr_dax_invalidate(ip, fa, &join_flags);
-	if (code)
+	if (code) {
+		xfs_iunlock(ip, join_flags);
 		goto error_free_dquots;
+	}
 
 	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
 	if (IS_ERR(tp)) {
@@ -1484,6 +1511,12 @@ xfs_ioc_setxflags(
 	if (error)
 		return error;
 
+	error = xfs_ioctl_setattr_drain_writes(ip, &fa, &join_flags);
+	if (error) {
+		xfs_iunlock(ip, join_flags);
+		goto out_drop_write;
+	}
+
 	/*
 	 * Changing DAX config may require inode locking for mapping
 	 * invalidation. These need to be held all the way to transaction commit
@@ -1492,8 +1525,10 @@ xfs_ioc_setxflags(
 	 * appropriately.
 	 */
 	error = xfs_ioctl_setattr_dax_invalidate(ip, &fa, &join_flags);
-	if (error)
+	if (error) {
+		xfs_iunlock(ip, join_flags);
 		goto out_drop_write;
+	}
 
 	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
 	if (IS_ERR(tp)) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0efe749de577..73a8bd789e36 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3560,6 +3560,9 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 
 int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 			     struct fsxattr *fa);
+int vfs_ioc_fssetxattr_prepare(struct inode *inode,
+			       const struct fsxattr *old_fa,
+			       struct fsxattr *fa);
 
 static inline void simple_fill_fsxattr(struct fsxattr *fa, __u32 xflags)
 {

