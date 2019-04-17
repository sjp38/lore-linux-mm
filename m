Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7D3EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96FB92073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="G4xFxM7r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96FB92073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EFDE6B0274; Wed, 17 Apr 2019 15:05:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29DA66B0276; Wed, 17 Apr 2019 15:05:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13FBB6B0277; Wed, 17 Apr 2019 15:05:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C67676B0274
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:05:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a8so2231947pgq.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:05:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JSVLcxpxPXWyi1ygugKI5o1GQ+joQEvPfhYsIY2BSu4=;
        b=nVf3LF9Xq42Z4K9bzacul7TQQ/92oxxteqK3yyL5lmsn9wb3ajyJxbkQ2Q7s89+VQG
         jDc1aosmCAVWRkiRyqs/KDkT8suxAkiKwiI6XIqpn9qIzyNmOh1Q/SuVlkGKZUfGgvzu
         5eNMHIlC6xkiuPCAh+j/ol+2h+am+K4p/0z5pYDCvF5ICtx+PuNUJ6ccyC7LjTOqCGfL
         +WVN/OdjEqS4ANaYrpHbfrHHN877me/qOsj+Eu9J4/NX7vGS/PrcS4LAftw+hRkUyV5i
         i+4rq2XlZKseSotL9uHNfopoRXUj5rjTSBiz3SnYUrboN67ni53VXxmFh0Mc/t3K1a0e
         IFgA==
X-Gm-Message-State: APjAAAWDxdvdS/a/AWCb2u9YJsI7ebeGOfpYQGmSyE5i11mmpw0niQI5
	LmjjHfTsYyGvNMpWVA53jxK6tww4Kbepv07g+IoRWSdZ5vvIB8B26dAxcxT5jK4ET1Ntj4GQUI7
	+Hl7JrTVcDqSfg4rkRjpHcgzsc8AWrRWH1XZBbAfUTxRIBO/JNePlNIcAnA3zj1u7gg==
X-Received: by 2002:a62:6e05:: with SMTP id j5mr88492279pfc.5.1555527905485;
        Wed, 17 Apr 2019 12:05:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2RuylXnbAeAceQM4lBLA/mHVGqQphUo/oVSzkI42QABxcB7bMitvaKfLfYLH8BgP8SqQK
X-Received: by 2002:a62:6e05:: with SMTP id j5mr88492211pfc.5.1555527904729;
        Wed, 17 Apr 2019 12:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527904; cv=none;
        d=google.com; s=arc-20160816;
        b=JfuQOnmwGNEw02X/p7qI8y+WRIe5D4/byLRCCwkiUmgh3M61Ih6E/zIJ46IGyI5OQz
         zlZEzZCi1UO1aZP8Ys9mOrWNaHbKJNgGDX3n74dKMfLibjmWqzudXgQcAbMrQLZEAd81
         pNdQaQsXOzb7qhrhppXUNKkngt+wQicByMkX2XVOP9zSwNYmYYoQmqgSsQK1fYdmjXz5
         IAQNFCJvhBfz3zjzUOiF0aEvbUKt1hCQS1n1HVrt8BFXnmDyfKOzhRz7wLO4cfrKbN+r
         3A0/uQPxYCHnguH+MTBVbe6fU+DsLSZS/SUgHPyfq6/r95ESBd+5onBPThmZn4o3eS1J
         Ujxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=JSVLcxpxPXWyi1ygugKI5o1GQ+joQEvPfhYsIY2BSu4=;
        b=HC5OuZeuZPQz5vmhepxux/wAAAZeZOLWC9uyRoCvLEasvWRD1LG1zkWnDyh5Ucf3Yc
         moJp6+6iUU9GnTwY/i9k6cMsTPpAdzCiSDKkm/sggMgDV7o4cKYPgjXMaSvTFQAaE0fA
         KuSoiMzBQRBcPmX2EDN9CGLmoLigAUJ0RJfFjsz+mrZJWmoRb8eJ0DnimBQFZkm8+bkG
         RlbPNRtKhLlYlgNMI13YrCT9ToBnLSY5De6WM1lMFU0LADsVqK+9diRAcBpD44hXdQQT
         dR7u5BUbfuwU0Cy3Eu51k6X0KCg98mImxhGCAcxWiAig/JtPFTAbNBpGKBGFAK1y9/LV
         Liog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G4xFxM7r;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e7si52769270pfc.152.2019.04.17.12.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G4xFxM7r;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwq4I168713;
	Wed, 17 Apr 2019 19:05:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=JSVLcxpxPXWyi1ygugKI5o1GQ+joQEvPfhYsIY2BSu4=;
 b=G4xFxM7r71qqe78JbXTHW4ZzrVHhjMKMrwmTw64/396HpK7/hjT+IN329tkrqq0ZG01n
 0sHwQQLYcgN4oJh9DAwYa8qzXEqfVB5W5sMq1m5Xm3q1ZXsgUinS6OTXh/WJsB3urPDQ
 7Mqx7wC94gFmj81duR6niXSi+/EzkJOaASuyzdt58KHP1LplnPoh1njZTG2Q8PqITwv4
 orQbMhXqxmJc6cmBid11/5DloPP8GP3WIhdjz+xV6WFRaO3tiZajXN43XX4JbyGqSU8y
 94QJh60JyIgqlK5lscTJx/LPUVDBq/tUmbDezNLwKF5M1kg04f/9L5GOeGkms0xZ5DmS bg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2rvwk3w0c2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:03 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ48D5159042;
	Wed, 17 Apr 2019 19:05:02 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rwe7ak1nu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:02 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3HJ51of009324;
	Wed, 17 Apr 2019 19:05:01 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:05:01 -0700
Subject: [PATCH 5/8] xfs: clean up xfs_merge_ioc_xflags
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:05:00 -0700
Message-ID: <155552790055.20411.3134851745045483842.stgit@magnolia>
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=590
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=619 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

Clean up the calling convention since we're editing the fsxattr struct
anyway.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index fdabf47532ed..5862b7cead4c 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -832,35 +832,31 @@ xfs_ioc_ag_geometry(
  * Linux extended inode flags interface.
  */
 
-STATIC unsigned int
+static inline void
 xfs_merge_ioc_xflags(
-	unsigned int	flags,
-	unsigned int	start)
+	struct fsxattr	*fa,
+	unsigned int	flags)
 {
-	unsigned int	xflags = start;
-
 	if (flags & FS_IMMUTABLE_FL)
-		xflags |= FS_XFLAG_IMMUTABLE;
+		fa->fsx_xflags |= FS_XFLAG_IMMUTABLE;
 	else
-		xflags &= ~FS_XFLAG_IMMUTABLE;
+		fa->fsx_xflags &= ~FS_XFLAG_IMMUTABLE;
 	if (flags & FS_APPEND_FL)
-		xflags |= FS_XFLAG_APPEND;
+		fa->fsx_xflags |= FS_XFLAG_APPEND;
 	else
-		xflags &= ~FS_XFLAG_APPEND;
+		fa->fsx_xflags &= ~FS_XFLAG_APPEND;
 	if (flags & FS_SYNC_FL)
-		xflags |= FS_XFLAG_SYNC;
+		fa->fsx_xflags |= FS_XFLAG_SYNC;
 	else
-		xflags &= ~FS_XFLAG_SYNC;
+		fa->fsx_xflags &= ~FS_XFLAG_SYNC;
 	if (flags & FS_NOATIME_FL)
-		xflags |= FS_XFLAG_NOATIME;
+		fa->fsx_xflags |= FS_XFLAG_NOATIME;
 	else
-		xflags &= ~FS_XFLAG_NOATIME;
+		fa->fsx_xflags &= ~FS_XFLAG_NOATIME;
 	if (flags & FS_NODUMP_FL)
-		xflags |= FS_XFLAG_NODUMP;
+		fa->fsx_xflags |= FS_XFLAG_NODUMP;
 	else
-		xflags &= ~FS_XFLAG_NODUMP;
-
-	return xflags;
+		fa->fsx_xflags &= ~FS_XFLAG_NODUMP;
 }
 
 STATIC unsigned int
@@ -1549,7 +1545,7 @@ xfs_ioc_setxflags(
 		return -EOPNOTSUPP;
 
 	xfs_inode_getfsxattr(ip, false, &fa);
-	fa.fsx_xflags = xfs_merge_ioc_xflags(flags, fa.fsx_xflags);
+	xfs_merge_ioc_xflags(&fa, flags);
 
 	error = mnt_want_write_file(filp);
 	if (error)

