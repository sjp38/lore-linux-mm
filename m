Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCAF1C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CC6C208CB
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="InU5VQwU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CC6C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 248428E0008; Fri, 28 Jun 2019 14:35:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D2D48E0002; Fri, 28 Jun 2019 14:35:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 074FD8E0008; Fri, 28 Jun 2019 14:35:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f208.google.com (mail-yb1-f208.google.com [209.85.219.208])
	by kanga.kvack.org (Postfix) with ESMTP id D63988E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:26 -0400 (EDT)
Received: by mail-yb1-f208.google.com with SMTP id n70so801792ybf.8
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
        b=Al7tzfo1hRbf5+QUJ6KhmYICofzPsjqg8SZQUVj9UwX+OhWaw3PZ3wlmXuja0pHiyb
         rWUk/xUP+Osw4Pxm9Wfay7TgZdTp2aq6sNQ8Rm+1ZI5qhvTfJy5w+Dp2ISElKwZCcIGb
         p5zXuL38XNFlnr9aScXi4JnEM88HBUq0dvA+eO77qCS/n9Zc1NWGJ28bAUvFMA7Md2Fk
         WMgA5oiU/qp/Dc+KCaefNrIQkezXoc8VT0Mtde10Gj4EVAlAJSPu7tVNJadEwyHJQ3JV
         409vXp2fTqo4Dw7M8kNMDux18NtZCdOwC/YXjhQuNFnKnJG4w83WpPQDmlNl8McpatMI
         u76Q==
X-Gm-Message-State: APjAAAXrtH+K/sMLPK5b8/0OadMI9IS30yr1rOjkzbW8mdwo4odjy4Ix
	5L+ZSa5hR8RcvxDPj/HUEpvmuTeYB/RZ4TLfisIeY2xekNn8Mrt0CLR2xBjk4W+bdhkL4FlMBWM
	OhokXxzNYLX98+REFryykl4XcEAbw92KEIc70DL8rvOf6MzuPASB+/cgHicgex7ke5A==
X-Received: by 2002:a25:2e0e:: with SMTP id u14mr7844030ybu.337.1561746926662;
        Fri, 28 Jun 2019 11:35:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMOMtN2qFBqLhNskYw7LlqubJtHQ8KXIWcpWsaAeK9/jszsSD4Z2FcZximGvOK3eSj25Q+
X-Received: by 2002:a25:2e0e:: with SMTP id u14mr7843998ybu.337.1561746926126;
        Fri, 28 Jun 2019 11:35:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746926; cv=none;
        d=google.com; s=arc-20160816;
        b=tB60uQFmoBgj94KVnU0+JBd3I45m8Ru+2H/wwY0ZBevNu/bpAW+SOMwJ8AVBn2R9/N
         9sps6DgOSGzGB4JMFNBCuogqT/47LrCAoYcuhym1HeQonlhlZPQAMj7bjVgbqiKyCoB2
         /zLwTO8GJcmVl+sfltmmolSsKdAHVdag6wsrZ8WKjFG4sztYG4jmS/8uNr+FuY3VN780
         pj26im0BtIZf7YFcF/7obv2tKLdGtYbABqiBJgU44msHzWTS3PZ5T89sNXhLdT3UmnSg
         YSMgc264gxF7znJx/Ngsp5in7Pl6TuYaTre0bgZN033SccCAxfskr3822qTSiOEIXlED
         m2SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
        b=IVAs9rU5tCtrSU1zF0WJ2YM9pgNg+IChHMOZcQklsEVr2woP77jLmQ+w1+JrkIecPo
         Et20CT0pVYNrnYGZMSAGs9Tmn+ME92tHP2wf+zCBjJJB4BKTyDPDZ6YcPzKlP+FL9Key
         C6V1te6AM5d0Z9v8zzw7EeaMTdxIauQ5I0LYbpxZHHbo0j7wQXXct0lxzcPuwK4IBv0X
         lwzaIs75vpnypAVk2n3hh3Zgj+/2uRchNzOS3dt3cJJyxTa4ytd3MAhcaohTNINLvh43
         kmpp7pXn8q8CNNqAdkY8torTa5i237Pk2t8cC1GFxMKhj3PfsXgGhQFUPiwZc0td33mN
         MbPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=InU5VQwU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id j190si1139189ywj.167.2019.06.28.11.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=InU5VQwU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYg95028012;
	Fri, 28 Jun 2019 18:35:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
 b=InU5VQwU/9kdWgyHNdeqJamZTFjgL8ed4NsqyIJsp1hQoTRw+cuss3QKw28DrcV+MwR5
 NeB4fDw3S211SaxJkEgWs/ZkYiDTII3xYEWMTlWXM6xHHN1Rt8aCBLQgFhwcOBsGPjd+
 L+wFuDCjf8ij8nvQzq781+D4e/bjHz9pWruNxQdDbokTlTpBPvyyLbHVQSgy1RyPAMiE
 JbrP87fbggSJM8vshLS1qI0MLBNpYz/DX7cBYg9uy+2ZB3lAIlhxzDquuSXcLj6p6BWP
 09uZZfbWmNnvcjsl2cOOUYvGPzOx2719utSM0C6FKO5h1+pepugx0bbxDLfeyC7E5WIe qg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2t9c9q72t0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:13 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIXc0S078839;
	Fri, 28 Jun 2019 18:35:12 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t9acdyegn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 28 Jun 2019 18:35:12 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5SIZCBn081341;
	Fri, 28 Jun 2019 18:35:12 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t9acdyegg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:12 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5SIZA31029198;
	Fri, 28 Jun 2019 18:35:10 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:35:10 -0700
Subject: [PATCH 4/4] vfs: don't allow most setxattr to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Fri, 28 Jun 2019 11:35:07 -0700
Message-ID: <156174690758.1557469.9258105121276292687.stgit@magnolia>
In-Reply-To: <156174687561.1557469.7505651950825460767.stgit@magnolia>
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=902 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
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
 fs/inode.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)


diff --git a/fs/inode.c b/fs/inode.c
index cf07378e5731..4261c709e50e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2214,6 +2214,14 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
+	/*
+	 * We aren't allowed to change any other flags if the immutable flag is
+	 * already set and is not being unset.
+	 */
+	if ((oldflags & FS_IMMUTABLE_FL) && (flags & FS_IMMUTABLE_FL) &&
+	    oldflags != flags)
+		return -EPERM;
+
 	/*
 	 * Now that we're done checking the new flags, flush all pending IO and
 	 * dirty mappings before setting S_IMMUTABLE on an inode via
@@ -2284,6 +2292,25 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 	    !(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
 		return -EINVAL;
 
+	/*
+	 * We aren't allowed to change any fields if the immutable flag is
+	 * already set and is not being unset.
+	 */
+	if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE)) {
+		if (old_fa->fsx_xflags != fa->fsx_xflags)
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

