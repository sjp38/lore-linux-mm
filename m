Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D399DC282DD
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8047D20880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CRe/lqFK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8047D20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 162A96B0008; Sun,  7 Apr 2019 16:27:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 111146B000A; Sun,  7 Apr 2019 16:27:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F41876B000C; Sun,  7 Apr 2019 16:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCE136B0008
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 16:27:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so8879512pff.1
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 13:27:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dhZCzWJyJFoBJ75COkiuAKNuKnOrPDc1hKAQlxLkLTw=;
        b=oMSNizE4SoidUp3LRamgEhCDz05lcOSdiQVQW5iiHRUWd3Jr0A2vm3lyaaIomkTipB
         O61fKDqBIneWeyu5vIG+2KXtsbd3EneYVZCBD2To482+myCpRundLLU2fXPjVRapGGwm
         NdsMCOx28/uaadXd0upC2W7dVIizRAoqWBNXw89BooM0+bR5uB6cr0sdiBhwcXEN9org
         LRpnRRGxR2JdIrQKV1QzQSs1R9h5HhRu36aQjbk++wl3zzimw1pqxgDQ+jjFjAWglvou
         BMJSJRmYjL6d997RIhXa3IkT0kFh4dXGykT/sEt4Dklst4xYfNDixKsECwf/3Cp6iHvp
         zZpw==
X-Gm-Message-State: APjAAAVxAn3zWioXFmEfwv3HVhpBGFCO3Gtzv1iC3mVHD25mNGJCmkS5
	vq0JNTTDk5JaxSWvEowbzs8T3k+8JJGKiNN53y+4J9jnctXI4v4IUWNQ8DXowbrxO+QCt0Gein4
	miJOsRLPdiynEVeo8RW2mZkKSFjgT0wDLdnNq40Wj3x4B8WVSVB84rNj0WxNqQ7dIzw==
X-Received: by 2002:a63:4241:: with SMTP id p62mr24553605pga.379.1554668852315;
        Sun, 07 Apr 2019 13:27:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn5xD5ZVK4pMevXZQrrWeydqfIjIhblah5a1naTlriVNLe5iocpFsrLjobwALpeRBhBpVL
X-Received: by 2002:a63:4241:: with SMTP id p62mr24553571pga.379.1554668851559;
        Sun, 07 Apr 2019 13:27:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554668851; cv=none;
        d=google.com; s=arc-20160816;
        b=SMP9J793o6jjKC+y92bR+CTP8YwmGhPPTde6HyiNRoSMLncmfkPcWqNMIH83lvfl+5
         9KzcJgSyaVIqV8ACwYhQwy2Q3XDGJYFJ3fVgEMXx6NpGKy259Oy4AxUjKhKpI68eRCvV
         Kkyvldu6wXs3zT/5bPTY12PspjF2ax+CF+GwobDWaPgKgO8SJ8UA6llMfNJwVOuNIgq+
         SUsiimS3ZUYXHRqFiKVPHkXb/lVf926ZsCgZIPhVoSBRRd4zi/fJ6LsHkGy16TjMAEkD
         IJL1ajOlsY8+mUgOQQ/0+WiTS7nJ9MF6JciP4hnNQtwq8tI0WvSCAttoNW3SLxzdCWKi
         nWgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=dhZCzWJyJFoBJ75COkiuAKNuKnOrPDc1hKAQlxLkLTw=;
        b=ZGbYuP3GcwtUPP5WZBBeRqP2uCyFnG52wmmKpSdxWM18IXsMzvb2ygQ6Iz4TKiXGzx
         BfkTUIGw8a/CC8ZAvIBWl/PS8zebjEci5iPcw+/+4xKwTSngnXuiqmKafG3Ouideye1e
         IUcgwXvt8wK8ja8iBEPxVNGAh026fAJmvH5gCiWZg639wMo25T7z1WyFsiZ47uHXC9Ut
         08HTP2vJ7NHaucuT+vBPkKC3UVvFzxNZ1obNFdngfUjnCngRE/cAxTDoqX65Rc0k9DXe
         SlsHmlTVwikg9+fAbJ1BTLEkXzElPtHIcPTsevtE47ITMlVsz0gmPEtme7TAAfUVPW33
         89mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="CRe/lqFK";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t2si23797406pgp.444.2019.04.07.13.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 13:27:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="CRe/lqFK";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KKx2b063305;
	Sun, 7 Apr 2019 20:27:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=dhZCzWJyJFoBJ75COkiuAKNuKnOrPDc1hKAQlxLkLTw=;
 b=CRe/lqFKWCFJxRbNttxCQ7SgecorAo+xzZO4nrDxSoo57SsBzEOA9wJUTk2F/AQGBe5s
 JAng93IH3nOYiG5MGf5Cxd6svj1EormZb5HPvrDMfTvMnxU4XilaeGJRU6Mbt5C0Vf2l
 RAA91h8Dk/rhw5jXOIU4P6oTvAvYot+PWuaCGHjRxLpDLcTy1XMzZFgx4EMzEtjfkIED
 WHUprTx6Ib5AoO5lzg3SyMJyPlUDb6CJb1+EE0co82tH6donqaKKWHGiO1ISV0wRnizQ
 jjvmSwm9RZfxqF8KHAzR/Wsc3W+4OaidB9o/oCfxwEbWxadBowI17mBce1p8mXBX9Arc KA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rpkhsk6be-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:30 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KR2p3165960;
	Sun, 7 Apr 2019 20:27:30 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2rph7rqdh8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:30 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x37KRT4A031880;
	Sun, 7 Apr 2019 20:27:29 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 13:27:29 -0700
Subject: [PATCH 3/4] xfs: flush page mappings as part of setting immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Sun, 07 Apr 2019 13:27:23 -0700
Message-ID: <155466884294.633834.1486289166159962611.stgit@magnolia>
In-Reply-To: <155466882175.633834.15261194784129614735.stgit@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904070193
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904070193
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
immutable flag so that all mappings will become read-only again and
therefore programs cannot continue to write to writable mappings.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   51 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 44 insertions(+), 7 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 91938c4f3c67..5a1b96dad901 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -998,6 +998,31 @@ xfs_diflags_to_linux(
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
+	struct inode		*inode = VFS_I(ip);
+
+	/* Already locked the inode from IO?  Assume we're done. */
+	if (((*join_flags) & (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL)) ==
+			     (XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL))
+		return 0;
+
+	/* Lock and flush all mappings and IO in preparation for flag change */
+	*join_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
+	xfs_ilock(ip, *join_flags);
+	inode_dio_wait(inode);
+	return filemap_write_and_wait(inode->i_mapping);
+}
+
 static int
 xfs_ioctl_setattr_xflags(
 	struct xfs_trans	*tp,
@@ -1092,25 +1117,22 @@ xfs_ioctl_setattr_dax_invalidate(
 	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
 		return 0;
 
-	if (S_ISDIR(inode->i_mode))
+	if (!S_ISREG(inode->i_mode))
 		return 0;
 
 	/* lock, flush and invalidate mapping in preparation for flag change */
-	xfs_ilock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
-	error = filemap_write_and_wait(inode->i_mapping);
+	error = xfs_ioctl_setattr_flush(ip, join_flags);
 	if (error)
 		goto out_unlock;
 	error = invalidate_inode_pages2(inode->i_mapping);
 	if (error)
 		goto out_unlock;
-
-	*join_flags = XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL;
 	return 0;
 
 out_unlock:
-	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL | XFS_IOLOCK_EXCL);
+	xfs_iunlock(ip, *join_flags);
+	*join_flags = 0;
 	return error;
-
 }
 
 /*
@@ -1356,6 +1378,21 @@ xfs_ioctl_setattr(
 	if (code)
 		goto error_free_dquots;
 
+	/*
+	 * If we are trying to set immutable on a file then flush everything to
+	 * disk to force all writable memory mappings back through the
+	 * pagefault handler.
+	 */
+	if (S_ISREG(VFS_I(ip)->i_mode) && !IS_IMMUTABLE(VFS_I(ip)) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
+		code = xfs_ioctl_setattr_flush(ip, &join_flags);
+		if (code) {
+			xfs_iunlock(ip, join_flags);
+			join_flags = 0;
+			goto error_free_dquots;
+		}
+	}
+
 	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
 	if (IS_ERR(tp)) {
 		code = PTR_ERR(tp);

