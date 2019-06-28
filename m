Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD8CCC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E37720828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EsEaGQJI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E37720828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 074A78E000A; Fri, 28 Jun 2019 14:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 023F98E0002; Fri, 28 Jun 2019 14:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30078E000A; Fri, 28 Jun 2019 14:35:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f78.google.com (mail-yw1-f78.google.com [209.85.161.78])
	by kanga.kvack.org (Postfix) with ESMTP id C0BC28E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:34 -0400 (EDT)
Received: by mail-yw1-f78.google.com with SMTP id j144so10034533ywa.15
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=MiY2VYpSFpzY6WkWYo65+t0yY/S+2bgdM8Tfcy+RPHs=;
        b=MIdsp7CblbgcpxsqvAle89nSQvs+Tf9pc777pwYkAcsCzIbrz5+EuYjNCe+PxPyj9p
         zoh6jT8LFfS7kilgWokwKRqwWItR78if1KvMv2HD2EkxxBNN4xg2Z2Rhz2ud+qLZ32NT
         wfTNoGbJPbHysROS/v938vPMEZ2ENhA92ecmgOxl+b0SYkYnLgZsKQi65+02bWAeKudU
         REVSYvBMioRgfQXVi2YH52roR/MnUevgV7XJrl7ITNrhTO86bY+5FB/zI+deNzUs4SD9
         ofWq37C4LZobhJ0IHPgxzHSJzYD4HYpHlCu5PxYC5eDqth+jXSgYZDcXhuWkSopdXhXi
         TOUw==
X-Gm-Message-State: APjAAAXfEJDGx2G9OxTO47AKJvq+t+sobIy1IpfOtPqffdSmTLUiRHjL
	7IPwrhUIXBcfJbLTCArVBqu479zxHwCsZsOseqx52oVqeb280eTm16848NpP8sbkIo1r0mnX+lm
	HWIGigmGPoeoDg/lJcdQdo0ggnvDYzHqvPvXE2/8Dgavt4mAPIjAkOW5MDMFHaidxnw==
X-Received: by 2002:a25:748a:: with SMTP id p132mr2745169ybc.196.1561746934508;
        Fri, 28 Jun 2019 11:35:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwxLQulCx7UYDQTsJ0judh+piH5VkbiiEOSBlozwi3uRFfaZYahzAL0ZpZ8Y6bYXyspvfA
X-Received: by 2002:a25:748a:: with SMTP id p132mr2745139ybc.196.1561746933897;
        Fri, 28 Jun 2019 11:35:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746933; cv=none;
        d=google.com; s=arc-20160816;
        b=ECpJ/suOcq7+jiKdKtvmV6CzTL7Me4JDYh3K+DQkMm8a1dNKqQZwqnKFTzNqv8n1XU
         NjOjWV7FTqbELYCiOk6K2I+PdyXUbFfxFH3Qc9xIw4+iXhfTtlctVAd80L9BDzBnTRsY
         tGPFh5aIaNa8mDuJ9KXAjUH8Dqa4W9SdNBinjnAOrn6ISqZp7GrSae7d3z/jV7aJAAVJ
         tCO3SAcYzu4qXr+c57lh1qr3Tewhm0hAdZyWDUv101e9juRROJ5QHOEtSzAmE254+5gl
         9g7fOUGwz5VieR4yiGXAmT+3j1PKbaz6TX74oOZ24s4IQueEo2EmOkvDQI702+FcexB8
         IzIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=MiY2VYpSFpzY6WkWYo65+t0yY/S+2bgdM8Tfcy+RPHs=;
        b=QSAlsR/C3w1fn7u7Nd2lExLD5hSmnyiwm5EDALn6gZ6UTgwctplOUEGUFwR+FN216i
         TGdXKIUTDlWjuLrJ+lrIjJmmFUCxXfVtdMAvU19v9xR2WJb/YJfJHKdA/BPid6YN5JCp
         +xyFGZOwW651vuuR17QZcraaDGFHDP0VTX9kpvEqnDfKq6TCHB/ctQSprqkFbN18sEG3
         wCYLOr1DcjFkqH6uhxvIPWZxP8lQWa0LNxNkV2gSmBiS0reuOCHsA6fKa33wtfo0ma76
         NU2H/gQZU41s32baTsGfZGDPypnzlJreRW4fndhpyrjgf+wEbXNSGxJwB8QHMP3RFBcp
         rnsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EsEaGQJI;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i10si1201890ybk.212.2019.06.28.11.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EsEaGQJI;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYILG027632;
	Fri, 28 Jun 2019 18:35:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=MiY2VYpSFpzY6WkWYo65+t0yY/S+2bgdM8Tfcy+RPHs=;
 b=EsEaGQJIsCrbPmH9OznS4Gvkxc1orFTlcEwxQExpwlUwRPJJ9/2dGYPxRHFWSzZmu3PI
 oz2WYxk4CJsXjWlDQqTaUTzi4QBK2xaXdZRS0x/XQ0n46azFi8QfHloIyya1nw/juBCv
 /GcNjv/IJGQrLp4Oz3RwgLvBPC4WljMtRCvxbicMqns6wNmSrHmhKHNqH77k4EAGUxdc
 /W1fzi3PzDN1nIDiHkcbLDcLd+ZiOZYxKdRPC5KmuODEGdubVjskPrZl2cKTFxlVG+N0
 uztVyNgEzIwjOCyFmMrxhWXH+XJo1bOazdUdyCKnzZrU7GMwZOJbkKkRTvt6ps9SySM6 Vg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2t9c9q72tx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:27 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIXjZ1001279;
	Fri, 28 Jun 2019 18:35:26 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tat7e3gfe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:26 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5SIZP9g002352;
	Fri, 28 Jun 2019 18:35:25 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:35:25 -0700
Subject: [PATCH 2/2] vfs: don't allow writes to swap files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
        viro@zeniv.linux.org.uk, darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Fri, 28 Jun 2019 11:35:24 -0700
Message-ID: <156174692434.1557844.13804911834937629088.stgit@magnolia>
In-Reply-To: <156174691124.1557844.14293659081769020256.stgit@magnolia>
References: <156174691124.1557844.14293659081769020256.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906280209
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

Don't let userspace write to an active swap file because the kernel
effectively has a long term lease on the storage and things could get
seriously corrupted if we let this happen.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/attr.c      |   16 ++++++++--------
 fs/block_dev.c |    3 +++
 mm/filemap.c   |    3 +++
 mm/memory.c    |    3 ++-
 mm/mmap.c      |    2 ++
 mm/swapfile.c  |   12 +++++++++++-
 6 files changed, 29 insertions(+), 10 deletions(-)


diff --git a/fs/attr.c b/fs/attr.c
index 1fcfdcc5b367..7480d5dd22c0 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -134,6 +134,14 @@ EXPORT_SYMBOL(setattr_prepare);
  */
 int inode_newsize_ok(const struct inode *inode, loff_t offset)
 {
+	/*
+	 * Truncation of in-use swapfiles is disallowed - the kernel owns the
+	 * disk space now.  We must prevent subsequent swapout to scribble on
+	 * the now-freed blocks.
+	 */
+	if (IS_SWAPFILE(inode) && inode->i_size != offset)
+		return -ETXTBSY;
+
 	if (inode->i_size < offset) {
 		unsigned long limit;
 
@@ -142,14 +150,6 @@ int inode_newsize_ok(const struct inode *inode, loff_t offset)
 			goto out_sig;
 		if (offset > inode->i_sb->s_maxbytes)
 			goto out_big;
-	} else {
-		/*
-		 * truncation of in-use swapfiles is disallowed - it would
-		 * cause subsequent swapout to scribble on the now-freed
-		 * blocks.
-		 */
-		if (IS_SWAPFILE(inode))
-			return -ETXTBSY;
 	}
 
 	return 0;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 749f5984425d..f57d15e5338b 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1948,6 +1948,9 @@ ssize_t blkdev_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (bdev_read_only(I_BDEV(bd_inode)))
 		return -EPERM;
 
+	if (IS_SWAPFILE(bd_inode))
+		return -ETXTBSY;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index dad85e10f5f8..fd80bc20e30a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2938,6 +2938,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	if (IS_IMMUTABLE(inode))
 		return -EPERM;
 
+	if (IS_SWAPFILE(inode))
+		return -ETXTBSY;
+
 	if (!iov_iter_count(from))
 		return 0;
 
diff --git a/mm/memory.c b/mm/memory.c
index abf795277f36..5acb5bb04e21 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2236,7 +2236,8 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
 	if (vmf->vma->vm_file &&
-	    IS_IMMUTABLE(vmf->vma->vm_file->f_mapping->host))
+	    (IS_IMMUTABLE(vmf->vma->vm_file->f_mapping->host) ||
+	     IS_SWAPFILE(vmf->vma->vm_file->f_mapping->host)))
 		return VM_FAULT_SIGBUS;
 
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
diff --git a/mm/mmap.c b/mm/mmap.c
index b3ebca2702bf..1abe55822324 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1488,6 +1488,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 					return -EACCES;
 				if (IS_IMMUTABLE(file->f_mapping->host))
 					return -EPERM;
+				if (IS_SWAPFILE(file->f_mapping->host))
+					return -ETXTBSY;
 			}
 
 			/*
diff --git a/mm/swapfile.c b/mm/swapfile.c
index fa4edd0cca3a..1fc820c71baf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3165,6 +3165,17 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (error)
 		goto bad_swap;
 
+	/*
+	 * Flush any pending IO and dirty mappings before we start using this
+	 * swap device.
+	 */
+	inode->i_flags |= S_SWAPFILE;
+	error = inode_drain_writes(inode);
+	if (error) {
+		inode->i_flags &= ~S_SWAPFILE;
+		goto bad_swap;
+	}
+
 	mutex_lock(&swapon_mutex);
 	prio = -1;
 	if (swap_flags & SWAP_FLAG_PREFER)
@@ -3185,7 +3196,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
 
-	inode->i_flags |= S_SWAPFILE;
 	error = 0;
 	goto out;
 bad_swap:

