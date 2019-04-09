Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A533FC10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:19:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3755020880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:19:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PcJU3m2j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3755020880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D08996B0008; Mon,  8 Apr 2019 23:19:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9C66B000C; Mon,  8 Apr 2019 23:19:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BABB06B0010; Mon,  8 Apr 2019 23:19:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E98C6B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 23:19:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so11578277pgf.22
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 20:19:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mIexr26prDUKCxTAI0NcBS7KOdrcFft7Rki/xwxHOyk=;
        b=jl2MPcRNMkbzG4wNYBEsFG3/UJlvFd8kS3KlHnMsCkd1dMHb92MgMC4qXWskM7WCuP
         68pQgdWLoKqe4B8PO9U0lwLYl9TypDIZ/j+A2OOSU4izOr6k+ErFgJvRIvay0KIqQeZ7
         FNUC2r4xjQp6xtUyGjbGjYL12RjOPs0PzFhYXTw6Alf0ve7TBAqxdjvwqL7SQfFsrGbR
         NnPxQelnmqgrwM4YecLn6QtFaN5GF+LL5o1n/b93qBt8N3lntjzEo/lVp09fz75ffkIf
         li16/JZT3qr725+p9EYhcdNx/6lXW11Ng6RASuz7j3F5pOrxJ3aMaYkMfzls3p8ZfXJo
         WKEQ==
X-Gm-Message-State: APjAAAXh49lgBMd8lJ+Cwi4nj0zruR9NXaNcbMBhtkmN9Znq/Tjgi96k
	MBYKrC3vicXBqsVOdZj8LbAGkf8BJhl96DrLXL9F3HnGYk2GC86wa43sHogh9IPgxj6RVmn4TIJ
	4ORFZn4eWCXXd+JfQFdOJjXpqiNQkPYMGWo/CLVfEocdHwImsu7gqYIB60hhTOA5Yig==
X-Received: by 2002:a63:554b:: with SMTP id f11mr31990609pgm.77.1554779977016;
        Mon, 08 Apr 2019 20:19:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOsp5mjd7kXyLHfarEex9YwbDs8NS5pPx4szgDKyMmyCOxFMBrXy0yMCTKo99yJmp1mYnr
X-Received: by 2002:a63:554b:: with SMTP id f11mr31990561pgm.77.1554779976300;
        Mon, 08 Apr 2019 20:19:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554779976; cv=none;
        d=google.com; s=arc-20160816;
        b=iIBmJoHQCNsJl+LdNX5D74PI6GF20zg/uVD6+0QHRs8/tzVkJIANZUVDh39IiE5B9h
         jWTx5CFMdh+pzCwzBZHHUB3GjlTdxYNp1wnpG5qz94467e+/S1Z6T86JNBOKjt2Q6Ist
         KraIeuXLSNZWih/rlh3SDB+yvdxPdebSYEX7/y7rmpEDSnKAvH3ioDJC2cLDo3Ct/GsL
         e0Z4jAgeKHcntePJDMfI+TxO+kvvuU8AwiJagI7da1TFB1JmDKu78IIfTk8gIBarfDd+
         FudgpdpMt7MvtXV0tisHLeU+4vwB5NwFiYLZk4lDmq9sERQhCQJc/Nmi0Fm7aX+oqOY7
         dn+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mIexr26prDUKCxTAI0NcBS7KOdrcFft7Rki/xwxHOyk=;
        b=Qj3Rqe3zu0QRPvWsZ7tBc5jHPh0LOfF70IUvlYtGRE05qXeu/UFrCwPpvdroEAoxke
         UKgv1pdAAo8woY0f2jFzbI9svPtkEHFEtiLjozXWHNSk9pyfObXjHyEBmgxY9WwStNoM
         ou2cOb9+qJcjLQeVcptLLRRmd0AN9/5bYhiK6ZNJj1fpNovHBsnj+XNzhKQAMucwJw4Q
         R5sZgG6ATZroVJOmXwh0PfpQzCJNul+nJWXSnkPhPEEPuDX7TQ/7ACNPpiVrnmkrs0l8
         6t5ULNtASR9/QfnI7Aa+CZph9ddlVCqaVnVMJiHAkYv3uEdtcjZRR6RQIdGZg5gPFxxG
         wsAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PcJU3m2j;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h73si29558506pfj.220.2019.04.08.20.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 20:19:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PcJU3m2j;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x393J3k7149070;
	Tue, 9 Apr 2019 03:19:34 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=mIexr26prDUKCxTAI0NcBS7KOdrcFft7Rki/xwxHOyk=;
 b=PcJU3m2jkXxT1SoOhu8yxDga6jXv9iveASgfuDZdeeEZD6yrbeYY59jk+hCUMTyyifo2
 4KoDZoRe4xx0tufR1Ni6Rh4RMZr79ND4tBvE6uFdttE0S/S3Evjs7R2RbCios+mF1z4N
 xLuYAiAHDWCM9fBxcskAE3537t0zZa1EL/eSflEX540lUJqxH+kAQc/lMmlWSs+rK/te
 hedhGPyrBaRKAfY7VDSlsBkWcHR9gVBZJLx0vcJypoGqdz0OVtWFVXFy/b5YlG4MABIY
 CTNvFoKhF+xkf71nWmccOtmba4XhJBKomWLNfoNXCvPpReF7jS1kMiYkRVDHpznqNOl/ Iw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rpmrq23mf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:19:34 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x393JXDv139555;
	Tue, 9 Apr 2019 03:19:33 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rpj5aarp5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:19:33 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x393JV4Q010397;
	Tue, 9 Apr 2019 03:19:32 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 08 Apr 2019 20:19:31 -0700
Date: Mon, 8 Apr 2019 20:19:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: david@fromorbit.com, amir73il@gmail.com
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: [PATCH v2 4/4] xfs: don't allow most setxattr to immutable files
Message-ID: <20190409031929.GE5147@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884962.633834.14320700092446721044.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155466884962.633834.14320700092446721044.stgit@magnolia>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904090021
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904090021
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
 fs/xfs/xfs_ioctl.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 5a1b96dad901..67d12027f563 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1023,6 +1023,40 @@ xfs_ioctl_setattr_flush(
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
+	    !(fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
+		return 0;
+
+	if ((ip->i_d.di_flags & ~XFS_DIFLAG_IMMUTABLE) !=
+	    (di_flags & ~XFS_DIFLAG_IMMUTABLE))
+		return -EPERM;
+	if (ip->i_d.di_version >= 3 && ip->i_d.di_flags2 != di_flags2)
+		return -EPERM;
+	if (xfs_get_projid(ip) != fa->fsx_projid)
+		return -EPERM;
+	if (ip->i_d.di_extsize != fa->fsx_extsize >> mp->m_sb.sb_blocklog)
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
@@ -1030,7 +1064,9 @@ xfs_ioctl_setattr_xflags(
 	struct fsxattr		*fa)
 {
 	struct xfs_mount	*mp = ip->i_mount;
+	uint16_t		di_flags;
 	uint64_t		di_flags2;
+	int			error;
 
 	/* Can't change realtime flag if any extents are allocated. */
 	if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
@@ -1061,12 +1097,18 @@ xfs_ioctl_setattr_xflags(
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

