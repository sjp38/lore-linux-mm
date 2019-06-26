Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 885CCC48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:35:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 326A220645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:35:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="h4CU9wnF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 326A220645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3A536B0003; Tue, 25 Jun 2019 22:35:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC5618E0003; Tue, 25 Jun 2019 22:35:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8AE88E0002; Tue, 25 Jun 2019 22:35:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91C7A6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:35:40 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y205so1809943ywy.19
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:35:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=FEN+goJhMPORyHM4KJFXebyZi4tarHTDm26+xICB5hA=;
        b=fr9+K0hzjhGSog8ool0xZUxf6V4/HmK5E87MngbNt1VqLxTmKsjf9o3ZnCTUebDNsn
         TYNrZ+c1T5DtpE+FQoNnhh9JbOyHucLA60pfTcSxOl0sMRyfBAGS24Ck2X5syCIbnOJA
         p7fBem2BRvaF+r380SMEmMsfWp/mnO8QtTZ5seucDBCmZk04bF7AIn03Mqk/vKfNqRAj
         fiPcTXZvuj4tUzgClaiPIHsYtIobipl1j2nv19dlePyLs83Z5kFpZj2fZi1iXm0m/FDo
         JreDfSad/lLwy3iTDHi96eG+oXQiUPuDSLzuZZYVP0m9D3xOis230KfAdaybVc6Zzuu8
         9R7Q==
X-Gm-Message-State: APjAAAWavFiaK2CbBJ+LTBsFFHGVRqybwsncfWg2z+fuNt1/cs8xQEFG
	HxaV6MJlNjJeBCyWilAC2grUAMp/8FvdI+0YMsurTr2d9pHOOvBuSsRxPGf1ZsApukzpKDOTeJ3
	/os4pPERAT0lG2mjbg/UfIRasA/gGiWF4cFHRb5W+uEWWKKofEXfF6kP4pdJKFNP1qQ==
X-Received: by 2002:a81:6c04:: with SMTP id h4mr1128721ywc.457.1561516540342;
        Tue, 25 Jun 2019 19:35:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypfO0zLMFscC6NIpq5wZAmBHDY6EFosureXhdQyTEoQ2ZPy7FSLreYwNjZZlfFxJ7N0wwM
X-Received: by 2002:a81:6c04:: with SMTP id h4mr1128697ywc.457.1561516539325;
        Tue, 25 Jun 2019 19:35:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561516539; cv=none;
        d=google.com; s=arc-20160816;
        b=pY6XyRyDFBKuBMyKMSIX3QFTGpbqnxRhi6/tvAqKbWvp8FCsmgwKijUGe4ow4rpXFT
         diG0UmnRNqoC47hbjm1qdoxpK+wUQHTEiRUlp0WZ8LGEJkk9cTlWj69Itt3sYWkuLMfI
         /kYpicSG4tp3gDW7HNRHDLR2FokFIGU8zCv1NssLEvh9Q6f0EBylqNnVmrGaf8MW26FC
         GJnviRhyO42jUkJQbNEx/HKVrP86nOx3lWvKs5+td1LOjaV4/lejzJdF8ib5VYfEj00y
         vo11iWl3qjeepO2hiU0y7tLsTF5nx5wzTOX7m6WxrnRKihScHrD7FpxK/a2woDRDxRqw
         dPhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=FEN+goJhMPORyHM4KJFXebyZi4tarHTDm26+xICB5hA=;
        b=jcDtyIujrpks/bBi+xAxEEzTz7f30vFXtREp7FKS3CGHFudj/bt8JdJAblRIVxEHSq
         ubA7AZk3/11RPw1NgDNu/3eJIx9BPyOsa1+gRaquTtqZhh6M6dU6TQzDaXZbZwi7bWMZ
         XfKk4NY8bXBQ+ahFUe+lP+vAMbqVQUvEtbHIsv98fy9yazfgj3MpU2Fkyx0AbCEbtRLd
         05S/UW8SYc+C4HWdUkoOTgqLmlEHqYPxc2IWIwwz/XNkQ0KqHFfd3ZccixFbmVLR23LM
         GciZ1snDMS9tZEso+Uz3r/PwGItgo77kL2bl7FApWHAK9CUhvDwuo+UxbP6q7XA7T1I4
         lg/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h4CU9wnF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t188si5669653yba.112.2019.06.25.19.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:35:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h4CU9wnF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2Ykgb120656;
	Wed, 26 Jun 2019 02:35:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=FEN+goJhMPORyHM4KJFXebyZi4tarHTDm26+xICB5hA=;
 b=h4CU9wnFOOS1YSb/1A5WUJ9R3mK0Lo4KDpPlx3IsKGFGb5GJDBgZdFF/ZkNeWJpw6ADQ
 z+48Fvs+Pd7PcF23eYSOuy/NgmC1FwimwF1CdjSRf7x6XmzQJR0FNvunJLDSAy/S3smG
 ddG5MlPmNZh7CEycU6bXfXwLQUBwmwz3yJdercybA222E3ljvBmtwC6s44Nv0fmoNFnY
 gQqgtyZlP6+to4/pWiK1OWN68DNeIlef0tARhlq4bA7ZqwvbkPG4MVRjDf2FeLozit1o
 ADMHU/0tRMhL9MKSCw8ikiY8qmzEGU5M3LTFzW066uDKTdzVCO3dSQqnm92Mh3qwjY4J Mg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2t9brt7msy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:35:26 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2XQWv081280;
	Wed, 26 Jun 2019 02:33:26 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2tat7cjny2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 02:33:26 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5Q2XK5E081200;
	Wed, 26 Jun 2019 02:33:20 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2tat7cjnxr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:20 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5Q2XJ67012227;
	Wed, 26 Jun 2019 02:33:19 GMT
Received: from localhost (/10.159.230.235)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 25 Jun 2019 19:33:18 -0700
Subject: [PATCH 3/5] vfs: flush and wait for io when setting the immutable
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
Date: Tue, 25 Jun 2019 19:33:16 -0700
Message-ID: <156151639615.2283603.2028690322950797383.stgit@magnolia>
In-Reply-To: <156151637248.2283603.8458727861336380714.stgit@magnolia>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260028
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
index 0f5af7c5f66b..bbd6d908900e 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -423,7 +423,7 @@ static int btrfs_ioctl_fssetxattr(struct file *file, void __user *arg)
 	old_flags = binode->flags;
 	old_i_flags = inode->i_flags;
 
-	ret = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+	ret = vfs_ioc_fssetxattr_prepare(inode, &old_fa, &fa);
 	if (ret)
 		goto out_unlock;
 
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 1e88c3af9a8d..146587c3fe8e 100644
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
index d6ed319388d6..af0fc040a15c 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -2826,7 +2826,7 @@ static int f2fs_ioc_fssetxattr(struct file *filp, unsigned long arg)
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
index 011657bd50ca..723550c8a2e4 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1058,6 +1058,30 @@ xfs_ioctl_setattr_xflags(
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
@@ -1065,6 +1089,9 @@ xfs_ioctl_setattr_xflags(
  * operation. The locks need to be held until the transaction has been committed
  * so that the cache invalidation is atomic with respect to the DAX flag
  * manipulation.
+ *
+ * The caller must use @join_flags to release the locks which are held on @ip
+ * regardless of return value.
  */
 static int
 xfs_ioctl_setattr_dax_invalidate(
@@ -1076,8 +1103,6 @@ xfs_ioctl_setattr_dax_invalidate(
 	struct super_block	*sb = inode->i_sb;
 	int			error;
 
-	*join_flags = 0;
-
 	/*
 	 * It is only valid to set the DAX flag on regular files and
 	 * directories on filesystems where the block size is equal to the page
@@ -1103,21 +1128,15 @@ xfs_ioctl_setattr_dax_invalidate(
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
@@ -1326,6 +1345,12 @@ xfs_ioctl_setattr(
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
@@ -1334,8 +1359,10 @@ xfs_ioctl_setattr(
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
@@ -1485,6 +1512,12 @@ xfs_ioc_setxflags(
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
@@ -1493,8 +1526,10 @@ xfs_ioc_setxflags(
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
index 51266c9dbadc..675ce9743bc1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3560,6 +3560,9 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 
 int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 			     struct fsxattr *fa);
+int vfs_ioc_fssetxattr_prepare(struct inode *inode,
+			       const struct fsxattr *old_fa,
+			       struct fsxattr *fa);
 
 /*
  * Flush file data before changing attributes.  Caller must hold any locks

