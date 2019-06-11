Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB206C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94EA120820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aajQA90v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94EA120820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441526B026C; Tue, 11 Jun 2019 00:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F29C6B026D; Tue, 11 Jun 2019 00:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E26F6B026E; Tue, 11 Jun 2019 00:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 138C46B026C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:46:52 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r27so9069787iob.14
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=OE6FPPB5Pqi/Vl6YrpWW8Mgm59ZrawiJ1ASuvgj6hZQ=;
        b=RZcEv3fLfTkAWF0a53VvBicjCAAE/JzZ6KF3m3gCsi4KgI8CQPQDiuYsKQlGa/4umQ
         E0S8vrnWTTY0rKtnZy7DAbcj3Yffu9Vtwg9S0XTo8ZGJnw6jjU5+ZaQwNPCnt8LMpPrN
         FPgSGR+ujIW4SDcuUGuPRbM9/Z3+SpnoaptK4XUDb/Pya0K7+ipQevjTqmq5VlxezolV
         g3X8OqW6VvUaTCg25DljzgsK9qaE9L9MDlnR9J3IM5jyUZjhbOIHZra2AQHufvG7Vpjc
         L1dHWwj0JnOYk1v7o0zCk/0VzocvHg5p9YorQ9VCEMNwu+Em5vCKt+QjLdaPeyzkhknZ
         8JCg==
X-Gm-Message-State: APjAAAU6KZWLZYWgnogFr57fCbxu3csCE9mImSxrfEO75MyRJdcLHGps
	CD56KEBgGdKWfdfrSsIfI3OMI2NdOxxrVkcVaP5+cjCQIywyid6Z3Xartq/6CAuslXIrOasxUj3
	gr6eDB7rArTJat48uml/Q9y4+yrmAs5gIoyvqs7Z5UtwuDze02byIjzvsrGpbliqxFw==
X-Received: by 2002:a24:2f93:: with SMTP id j141mr16103598itj.158.1560228411809;
        Mon, 10 Jun 2019 21:46:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy62smU9F5p52zCrjyoNTD0Itp6X0+YstqXyXGOrnClQwRO6aueWpg6KkISijOoRCEx4a6Z
X-Received: by 2002:a24:2f93:: with SMTP id j141mr16103575itj.158.1560228411021;
        Mon, 10 Jun 2019 21:46:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228411; cv=none;
        d=google.com; s=arc-20160816;
        b=Y//88EY8GDJf8P7SsEoyGLnUXDgmuf0J9VtcK+9b2ISzxOO9I0xF1cBgt0kBbICtWu
         DCbmY+vnby96GwO3iaGgAjSe6IZOOonLuy25o9r91bC4xVDrSAefSd3Yt7uNqSiBVzQL
         Rl6oHBQW2JIZFhDNrHD1SFrx+VQ3taDPpUcVslw7jDnaGE6d6wqg0s1W5gYz4eaG89xJ
         A75tRxWZc4A4IxxwpeDlyzu2mUtZW0v8l5bkA85Gg5cHhpCczTx9DmNs7tv8UUMpAF1g
         MQ4CA4ziRcKN1oZxkwmtcA0jBXmfHn3DixELDYHYX2Da4s1xBagrSJyh6YFyAizl5O74
         Zpog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=OE6FPPB5Pqi/Vl6YrpWW8Mgm59ZrawiJ1ASuvgj6hZQ=;
        b=H2/IgZuM56J25ZtybkCCShNfmULti7KPSKSNxn6i1YDx/SkoHLkCSXxbvqyr1jlYJH
         fkxivN1xBebx6gyvGFDRCnwnEm5U3uAvKKZsCRPBMC786kJ3mI8wG+/gpZp+zpBEprmw
         iasW3ck/ApW+X3DsAPafFJAuZc0GLuA2/GJPJapb9Jw03UbpMtXm019H9PnGbT8WDgtg
         HYWCwcmvLmn1wm6+6BJ14EElJiXIJ2Rb7eQUWgO/dg4Gf8Rjlm2u0JhDQWzyw50G5VRC
         JyQ/dbXH1Ej5vlBiluvWWgzP+WCIk3olPRmWMpQX6gMz0r5vmswgN6Ht6wviB6Wone3c
         g/tA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aajQA90v;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e64si972447itg.46.2019.06.10.21.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:46:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aajQA90v;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4hb7L159153;
	Tue, 11 Jun 2019 04:46:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=OE6FPPB5Pqi/Vl6YrpWW8Mgm59ZrawiJ1ASuvgj6hZQ=;
 b=aajQA90vj37ND50UtdyHx5H16e4znrHfLUb+wBHywGqmqqRsIos1xOgFYLz7aYNs00s1
 mkdEqPk+9iThLFFbd7m84IB9UbTbiJsER4EGmYV30XNlH6n40JvOmYi8cKj93Y3wOIWS
 xXXEp1l5r1zAYgrHOMIuw78O9W4vf7dHoDzzlKM07X2NgjrlxKWaQ90Q6ZtGKszaDIiW
 t6S8su+95if8Mv8oeTvn/HimNYzwaiJe7JgUnemVyARWuXBfLDIzU5Dpew2Ysp6JC1dM
 Nh5hEvqL7jgmqANgt7EJvwjiQk/FOzixoiiL9QVfsDpehQuyb5PWlCJr/s6iVqc1Wuda mA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etjkw1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:43 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4ipsN119991;
	Tue, 11 Jun 2019 04:46:43 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t04hy50d3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:43 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4kgVr123729;
	Tue, 11 Jun 2019 04:46:42 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t04hy50d0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:42 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B4keoZ002792;
	Tue, 11 Jun 2019 04:46:40 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:40 -0700
Subject: [PATCH 3/6] vfs: flush and wait for io when setting the immutable
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
Date: Mon, 10 Jun 2019 21:46:33 -0700
Message-ID: <156022839302.3227213.8773888198343223122.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
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
 include/linux/fs.h |   23 +++++++++++++++++++++++
 5 files changed, 65 insertions(+), 6 deletions(-)


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
index 9c899c63957e..dae2b31cd32b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3584,5 +3584,28 @@ static inline int vfs_ioc_setflags_flush_data(struct inode *inode, int flags)
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
+/* Flush file data before changing attributes, if necessary. */
+static inline int vfs_ioc_fssetxattr_flush_data(struct inode *inode,
+						struct fsxattr *fa)
+{
+	if (vfs_ioc_fssetxattr_need_flush(inode, fa))
+		return inode_flush_data(inode);
+	return 0;
+}
 
 #endif /* _LINUX_FS_H */

