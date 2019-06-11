Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC14C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08EE22086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ygS9UVyB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08EE22086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0ECC6B0266; Tue, 11 Jun 2019 00:46:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BE836B0269; Tue, 11 Jun 2019 00:46:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887AC6B026C; Tue, 11 Jun 2019 00:46:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCAC6B0266
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:46:32 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n4so9119218ioc.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:46:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=3VbsaLgMKmnivyw2BABUNL3yVLlrUKnFsmwkVKP7/7Q=;
        b=KYK/BX9rULQp7L/qOsJKkHdUdhYDj+xN5pBgCZ/zeIHOBWpbgjJAw79Haft7giYkzM
         V9cp7dI3rAnXnhQjUyOv0rk6nLhvVfldQ0J4OIxyk3m/hV+UxvISy2+jWwOzrlstuy5H
         8kGFMh7iCL8OGD/3cUaBPuLLeXgvmh9+DnSGJfH1IdqBWMPbT1Zej/s6JUIRpIA5HVx6
         zWwI0Z9RXJ8chPVm7x6eK1SQzlTsqwFCLgGaKLtM1XmKeQwBuVfMInV6boInk2nTxMrd
         QEm6ym2JtFZYdx3fYkF3MB2opTk2PA21bOVlVVatmn3j/Bd5gf37/vkuBEwoIE8iiomS
         YZpQ==
X-Gm-Message-State: APjAAAUv3nwlwbm8xJQvWhBmyL/Lbl3a9NlzZuoEDjJsFFb32X51ywyN
	oYTD/grVBqLl0C+nW/z2W0DCuXVBM78mohFR9XbP3+0Jvhe5LTSbpd+8gfWuQk/6casBCp85ZKl
	Ftc0jDamx9laNpvflSjZKQZ60ZFyI35TPS9AaaGbpR1N42nT8zyn/L27Ht/18k9UFIA==
X-Received: by 2002:a05:660c:b0f:: with SMTP id f15mr13443479itk.111.1560228392116;
        Mon, 10 Jun 2019 21:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWnBZsJmJkkaHxv7Ol4IEwPJBsQccYtk0MzjvAnqlDkCME0i1mtT2+MktLMeLqbkHJj1UJ
X-Received: by 2002:a05:660c:b0f:: with SMTP id f15mr13443462itk.111.1560228391338;
        Mon, 10 Jun 2019 21:46:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228391; cv=none;
        d=google.com; s=arc-20160816;
        b=uyMgrwi/KDYQYd7YWGfAa0U95ExRtiQPNtVu13oDf/3tA62zEd5TUtBgG8z8sUqFKM
         BKT7N5CjXmNewEzhi6x/LhmsabgEjDDCrVOaTzHMjh61GcN3p/0ITfcpcwuE4PIt1G55
         9p4QgNmWRIGOgn2l9u5lvOzXreAWvksTidLD5kpOsJbTeOUL8DOYgZtQvYOCrjx/U5HW
         W7RMC2K7bkFSRvCS5uvP4FJqmQ6jlFM/KSX5paHLsX+8qZS6QVp/wqrIflZKGIP+xkpb
         3lGxpee1GN9KwLYAoattZCwbxHtSeVWmcKA5gilb81d0mDfTh+3tn5cVDEKzCE9um2eU
         rslw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=3VbsaLgMKmnivyw2BABUNL3yVLlrUKnFsmwkVKP7/7Q=;
        b=DfkeNCn3Afo3Q1qEjT8H2D2iyYsdWWd1PmDQbknvU5TkgKTn0oTcDfRP7vkSrY4CBi
         T3KgwPkdLtD59fUxpleF62BWd9bZjz050k/rmyH7ktgtWmwxdbmhBVqPp0AZxz06MRXH
         mn5zo1WaG5hKxOfNyCjseClvl3TuwUj7lf1f0Ff3M0TxIg6w9GKeZE7XVT7p91dl/DaY
         9FT4tsvauqKuZ83X76hxZa8h1TNs0YOvJMhk7HS1E/qqKA9S507Jv0JVpy3oPcN+oM7Y
         EdF8I8relReAaR9GJK4irR9+TNNg9Z3OMymxnJwDwOLs0XAvzzE6VJ89cKAkef+/YsAm
         XEtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ygS9UVyB;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v5si8364510ioq.60.2019.06.10.21.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:46:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ygS9UVyB;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4hvkn179926;
	Tue, 11 Jun 2019 04:46:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=3VbsaLgMKmnivyw2BABUNL3yVLlrUKnFsmwkVKP7/7Q=;
 b=ygS9UVyB8LyUAR7C1mNHPgi0PbSv7gBd3P6tWeLnsQcfs4hLgurKAu8u/njUDzM8jtZl
 vwft8Ixt1L69hPzvX7z0AOvbjg30Rm+6FJl+f7XNM9UPFWffippfEl73w1UntK28uwUO
 Fr2orJrX3KwsU2DI1zdH2KeSHJb84PM6VU23UBPkhgWNXotRA3T3er9eRujknfOhMugG
 nAK8v+cAc4CkT/t6pkRpKrVFJgpouXY14kWiyJczzBwEPMhnGyvQF4902QhWOGDRE3Jx
 XbBGcmgJv4/EAPD1RHtwu9roWvkuSaYyc0Aa5vqwgIaerbFx0TB0XyAtNQNve37DvQSC wQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2t02hejrfu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:23 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4k8F6173710;
	Tue, 11 Jun 2019 04:46:22 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34fg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:22 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4kMi7174183;
	Tue, 11 Jun 2019 04:46:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34f8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:22 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5B4kKHR023006;
	Tue, 11 Jun 2019 04:46:20 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:19 -0700
Subject: [PATCH 1/6] mm/fs: don't allow writes to immutable files
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
Date: Mon, 10 Jun 2019 21:46:17 -0700
Message-ID: <156022837711.3227213.11787906519006016743.stgit@magnolia>
In-Reply-To: <156022836912.3227213.13598042497272336695.stgit@magnolia>
References: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=307 adultscore=0
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
index df2006ba0cfa..65433c7ab1d8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2940,6 +2940,9 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
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

