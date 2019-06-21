Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 984E8C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5000620821
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3Y+kdV0F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5000620821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00BCD8E0008; Fri, 21 Jun 2019 19:57:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED8578E0001; Fri, 21 Jun 2019 19:57:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D78C98E0008; Fri, 21 Jun 2019 19:57:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5CDA8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:43 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id g7so7387934ybf.10
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
        b=WdT1TyGejTQIElffG1W9LQkBmfB+j7fy7C0HqLPqleYziW+B2avepGmM0RHDa9AzAe
         L26VkeXQtzriFNClzuSG37GzSKFXIt1HuvorO99YaCqv+1gLaRWxkFCVcnKhC/0F9Vyc
         aMMI6a4GB8+CRiRaP5AROq3ReX3r6I5AsKiNNZ1UH8ga1dfLt4pSyjQX+EANSkLNNMae
         AnJyDguklC4G4ns1eGlUYW0xyFtyhPghvJD1GDN/SzHQN6xWo7y0eFBdFzoSHs6a86fo
         eEzikbOCzleOLAIRF0/RM8mb1i6X5eI92PaS4PsySN90iRPpxtSm/eVAjza/Pf2HUYOc
         ZtRA==
X-Gm-Message-State: APjAAAXFfxUPHp1imGtbvpfTrSk10JJXGS4Gzv8CPMXGWC4c+az2Rz+6
	JcP+cOHeRoJ7a24K3VVzED3pZJc4F0QxVqZizP30W3CAbJgIfBKYm7LobnyW3D2Afy+i/+6rOy+
	YTb1OOvHYHOvFWdDpAdoRXTdio/a95qI7FGR+uG8YcM4aDzhuK2tkk7vUAvXJ8C0a2g==
X-Received: by 2002:a81:1d13:: with SMTP id d19mr72313005ywd.490.1561161463506;
        Fri, 21 Jun 2019 16:57:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv1NCR0nIHV/lefrJWpoiARPBToYPfOUjQ03mWknQJUpVoUiKqv3jzgy3Qyl8UK8ttY/Nz
X-Received: by 2002:a81:1d13:: with SMTP id d19mr72312987ywd.490.1561161462858;
        Fri, 21 Jun 2019 16:57:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161462; cv=none;
        d=google.com; s=arc-20160816;
        b=cFu147DOcQebpJ4f2ZLClqk/6m90gYipdixdsKre765u4wlpoC7X60nEbrUruBv3uy
         V+8HKggfqcA7N8+BZgJ9YdPpiujyXlqL2ZkXhlDUFXp363hDAPxyfcKqxNM6xW5vQIG9
         o2iTTpHo1uFrD0MENY4CiZcy7ILyov8nLIJnlUB4cKHJCRXh4kAyA+n6jUwecLN45Snj
         mLZFbX3E1YGHuSOqYmbAkCmbpZOW2fZ3gtlYuKK1H/san4fHxlNYlaDQF+ZFzYDodUzC
         +MjP1zCoSuy0VTBYKe86ZF/epThu2lvivEws3R5o8jCOOQG+h6m1puupTfpoYTg1bW6n
         AwYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
        b=LPSB5KksRpp6eifo7H5D7i+DxWckYcGVlZQ4rzYLxffoYku1LKgHvVHS86jNMANxOK
         FlnHTAYHUJ1Eju30z9UJ0jrUaYynCCP7NXaaBQR22VIgSvbZXHcLvAHXAngAaZ87jGai
         SPfge28XC3pExiqy22527qI3cXjloxhIg7Edd5MaWusc/LDUaUdA+cXDWf8RfKPLNrqZ
         I8tARHH4TPhpb3VTVyL+hvB/e8fEV1YhHqRGlkdDAj314LGIYa3CCVwsulcEuokzPyNZ
         mQ8zUBcSIur0relMTusVELPoouNgedPSmBEqquUAWOFMaD7s+f/AEgXm56BK007upi3O
         cciQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3Y+kdV0F;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u203si1524995ywu.163.2019.06.21.16.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3Y+kdV0F;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNsBti058928;
	Fri, 21 Jun 2019 23:57:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
 b=3Y+kdV0FiS+tW5au38wMNPWuEC6sxrct9Yc3CK79Ps2gZr3sIwaz7QELL0qPbY+1qF0J
 lIgZ3Rgp/6bzk8/RdtUIyrGMt6hJJUyiio72dubmoyXK970/MtSrct7KLItSYck8385+
 gKeU/c7adOZBK3y2sgrIhX1NQ2QUEREBJcpWjYVK3mpxNTKe+RrqHXtk3j2LQpRyu9ev
 J5Mq7oRWE8vTr2OVMFaXnwNKLinN0hH9bh7T21sbTPqWk7ma1VEZDWKSBR6072dcrO+W
 iKut11/kS8KO+ACrX7Sf61/83yFgeGnY7W/5dTFnHodoCvrlli7/kfhPMyPix5QSOhrZ Bw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2t7809rqvg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:35 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNu8OR042309;
	Fri, 21 Jun 2019 23:57:35 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3030.oracle.com with ESMTP id 2t77ypeshd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:35 +0000
Received: from userp3030.oracle.com (userp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNvYK4044889;
	Fri, 21 Jun 2019 23:57:34 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2t77ypesh2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:34 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5LNvXDf031731;
	Fri, 21 Jun 2019 23:57:33 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:57:33 -0700
Subject: [PATCH 5/7] xfs: refactor setflags to use setattr code directly
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
Date: Fri, 21 Jun 2019 16:57:30 -0700
Message-ID: <156116145090.1664939.13744166286109265130.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

Refactor the SETFLAGS implementation to use the SETXATTR code directly
instead of partially constructing a struct fsxattr and calling bits and
pieces of the setxattr code.  This reduces code size and becomes
necessary in the next patch to maintain the behavior of allowing
userspace to set immutable on an immutable file so long as nothing
/else/ about the attributes change.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   40 +++-------------------------------------
 1 file changed, 3 insertions(+), 37 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 88583b3e1e76..7b19ba2956ad 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1491,11 +1491,8 @@ xfs_ioc_setxflags(
 	struct file		*filp,
 	void			__user *arg)
 {
-	struct xfs_trans	*tp;
 	struct fsxattr		fa;
-	struct fsxattr		old_fa;
 	unsigned int		flags;
-	int			join_flags = 0;
 	int			error;
 
 	if (copy_from_user(&flags, arg, sizeof(flags)))
@@ -1506,44 +1503,13 @@ xfs_ioc_setxflags(
 		      FS_SYNC_FL))
 		return -EOPNOTSUPP;
 
-	fa.fsx_xflags = xfs_merge_ioc_xflags(flags, xfs_ip2xflags(ip));
+	__xfs_ioc_fsgetxattr(ip, false, &fa);
+	fa.fsx_xflags = xfs_merge_ioc_xflags(flags, fa.fsx_xflags);
 
 	error = mnt_want_write_file(filp);
 	if (error)
 		return error;
-
-	/*
-	 * Changing DAX config may require inode locking for mapping
-	 * invalidation. These need to be held all the way to transaction commit
-	 * or cancel time, so need to be passed through to
-	 * xfs_ioctl_setattr_get_trans() so it can apply them to the join call
-	 * appropriately.
-	 */
-	error = xfs_ioctl_setattr_dax_invalidate(ip, &fa, &join_flags);
-	if (error)
-		goto out_drop_write;
-
-	tp = xfs_ioctl_setattr_get_trans(ip, join_flags);
-	if (IS_ERR(tp)) {
-		error = PTR_ERR(tp);
-		goto out_drop_write;
-	}
-
-	__xfs_ioc_fsgetxattr(ip, false, &old_fa);
-	error = vfs_ioc_fssetxattr_check(VFS_I(ip), &old_fa, &fa);
-	if (error) {
-		xfs_trans_cancel(tp);
-		goto out_drop_write;
-	}
-
-	error = xfs_ioctl_setattr_xflags(tp, ip, &fa);
-	if (error) {
-		xfs_trans_cancel(tp);
-		goto out_drop_write;
-	}
-
-	error = xfs_trans_commit(tp);
-out_drop_write:
+	error = xfs_ioctl_setattr(ip, &fa);
 	mnt_drop_write_file(filp);
 	return error;
 }

