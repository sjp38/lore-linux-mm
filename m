Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13E53C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B688B20823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1kL5ci9A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B688B20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45F896B0007; Thu, 28 Mar 2019 13:50:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E6D76B0008; Thu, 28 Mar 2019 13:50:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 261E46B000A; Thu, 28 Mar 2019 13:50:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D518F6B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:50:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h15so16825158pfj.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=QWFkhrEj/UWEKTtDQrlQN9lEAI12q4qBRSWOWf5aE6A=;
        b=hfuw5nY0JoXbu+QBlF5McmrHoMNj4IVSc5WYtrdna6nIMyjJc1vMr5DKsDdahOxrEF
         V6O9QCiJw2gFPpwbPc7cmxKYh76osWchn0tXvSLV9X4c2Nirz5NbFRs3rJD4ErwGjc9b
         Yviv5y+MY03CT77baF5HKT78TOxy75BKhoHtZhHpYo2aTE8mhJG/8ylhBcWub6DEa0dK
         JpWob6zIstk1QfDFdxDpsClsHfVQW5TOZTBI7NJZjO1m2ktfwya9Q3n7sKXqNtlunX3l
         Vm2P6V/J9WzXB7tzgZtAwB7YrGcnJ7flI5zSNCxxZEVoHdeMdPe7JU/yJPYR4pgpkwQs
         v2Gw==
X-Gm-Message-State: APjAAAXH2h5W5WhsdnlU9BrLPS+v5bRAzDZYIqa9k5t29RPGphXs4q9r
	D/EqqMMblkqRd0+Vu8EFpOPKr+tzjuNDesFTCP0KAe8vvmHKCZqWYBnFR+LXfv+HZ5XBQzaSBtd
	d2v9ZKYjgwFtsXm4xVEvpO2pe+X0n3Q6OI1P/8M/Dc5dBL6ZAKB6Kxn9YTfuzz+SKhg==
X-Received: by 2002:a63:c64a:: with SMTP id x10mr11619503pgg.12.1553795452463;
        Thu, 28 Mar 2019 10:50:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzSrWMF+7wNhcGdaEvOIB9vaevEWf15WvyXcFAsPVC80IsOZIkoqA/edK7/qLb+YW8ROtS
X-Received: by 2002:a63:c64a:: with SMTP id x10mr11619456pgg.12.1553795451747;
        Thu, 28 Mar 2019 10:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553795451; cv=none;
        d=google.com; s=arc-20160816;
        b=dzdcCNVqMbYKNFqgo9yH25yJsWBf76Jx94nCryVAfUuVooDXMMn2YqJ9Gv7XcgPAuO
         LSuxNT5nVz9mCn7AmVMPCdE0Qi5MiNHgfk/depjQHCyseKYblHn80X8nGrS72lselGNS
         skmQTGBPWA1LzK0KtCmSB6CbQG2R8GA8Bzy41ekSEfs00ZzuVkJUNCwW5Ph23VbfBGXn
         WNNQzaFeqdFXa7iez0REeizNWd8N59DdAJLnM643tErQT57q6ahbKanbKyrRAMv9dm1K
         Q87BtfmiixsMG1rvTBmNTRZxDeLHGZtdtYf/V7SHRgO1yVCxXCI8qMvYkcPk1Mey3uWT
         wW/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=QWFkhrEj/UWEKTtDQrlQN9lEAI12q4qBRSWOWf5aE6A=;
        b=vAI6D06QTaa6mo7V4SDkAfQB26T9sqteN11MACWpHxbKf4kxnLy/zz4XLnmLol7rCD
         EhKZUl2vY9b2XQaLU9EbbMrV3QyxOzysfsODFEwgkcVGcZmpKJxYRC4FFfPA9rGgXlrG
         7mfbQb/cnyyPGd0r82U5UhwNMH1dvybWRyt5H7gBnrcFaXhFBZ/qB8mXG0yUOSTmU4c9
         XP6cc/YvwIiNfsgYCBnJdzj8jMKX9/CmvjHXwox0V1HA9TlYGdsKtPoDKb3+yzUDa+mB
         Kut/Lh/gf5mAKPOliRP0EiIL2qnOFlHJ5k/Ar9O6pt16p6/YgcxdwkojSNRwYPyRoGAA
         xnuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1kL5ci9A;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o188si21816353pga.297.2019.03.28.10.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 10:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1kL5ci9A;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SHnFbH045222;
	Thu, 28 Mar 2019 17:50:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=QWFkhrEj/UWEKTtDQrlQN9lEAI12q4qBRSWOWf5aE6A=;
 b=1kL5ci9A0ShDtplZSlWzGFRsQE+gk47tOhTWQtwBpLPMpXEd6hg00YAALT/cbvgPQpbD
 fnSRohTjoI7RLLX7CKrgTI9aua9FA4uJFerc9hLRPoWwzNvzaQ557M1MvW2SuN0QSHiq
 Vyv6ZN9Q4dbl+qZrZOwxPhv7HhjmXNaz2ZtZoW0G61gU0XjdtrVk5td4aFE4Dm3kpASy
 mt6FbLLqA9hg0d9ntBEfD8WZ6XGz4CW+JpUa8zclDrafj2kiZ4fYgAkdpwPhldW2dOCy
 H40mU8hGB9GJC0afxmCuLPONrqnh5JVL4/mPp3EdEBa2Q/7seZM2RFnjiFvzkC/yCPWr iQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2re6g1g6pg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:50 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHonoC029902
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:49 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHonCl005937;
	Thu, 28 Mar 2019 17:50:49 GMT
Received: from localhost (/10.159.234.216)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 10:50:48 -0700
Subject: [PATCH 2/3] xfs: reset page mappings after setting immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Thu, 28 Mar 2019 10:50:47 -0700
Message-ID: <155379544747.24796.1807309281507099911.stgit@magnolia>
In-Reply-To: <155379543409.24796.5783716624820175068.stgit@magnolia>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=704 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

The chattr manpage has this to say about immutable files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

This means that we need to flush the page cache when setting the
immutable flag so that programs cannot continue to write to writable
mappings.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   63 +++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 43 insertions(+), 20 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 6ecdbb3af7de..2bd1c5ab5008 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -998,6 +998,37 @@ xfs_diflags_to_linux(
 #endif
 }
 
+static int
+xfs_ioctl_setattr_flush(
+	struct xfs_inode	*ip,
+	int			*join_flags)
+{
+	struct inode		*inode = VFS_I(ip);
+	int			error;
+
+	if (S_ISDIR(inode->i_mode))
+		return 0;
+	if ((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
+		return 0;
+
+	/* lock, flush and invalidate mapping in preparation for flag change */
+	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+	error = filemap_write_and_wait(inode->i_mapping);
+	if (error)
+		goto out_unlock;
+	error = invalidate_inode_pages2(inode->i_mapping);
+	if (error)
+		goto out_unlock;
+
+	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
+	return 0;
+
+out_unlock:
+	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+	return error;
+
+}
+
 static int
 xfs_ioctl_setattr_xflags(
 	struct xfs_trans	*tp,
@@ -1067,7 +1098,6 @@ xfs_ioctl_setattr_dax_invalidate(
 {
 	struct inode		*inode = VFS_I(ip);
 	struct super_block	*sb = inode->i_sb;
-	int			error;
 
 	*join_flags = 0;
 
@@ -1092,25 +1122,7 @@ xfs_ioctl_setattr_dax_invalidate(
 	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
 		return 0;
 
-	if (S_ISDIR(inode->i_mode))
-		return 0;
-
-	/* lock, flush and invalidate mapping in preparation for flag change */
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
-
+	return xfs_ioctl_setattr_flush(ip, join_flags);
 }
 
 /*
@@ -1356,6 +1368,17 @@ xfs_ioctl_setattr(
 	if (code)
 		goto error_free_dquots;
 
+	/*
+	 * If we are trying to set immutable then flush everything to disk to
+	 * force all writable memory mappings back through the pagefault
+	 * handler.
+	 */
+	if (!IS_IMMUTABLE(VFS_I(ip)) && (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
+		code = xfs_ioctl_setattr_flush(ip, &join_flags);
+		if (code)
+			goto error_free_dquots;
+	}
+
 	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
 	if (IS_ERR(tp)) {
 		code = PTR_ERR(tp);

