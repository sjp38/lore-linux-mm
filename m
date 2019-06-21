Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3911AC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2B13206B6
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LCPK7AWC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2B13206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95D828E0009; Fri, 21 Jun 2019 19:57:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90B298E0001; Fri, 21 Jun 2019 19:57:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AC838E0009; Fri, 21 Jun 2019 19:57:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC0D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t196so9427304qke.0
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
        b=CDfYKQpq3i0ezsem/EYQLz7FXErdd1OpKMrBql+MXS8AFvwWlYZ9U7Nf33WiMdo+TY
         m+En868vDuiIVvm8zAo3vknX6SJ34RNNth0Cr1twks4jSDiZMv5teFKgJf70Bkktyspj
         nh7WHg6bBPAW36QRsIh+eqHsYJRAcZXfNZL2rR+b8fGnd72uwJNMOL3GvZ7os5HxsYi5
         kDT266btpqSB77zMgmRLtULRMFTK9Hh+Le2Dn+kkVAmdZhf9yjp6okR6xLxChdhfff/i
         joAcclZL9IhOzTy6nd7TeLOuH20PDvSn/2eCWhOnS1aahK99HxSPoXD0Upa8Yv1El5Ox
         u0Lg==
X-Gm-Message-State: APjAAAVFvNF6JhELZLKuq2C2R3q19gsmiNcsts+kC+ArA9MldIincvI3
	gYksw6sk4mQyerE6VzeFinSELJglZYvDBk99SIQwUz0yUe4SEIzJcvyKEB+OeycrgeQ09A+nJx5
	0SfPwmnaxLWGfAdrcBkRJThGmVxj83Qe9Ku2HmkgS+eY+PQjN7UyK6kD8/Boi0/ToLg==
X-Received: by 2002:ac8:3078:: with SMTP id g53mr116526699qte.126.1561161472109;
        Fri, 21 Jun 2019 16:57:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3MowAHoFazKtTmViHcdR/KY4zYtjKxvL1TJEj4Lx6nf19xg1WPgUDqvYLE38Lz7f9cG55
X-Received: by 2002:ac8:3078:: with SMTP id g53mr116526678qte.126.1561161471604;
        Fri, 21 Jun 2019 16:57:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161471; cv=none;
        d=google.com; s=arc-20160816;
        b=jp/ztVTVTWkQXlM+mH7gjnrmoswfVCaBFRpHT2VabyR2NptGUMiAXWZncXU2m4XtWH
         cfTA5jmMu93jDPypIsUf7cmvdUcoH+xOOnww25tWj6cMROuBRLvVVHw4/GkEHvcdG8yt
         ApsXPPep9dFA6tRR9vs/3n6dTWFChBIlfYXWPdHOFOiJGqD53MRr911H0fj6hClpNSeV
         +TAnEgYrCHU/rW+h1q5K5tnFDzlAl5CjUHYCmGhZmEOVgVeU2e5dUMcR4yiNrmtz9c8H
         zq5Cnhzc+xGtTvNSK+Fy9QorvIjSbCm2I26Yghx0TXqVsVgCZiO1usBWzsSLKzFtWHl1
         hPGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
        b=BmCD1SxMnic8ne4Jf4acOJY6MdGkad1cq4qlHqqY4ijqogup0+Qw9sc2rLrDXW/VYX
         WTCdWXe/i1dMRd6FEzpCh6jK6kSwdSLj2ZoM5M0mfNrWPyI2j2sc0YBpJS/Cl37b5G+H
         tKUwhnl8xpB49CRXV6fJTAHBJT4zMKsaVagoSTuDYkmYxb+HybYUUZygujvIRgszhAPd
         8K/plrj6fAhamTmLS+ZVPiYsAd9yoGxjVYr6eI1jqiWIj3LKMTNeGUxdoi7cxqdUvyCe
         Uw0RcSntY1MnxIIGj8HcvPM+RrGbOBK6KGXOEWavkdJy1S/AQHKMBWv38ATJo+L0igA0
         TMkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LCPK7AWC;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y57si2990660qvh.13.2019.06.21.16.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LCPK7AWC;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNuMtI060602;
	Fri, 21 Jun 2019 23:57:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=w6B62XWgEySnIWZsve79cF+lTRasJpmyyQueK4g93UE=;
 b=LCPK7AWCsGBI+RqAzXGFgNPkRiXblgkq9WSLzaq9Z5PAnvNp/X/wTP3QFBjyDnp8Bgll
 L3vmL6Xq68Xv+Yf0N1PngmAjU64QyoIR07RPDYMd1ftuds6jFGEtNEZHw9W/Y3ze8Szf
 EU7883mLnIRViAC3o8bFq1u+W+6Zgwly1DzWCMBrnmxPgfRYeEdOB2PYCDEvh2T8mX82
 ma/K8Md7Uepq4zO72Jn1QXSWCa+54A4BmVUS1lIDC0gbWvA6b71iVR01TRGSHLg2vO41
 axO4hlGWZmk4yOHrsvTiApeDqICstAnZjwOptSjUH2isRmYV5KhT+PO+naU0f5eOU+zO hA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t7809rqw6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:44 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNuYZh036128;
	Fri, 21 Jun 2019 23:57:43 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t77yq6ug3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:43 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNvhDq037856;
	Fri, 21 Jun 2019 23:57:43 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t77yq6ufw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:43 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5LNvfqC020811;
	Fri, 21 Jun 2019 23:57:41 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:57:41 -0700
Subject: [PATCH 6/7] xfs: clean up xfs_merge_ioc_xflags
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
Date: Fri, 21 Jun 2019 16:57:38 -0700
Message-ID: <156116145859.1664939.13167913873080632498.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=612 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
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
index 7b19ba2956ad..a67bc9afdd0b 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -829,35 +829,31 @@ xfs_ioc_ag_geometry(
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
@@ -1504,7 +1500,7 @@ xfs_ioc_setxflags(
 		return -EOPNOTSUPP;
 
 	__xfs_ioc_fsgetxattr(ip, false, &fa);
-	fa.fsx_xflags = xfs_merge_ioc_xflags(flags, fa.fsx_xflags);
+	xfs_merge_ioc_xflags(&fa, flags);
 
 	error = mnt_want_write_file(filp);
 	if (error)

