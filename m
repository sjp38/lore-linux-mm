Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14DBBC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3B5206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:05:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xFoILBd6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3B5206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C0566B027A; Wed, 17 Apr 2019 15:05:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66D986B027C; Wed, 17 Apr 2019 15:05:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53C436B027D; Wed, 17 Apr 2019 15:05:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 281346B027A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:05:24 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n13so23481984qtn.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:05:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=65zAMWNbUYxjRT2cZg/WO6PMiXob/jmyxtPBrDUR6D8=;
        b=GBO7FlNpAQj0JoCXTjY7sVV96U+2Yk2cWxzepmqEy/7aORSF3K2d1C5wDE9jBUtqSm
         oqjn0/IS7zqEBVe2Ah6BsRg9iEERv0FFvAiDEsf7ZG5rIR+AiMGOAqyLvyF/2msL++ed
         3lGs1RNpzPDN1X6f//RMxWU/z0v4hjpmjMoh9et5HY4/7N887+eTNnjj60NhAh0yEzO7
         MelH1TtgfjhzOjPXP3HJn46/ZLpL8CtqzJxKzHkfPCgQmCaAFtnLfYEqC9dP3KqyqmgA
         ayQ5Q79ARAcKz2oP4nODNl/3k/sqNfRAnRYM7y/7JNYzMhl/K0Hosys46fQbot/rOwlk
         Rxyw==
X-Gm-Message-State: APjAAAUCsPdUsrrmWZXE48F0ya0T6gQBa8knEYgUtZKdtOZq2/Yw1kFF
	iczuRPCszm/s0DBDfk9EFl4GENvATBxi4q933R5prf1bW2M34azympxZR6RyCqfA3m/gIs2/3P4
	01V78VH7Xb5dT7zz/wDGQ6wPoqUEJnkoRBqEsUCRITSFAhGnxhKzp0rrMHTO1EywduQ==
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr71250719qve.19.1555527923926;
        Wed, 17 Apr 2019 12:05:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz74inPMFdPbQZArRYMr9tDuPkPrPGxdjZ6aPZ50NVb+hH0g8VUbhJuZN3UEBHLR5rNixYB
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr71250669qve.19.1555527923167;
        Wed, 17 Apr 2019 12:05:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527923; cv=none;
        d=google.com; s=arc-20160816;
        b=FJwB+hKvo96bCXvKvqzN/I7l0uO1QoBHJNkk3wK2nXkS1yxpSCTUtn4AU98xmJlk81
         Y9Kq+kVzbRZQ5gJeYspLYCJbs+vwZlG3IHpo3Dj0Ro461/3I1jsF3TgMuYppi+CXRo0c
         V+qvT0avQSIOETP81dNBTGtUn+o6uiFZ3ue7csaAwz9k2g8pIlc0UQL2p+V6a2zTGFKv
         UAe2yTu7iPFoMEHN8BWrqbXhjF9cH/nB2Taz6o87z/5znX4l8SVV/66HdqC21KIvKnRj
         OdgAcpyh1qsABAb36qPhdfgHBFgnJE+rOj/uXCODrNwUohaUHS6nw0Fy54SYGpGKHmmY
         5Yyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=65zAMWNbUYxjRT2cZg/WO6PMiXob/jmyxtPBrDUR6D8=;
        b=H9ISOKoyJyFHGOjU3jJ2MWgkZiGyX3T3wSB3z1/fjQsPV/ZUrsOoVrEpM+CW8BbweB
         mW+ufr1OcpN6hgiZU045XnI8d1zjMzR9ML4KQoi4iiD8x0/tKc823Ue3fnlfwdFwtdHC
         VS0lEDT89aWMd9pYu0fbe/kPxfS+hwMxXGsIDgvahXq88ah/JAESsAExITlGN0SJIQ3E
         vcSJ0TcKL0nQuQS7l95io/xTPMrFoOZMltUxuWEzIBAwZPl651X2qSgMuKqQwxUNf311
         CKb04bKAOiG+mixgMDaEpgRY/agKOg4FsimjT/SfNoSdeu+Xupuz8IsAOkag5YpiqHau
         Vhmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xFoILBd6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j8si237336qtc.390.2019.04.17.12.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:05:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xFoILBd6;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HIwfwM174822;
	Wed, 17 Apr 2019 19:05:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=65zAMWNbUYxjRT2cZg/WO6PMiXob/jmyxtPBrDUR6D8=;
 b=xFoILBd6NJ8C+0ltAFOAks1eAAGn4Z8ljn3Winqydz1TrtFh38bVmClNJLmGhYB5fJRC
 KANcJQgTNRiUXYWEuMtIGB4hJPugi21DMaQScUDNdi1JQ99C7DmxSSi+zEOmSBPv4gMw
 fvgR/O2lnjyXZEVXlQV39S5ETSVmFeqb2Entnoz8vg97kuVT05NPUK/Gow5qH+GivmV5
 vAfEdhGuvKnd86bjckJTngZuHzRNhYElmcelQfzRsLE2rsciSUjxYnfOYTwnpSspqRg5
 eQ27/2Fpswz7PFNMSOWvDP5d/NtjfAuQFY8A4X5XtsFVYsK2TkoYSDoUag4l5sq0m3W4 ew== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2ru59dcx5k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:22 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3HJ53Sh087410;
	Wed, 17 Apr 2019 19:05:21 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2ru4vtyy2g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Apr 2019 19:05:21 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3HJ5KBK020437;
	Wed, 17 Apr 2019 19:05:20 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 17 Apr 2019 12:05:20 -0700
Subject: [PATCH 8/8] ext4: don't allow any modifications to an immutable file
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 17 Apr 2019 12:05:19 -0700
Message-ID: <155552791984.20411.6785112966155823848.stgit@magnolia>
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=594
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904170125
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9230 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=618 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904170125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

Don't allow any modifications to a file that's marked immutable, which
means that we have to flush all the writable pages to make the readonly
and we have to check the setattr/setflags parameters more closely.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ext4/ioctl.c |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)


diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index bab3da4f1e0d..abf3b88d5af7 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -269,6 +269,29 @@ static int uuid_is_zero(__u8 u[16])
 }
 #endif
 
+/*
+ * If immutable is set and we are not clearing it, we're not allowed to change
+ * anything else in the inode.  Don't error out if we're only trying to set
+ * immutable on an immutable file.
+ */
+static int ext4_ioctl_check_immutable(struct inode *inode, __u32 new_projid,
+				      unsigned int flags)
+{
+	struct ext4_inode_info *ei = EXT4_I(inode);
+	unsigned int oldflags = ei->i_flags;
+
+	if (!(oldflags & EXT4_IMMUTABLE_FL) || !(flags & EXT4_IMMUTABLE_FL))
+		return 0;
+
+	if ((oldflags & ~EXT4_IMMUTABLE_FL) != (flags & ~EXT4_IMMUTABLE_FL))
+		return -EPERM;
+	if (ext4_has_feature_project(inode->i_sb) &&
+	    __kprojid_val(ei->i_projid) != new_projid)
+		return -EPERM;
+
+	return 0;
+}
+
 static int ext4_ioctl_setflags(struct inode *inode,
 			       unsigned int flags)
 {
@@ -322,6 +345,20 @@ static int ext4_ioctl_setflags(struct inode *inode,
 			goto flags_out;
 	}
 
+	/*
+	 * Wait for all pending directio and then flush all the dirty pages
+	 * for this file.  The flush marks all the pages readonly, so any
+	 * subsequent attempt to write to the file (particularly mmap pages)
+	 * will come through the filesystem and fail.
+	 */
+	if (S_ISREG(inode->i_mode) && !IS_IMMUTABLE(inode) &&
+	    (flags & EXT4_IMMUTABLE_FL)) {
+		inode_dio_wait(inode);
+		err = filemap_write_and_wait(inode->i_mapping);
+		if (err)
+			goto flags_out;
+	}
+
 	handle = ext4_journal_start(inode, EXT4_HT_INODE, 1);
 	if (IS_ERR(handle)) {
 		err = PTR_ERR(handle);
@@ -751,7 +788,11 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			return err;
 
 		inode_lock(inode);
-		err = ext4_ioctl_setflags(inode, flags);
+		err = ext4_ioctl_check_immutable(inode,
+				from_kprojid(&init_user_ns, ei->i_projid),
+				flags);
+		if (!err)
+			err = ext4_ioctl_setflags(inode, flags);
 		inode_unlock(inode);
 		mnt_drop_write_file(filp);
 		return err;
@@ -1121,6 +1162,9 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			goto out;
 		flags = (ei->i_flags & ~EXT4_FL_XFLAG_VISIBLE) |
 			 (flags & EXT4_FL_XFLAG_VISIBLE);
+		err = ext4_ioctl_check_immutable(inode, fa.fsx_projid, flags);
+		if (err)
+			goto out;
 		err = ext4_ioctl_setflags(inode, flags);
 		if (err)
 			goto out;

