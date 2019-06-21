Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 904A8C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B3D20881
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:58:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="j4pMav0S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B3D20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEE8F8E000A; Fri, 21 Jun 2019 19:58:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D780B8E0001; Fri, 21 Jun 2019 19:58:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C18A48E000A; Fri, 21 Jun 2019 19:58:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7658E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:58:00 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w127so8028805ywe.6
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:58:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=rwZuzZLu2QSuxM1deZeCZnnfsOeZtWtWWa3iVLz4Y0o=;
        b=UBxPV/TPDjajH2rhDxXOBx5pfkSAJUjizHcIfVVSEUJfocq0GPx5tS4iJPr3MO0lg3
         KViVQVd7sQgfGbjBtTItc+gOl952vwetTVxSCTrcpAPTadUCBmlEpvtYwOiNnJwn4OdI
         SMWX+rX3II2V8b1nIT2QWmi093DeJJrpjFH2pftKiezvR60A1IKQmOunATh882ksZrz8
         gzLZc7rUS6NLLMA08GpRTOZaM+/rCMFvTPTtvNu8WQW4mlMlGDIgYKJaO+cHu3i0ANJh
         d33a25/tEjdBS8E+uxdfVZsT6+SP20ylxly2megWryrlzxgQkpyjqrohUSlDeFUBsmnh
         +YCw==
X-Gm-Message-State: APjAAAVlrxUt44TRSP/9UKUpVhHmjCsVg+19pR0Q4o3F8PShiBmdg28B
	erFYT3EFUmb6lnY40mZVF+NIEfVu5aIkxqqOa1IUYYICgSat0YyfGZp8wKud74LE78dRMz7NcqO
	vJmmG76Pkr2PN+H+EcMWGZD1WuJnrutTGg7rqeUbvQBb5XtSL3lILCJF33cphbmOFsQ==
X-Received: by 2002:a25:e405:: with SMTP id b5mr7436691ybh.330.1561161480392;
        Fri, 21 Jun 2019 16:58:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHi0EAHtyvlY5LBWepYCtcbb4RFUgN7Ma0GYibx5lePSb1pnDFnALLZnTehu5eDEEzeBZ5
X-Received: by 2002:a25:e405:: with SMTP id b5mr7436673ybh.330.1561161479765;
        Fri, 21 Jun 2019 16:57:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161479; cv=none;
        d=google.com; s=arc-20160816;
        b=bp68dM6HIbQ5GMrtG6dx72dQbQ4csOXX8IYL8wHmtEUWGQVkTR3StpU3B+8FjScKJ+
         jaf56Dw/zvvsRn4SH2+XaS3LQRAh1S6tVctoGA43yRZANYBnts91UMEFpcNyBqL/Jhjy
         LJdSO0Ava52hhC9VF2MxH5H/dRUkJ+4YYfvdIVvS0AoExFo2ye4Gep1xmIbLZaGmIev/
         OWYh92uLn+0nFwjP+veCvFm+OqwcS0p1mT2Z4w06KuY8VVHbybhh9K9AL6ee4J8DeG3F
         9RRg4qw2WqvqtjPMZWor/t1LDwfgnsNAyHCJ2DXaD3dsrOJ5+65BjgMwUGEytxnq5FRY
         JOgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=rwZuzZLu2QSuxM1deZeCZnnfsOeZtWtWWa3iVLz4Y0o=;
        b=Pz9juVQ5NsGjXwjfydENFUAOXkzp2EwI0BOVXiScJNR6dgQgYaPhx6btQi27i+3bF2
         PMg2LbDHiLXXniCEYrda3vnFmImB3qz9OLTmmxa7wpZHMS2hNN/UA0PsW3jixcaRzjZG
         D4lzIUaG03VTcpH6YFl0cYpmbYZBsFKxM6tOWmMLzTusH9UYYc7cewC/mXdLpRZ3e6Fy
         91DZxVcX/IR1b8XfXuJhJwVog5LDKBM+j7hJvePfQqjRYhkEpyNpUnGXYFvKBaJ8wac/
         fapA3/vNTBHiP+ze7guQYEi0whg2GDrPQmvPRSrX33lsKpPyV1OI3oDOy3cEgniNIdO+
         UwWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=j4pMav0S;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 9si1562616ybq.246.2019.06.21.16.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=j4pMav0S;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNt22Y052769;
	Fri, 21 Jun 2019 23:57:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=rwZuzZLu2QSuxM1deZeCZnnfsOeZtWtWWa3iVLz4Y0o=;
 b=j4pMav0SW7e9IFJcTpCLcn4neiQwevtJo2J+lHllOH0GrPdCMsB8iQfSOQ1NgxlBqbVT
 OICMIQi3C2UlR7VmtDc28J0RWQyGpW/svba+WkpNuDwnYYbtGkzIR9onweaaZ42Hjd4v
 7+6DtESjx18TSxlVMjfOZTOLmVoXhIFnHLJx/ZuAg0EjP7ntcN5y53Ydpo+wlR3McVro
 P/X2vkBxkiaF5hh8rtBC9Y3IHL9TJQU9hmFMqtuN/6D9K20cct8ZF1rNphEDE4665jhl
 j72tS2nlAV7F8v5YLxysiYVfhqU1R1I/qPp3EaMXTsfzZ3rfbLk0QJO1ozCXzn3jkiUu FA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2t7809rsyd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:53 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNvFfg108897;
	Fri, 21 Jun 2019 23:57:52 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2t77ypetb6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:57:52 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNvq84109606;
	Fri, 21 Jun 2019 23:57:52 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2t77ypetb3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:57:52 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5LNvocq020839;
	Fri, 21 Jun 2019 23:57:50 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:57:49 -0700
Subject: [PATCH 7/7] vfs: don't allow writes to swap files
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
Date: Fri, 21 Jun 2019 16:57:46 -0700
Message-ID: <156116146628.1664939.13724544486987830540.stgit@magnolia>
In-Reply-To: <156116141046.1664939.11424021489724835645.stgit@magnolia>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=969 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
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
 fs/attr.c     |    3 +++
 mm/filemap.c  |    3 +++
 mm/memory.c   |    4 +++-
 mm/mmap.c     |    2 ++
 mm/swapfile.c |   15 +++++++++++++--
 5 files changed, 24 insertions(+), 3 deletions(-)


diff --git a/fs/attr.c b/fs/attr.c
index 1fcfdcc5b367..42f4d4fb0631 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -236,6 +236,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
 	if (IS_IMMUTABLE(inode))
 		return -EPERM;
 
+	if (IS_SWAPFILE(inode))
+		return -ETXTBSY;
+
 	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
 	    IS_APPEND(inode))
 		return -EPERM;
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
index 4311cfdade90..c04c6a689995 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2235,7 +2235,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 
 	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 
-	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
+	if (vmf->vma->vm_file &&
+	    (IS_IMMUTABLE(file_inode(vmf->vma->vm_file)) ||
+	     IS_SWAPFILE(file_inode(vmf->vma->vm_file))))
 		return VM_FAULT_SIGBUS;
 
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
diff --git a/mm/mmap.c b/mm/mmap.c
index ac1e32205237..031807339869 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1488,6 +1488,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 					return -EACCES;
 				if (IS_IMMUTABLE(file_inode(file)))
 					return -EPERM;
+				if (IS_SWAPFILE(file_inode(file)))
+					return -ETXTBSY;
 			}
 
 			/*
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 596ac98051c5..390859785558 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3165,6 +3165,19 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (error)
 		goto bad_swap;
 
+	/*
+	 * Flush any pending IO and dirty mappings before we start using this
+	 * swap file.
+	 */
+	if (S_ISREG(inode->i_mode)) {
+		inode->i_flags |= S_SWAPFILE;
+		error = inode_flush_data(inode);
+		if (error) {
+			inode->i_flags &= ~S_SWAPFILE;
+			goto bad_swap;
+		}
+	}
+
 	mutex_lock(&swapon_mutex);
 	prio = -1;
 	if (swap_flags & SWAP_FLAG_PREFER)
@@ -3185,8 +3198,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
 
-	if (S_ISREG(inode->i_mode))
-		inode->i_flags |= S_SWAPFILE;
 	error = 0;
 	goto out;
 bad_swap:

