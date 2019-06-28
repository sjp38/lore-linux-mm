Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 651C6C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EB0120828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jRRaM6/c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EB0120828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B981D8E0006; Fri, 28 Jun 2019 14:35:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B48408E0002; Fri, 28 Jun 2019 14:35:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E93E8E0006; Fri, 28 Jun 2019 14:35:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f78.google.com (mail-io1-f78.google.com [209.85.166.78])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD108E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:11 -0400 (EDT)
Received: by mail-io1-f78.google.com with SMTP id p12so7542263iog.19
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=hDvAuKrMfSUW7AbzqNfZSt/8R1aeCpTe5TGF8T8lRYc=;
        b=gu/TYDEVY7f9691KVIfakI4+UQqtH9ceiY9HV1SE3TFDFIT9DfNl+ejN5kQAPHrt0E
         MJXbT6WvQtcDT2BD/egBbcvVsx9GGQcGiwLNyo5ZWmsKuO7vWSmTocb+AIlUPXWnTgPe
         PO7Dm22w3BkXa+Tmp/OHEMbTjMtuplUftLou/qAt34bs6Os6a7TwAb57dEcPJ8271rGT
         9WKan3Vw3t6Uw6U0QcUD2pczWsROfz5FTi+4VnPOCkJcYxmw1MUoi0GqkbGJSeubPWMn
         7SygR/jHURjT0SXLKvCWD76JSBBKXcbjY9J+DM2kqc14HAAaC02BwxgTy4eqOigjRA2y
         jTPw==
X-Gm-Message-State: APjAAAVAeAKThwc5ul5GSPkgHtmax5CDNiPKe8TwBIeTTj3n5VaFbqGK
	QE9URuq6kA5FLrdZF0uqoGYwYNY9W8kvQvvvYubQoxfZxchKDajZiE8S5iK1/s8XQWLTVYTpUhm
	zsjmndHuwi32e5crzNatF9VdimawhxPncue7iB3MCDubojxASXY0rBoFocAlsfs7ijA==
X-Received: by 2002:a5d:9a04:: with SMTP id s4mr12961841iol.19.1561746911241;
        Fri, 28 Jun 2019 11:35:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvvoko8UBVj3EYWOqlgeuRa5/DEKTcjwKQHDgO7loL+UxEDkXa7b8wefEWJuuTr7df35x4
X-Received: by 2002:a5d:9a04:: with SMTP id s4mr12961748iol.19.1561746910262;
        Fri, 28 Jun 2019 11:35:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746910; cv=none;
        d=google.com; s=arc-20160816;
        b=dHWIS5PrYN//04VDLBtGsVLvcXj6vo2UQcUPDBGW+Q95q5HsbZqUmgYV7kwlXzp4AG
         W+vhx8Rw1fSJOPd1kfutaR2UeLSiNUyUZplxCd30aYKOPELvIA05w9ligtSbFkNehhQf
         ocizaoRZaI1w/1ojwhFK0WYuKVIU+CizQOG6rRqlk1+/T0MpQ9NhaBdCXD2eCZ96SZxC
         NOVWOzLTh7nYULkXdf6aSYIf+ZE7se0mjcrKR0T8hIVN1Ue2seeycEGaa8k55hzevD4I
         xwPH8AX+B8CR4fNiU79Q1UN+I6nY+MrTa8P/YgW0Al52DYGdIFV/3YC3z0Aqm561FUt3
         UQ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=hDvAuKrMfSUW7AbzqNfZSt/8R1aeCpTe5TGF8T8lRYc=;
        b=w7ygu7cvtOAqPXebt4xOsthpLTkCCaNU0YulHUA2jw3HEeFQAas7c8PF2zSimGf+4L
         bliZw9e8+hCHm3y5yY6R+bwAZ35gQA1Ix46D7JgRBFg98BzfVOHjyoEkJYZ4T7190fWX
         S/DoLCmw8TDeA31tF4sojrdwapxLnWMIr/faIJuQzYiP0omys1/EkEt4w6frNa/F/x0D
         Ahi99hEvxAMvU/8qYlYWarLFyuzYHg1CaIf74UpAZMRPbs/EcuMFWuh6l/SgVDdRFWSy
         qgCt9092DNcguR/59gy5Ezh+q+9dd55FiQkWf7QhMl9RYAnMwAs6K4D1B4Hewo2KjemR
         SL5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="jRRaM6/c";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c3si4445014ioq.99.2019.06.28.11.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="jRRaM6/c";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYQRG108883;
	Fri, 28 Jun 2019 18:34:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=hDvAuKrMfSUW7AbzqNfZSt/8R1aeCpTe5TGF8T8lRYc=;
 b=jRRaM6/cr2s1fN3nJa8yFGdPIm650NetSXoqzer/0L2yCpma7vUORBQ7mNoB6zegt3yV
 2WaPx92M+xx36rc1eyqskvJFn7teZ2EjeHlgbNGpAU6lHKWmerm/E2KLpNPo+wGArDa1
 K8c2RTjP5b+vZvA0NI05COGDHcOesafa6zvfR7n2l6a4vNBTxFEAFBe9kju/lSpjuOFA
 sfZS2IZRGf2rVNN8QJ4XjaPhFu7Dg9WBD5nM9iuWr+1Q8xXsS4BvM2zQ5vYY9tZSIFZD
 S1ts7ni4Y8CuHWQnPN6AP834iFHazwJqlHUIP93kvyf0vy/iHyKGjVX9sQiIRpp9eMnJ xw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2t9brtq3hf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:57 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIXXPt000897;
	Fri, 28 Jun 2019 18:34:56 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by userp3020.oracle.com with ESMTP id 2tat7e3gab-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 28 Jun 2019 18:34:56 +0000
Received: from userp3020.oracle.com (userp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5SIYuM8003117;
	Fri, 28 Jun 2019 18:34:56 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2tat7e3ga7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:34:56 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5SIYsCq029052;
	Fri, 28 Jun 2019 18:34:54 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:34:54 -0700
Subject: [PATCH 2/4] vfs: flush and wait for io when setting the immutable
 flag via SETFLAGS
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
        adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
        dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Fri, 28 Jun 2019 11:34:51 -0700
Message-ID: <156174689192.1557469.17945809794748607270.stgit@magnolia>
In-Reply-To: <156174687561.1557469.7505651950825460767.stgit@magnolia>
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=753 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Darrick J. Wong <darrick.wong@oracle.com>

When we're using FS_IOC_SETFLAGS to set the immutable flag on a file, we
need to ensure that userspace can't continue to write the file after the
file becomes immutable.  To make that happen, we have to flush all the
dirty pagecache pages to disk to ensure that we can fail a page fault on
a mmap'd region, wait for pending directio to complete, and hope the
caller locked out any new writes by holding the inode lock.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/inode.c         |   21 +++++++++++++++++++--
 include/linux/fs.h |   11 +++++++++++
 2 files changed, 30 insertions(+), 2 deletions(-)


diff --git a/fs/inode.c b/fs/inode.c
index f08711b34341..65a412af3ffb 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2193,7 +2193,8 @@ EXPORT_SYMBOL(current_time);
 
 /*
  * Generic function to check FS_IOC_SETFLAGS values and reject any invalid
- * configurations.
+ * configurations.  Once we're done, prepare the inode for whatever changes
+ * are coming down the pipeline.
  *
  * Note: the caller should be holding i_mutex, or else be sure that they have
  * exclusive access to the inode structure.
@@ -2201,6 +2202,8 @@ EXPORT_SYMBOL(current_time);
 int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 			     unsigned int flags)
 {
+	int ret;
+
 	/*
 	 * The IMMUTABLE and APPEND_ONLY flags can only be changed by
 	 * the relevant capability.
@@ -2211,7 +2214,21 @@ int vfs_ioc_setflags_prepare(struct inode *inode, unsigned int oldflags,
 	    !capable(CAP_LINUX_IMMUTABLE))
 		return -EPERM;
 
-	return 0;
+	/*
+	 * Now that we're done checking the new flags, flush all pending IO and
+	 * dirty mappings before setting S_IMMUTABLE on an inode via
+	 * FS_IOC_SETFLAGS.  If the flush fails we'll clear the flag before
+	 * returning error.
+	 */
+	if (!S_ISREG(inode->i_mode) || IS_IMMUTABLE(inode) ||
+	    !(flags & FS_IMMUTABLE_FL))
+		return 0;
+
+	inode_set_flags(inode, S_IMMUTABLE, S_IMMUTABLE);
+	ret = inode_drain_writes(inode);
+	if (ret)
+		inode_set_flags(inode, 0, S_IMMUTABLE);
+	return ret;
 }
 EXPORT_SYMBOL(vfs_ioc_setflags_prepare);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 91482ab4556a..0efe749de577 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3567,4 +3567,15 @@ static inline void simple_fill_fsxattr(struct fsxattr *fa, __u32 xflags)
 	fa->fsx_xflags = xflags;
 }
 
+/*
+ * Flush file data before changing attributes.  Caller must hold any locks
+ * required to prevent further writes to this file until we're done setting
+ * flags.
+ */
+static inline int inode_drain_writes(struct inode *inode)
+{
+	inode_dio_wait(inode);
+	return filemap_write_and_wait(inode->i_mapping);
+}
+
 #endif /* _LINUX_FS_H */

