Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF6FCC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A280321773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pX5N0Qwt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A280321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 168D26B0276; Wed, 17 Apr 2019 15:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1188E6B0278; Wed, 17 Apr 2019 15:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFAFD6B0279; Wed, 17 Apr 2019 15:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B062B6B0276
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:05:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l74so16779984pfb.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8KLtIeEvuadXuqX+Q40mZMyqFOGgRptDXywqCa4tRUE=;
        b=NLkf1ytidaXsTzWIQgpZSg4kHCf5ZT8MI6ycrb8VyfpNTpT0Tgv0Pf2bXP0hTYNzq6
         WsQiftLo/pzx/CPd/cxYXQcOS1yImVDaGktVy+8HjwZoGQl3EpIYGvINHqD7NX/FZdBw
         Xz9YOvvBfsuANAwZb5Yf7NPNnGZ9Iy8N/qPZwX82VRuMLfAW38oCGm0ZCQqfBWQoGD4k
         TH/pkjxrOlb/JSW8nzLrCWUQLliplPid1Z48eMPlP/RREWMJx9+OpFgFVWXZHvEbM/x+
         ic3Rko04jYoglZwIp+vvnQw/9uNm38Pt9Pbsqr/Axqds3I8jE0LsKVo7rat0PLByLyVA
         Jnhg==
X-Gm-Message-State: APjAAAVuPpl1TVaTFJ2J48DmOJE8pIGbq8A6kglviYrJ1wQlOYvvfTDv
	S/VbUqUMysIg61E6DcZMesELOW7aDv1/FE3iZCWkNPZDlfZE8n0JyC2Eayg6eQJY8nuqCjLpYpa
	y8ksZCjL4ev8qiCCIaCBwVSKraRY3pBUkHGC5HkddGjBaOq3LNnDAEu07JYZSh0W+nQ==
X-Received: by 2002:a63:d444:: with SMTP id i4mr86153401pgj.149.1555527911371;
        Wed, 17 Apr 2019 12:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOILbk7WsjoCE1poIlUdxzF3iG23XDZxD0WxKNExWAjDUpUL6PTv1StkcHdf5PSqk9duwL
X-Received: by 2002:a63:d444:: with SMTP id i4mr86153322pgj.149.1555527910446;
        Wed, 17 Apr 2019 12:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527910; cv=none;
        d=google.com; s=arc-20160816;
        b=vkEbwMA9T8vmBDGyw0G+1BNPzVaFSVWxISiVboWKli4sIDuwoIi7lsLRAuteKhVyX7
         OiRf5WUn35LuquaB296RGHmAGIuR3smeVipxPDFOn9KLESA30MoGaX3kFV8HOLNZWZAi
         g0weW3SgFmvqfOtD6pDD+yB18rm+c6BjDEEeh48VvEH+SsVIqiB39lhvVqAV20zEXDXI
         Ml0zsLl2NpUAJFhD64sYVZwT1gI9wYXpYi1yq0gKoBonXRraETkI9OrnIDpGiVpvRRg9
         UZr2K1nGY5Bgpt72bmgwkocD7RzcifN9COJjGTopN+qdhFgraXQs4ACxtATdVYYPURYZ
         m8jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=8KLtIeEvuadXuqX+Q40mZMyqFOGgRptDXywqCa4tRUE=;
        b=dVQtdbEDt6+n8M9Kz+/QVeeZoP97E0hfyvcPsC3bf88HKXyBpE/Wt77faF6Pac4qUP
         hmFCYUsxA/IBlIWSlXcKzq1E4y+Z/JRVL2gUum8SEnQWsmbJlS3IGJjoTpw2yhxNTRSF
         rmImHThVSguOMn1ZrRYAtZ49PuME24mLxh/ZgwdEidOIqxehgW97Aeub+PBUh2dyl+5o
         /7WFK7X2sq9yFXnufJ0Xcbj+3mmNhg/0f6b+rFPqhelbp7fglSj9F/eTz8UMgG1Uds1n
         sasT9A+tSbOfqKY3NGRQeqlYXhDjTE4BKZfIKCDkhzpOKu+7K4ybU5u8hu/aUi47zzFc
         NL0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pX5N0Qwt;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g11si41166178plp.278.2019.04.17.12.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pX5N0Qwt;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwfsa168645;
	Wed, 17 Apr 2019 19:05:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=8KLtIeEvuadXuqX+Q40mZMyqFOGgRptDXywqCa4tRUE=;
 b=pX5N0QwtrdKOdjejCm37pjx5aLZjkbVvvxFG51hoEsQrP/WBeozMU3nD+XgTrtEQCmoT
 OhD/Usm1zdetVkV/DFRhHHESWgtc3EV5Y+1ziSUQE0EzO7vGQ5CQ+7isOmg8IvkzL0CR
 aw9uiehD8X+kPo+ka6ADnfudtOtNDR+aoDwRIb9gmHgLnyOqU7JIf3YB8eBfLonZjPBO
 kQGBFTBGTtFIMdoHKVSRxjXBjZbtLEoe1MfdY3+ekHmvdBNt2FeULxsXQFL3FW3Ypo0c
 mbxoEIcrF3tlPGjoeH7IzGTeJWRavuyjeeLUu0MN05Vze8AiOB1goDRds1DtI722l02V 6w== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2rvwk3w0ck-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:09 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ49Xt159119;
	Wed, 17 Apr 2019 19:05:08 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rwe7ak1rc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:08 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3HJ57AX008626;
	Wed, 17 Apr 2019 19:05:07 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:05:07 -0700
Subject: [PATCH 6/8] xfs: don't allow most setxattr to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:05:07 -0700
Message-ID: <155552790705.20411.14086909835362619590.stgit@magnolia>
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
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
which means that we can update project ids and extent size hints on
supposedly immutable files.  Therefore, reject a setattr call on an
immutable file except for the case where we're trying to unset
IMMUTABLE.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_ioctl.c |   47 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)


diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 5862b7cead4c..b5b50006e807 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1038,6 +1038,41 @@ xfs_ioctl_setattr_flush(
 	return filemap_write_and_wait(inode->i_mapping);
 }
 
+/*
+ * If immutable is set and we are not clearing it, we're not allowed to change
+ * anything else in the inode.  Don't error out if we're only trying to set
+ * immutable on an immutable file.
+ */
+static int
+xfs_ioctl_setattr_immutable(
+	struct xfs_inode	*ip,
+	struct fsxattr		*fa,
+	uint16_t		di_flags,
+	uint64_t		di_flags2)
+{
+	struct xfs_mount	*mp = ip->i_mount;
+
+	if (!(ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) ||
+	    !(di_flags & XFS_DIFLAG_IMMUTABLE))
+		return 0;
+
+	if ((ip->i_d.di_flags & ~XFS_DIFLAG_IMMUTABLE) !=
+	    (di_flags & ~XFS_DIFLAG_IMMUTABLE))
+		return -EPERM;
+	if (ip->i_d.di_version >= 3 && ip->i_d.di_flags2 != di_flags2)
+		return -EPERM;
+	if (xfs_get_projid(ip) != fa->fsx_projid)
+		return -EPERM;
+	if ((di_flags & (XFS_DIFLAG_EXTSIZE | XFS_DIFLAG_EXTSZINHERIT)) &&
+	    ip->i_d.di_extsize != fa->fsx_extsize >> mp->m_sb.sb_blocklog)
+		return -EPERM;
+	if (ip->i_d.di_version >= 3 && (di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
+	    ip->i_d.di_cowextsize != fa->fsx_cowextsize >> mp->m_sb.sb_blocklog)
+		return -EPERM;
+
+	return 0;
+}
+
 static int
 xfs_ioctl_setattr_xflags(
 	struct xfs_trans	*tp,
@@ -1045,7 +1080,9 @@ xfs_ioctl_setattr_xflags(
 	struct fsxattr		*fa)
 {
 	struct xfs_mount	*mp = ip->i_mount;
+	uint16_t		di_flags;
 	uint64_t		di_flags2;
+	int			error;
 
 	/* Can't change realtime flag if any extents are allocated. */
 	if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
@@ -1076,12 +1113,18 @@ xfs_ioctl_setattr_xflags(
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
-	/* diflags2 only valid for v3 inodes. */
+	/* Don't allow changes to an immutable inode. */
+	di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
 	di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
+	error = xfs_ioctl_setattr_immutable(ip, fa, di_flags, di_flags2);
+	if (error)
+		return error;
+
+	/* diflags2 only valid for v3 inodes. */
 	if (di_flags2 && ip->i_d.di_version < 3)
 		return -EINVAL;
 
-	ip->i_d.di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
+	ip->i_d.di_flags = di_flags;
 	ip->i_d.di_flags2 = di_flags2;
 
 	xfs_diflags_to_linux(ip);

