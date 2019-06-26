Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25CF0C48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0CF62085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Bbgfx+OF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0CF62085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C2A98E0007; Tue, 25 Jun 2019 22:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54BAF8E0002; Tue, 25 Jun 2019 22:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C50A8E0007; Tue, 25 Jun 2019 22:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 159738E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:33:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y205so1800694ywy.19
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
        b=qZ0vLbT1Zt5efqLtRN9JJajEKfoKmHlhjoYs+9f+AlR7tsmT70pHx64P8m8oJPgR0o
         AxKwsDljURpPr+0AMBAt5pcOeQ6BU2Le4/HiZwmsNrGX32553bD6R79YnJ0a1fOaXmPy
         zk5m1tqcrbKbUaaMhAgBRUB8VPn2nJAwj3LSDAE6kcwdW3OlIyB2i2g9Vh6IRkwOyUh6
         KtaUfRjm6cV2rzNKPtpYcU5LcfRvBxKAk2kf9vtK3Ou1j6nOfrFUMkyL8yMdhZtuTrNV
         OsHJDb0jC2+7kVyVxM+wbN9lbdbFUJUdjdvgbZwEIlIlD8U78LJvscmIqur4jlExus8n
         OwCw==
X-Gm-Message-State: APjAAAUfGGnDLsyyyCFGSiMY+vRxibTbxBBSuLuq7/+/2VWTqRgXvsIa
	MyHM0uM+SqWlpLbO9ZEJN5iSTEVCl/lbiHfbQbfE3h7+4qCBFwkt4GfWXpAUY4vhskNmY/3t3oM
	7jHvqQIEcOjub+rp+CjCbcLDM4wfa4zVF5niAlUJTUkjDLp9ggPWxY25bbSjXFIUSaw==
X-Received: by 2002:a0d:d50c:: with SMTP id x12mr1244966ywd.418.1561516423791;
        Tue, 25 Jun 2019 19:33:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynnNmqW3GUl0+i1zeBQwxULJKk9rMcZElk/ndzPIn/JYCWShJfuMq+G0HxP62XrHIVndIO
X-Received: by 2002:a0d:d50c:: with SMTP id x12mr1244953ywd.418.1561516423086;
        Tue, 25 Jun 2019 19:33:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561516423; cv=none;
        d=google.com; s=arc-20160816;
        b=duHC5/fsyS+uk45RCmHor8zJf0YGIesb55UlWwZ3Rt8EEPoTwjTDa4/AUmgQUuo/+A
         8BU+3XiKrRO47jUqGjKCQ+b1bzm7TZeJz4vSZMdTZz7rPdHn8gPSAvRWFjP7cO97dASM
         gmvDx7R8BmXEzn1S2A+M2RhVRcWHcFonHM05FG+UpKUUpCv4RAhdEFRlkg3NqfvC7QbK
         jIe/moV7yKKxAie2+WO6BczUDZW6LxP2B/xwj16I1659SRjq08wWJrj+Pg2lArDmpgv9
         WO+X+W8bI0d4cMnBSxvgjfVuCtD+nzV0SxmQqYcZFGwvyzsEnLTEgA/uI+0Qyc7WPnIn
         fpoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
        b=xupkMWDX+G3PG4xxg1XZ6SlTZjYOh8jxHLsdkySXhqMpSO9vjJ4YMyPi/C1Wc6WVZs
         0PoaHhpr1pxxFVLmpUFEGd5FBhicagGTnDKMSluxcZoh+jCk7G+ph2SyWW1euhglxGaJ
         FKTJQwIRJlVZTxGx3UJdejH+mU4uBwMhz1Nz7WfrDRO45+t1ZK8zYqqaej1fnMd4cuJ2
         5uSs8MXjDncbxHcO+kz7J0ksA9Gv8sbYibkLhP/fTWyh9mjUKpf+nd1dGSi4U+O+y8dO
         x0W4VB07b6AlXRNBnGkWjCS7JQ5T99avAzEjufHm7T9kfxtZaLnUJNaAi9NJNuca73eH
         J39w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Bbgfx+OF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m69si3487059ybm.60.2019.06.25.19.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:33:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Bbgfx+OF;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2T27Q116704;
	Wed, 26 Jun 2019 02:33:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=mV9lFn0ZU5Q9Z/uVcSNUaPT4H36wgugtQJzUEwexaJw=;
 b=Bbgfx+OF55IU8/l75LipHQ6ChFrxwEh3rej4w1HwnTiGr/YF8XpRL2Gr3GPLc5TCwsni
 EZzjsXkEb4i8hu7iHWaB9bnxN6LeEjyXUTH2cFB98jE65Cq+8AUQ4FEmQivvki6SJ5Zf
 Hho8t8iJZl+aAEcupTrda0bvVui6NciXafJvRqe/3bA4axOe/5sbOwAJr8/nXvuuoQKT
 1hFautW0d9ZwytdNz83QDzFzXR0YIzfOmIU7x9qeyprMF5NbacmHfHsaauQ5H6AfjALF
 vLuw1Tum1ogZV7XwEVxCcFUJlujj07A0PYITiCds/n2YGe3Xyx4D/ChX0QzpclqG4mGi 0g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t9brt7mn5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:32 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2XVsr152430;
	Wed, 26 Jun 2019 02:33:32 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t9accehj8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 02:33:32 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5Q2XVTW152431;
	Wed, 26 Jun 2019 02:33:31 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t9accehhg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:31 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5Q2XQor012254;
	Wed, 26 Jun 2019 02:33:26 GMT
Received: from localhost (/10.159.230.235)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 25 Jun 2019 19:33:26 -0700
Subject: [PATCH 4/5] vfs: don't allow most setxattr to immutable files
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
Date: Tue, 25 Jun 2019 19:33:24 -0700
Message-ID: <156151640402.2283603.11025968584452701508.stgit@magnolia>
In-Reply-To: <156151637248.2283603.8458727861336380714.stgit@magnolia>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=895 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260027
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

