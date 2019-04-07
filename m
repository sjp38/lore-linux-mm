Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C209CC282DD
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A6C320880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 20:27:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tE2dKgm+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A6C320880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D7646B0006; Sun,  7 Apr 2019 16:27:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 186C46B0007; Sun,  7 Apr 2019 16:27:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0505A6B0008; Sun,  7 Apr 2019 16:27:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0BA66B0006
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 16:27:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so8879305pff.1
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 13:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
        b=naV7VVeZCjgy2UNSpC0t+PC4NjLfGY28s0KbIjbldf+10e6tKI96cP3pnrJfjTfsq/
         ItvClxclZDYCy65le72FeQ6ttAWuPYldyA23L4JvtXRoCNo6UNO/g8jUjTDTY55PZr5i
         1ZIOrTZTv/+ndWqK8Qth0jzI0PTslpXkSDEbz82oZh1xDnj0HTehM/V0/9bmrTWaEu7h
         vk0nXTE8oiHvCB8IR5BbKLK9Z4WL71QSwNNIVGQsmZJlKtQNXS5Com/nS8w8KfMgiWoP
         82cnorhDs2l7eTtHaEJjLGr5HfrYkQ7I4QwigpjvQJ/zdzUkc5XHHcn7GOc9F15v6k6o
         VYbw==
X-Gm-Message-State: APjAAAUF8zA+bYKwMQ1RxoQ5aAMvT2k0UgSp6JKfb4tRRFyVdwo+P/Gh
	/YW3dALtdmm1+uk86sJwsDhETrVjmztlzwFT5F9+Ykr4Wmv3Z790JXvFrC1o83th4s1wBwIvn4D
	+p5GWNCALI6V06uC/rK9TAEW5isTIyEX11ebaM3QgXsg5KiH64F4wO/E5p2/IbWOsPw==
X-Received: by 2002:a62:1a06:: with SMTP id a6mr25879345pfa.18.1554668839251;
        Sun, 07 Apr 2019 13:27:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNae++Yb1LjTvUzetHYees0isiOKG4Bd8u7I7Y3Ugq/5WGbq7Tnn3EvqgXXpxrzJrL5slV
X-Received: by 2002:a62:1a06:: with SMTP id a6mr25879307pfa.18.1554668838423;
        Sun, 07 Apr 2019 13:27:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554668838; cv=none;
        d=google.com; s=arc-20160816;
        b=j8iyromLtW+bb9OP1ActEPqsr4ZFB0SKPy/ihT0wS1wVBRZB0Ukf7VOH6y865hceBJ
         LA1KUeqHHLxwASCr8Z6jvhRVb5UPkEiKeISjpbU4X6YfYqCGncBVNZd1xXO+gdzS0CzN
         wVEj0VD543sOhj9yyF6zLs6CTHjuA+1TKryw4sQr747hzjwUBiXuc0w+18zksaegm7Rs
         dyOOqU73zHphZlp9ixj8qP5cUSFM9qzMzSAzIZs9V9CB4fkKtBaAJpt2mgPhaUjkJrbB
         gv7ytnBxk73OUOxIyZYAQzj1xXYWZekOyTp8d3CaTYqpcwWkcotWoAjQaZdTEBLQKkQw
         8C3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
        b=tnscB36HS2hBYl2roOPkDlAYkRw7F9My3ieYgDicmX/i/76/8QkDYBZKib1swXszMW
         RpZ1AF4o9BWThyg+RPi702SUuQi7rz/Nbj8qrC5ZYdeusEDlUMe1v7fkZy/bKr4ge3Jc
         fKJZzP67KqFHzEhcC3guBr6B5k3ythZou9gTj6jw9djmwcKLAUJjAKR7Xcx0JRgKoIQZ
         AuP6NSBhla5hcGXUqap4SgMd8Htn1905HVNi5kRIBpQa+xF6Hnb1/733mFp70t6BmRdC
         U0LVPnnOAkg6uHYph6cbFep70Ij9U97T+5q5wXPHHaFf0O4B+vL9Yy7wR9/d/33uvfXZ
         kmQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tE2dKgm+;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id s34si24836892pgl.97.2019.04.07.13.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 13:27:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tE2dKgm+;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KPGDc076183;
	Sun, 7 Apr 2019 20:27:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
 b=tE2dKgm+QrzvW0UAJynvjLsoXj7nXe6GQm+EAWEQhd9kFKldDSeeZp4sYigpPUOrEgtP
 FteL1naRdN4NBQA1aFZ2Ou3Ei88zWRxR6R6KSujVEE9FgvnUqP5cYC9VlJ6YmDH75ScJ
 EpgR9Sulqlm0cIXS2NqQrbW6vIXg9JEXgt/+/kCuR/iK0K3x9nTdZKDsFS9HlyMSV7sj
 WUVO4cfHsqrjW/0GgWLBzgPqUSSaY6y3LaiEq34aLmaDDl3wxmZucnrhpuSMk9vIwaNM
 sAswXQ0iqjAjjdjLI25TFIK2BAlWtAbAfbfN4dEH/7UcGp36XBZdRM0XxN/kghJu69wd Fg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rpmrpu3e6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:17 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x37KQ7MK193939;
	Sun, 7 Apr 2019 20:27:17 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2rpkehduq0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 07 Apr 2019 20:27:17 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x37KRGtB032470;
	Sun, 7 Apr 2019 20:27:16 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 13:27:15 -0700
Subject: [PATCH 1/4] mm/fs: don't allow writes to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Sun, 07 Apr 2019 13:27:08 -0700
Message-ID: <155466882886.633834.9877039193610671186.stgit@magnolia>
In-Reply-To: <155466882175.633834.15261194784129614735.stgit@magnolia>
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=395
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904070193
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=427 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904070193
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
 mm/mmap.c    |    3 +++
 4 files changed, 15 insertions(+), 7 deletions(-)


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
index d78f577baef2..9fed698f4c63 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3033,6 +3033,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	loff_t count;
 	int ret;
 
+	if (IS_IMMUTABLE(inode))
+		return -EPERM;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/memory.c b/mm/memory.c
index 47fe250307c7..c493db22413a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2148,6 +2148,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
+	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
+		return VM_FAULT_SIGBUS;
+
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
diff --git a/mm/mmap.c b/mm/mmap.c
index 41eb48d9b527..e49dcbeda461 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1394,6 +1394,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	if (!len)
 		return -EINVAL;
 
+	if (file && IS_IMMUTABLE(file_inode(file)))
+		return -EPERM;
+
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
 	 *

