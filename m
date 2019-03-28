Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E934C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7E3A20823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:50:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="06/ipe6r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7E3A20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CECB6B0006; Thu, 28 Mar 2019 13:50:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 657186B0007; Thu, 28 Mar 2019 13:50:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5214D6B0008; Thu, 28 Mar 2019 13:50:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED6F6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:50:46 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y64so18281919qka.3
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:50:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
        b=in9TWE9QHZuSzBwaZkSvriL2WrsmgPwWIqNNIFl7uX0d1bJWtW6Ph0m8bftK+RUeFR
         OMpU1awT6fYuCJkhDavwsJ1gk2i8MuNosvBCKOn2rTmO0mA2F3CY7pJyHab0lqlDRgoZ
         H54jOR8Y3QVDKkifbcwz2KYAZ+n814213v67louilbOWlxqnnPD+vSDLesubQNyi0+yp
         2aFeag1FgzepcJaNlwgQGIHhiJUW0bDWan05Y+DwoKGpIUEo/jIYwEhVARg7CkwYeIew
         9+HYSATDczgPDyo82rIAPajPFvV7etua8S6ikMqmXXqwJojnRNRS28eIlZ7e126cEhPE
         ycNA==
X-Gm-Message-State: APjAAAVsQfTCFKRQYlSwVSfxB7p5VFlMYFinaj1HsuuJVxhT0r/VGSLO
	H4QUkGac61SNnVrot1+rVJKhx8WoKWoBphl9YMYwgoF7nsJKqYlztreXWc2UwTFLPbiwHywdx3h
	G8kikm4J/iwcpCPTogF452JgSHRb3TYRk6QFkM4aEjdPQidI+ZFYeBoBrer4nwbvkcg==
X-Received: by 2002:a37:6814:: with SMTP id d20mr36256619qkc.102.1553795445946;
        Thu, 28 Mar 2019 10:50:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2aH3V1w8We/TxTon3Ib/rVH2R82BT7vV67R86jBNO08ddt2NTCyLztouFD/eOLY8IGzGK
X-Received: by 2002:a37:6814:: with SMTP id d20mr36256560qkc.102.1553795445166;
        Thu, 28 Mar 2019 10:50:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553795445; cv=none;
        d=google.com; s=arc-20160816;
        b=tnFWkda4dgcvy0i7n+fFN8mNC7jgHF/fAp0U++6p5UAGq2y9/KA4LjfSuqNvih8X9O
         NrUgM4Bca9vbfZ9roD1vMlXXhs8+7wDdGV8MGFN2q4aBwS75rFVwJaWzhA10AuACM6BY
         WfZWhxX+e1BckquO1+5y/plEFgvszc5q3e1OdqxkCw9CwOq4U4lRjGZd42KOcxBrNmHT
         ITVlLfz1zPJ2jnb79KNu3AV7i0Zcz61EY1AP3NaQZ/0veHJFTanZuO9krcseUjb4Awew
         u7/8EI5+mHTfXupF31rszEB3hk9MM1o5LMPTQR69OghITLIMo6XxY0vM02dYw4OozJRI
         3GRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
        b=co+/1vJ33lKkdRRn2APdTgoer5ssWgNQkNhuvRXuStXX2JS+kXQQSsPDlCL9j2gZXv
         EfCdX8QNJo8LV4fBrVAeuyO9+OkzcSNPTIXblcr5di4qlgGshMJBxudejz9JuDDYndOZ
         EQohw1PDr3VwckpuULZdjk912l9y5qSDJDWXDvK0OVH1D4C06t+qsZXnhbLkT164NQWZ
         mHeJR61YdW3A7AQ1X0aZwBh9xFvCvrmJSbRi+GrgrWHyLZUvXTgahCpWpOSQAB6qhDoD
         zdA3tVmChr4t5026DFRMqCO2PLfF9uc1dajZ7ZYY6QYL9/wNm/Syl4yFbhN7Lp/XkkoP
         PATg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="06/ipe6r";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y199si427934qka.267.2019.03.28.10.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 10:50:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="06/ipe6r";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SHnInj049215;
	Thu, 28 Mar 2019 17:50:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9mq463y6Fy+tnAy6EAF3waabQKAMjMyUGNNPLiFAWs8=;
 b=06/ipe6rPVPCmRT+ZDZ1UYm6lTddupzdsLbZKnyxxACsXOMVgVpbAqwVHWoOXiMGJm5K
 TBtsCl8fw8vRWdtMYTIo5Ooi8xDSsY6rl2/11GAH3q58pYxhznYZN1Vzz53wxcUBWCsL
 0Q6+TB/he1b1fT2DL6djhk+Vj9AMCZn0fOqrtUCSt/NPENvnctzuHqpvfDrZRPddQs5o
 xP0dQlC2+i9gGmAoaOIwLHDB/XBtppbrHEjAu392Q7PuTER+K/ULqEmy3Bu6yak6Flnc
 9SaA/mRSn3v2ZIb484gddpklZUrBJDrbh1w6dHOugyZ6V9TlDIBf7LFnW8GoZk9OolD0 oQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2re6g187wm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:43 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHogvP030296
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:50:43 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2SHogTt009429;
	Thu, 28 Mar 2019 17:50:42 GMT
Received: from localhost (/10.159.234.216)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 10:50:42 -0700
Subject: [PATCH 1/3] mm/fs: don't allow writes to immutable files
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Thu, 28 Mar 2019 10:50:40 -0700
Message-ID: <155379544071.24796.11489520877297987568.stgit@magnolia>
In-Reply-To: <155379543409.24796.5783716624820175068.stgit@magnolia>
References: <155379543409.24796.5783716624820175068.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=240 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280117
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

