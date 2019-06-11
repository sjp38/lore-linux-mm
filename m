Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C247C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DD4A20820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:47:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GE9rwfHp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD4A20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD2976B026F; Tue, 11 Jun 2019 00:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A815D6B0270; Tue, 11 Jun 2019 00:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 949E86B0271; Tue, 11 Jun 2019 00:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7718B6B026F
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:47:06 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id p19so1411584itm.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
        b=ucA7LsKSalpo5pBqrbmo9fnn2omHB+/7zYCtYMnz+ns+wzZOS+YaJjGnJVb7L3Wmfc
         3TXuBt0ZoI/JmHAfPUoekMvQtqcFjEp7xx7LjBusmnqO+2WdGCIUjdKnpXjBycu/hopY
         0cKDTrIP0WPSynfLSFDQHI7K20bZu7y9qqwto0FTWRtBy9UgRADDQEwc6b3txFNRLGiW
         /xnKpyeHpQQoNtv6KzCr6qV2xIGaEw4jO8W0JTmrzXhiXfnJAvH+NUbxBq/cnXytkz4U
         l9X6m+MvZ3yJY4XsZtCh3iCy9BSESkL0QVEnAAeNHm9kJhV2LbOSHyPuL6R4XNnR21wT
         yyjg==
X-Gm-Message-State: APjAAAWnBtC8bYZPknWSgVTgFQstTyfprqtgfOqLQhatdzNS7qj5AxLu
	KK8qNkWhoEtLltF/SvpS4AeVQ8EACXaSLhsqyfwQ1cO70inIM0JoExfYwmSMUp1it7BlRBFKSOm
	RhPpubLkX0n4ueAUkAFXzIUeE94qkTD/gh4exNb/1M1s+JOqfbUti+sF22+HRbO1JKQ==
X-Received: by 2002:a6b:b804:: with SMTP id i4mr31305513iof.119.1560228426179;
        Mon, 10 Jun 2019 21:47:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzmYAI5jJ3HygHLQ6i5js6gBnBOhVuWap1j+8vWf4l4xQv1ACZmn7/nljlyH85i7fubcD9
X-Received: by 2002:a6b:b804:: with SMTP id i4mr31305487iof.119.1560228425285;
        Mon, 10 Jun 2019 21:47:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228425; cv=none;
        d=google.com; s=arc-20160816;
        b=yZ2w/6OLT9S6ZXczRf3/P4YYKxK5tMObXxmpqn8LRC3yAIK/b3nqqb6K++5veb802j
         4ft30IUMws+1ia+obYEnlGX0PZ/J1tniYD2QDePS6ujsu1MAGRvIcNpbg/W/JZn7mSGe
         WXA9RrHlci9Z4McXp89uzCV93Rh4fkztpJ0LJBX4kNWac1ZHeO/IWECwgRRCFoekvOjy
         Ii5v9lMiB3YjYrnpOykItv1sT7x8g86JchTQi4ngS7yMySjn3yb80AQJaMaH4AOAPcub
         q+g68j1uaueLNkTjUhlWc5TJo+PI2k7AodgB6RvhBjoBZKnOnDNHq9qDpOhNWFWvDWEG
         VjxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
        b=rmWtWdEcebw9Ap3sMAqzTIyEjw2CI72SzhesdiQmKwiVZ3MzlPoK/4OSdU3eQNM40g
         6YaD8VzgICuD/m8UFaU6W7ukWvC9ljTWO7PiPK5HP3K1TeWEq+CE1gE5NTu5aZR9ZFr0
         hhOA3WMtC3Oj+hERpQYb9AzoWpec2sok3dRFu3t9R5XpQLvZaQuD+XNVJ2bzMjTu70fj
         KTa/3Xdc07U5URv45t6by5wey67GR+b2xyVWRTSx7nFxPXMM6E8t69kSBZsY33cpX8j+
         KWC72skvtAUNXS1AGPPRzl6L/E/hvPNVwvvXNtryQattVgSliArXGh8ahGAv28s8jPUz
         9R1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GE9rwfHp;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h124si8255216jab.37.2019.06.10.21.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:47:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GE9rwfHp;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4iSvp159663;
	Tue, 11 Jun 2019 04:46:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GoNZ4aRxdLiu9VXKzoYqQXkZ8KvvgodmwFDB7EyF+mY=;
 b=GE9rwfHpB156RhzOW3QIE5Ib1NCYfB6ocjrsr9h85Z64UFXD2joZMNqo9BS8hoswAb0h
 eMAxHh82iy8Lv4rluHpal9wg9+RaKQScBCSecygwBgnvkAUZM5sU43iqnz7VygBHop2T
 TINkuaZH8bLj30vUyrvPfBAT8pE1KIIobZBEHu7eel+2Pquec3TPNQb0ILLZLbp+DKHb
 xtA5NBfYliCuVi3kGxugHBhIpxC8E3jeBWUn/osSIotdpHia9oVvnqfNIHWWMVTnVeIO
 +7ivXGGQbsVKWghtSxPgDA6HW2/f8n+wupQ5UMy8PdvoRMhpBs3EirSgchcpVtLqnphd uw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2t04etjkwq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:58 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4klnb052783;
	Tue, 11 Jun 2019 04:46:58 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2t1jph7x07-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:58 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4kwXe053046;
	Tue, 11 Jun 2019 04:46:58 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2t1jph7wyw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:58 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B4kuxl015492;
	Tue, 11 Jun 2019 04:46:56 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:56 -0700
Subject: [PATCH 5/6] xfs: refactor setflags to use setattr code directly
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
Date: Mon, 10 Jun 2019 21:46:53 -0700
Message-ID: <156022841356.3227213.6932589992914531998.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
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

