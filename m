Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9F26C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E37520821
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iop0iBLc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E37520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00CF98E0006; Fri, 21 Jun 2019 19:57:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFF748E0001; Fri, 21 Jun 2019 19:57:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9F418E0006; Fri, 21 Jun 2019 19:57:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0D7B8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:27 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id y205so8018053ywy.19
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=bO+sN6Te54B7Gm32yC/95CPAosLiG+rfFvZuf1HgzMU=;
        b=f3VOpJQEZ2hxmLrZxbREJYsg5D4NGS8PEtMOPCNq1x3iC4JRTiaQNIENZKFpxdOXIg
         oKpy664OlZSeyKV5/kq2alge4bQFHy+Co1aPShkRhjuzwymjMSDDr30Vrs3Dd8mFxsvl
         ljtNukvnx3EW+/doyd2HMwQII9j3X8d4CmYiXM3kuHPDlU2Kpfx9V1wgZrZi5r0yLXKX
         Ydi4evq7XqB4AnAsoBLNfdD0nTqX6VM+7iqjcZpPcrbAJkZ5g45E44P9mvJPx8jauoo1
         +rTeKfKRU3Ije2OtXd6AfZsJHZnYqlmY9eRRqyP6hjpEQ0K4CjUClFE0+GZNtsCcaMw9
         HoMQ==
X-Gm-Message-State: APjAAAVHX1Ra3gmaisyRN6h/jXbScPh5ygonPRPC/n4TeGmjsfVM2MGv
	Cii7ueN1KBj9HdAlFcRhxBPZqeYI7FE3/s1GK/2KtIanetm0yXS+KfGouELutLtnTTLPOxNHbJG
	WixiOc0l51bguWQ6BG64ketU5lqRIhGyBzWnBWXQLEfw8deZROYftXFVgpJ0eVUqjMw==
X-Received: by 2002:a25:be01:: with SMTP id h1mr25905935ybk.520.1561161447398;
        Fri, 21 Jun 2019 16:57:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcjTuXk91f1oprkRKKWCwMpxvUokdNJhNHe1Jl0SN2/zi9Re/8LA2/KKxNlfTAksVBr6y4
X-Received: by 2002:a25:be01:: with SMTP id h1mr25905924ybk.520.1561161446661;
        Fri, 21 Jun 2019 16:57:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161446; cv=none;
        d=google.com; s=arc-20160816;
        b=uy2EClK6Qm4LWDTim8ECyDXLietQ3sPFTr1duXLpih9M9sRW0+ld2skwp0qd7KNqLH
         whA/zN3c5bTTuiHP45NeHd7J07pO6tzxxqlwzYNnRr5A/k44FwQdW/lCDFg1vXQ8E5Ue
         bU5qs2rr1j9jt63Nti+jsIP0Mejbvjz6PeBoYghwa4Am4d+MCLcjsyg9Vhf0wG8YGHvp
         Jh5MPP2Xyt/tb4xX5LwJONu4hs7V1OCH8u434p+qBCBOT5Ny2xzBYK+nStURHUwmDu7i
         8dqEDeJnFbHMvu+NrtvB6q9hLXXNfnhVsDnxYnn1nZjir5dwd10ALbLVXnWfuO9Ohxcy
         qawA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=bO+sN6Te54B7Gm32yC/95CPAosLiG+rfFvZuf1HgzMU=;
        b=f6gzh9b2iLnVe3u32cDOyItmISoqTUtKA3fQy/pdgL8J9aRIybYuxA5y8awJbAiKVF
         /bwBHbconpzxeGO8wdBokA55MZwni8KPYoFew2KIVQNLdH1hZ0rwX6OfOoVvVTt3P+6Q
         R4BBt20A5Jh2XjxbrV52ZqLq9dPb50VPiNShEMLMA5bugNzQj9RVBiHLJ9Db4k9HewxF
         pSTjEfSck6vcZTVQlsMum5Wc1m4JDdW6rekLRc8ZbhjFKlbKrI0DDR2Tbq9ZI92HibBk
         ryJ0MpZUCroty6JyNMyH5oRclf8gjRY2h5CwGPeWsb4Z3lbB03vyTRB7dpVtnNNVEfRO
         odWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iop0iBLc;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r13si1365529ybp.145.2019.06.21.16.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iop0iBLc;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNsqBD059305;
	Fri, 21 Jun 2019 23:57:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=bO+sN6Te54B7Gm32yC/95CPAosLiG+rfFvZuf1HgzMU=;
 b=iop0iBLcfymdJCKdAp5ye36YRtYmpLaZtzpeCNIekVvk8BHvE0TvsQwZPTRe3GvBvnHB
 POhg9g6OZky6l9+XmlonbM47GDVpeHCNptPw1f0SGTFD69qudz5qj2jFjltpAPUFyq13
 w3KNWu+wVs7ezxklCQg9TRG/odCOQBt/cLogJMrLkTERZiJDfOXSZr31CkR+QhJH0+68
 gjtvuKs3csVg+Tg8WtXM+Uv0cSBNM7/LjpN7quqI1LB93qlLu9XwdmKKwOJl6wy5h1U7
 wT8duhrMKfSo1Tj8wa37VlB+1nB222jRZXy16Cni/dLFHtFij5jp8ZgfZ5xzfhH5L5KN WQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2t7809rqv6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:20 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNu9VH042326;
	Fri, 21 Jun 2019 23:57:19 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3030.oracle.com with ESMTP id 2t77ypesfg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:19 +0000
Received: from userp3030.oracle.com (userp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNvJbZ044395;
	Fri, 21 Jun 2019 23:57:19 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2t77ypesfc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:19 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5LNvIgI031562;
	Fri, 21 Jun 2019 23:57:18 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 23:57:17 +0000
Subject: [PATCH 3/7] vfs: flush and wait for io when setting the immutable
 flag via FSSETXATTR
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, clm@fb.com, adilger.kernel@dilger.ca,
        viro@zeniv.linux.org.uk, jack@suse.com, dsterba@suse.com,
        jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Fri, 21 Jun 2019 16:57:15 -0700
Message-ID: <156116143526.1664939.6767366095685084430.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
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

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/btrfs/ioctl.c   |    3 +++
 fs/ext4/ioctl.c    |    3 +++
 fs/f2fs/file.c     |    3 +++
 fs/xfs/xfs_ioctl.c |   39 +++++++++++++++++++++++++++++++++------
 include/linux/fs.h |   37 +++++++++++++++++++++++++++++++++++++
 5 files changed, 79 insertions(+), 6 deletions(-)


diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index f431813b2454..63a9281e6ce0 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -432,6 +432,9 @@ static int btrfs_ioctl_fssetxattr(struct file *file, void __user *arg)
 
 	__btrfs_ioctl_fsgetxattr(binode, &old_fa);
 	ret = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+	if (ret)
+		goto out_unlock;
+	ret = vfs_ioc_fssetxattr_flush_data(inode, &fa);
 	if (ret)
 		goto out_unlock;
 
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index a05341b94d98..6037585c1520 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1115,6 +1115,9 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		inode_lock(inode);
 		ext4_fsgetxattr(inode, &old_fa);
 		err = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+		if (err)
+			goto out;
+		err = vfs_ioc_fssetxattr_flush_data(inode, &fa);
 		if (err)
 			goto out;
 		flags = (ei->i_flags & ~EXT4_FL_XFLAG_VISIBLE) |
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index d3cf4bdb8738..97f4bb36540f 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -2832,6 +2832,9 @@ static int f2fs_ioc_fssetxattr(struct file *filp, unsigned long arg)
 
 	__f2fs_ioc_fsgetxattr(inode, &old_fa);
 	err = vfs_ioc_fssetxattr_check(inode, &old_fa, &fa);
+	if (err)
+		goto out;
+	err = vfs_ioc_fssetxattr_flush_data(inode, &fa);
 	if (err)
 		goto out;
 	flags = (fi->i_flags & ~F2FS_FL_XFLAG_VISIBLE) |
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index b494e7e881e3..88583b3e1e76 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1014,6 +1014,28 @@ xfs_diflags_to_linux(
 #endif
 }
 
+/*
+ * Lock the inode against file io and page faults, then flush all dirty pages
+ * and wait for writeback and direct IO operations to finish.  Returns with
+ * the relevant inode lock flags set in @join_flags.  Caller is responsible for
+ * unlocking even on error return.
+ */
+static int
+xfs_ioctl_setattr_flush(
+	struct xfs_inode	*ip,
+	int			*join_flags)
+{
+	/* Already locked the inode from IO?  Assume we're done. */
+	if (((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL)) ==
+			     (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
+		return 0;
+
+	/* Lock and flush all mappings and IO in preparation for flag change */
+	*join_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
+	xfs_ilock(ip, *join_flags);
+	return inode_flush_data(VFS_I(ip));
+}
+
 static int
 xfs_ioctl_setattr_xflags(
 	struct xfs_trans	*tp,
@@ -1099,23 +1121,22 @@ xfs_ioctl_setattr_dax_invalidate(
 	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
 		return 0;
 
-	if (S_ISDIR(inode->i_mode))
+	if (!S_ISREG(inode->i_mode))
 		return 0;
 
-	/* lock, flush and invalidate mapping in preparation for flag change */
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
-	error = filemap_write_and_wait(inode->i_mapping);
+	error = xfs_ioctl_setattr_flush(ip, join_flags);
 	if (error)
 		goto out_unlock;
 	error = invalidate_inode_pages2(inode->i_mapping);
 	if (error)
 		goto out_unlock;
 
-	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
 	return 0;
 
 out_unlock:
-	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+	if (*join_flags)
+		xfs_iunlock(ip, *join_flags);
+	*join_flags = 0;
 	return error;
 
 }
@@ -1337,6 +1358,12 @@ xfs_ioctl_setattr(
 	if (code)
 		goto error_free_dquots;
 
+	if (!join_flags && vfs_ioc_fssetxattr_need_flush(VFS_I(ip), fa)) {
+		code = xfs_ioctl_setattr_flush(ip, &join_flags);
+		if (code)
+			goto error_free_dquots;
+	}
+
 	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
 	if (IS_ERR(tp)) {
 		code = PTR_ERR(tp);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ed9a74cf5ef3..b4553d01e254 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3607,5 +3607,42 @@ static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
 int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 			     struct fsxattr *fa);
 
+/*
+ * Do we need to flush the file data before changing attributes?  When we're
+ * setting the immutable flag we must stop all directio writes and flush the
+ * dirty pages so that we can fail the page fault on the next write attempt.
+ */
+static inline bool vfs_ioc_fssetxattr_need_flush(struct inode *inode,
+						 struct fsxattr *fa)
+{
+	if (S_ISREG(inode->i_mode) && !IS_IMMUTABLE(inode) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
+		return true;
+
+	return false;
+}
+
+/*
+ * Flush all pending IO and dirty mappings before setting S_IMMUTABLE on an
+ * inode via FS_IOC_SETXATTR.  If the flush fails we'll clear the flag before
+ * returning error.
+ *
+ * Note: the caller should be holding i_mutex, or else be sure that
+ * they have exclusive access to the inode structure.
+ */
+static inline int vfs_ioc_fssetxattr_flush_data(struct inode *inode,
+						struct fsxattr *fa)
+{
+	int ret;
+
+	if (!vfs_ioc_fssetxattr_need_flush(inode, fa))
+		return 0;
+
+	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
+	ret = inode_flush_data(inode);
+	if (ret)
+		inode_set_flags(inode, 0, S_IMMUTABLE);
+	return ret;
+}
 
 #endif /* _LINUX_FS_H */

