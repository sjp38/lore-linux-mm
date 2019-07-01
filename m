Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 637E9C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13E0220B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 15:44:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="x/SdHBcY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13E0220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F6BD6B0003; Mon,  1 Jul 2019 11:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A87E8E0003; Mon,  1 Jul 2019 11:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86EDF8E0002; Mon,  1 Jul 2019 11:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f206.google.com (mail-yb1-f206.google.com [209.85.219.206])
	by kanga.kvack.org (Postfix) with ESMTP id 68BC36B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 11:44:35 -0400 (EDT)
Received: by mail-yb1-f206.google.com with SMTP id z4so249199ybo.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 08:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pYgOiYG9niz5w5j2Xs2uAj2RGhsP9dEqiFiqy+v2SHk=;
        b=dF+sD9NpMdTXPwTzsIC5VGiMsRnAjp8QS4OqvZLFMK2TyqddpjX5oJhveFCJDytoDX
         aK8WUs+DY+XWc2BsrrKyCD+L5HcoN00UpGeG+Q/fLmxlc+njHzERaobIRVwTwafNBSyM
         r8hQi/V0G8k6bN6yvgib+tk8VyIEEr5EpM4N3hQuH+D6YLYRM6j1fpExnajnD1aZt2nd
         AhVaaRntGZlw+Jg+VR1UE4B7U6l7+vwsxfrcq4cb/E7a3n9H0rpqk8kJRUHwdTMErPlz
         9A5ND75nmD8FwgEStqceqaLJyeV2EQB8g/ewNY/mFfUozJvMex1jHAZQEk12Y//K466U
         d5fg==
X-Gm-Message-State: APjAAAVqf4YF9JoqEUy6PwrvIFj881ubXv+pEepngwxhXMyKBGd8Vdap
	kywVYMTy3YY+gUy8v5XBWKnA3sBM8LbI597jGxahnFfXUVweWdXLrPn84t0hPE9A52faywFkVKT
	WKDSI3HPr38qoP0zHeMd3Ul6UmJ12a+DFH4s+go2fpYNYI5SCzWlDBZgtNfXXFhxyMg==
X-Received: by 2002:a81:a801:: with SMTP id f1mr14879008ywh.26.1561995875117;
        Mon, 01 Jul 2019 08:44:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfLlrmW27uj02CqbKCIvJvy0bk1Ip+JLRvbSNNdafjbrTp1PDAr+wsMON87uwMU1KkEz67
X-Received: by 2002:a81:a801:: with SMTP id f1mr14878966ywh.26.1561995874230;
        Mon, 01 Jul 2019 08:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561995874; cv=none;
        d=google.com; s=arc-20160816;
        b=B4iM8XD9XhwxD8ZNoB8hq6DufGChwW3J1VmeGMcFMGmRmzriteS6VJAU4GNWtnZ9ZM
         8DLU15180ikyC8lqnC5rB6TwQeBZw+qLgyxyH+tDYXt4nYlIkAmpu7QzExFLid2Vp/ym
         1r7WJOI3g7xip295GnyUdhvqxiimakkhagsuYc1tgDLegYKHIUTU6Z3S6K22irJLj/tU
         iNSiSEAeMJNMdjjATx2G5FKvvWqMvw8M1EwLvWgUPN3w6WHLxAJcXKYVbBGmQksDhbod
         TUb2B9P1wyKQLAhkDzG3mjPIemSnIYtDAV5EcYh9BtUsC0v6LDCqU7ldhPRwq9Geoh8E
         /u6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pYgOiYG9niz5w5j2Xs2uAj2RGhsP9dEqiFiqy+v2SHk=;
        b=pUsNfJZ77R6AbB5ctK3mEuZDhQcD/9icLw20PDOugidTRQyyVL1gmgTv505wsY1Wzj
         0dlIqSEvZ4CZnIQUnTqk6kdQ5NXa2ALYyLjPHJIIe2KM8RYjPmH7bOdzo9+rRp3Xre7k
         B45UJlzGWb7R/er+8dv4OiNDQtBbsMjIx6XDM+P5+3bxXY2E3MwbCrEjkInXALg197nw
         SoVFYAu12+7iQl4cfTN+DqmC+pMmhGS5WjPqe2e2xTniZRavLuRM2BB/Jr/xDbYCevjH
         7nP/mCBs2Tqd8BuwY7KX3ZC8tLAURPQ4JP7GFK/R0L2knQUsU/MxckFSd5oh1I+qdBW3
         tlEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="x/SdHBcY";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h193si4613087ywa.364.2019.07.01.08.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 08:44:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="x/SdHBcY";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x61Fd1eX135390;
	Mon, 1 Jul 2019 15:44:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=pYgOiYG9niz5w5j2Xs2uAj2RGhsP9dEqiFiqy+v2SHk=;
 b=x/SdHBcYO8s8zWcphUBtW0vaxMhmfi55Tc3O1uqVw5wFQoSV0TdcaQrd5DCa4/j3leVl
 afbReE/QG5U9d5RMDtBeMdXqUXH0ZjmvMBZR4Bqmxg/kAljEVFLfyeY/NtPkYHmHYr9X
 LYGxft84ZgeBGOpFpDLQVRFORBGkrIKz998fNMkSDSFhU9OkEimNW4ZMMNbmgLHWe6Wa
 H32awHJIcTvxMIApJV/pr3XFucA4iWiPO5eUtLjVkO8Vi1P6W9rEo/9vB6C/HmqfVy1z
 wSoSDGjT9hh0PbsVNlgPWgfY33Zl0N02nGKztDfgCPOv1W9YyXHHcQeRRazJE5zmpoPz vg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2te61ppf40-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 01 Jul 2019 15:44:09 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x61FcFES032310;
	Mon, 1 Jul 2019 15:42:09 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2tebbj8db7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 01 Jul 2019 15:42:09 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x61Fg9hp040678;
	Mon, 1 Jul 2019 15:42:09 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tebbj8dap-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 01 Jul 2019 15:42:09 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x61Fg3SU026276;
	Mon, 1 Jul 2019 15:42:04 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 01 Jul 2019 08:42:02 -0700
Date: Mon, 1 Jul 2019 08:42:00 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        ard.biesheuvel@linaro.org, josef@toxicpanda.com, hch@infradead.org,
        clm@fb.com, adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk,
        jack@suse.com, dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: [PATCH v2 4/4] vfs: don't allow most setxattr to immutable files
Message-ID: <20190701154200.GK1404256@magnolia>
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
 <156174690758.1557469.9258105121276292687.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156174690758.1557469.9258105121276292687.stgit@magnolia>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9305 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=991 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907010188
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
v2: use memcmp instead of open coding a bunch of checks
---
 fs/inode.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/inode.c b/fs/inode.c
index cf07378e5731..31f694e405fe 100644
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
@@ -2284,6 +2292,15 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 	    !(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
 		return -EINVAL;
 
+	/*
+	 * We aren't allowed to change any fields if the immutable flag is
+	 * already set and is not being unset.
+	 */
+	if ((old_fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
+	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE) &&
+	    memcmp(fa, old_fa, offsetof(struct fsxattr, fsx_pad)))
+		return -EPERM;
+
 	/* Extent size hints of zero turn off the flags. */
 	if (fa->fsx_extsize == 0)
 		fa->fsx_xflags &= ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);

