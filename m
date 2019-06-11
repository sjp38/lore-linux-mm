Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F867C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:47:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC6172089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:47:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="a65p1F4G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC6172089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0DC6B026D; Tue, 11 Jun 2019 00:47:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 552AF6B026E; Tue, 11 Jun 2019 00:47:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4410B6B026F; Tue, 11 Jun 2019 00:47:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26B906B026D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:47:00 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id n14so11776338ybm.10
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:47:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=9SKtfVa/Ru/24wF00+1XpgCjgE3DaoVXLTp8OBycX6Q=;
        b=boCJ8w7OsuQ0a+HJPPCc7jumShEvjmQkL2AMLO0QOu+ruSZ4kUWG0vuIzob7F94fwX
         j1PzvAtasdSLUE2Nd4he4959bcIoMaJ4T+fDtvn4kz/xWjLinv6VcDmt4E9ufKcpaJzp
         83/pvHLDmTo+UU7aVEzDVgVxxGYxeDEaw+RJjR9d4dn+OAjyUPj9K5LyvU9RoqfJCVZ3
         hO3lGqwlnMAVRVGA/y4z7aGOwcBszDJqNZfe1ALETaGbcAmuFCZdNrMJ7bN41sp3EBd0
         j8aa7ycw5MsAWL+LLKso3mJKvrQ6+omBWuL/yzjhu+wqlh3AAd68cvOVOgXmYwmbbeZt
         Zp9g==
X-Gm-Message-State: APjAAAWALn1AYSLiBeqUgVMT2J4ogsBsLkrpgKolax0H/bNUSxQE6zQc
	Dg2p+m0YANMKEdI+/vO3FxUMoCbvllFa5PVMe64zO8l13rYupue85dRCWrZEiDj7kjXEmSghId3
	cx5q17QL4v2XptkGojItemNwFNeNi84yW+WzK615QcdKsyvJfWOmRzNhzJ7Qv8RZLhg==
X-Received: by 2002:a0d:ec44:: with SMTP id v65mr39032716ywe.201.1560228419781;
        Mon, 10 Jun 2019 21:46:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDax3MAEu89Df19zoQvQUkWVOikXNXMTbXAauMqjlwsisz3JrbMzT9yioE/GzrhCRN4yNH
X-Received: by 2002:a0d:ec44:: with SMTP id v65mr39032701ywe.201.1560228419146;
        Mon, 10 Jun 2019 21:46:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228419; cv=none;
        d=google.com; s=arc-20160816;
        b=xDbS/VlAmD7ae1cTTpvGXm5+jfK/Sj1zHy/mKW10TPkN4TXAP6nPMm6AQklUdYugCX
         T5vZJBHPUn5+PG4T1zGUWtxMKQIFp/FL1oIOYtcVhuZjD0BtzT35yUNaFN1ElSRyJvqy
         wqXQE4IZPWy/4Ew2jIvXW1gtdCCf5C9v9ktZ9EsOxSLKAKs5i5LI+MBpL1FHu3JRYuy+
         VYqjpOl+C9ibkn2PgfThQQiHiHo6lzusWk+aCFq6M4qvNKYnuB+kOWj8c6AP2riKTk06
         owEsWuG2WPuyyt7H94kpdw62QZmNAYWsXLXtf3F3YlkbNnjK+WFy0nTZyt6MOS8DCHA7
         lNVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=9SKtfVa/Ru/24wF00+1XpgCjgE3DaoVXLTp8OBycX6Q=;
        b=YQtfcQwBsVdwihUdmMhu4AeXrGV5zUKSruVDqVxVYovOX/eAoN0eE8tfIg+wFMNJtt
         jjIyKkq1A40Wv89bfYGvtlnaz1rsp1cAjHtK0R8mTGPPbtffuumWNjnbv+Jzhxw5eyXY
         RJfYmb58YH//QeUEEvIjAqVgMCdGoonWNMGAbaKX2EyE9I+K9BMBP+ACz6CRcsAwICd3
         Lj5PYei4mX3lRamlXxYG4k12LxXT2hWq4c6PiO834UjROU64jaLx7bMxrQ4waZWZXZ95
         Vj5F0uY7aVbZZoKq+VPUb2GMi22nzvk1tMHL3VDi0DJWUkkDeJJrMxMpm0PPO37hnLmf
         7bVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=a65p1F4G;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id l63si2576273ywf.400.2019.06.10.21.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:46:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=a65p1F4G;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4ieXX180356;
	Tue, 11 Jun 2019 04:46:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9SKtfVa/Ru/24wF00+1XpgCjgE3DaoVXLTp8OBycX6Q=;
 b=a65p1F4GNMOD7ZhfQQ0Aee5lYxxpF5bEu3ejKPQ2FI7leIuD3L5Od98XxlBZBiULo+I0
 PiLxwPa4TP11fmkzFx2hTEBttQ70Asjs3pVhj0xnUyuA4TDA1PdZ8+K3B6AKTniIH0Wt
 PmgpOJ8FLa5n7B5QaOsMaglRlEL7Jg9amXjrWd4aSz73BNDqzucGWJCWPu30LR2AHZmZ
 Vp4STkJq+EZPOJb8jfflSMgEzgDqHawNUz8Vj1787pJfdkW2tYHVSsDffdIcIn3YNzqe
 XNFe4G9eEolFtUBijCmtu6ZVbwPdu+R01OhSK+PU52cI/5p/ugsYJGx0SL2G2TuMpOje ZA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2t02hejrh6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:51 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4klpd052677;
	Tue, 11 Jun 2019 04:46:50 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2t1jph7wy0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:50 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4koOo052887;
	Tue, 11 Jun 2019 04:46:50 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2t1jph7wxv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:50 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B4kmA1002826;
	Tue, 11 Jun 2019 04:46:48 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:48 -0700
Subject: [PATCH 4/6] vfs: don't allow most setxattr to immutable files
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
Date: Mon, 10 Jun 2019 21:46:45 -0700
Message-ID: <156022840560.3227213.4776913678782966728.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=893 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
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

However, we don't actually check the immutable flag in the setattr code,
which means that we can update inode flags and project ids and extent
size hints on supposedly immutable files.  Therefore, reject setflags
and fssetxattr calls on an immutable file if the file is immutable and
will remain that way.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/inode.c |   31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)


diff --git a/fs/inode.c b/fs/inode.c
index a3757051fd55..adfb458bf533 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2184,6 +2184,17 @@ int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags)
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
+	/*
+	 * We aren't allowed to change any other flags if the immutable flag is
+	 * already set and is not being unset.
+	 */
+	if ((oldflags & FS_IMMUTABLE_FL) &&
+	    (flags & FS_IMMUTABLE_FL)) {
+		if ((oldflags & ~FS_IMMUTABLE_FL) !=
+		    (flags & ~FS_IMMUTABLE_FL))
+			return -EPERM;
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL(vfs_ioc_setflags_check);
@@ -2226,6 +2237,26 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 	    !S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 		return -EINVAL;
 
+	/*
+	 * We aren't allowed to change any fields if the immutable flag is
+	 * already set and is not being unset.
+	 */
+	if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
+		if ((old_fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE) !=
+		    (fa->fsx_xflags & ~FS_XFLAG_IMMUTABLE))
+			return -EPERM;
+		if (old_fa->fsx_projid != fa->fsx_projid)
+			return -EPERM;
+		if ((fa->fsx_xflags & (FS_XFLAG_EXTSIZE |
+				       FS_XFLAG_EXTSZINHERIT)) &&
+		    old_fa->fsx_extsize != fa->fsx_extsize)
+			return -EPERM;
+		if ((old_fa->fsx_xflags & FS_XFLAG_COWEXTSIZE) &&
+		    old_fa->fsx_cowextsize != fa->fsx_cowextsize)
+			return -EPERM;
+	}
+
 	/* Extent size hints of zero turn off the flags. */
 	if (fa->fsx_extsize == 0)
 		fa->fsx_xflags &= ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);

