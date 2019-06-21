Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EBC5C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 581B1206B6
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OcnqzjPS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 581B1206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1028E0007; Fri, 21 Jun 2019 19:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081368E0001; Fri, 21 Jun 2019 19:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8A5A8E0007; Fri, 21 Jun 2019 19:57:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C41268E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r57so9726312qtj.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=H3uevlbLebMWG9Gcus8tT+xdX29l/sejQz3Gcj6GgOM=;
        b=uXf1PHFoDG6C3Wmll+z0JkSjjKxV5qRwqS9Rv8VvRgY0Edn7wwfDNamcjU+i2akqPm
         tAMy8Sl84hrLxdMFkKcZlI+taBLH0BxloPnEM0JsoSeeIJ1UF7OCP5gnI5pJaomd5Ow5
         FWcgoGlnJSVIlLTIeGCuSXfa7yJo9ubzm79hfZxzH+vekmBlquYCSmuxjGUj7inpBfeD
         R1o0ZP/rGJxUFbpHRUikdDBAlLJD9Xa7r0w2t1mjZZq/FgXd6HLvE431nFrAlbC663gB
         MpOYIYSg7v6xmyrmXXacFwGlnARKUuykrT6Jo0uPhkDkKS9bI4+TVn3D4xfN/sEbfa9o
         j0UA==
X-Gm-Message-State: APjAAAXFfakY5IQ67uqBI+qb9ygm5Pmqsc/+FHZK0RWs5U6JIFue8/EK
	LCOrbsBYqY5cuAd6vS1/gk5O2KSfbA8hDv0sdystLK+Az2U4FH8J/PufycIKvYPn+vYFkD2Dxi8
	PcjJeFgMJem1BPwcCv22DpieuYQvMOPnw7CBOSWMSftKZ7hN7CTvKxfIU6syBnc2VEA==
X-Received: by 2002:ac8:25b1:: with SMTP id e46mr100087950qte.36.1561161457545;
        Fri, 21 Jun 2019 16:57:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBv7yUkM895IrvLBAMklAszoGRYyy3Kd0i31Y9CqYEMdLWWw2kgUyMQ1IE8dxMj3xF5C51
X-Received: by 2002:ac8:25b1:: with SMTP id e46mr100087912qte.36.1561161456910;
        Fri, 21 Jun 2019 16:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161456; cv=none;
        d=google.com; s=arc-20160816;
        b=rucDzxeZ/eV8Fl7K9FG3w9Xfmk3AKZ6ONj5vX4rmuKSyg46gmKEHjxGmfHggEmGuR0
         cZQXydLlzuWuH57PcX1YcIsd4wXjZ2WF+/1CtEFPpOSSQi8tVwQhHK/cvSqz2jICPYAy
         Wz9LB4f8AD7gPYVkSrY/awrG+5bDzyGuQHyTfoSDDElXtdaiw7qrKXMlYsSeqgZ+KiIX
         ObEurkZHcQzjsGoIkxdoTeHMNH7YR6wUD3LIKBXsQ6EMiuQJ+utDhxOu0X90sZNqcGUO
         kZA6PHo1N4flTlCyWPdj3iDjAWTCDJPfVjoHeY5LOvTwNm+SzG/FL7/m4avoqbtsID4a
         eyGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=H3uevlbLebMWG9Gcus8tT+xdX29l/sejQz3Gcj6GgOM=;
        b=aVRkRjIYh/Xe9H5AJdrh5hy9xLyBqTroNdbW/2XtosgGqT5tkB3Sia384C4hpet58N
         +8JHEG/U96gAUkscz3G5X6lMhnMIedd+kebD0nBCpr6hgku+mho+Wk5QhE9/YiuCYKv6
         rTYtOPkG93hrmc2JAk1/cBMAfaFec+IwN2R2obWX2Vj1qwfmtWV12eVuvLUa42kfA8fX
         /3QZJjWFfFXgmXBxE2cxQOVRKDIWusbElQzw8I9XGH+2JHcNAAmyx7yPzoUp6Hxrql7r
         LCwh1LvklvTqwF0dHxlJ0mS3WXhj63olkiXJULIc4iOjqHjp2R2FRYkxKMEsCu+cYK6D
         LbRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OcnqzjPS;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e48si2721536qta.238.2019.06.21.16.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OcnqzjPS;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNsvRV052754;
	Fri, 21 Jun 2019 23:57:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=H3uevlbLebMWG9Gcus8tT+xdX29l/sejQz3Gcj6GgOM=;
 b=OcnqzjPSKPtrxCRWYar6ofhsldYVF9c+tkfBHXonTVfuZMYUnfzwd+pZBE075w5zCRmi
 ZvsUfy3kAcVu/YedEjN9R/6USufYjacFfPaKsIdUv80jaVBQnD/OAu6lBasg+yQiEqjP
 eKuWczOltqaQsSQOKOYn/WyUhF9mG4q9hlyIS5IHkJIYG9MP/Y+1AJ1FU73ge2OLZkP1
 hZaOIE2TRbrQFAunY0/VNR5vRAiBxDfmhK6deScIzINNLh1gycqSUk/W9IUPYABlnujp
 Ix4fU3tFgbn/QJ+lm60ma+H/Asm2thRj0sXAL9MfISyk+U6RhkB3o0SFsco43PF8crSz hg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t7809rsx8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:29 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNvQ7S171581;
	Fri, 21 Jun 2019 23:57:28 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t7rdy064m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:28 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNvS47171635;
	Fri, 21 Jun 2019 23:57:28 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t7rdy064f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:28 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5LNvPo2020773;
	Fri, 21 Jun 2019 23:57:26 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:57:25 -0700
Subject: [PATCH 4/7] vfs: don't allow most setxattr to immutable files
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
Date: Fri, 21 Jun 2019 16:57:23 -0700
Message-ID: <156116144305.1664939.3544724373475771930.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=885 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
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
index 6374ad2ef25b..220caefc31f7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2204,6 +2204,14 @@ int vfs_ioc_setflags_check(struct inode *inode, int oldflags, int flags)
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
 	return 0;
 }
 EXPORT_SYMBOL(vfs_ioc_setflags_check);
@@ -2246,6 +2254,25 @@ int vfs_ioc_fssetxattr_check(struct inode *inode, const struct fsxattr *old_fa,
 	    !S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
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

