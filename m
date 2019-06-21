Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF6B4C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58F52206B6
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EN0d442h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58F52206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F004F8E0003; Fri, 21 Jun 2019 19:57:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB1BF8E0001; Fri, 21 Jun 2019 19:57:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA0458E0003; Fri, 21 Jun 2019 19:57:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAED38E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:13 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id l1so5443609ybj.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=twjcs7hmw0I/0y9CON1SwlujfVo0pxMu7JFwyONml5Y=;
        b=I3ikONdIc0QlsqS1XqzmlxUGRgvTjcE51o7ca3RFysMrzaS9wC7mYjYked7/VSb327
         p17PY9cS+fK1/pINBMk3JwyBnP5gHaGmFNzpBuxcf4Y1nD/pVj152hzwxoldxqae0yVT
         gpcQb6XJRhQa9qOX2q7G1DNLtshGAr7R44Htmdxv8WmMyeaLQhQYnl145lkTO8THmXjL
         rOM0PRSZWHLuhufFxfB/9N8FHjCF1gaVhElEyDeCB9Rrk5wk1uDpabtMZTci+mIjHlAf
         qj4CXo5c8Ai9LnS6gMJ+cyAjMzNhAWAMgsZa9IRyha6k5cU1p+c99eFBsTWE1D4MvMZ6
         M6PA==
X-Gm-Message-State: APjAAAVCIDC8DEakGR4kZDuERLn8jVJ4fNqu3kOAQnxm5lrGEPZvaR0R
	nBJRT4GLj1qs1rwMD+vex0w3pIHVOSIEcDAOfBQQLVjPJDbjwqSlDdLEdXJhN+lQHnUR9VbpcqO
	j98M6iFwSIPJCu8dWbwAzR8EIj53dDSsJ4RUl5FHGMd1G8YY0U+OTKorN1f1guUKX5w==
X-Received: by 2002:a25:e64f:: with SMTP id d76mr76250406ybh.473.1561161433419;
        Fri, 21 Jun 2019 16:57:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzVdRdDhW2QWqxoUIaFTJLFsPBrzGYytJBtuJZ+rHzTm0OgSSAwm9xXdPFZ2asCK2F6COA
X-Received: by 2002:a25:e64f:: with SMTP id d76mr76250390ybh.473.1561161432704;
        Fri, 21 Jun 2019 16:57:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161432; cv=none;
        d=google.com; s=arc-20160816;
        b=trFYMKgNL3SUM9SnhGu6tQrnqlwZYTvxxUkURAsKyhiQPSusQsNdj6jrXrMNiYs6Ak
         GL+RWidKKzBwJXcLcUlj8F0W2gTu6mW6Ps1JMbbdFWAUHs7WH4ZW0o3HowWpYvY7rrrx
         a3CNgBFUFuauIWUEeb+cSB5ESVJarGu1kGcBw5+MZ6+2hU95JAmwRilDmeBniiFnecIz
         wxhgVgd7fgrOIpcHhIhJ0t8geAdKZcnaTZnAdzIovqWzhAEJKc8T+AtdaOOqppCRqLVX
         3IvLrWrE5a+65Juopr22ZKS/Ey/njj/EJCVO0d8t8P9ehCvh4lU4/Edjy9y3jboUxQYt
         uNqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=twjcs7hmw0I/0y9CON1SwlujfVo0pxMu7JFwyONml5Y=;
        b=efp7Ww7xaax+yaDGNyw1tGZTfqetuAPTCy4B4hSt3EzTe2x6n7G5lSGKhUHF3m1E34
         xrQ11MtdqpMrrvbcJ4XVneRMoa0X7rDvvMBo5+KTz9lUaKMw2Ya7Y2zi+GlTJgFKUaEw
         JMnfjRZntM0i+TNsgljcXQ/DCPJ+S5ogHhfrQ6PJ7xkCoofZboSDzo/TjGriJHlmBcIM
         EAvv6+1lA6lUTA8ovhmHgDuUSIWIegmAz8Kdrwyq06vxQKiL0dJhcyk+O/ita1AD1blj
         RaxuYv37gT/3Vo3xtknHDkcXbG4I2fa/L59tZP2Ypmm/b7MgKwt1ATnbDn/SsV+6k7P/
         NnFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EN0d442h;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v15si1477885ybk.403.2019.06.21.16.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EN0d442h;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNtT3B053502;
	Fri, 21 Jun 2019 23:57:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=twjcs7hmw0I/0y9CON1SwlujfVo0pxMu7JFwyONml5Y=;
 b=EN0d442hHQvSNNdl/RDvWSv64qxAaUqBJ+XWzb9wmHNittQOUUWson32FwnA5XsOJ7B1
 iGsLJuG230CgcItr8GkMiTTOOQPd++pT+F2FFKTrjIIUW23zuCjPo4q9zWJSRjhtqh4y
 tHUs2KjIj99SfJcNC3WfbXVxr7c5JoLZ6M05US2Y9VlFyVrcg+sjXlOJohNfSt1B3GLs
 aTA1JLQMueHt86DwwYNKh4l87ElhhVid89sOr4rk8MXfz9FIGnNxYLjrMalcbFp/7Ylc
 5dsT5NuF7PizftC8G7G17VjxcDrejTJ0B4mzo+6ilFAPLgyMkxYtyhCXIMImzP87l7n9 2g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t7809rswm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:05 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNtKFi168028;
	Fri, 21 Jun 2019 23:57:04 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t7rdy0612-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:04 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNuhUw170079;
	Fri, 21 Jun 2019 23:57:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t7rdy060u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:04 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5LNv2Il019145;
	Fri, 21 Jun 2019 23:57:02 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:57:02 -0700
Subject: [PATCH 1/7] mm/fs: don't allow writes to immutable files
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
Date: Fri, 21 Jun 2019 16:56:58 -0700
Message-ID: <156116141836.1664939.12249697737780481978.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=315 adultscore=0
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

Once the flag is set, it is enforced for quite a few file operations,
such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
don't check for immutability when doing a write(), a PROT_WRITE mmap(),
a truncate(), or a write to a previously established mmap.

If a program has an open write fd to a file that the administrator
subsequently marks immutable, the program still can change the file
contents.  Weird!

The ability to write to an immutable file does not follow the manpage
promise that immutable files cannot be modified.  Worse yet it's
inconsistent with the behavior of other syscalls which don't allow
modifications of immutable files.

Therefore, add the necessary checks to make the write, mmap, and
truncate behavior consistent with what the manpage says and consistent
with other syscalls on filesystems which support IMMUTABLE.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/attr.c    |   13 ++++++-------
 mm/filemap.c |    3 +++
 mm/memory.c  |    3 +++
 mm/mmap.c    |    8 ++++++--
 4 files changed, 18 insertions(+), 9 deletions(-)


diff --git a/fs/attr.c b/fs/attr.c
index d22e8187477f..1fcfdcc5b367 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -233,19 +233,18 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
 
 	WARN_ON_ONCE(!inode_is_locked(inode));
 
-	if (ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) {
-		if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
-			return -EPERM;
-	}
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
+	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
+	    IS_APPEND(inode))
+		return -EPERM;
 
 	/*
 	 * If utimes(2) and friends are called with times == NULL (or both
 	 * times are UTIME_NOW), then we need to check for write permission
 	 */
 	if (ia_valid & ATTR_TOUCH) {
-		if (IS_IMMUTABLE(inode))
-			return -EPERM;
-
 		if (!inode_owner_or_capable(inode)) {
 			error = inode_permission(inode, MAY_WRITE);
 			if (error)
diff --git a/mm/filemap.c b/mm/filemap.c
index aac71aef4c61..dad85e10f5f8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2935,6 +2935,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	loff_t count;
 	int ret;
 
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..4311cfdade90 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2235,6 +2235,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
+	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
+		return VM_FAULT_SIGBUS;
+
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..ac1e32205237 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1483,8 +1483,12 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		case MAP_SHARED_VALIDATE:
 			if (flags & ~flags_mask)
 				return -EOPNOTSUPP;
-			if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
-				return -EACCES;
+			if (prot & PROT_WRITE) {
+				if (!(file->f_mode & FMODE_WRITE))
+					return -EACCES;
+				if (IS_IMMUTABLE(file_inode(file)))
+					return -EPERM;
+			}
 
 			/*
 			 * Make sure we don't allow writing to an append-only

