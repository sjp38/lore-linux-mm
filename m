Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38D59C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8E1F20645
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:33:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OwYWG9CO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8E1F20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489E28E0003; Tue, 25 Jun 2019 22:33:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A7C8E0002; Tue, 25 Jun 2019 22:33:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 350EC8E0003; Tue, 25 Jun 2019 22:33:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 160A78E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:33:20 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 133so2363398ybl.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:33:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=GZ5Da9i8UXdicVq5/ebI4XscP19RKvf9/ymCHA5iuvw=;
        b=Nj85QZzC+4V3eys8dS60lN4cIOqbwsYjX0zJs5Ib5bU4VtnAhlfXrOJdR5kc/50UlP
         IwYFBcRPBwGEbt7oCBxAUadzhFq/klNLXoLzoLX009eiWe6FZ15okacDXdIXmFR+iedz
         6JE2MGh4drDqjYAHPrDnOcEL0yCPegGaeKd5YXHNCJfNKiVQY1QnpZDMYIv3KMUxHo0M
         Lnm7IMx7ElPozt615wNtzalwIk+7IlNhI6oWHAa1AooKRje3rMDBnlNe4mJ0ZBZSdNQy
         RcKamxpeOCmrOV1WVBXdXfUWDUJDbgMjU+6xypjMD1wfdWCjp5Yje8Vih4AgVWHeSkog
         7cmA==
X-Gm-Message-State: APjAAAVbdSH5sl4zQ6nNZtXpw/wOHyTNxgxtSovm4TUHyzTXJOj1N1q6
	IE4m6zrnDxOTWB35mMSdIMJJ+etA2tukz0VDKm84jZGaXfjpKYQEGgnV1QGNsaj4q5I3FRVTAXH
	SFOXwJTpDsKLslgcA3uB6SkB16pamLNkpHC5hoJAb4cOlcZGpFcrh1lH4O+lG712wqA==
X-Received: by 2002:a81:7b02:: with SMTP id w2mr1268747ywc.436.1561516399703;
        Tue, 25 Jun 2019 19:33:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdz0m+3CVZrodg7rrzhT4bt85DH+RKe33SDn6d7Mo0BpOjKKVQs6pU+/4QALdCCGmaDRKN
X-Received: by 2002:a81:7b02:: with SMTP id w2mr1268728ywc.436.1561516398870;
        Tue, 25 Jun 2019 19:33:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561516398; cv=none;
        d=google.com; s=arc-20160816;
        b=AyJt6JCfvdGNoh9VKQqeD6Dy2SZwCyqbTgTIMrMVFqukBXa8do0FvuD8MLiaHTKP4+
         dyvmby4Cz037M9lUAjGH/rirLR2SlJzZvag8aVcQTJJ89HfdvcrfBsp/A3qskJoWEKgg
         I+BRl7AZiejHCyUtPRc/TPs0nNCRnKkSZnCQSANcSkyDoRljAjfyxyYC6wUMLhwW+wi+
         nQMX0k4wyAVlg/vlJC5uIiUEkwIjnUOq6jIdC1ordLrbZ8s8XS9j2WiAlZTLf00w0BBG
         MQZ2jq/aRTIM7btW/A5YMmlUbO7WnGP7C1ATitIpqQcR1cGcgo3BleUUKxllj6+TrV/2
         oPNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=GZ5Da9i8UXdicVq5/ebI4XscP19RKvf9/ymCHA5iuvw=;
        b=vuHKH85Kc4PABXjm+uofhug6GcCcaVCBpDPr1767DbDrYwP+YNFZXj1zhuSLD+jsZS
         +Da9bT3+o7GZflZcJ6E8qO8EaHxcNe9mw2802fV9BTdyjQnmI0WkV8iYE1XK85aSjtZK
         FibYXnZw0YEj8u6KZIKaxbx5pMTy3d2t91oijx0WokXkghj6wBg08juwRvO+zYLQxPyc
         MMdvuCpdiyqLKosUOqwK3t/ol4sJTy0rpTiuE286EF1i1bPl6ExRNwOaiR9qCLquLiCc
         yvbf2RAbhcxrNQAwx4eN1DPrSXiJrNglr0aY39ScipOpGsD4a9HiX1y7SEsIW0SaEpAj
         BpPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OwYWG9CO;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r126si5905821yba.165.2019.06.25.19.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:33:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OwYWG9CO;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2St3m116601;
	Wed, 26 Jun 2019 02:33:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GZ5Da9i8UXdicVq5/ebI4XscP19RKvf9/ymCHA5iuvw=;
 b=OwYWG9COa/utVeg+XFueBCQNbNHCKEORscmBRW6CX5wX1eaV2FXBC7NljSPy3RS4qDUE
 b9M9KeySwRTS+CsKX1Xla151y395HzGSXJJfbVfWx4faXRcg07z0e6bgKSj3w9DHkvII
 gHuoqvYt3YoddlkFH+TkNlF+72zdoGX3Sep9OlkXKvgZw+mtCU/rS3hW1v8feUw3Jiv+
 swWRG78ZiDDHbKViaLEwV+Y4c0KtsiRV7RBTt83NxTKbz7E7deMXzIVYS9lFPFateZVC
 +waBXMHaI1HYAQqb+CTireZ6bU/vo07hOOzWEEuIfzyuXzso74QcEtkOyaT392xtlJLV lg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2t9brt7mm4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:06 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5Q2WkGE080003;
	Wed, 26 Jun 2019 02:33:05 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2tat7cjnv7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 02:33:05 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5Q2X5bt080432;
	Wed, 26 Jun 2019 02:33:05 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2tat7cjnv1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 02:33:05 +0000
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5Q2X32M024230;
	Wed, 26 Jun 2019 02:33:03 GMT
Received: from localhost (/10.159.230.235)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 25 Jun 2019 19:33:03 -0700
Subject: [PATCH 1/5] mm/fs: don't allow writes to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        Jan Kara <jack@suse.cz>, devel@lists.orangefs.org,
        linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-nilfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        ocfs2-devel@oss.oracle.com, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org
Date: Tue, 25 Jun 2019 19:33:00 -0700
Message-ID: <156151638036.2283603.8347635093125152699.stgit@magnolia>
In-Reply-To: <156151637248.2283603.8458727861336380714.stgit@magnolia>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9299 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=324 adultscore=0
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
Reviewed-by: Jan Kara <jack@suse.cz>
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

