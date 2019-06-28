Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79141C5B57C
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38BCB2083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W7BT12TU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38BCB2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 535F58E0009; Fri, 28 Jun 2019 14:35:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BB738E0002; Fri, 28 Jun 2019 14:35:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E54F8E0009; Fri, 28 Jun 2019 14:35:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f78.google.com (mail-io1-f78.google.com [209.85.166.78])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF5B8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:28 -0400 (EDT)
Received: by mail-io1-f78.google.com with SMTP id y5so7564348ioj.10
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=o7DgJUcGo9xVHV7BN6dTCgC24ypKZRenCunIj09I43o=;
        b=rBT7o02XSsg/al2tsP53Cz6ge+ep9N+zgtJggKctiEPV180dtgtee1klLnSXMgo8p2
         R841ukE463aHzloeu76vTjpcC8ZbYLFoBcjAzhE1ITXO7+vLVT3Dv/Z2zNztVf97AaBQ
         eCeWCPXvZ1rlQv3C7a31YQkUl2D80MXaVGYtlZx2SifpCD1mpbuxYkAZQzKzWNKNZ5Bs
         GdQfaOzm6hV8A3hOsFwRhhFUAfohxRhwHhKzSXo4eBRQEJmav32o/zbiuUvi97RLazPQ
         cZydjauNI91GAptOtgMvveRNcAa7C2McY0m/IrL4BluuDIlIKUIJOjYjgTEEoYI9BNvn
         Yo/g==
X-Gm-Message-State: APjAAAWs/An29OxvsiGbXBLMCcLxFaPDbD2qGhcYtsMMjBqeIDl3ePj3
	E7MZnzlhCFNaUzy/tZpKDdfudOZZqeaPPKNHxc6d589MWgNPwQPCrAkpq9EnWAc4ovHDG8Lsrmw
	j3VAjCrPEG38ckJcPjXPOV5wvPih6XRXha3HvfPSxssrw4r3Sqa1B0wlzg1eDpe+p/A==
X-Received: by 2002:a6b:3c0a:: with SMTP id k10mr8192701iob.271.1561746927844;
        Fri, 28 Jun 2019 11:35:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0mVNGMa4zTan4vcEAjeD1od1I3S649G2N1G5JpkJboU6XVnQL7AF3U2eW7Z5Cu069/I63
X-Received: by 2002:a6b:3c0a:: with SMTP id k10mr8192650iob.271.1561746927190;
        Fri, 28 Jun 2019 11:35:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746927; cv=none;
        d=google.com; s=arc-20160816;
        b=P3v7stI6QuFYNtRZJxKjAQ4UkHFOqTCcuCqOpPQucmUyDOHHa2gJL7K1bVDGywviH6
         m3a57KIGgOgSVOgX2/q1GTy0bx3E2JnDOgcsFiEXKt44EBr9cUI9aqayJJkQGu95r+AG
         /yNF4Qu4pQuWT2IlCR6YO+dtS1RE+EuaPTwm6RuJgqBcUxAZ//kbo6T/Gt1HWaNPXOEt
         AjGIgQwZY++fNuWRnL8yPyJ7RLx5rDFRUMKYpFjawnYkk363J+vogcpYzozT+U+0Y06K
         jlyZsyZ1/3tuYwjBbpI+KaU02Wa1iH7tTxe/xUCkct2LBkPR7lnPZH8mdkUKKUusBdAw
         h0Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=o7DgJUcGo9xVHV7BN6dTCgC24ypKZRenCunIj09I43o=;
        b=sGQwcPl8pKIGYiWh4eUsQQrO43PwT0aq3nrtkLP6FclCTDhSIyneKTSI2mY2IPUBD0
         hcayg6trj5E9Lgmkb3YLFG/puAq+sP3ro1MsGOs94z7QPKlbNw8x+yB5BUqgNQRWHMEm
         mLhIZJZIlze11NTQhxeLp9QbuqYaYI3J5JDTWEhB68Kj/Vz0DeY0QZkYKMSt8tB216rD
         DVhk32xcy9GkpkKRy8ScOs9X1Lb1n4sWwLOlHXlj1yfZW0zP/sYGmMroAXKuQh46YMJ8
         Oq+Rl3BdLyJzvXKfdL0zHatZ+FUVg82qPp0YgGuvOc70gFrI60dKElB6nlXbpGtvCuNB
         Tyeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W7BT12TU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m18si4635273jaa.95.2019.06.28.11.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=W7BT12TU;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYGGJ114587;
	Fri, 28 Jun 2019 18:35:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=o7DgJUcGo9xVHV7BN6dTCgC24ypKZRenCunIj09I43o=;
 b=W7BT12TUQkRJc9zRIeLhgn2TNRvJwTMiDY2FRc1JZiV7LY8SgJhVvHyo87i11W9DBPa0
 pdCDemTe0pkBz32X7/AXbMRQmMr+omDeTw82InHU3ID+hot/1bDViavs0AMQpu2xalrc
 /Mf0xks9kzi7JYAlYEHg/Hqdu98lhi5JaWG/YgM7H71rO7WVKKkOxQZ/7blOdeZgl/pr
 9FUAQNbeoiYEsIiEjutUGPEdZXAyInYOFdWCkcqe2teTVjDL3kR2iF0Xyo34VLK9uzF6
 2IvnN5yBkZH/gKUyJsWEo+UmyOPG6dvxFFdCOvc2rndw6PvnRWiSKpHisobdXsZiNLnJ MA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t9cyqxym1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:20 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYqFH152196;
	Fri, 28 Jun 2019 18:35:19 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2t9p6w238c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:19 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5SIZJNC027332;
	Fri, 28 Jun 2019 18:35:19 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:35:19 -0700
Subject: [PATCH 1/2] mm: set S_SWAPFILE on blockdev swap devices
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
        viro@zeniv.linux.org.uk, darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Fri, 28 Jun 2019 11:35:17 -0700
Message-ID: <156174691783.1557844.3238867236650883424.stgit@magnolia>
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

Set S_SWAPFILE on block device inodes so that they have the same
protections as a swap flie.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 mm/swapfile.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)


diff --git a/mm/swapfile.c b/mm/swapfile.c
index 596ac98051c5..fa4edd0cca3a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2284,9 +2284,8 @@ EXPORT_SYMBOL_GPL(add_swap_extent);
  * requirements, they are simply tossed out - we will never use those blocks
  * for swapping.
  *
- * For S_ISREG swapfiles we set S_SWAPFILE across the life of the swapon.  This
- * prevents root from shooting her foot off by ftruncating an in-use swapfile,
- * which will scribble on the fs.
+ * For all swap devices we set S_SWAPFILE across the life of the swapon.  This
+ * prevents users from writing to the swap device, which will corrupt memory.
  *
  * The amount of disk space which a single swap extent represents varies.
  * Typically it is in the 1-4 megabyte range.  So we can have hundreds of
@@ -2551,13 +2550,14 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
+
 		set_blocksize(bdev, old_block_size);
 		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
-	} else {
-		inode_lock(inode);
-		inode->i_flags &= ~S_SWAPFILE;
-		inode_unlock(inode);
 	}
+
+	inode_lock(inode);
+	inode->i_flags &= ~S_SWAPFILE;
+	inode_unlock(inode);
 	filp_close(swap_file, NULL);
 
 	/*
@@ -2780,11 +2780,11 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 		p->flags |= SWP_BLKDEV;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
-		inode_lock(inode);
-		if (IS_SWAPFILE(inode))
-			return -EBUSY;
-	} else
-		return -EINVAL;
+	}
+
+	inode_lock(inode);
+	if (IS_SWAPFILE(inode))
+		return -EBUSY;
 
 	return 0;
 }
@@ -3185,8 +3185,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
 
-	if (S_ISREG(inode->i_mode))
-		inode->i_flags |= S_SWAPFILE;
+	inode->i_flags |= S_SWAPFILE;
 	error = 0;
 	goto out;
 bad_swap:
@@ -3208,7 +3207,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (inced_nr_rotate_swap)
 		atomic_dec(&nr_rotate_swap);
 	if (swap_file) {
-		if (inode && S_ISREG(inode->i_mode)) {
+		if (inode) {
 			inode_unlock(inode);
 			inode = NULL;
 		}
@@ -3221,7 +3220,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	if (name)
 		putname(name);
-	if (inode && S_ISREG(inode->i_mode))
+	if (inode)
 		inode_unlock(inode);
 	if (!error)
 		enable_swap_slots_cache();

