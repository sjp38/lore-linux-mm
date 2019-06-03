Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 472FDC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0960027DAC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0960027DAC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A19936B0008; Mon,  3 Jun 2019 09:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CADB6B000A; Mon,  3 Jun 2019 09:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77FD16B000C; Mon,  3 Jun 2019 09:22:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7326B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 09:22:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so27416726edd.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 06:22:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=aGgl0qNJ4aNC6jFuYzpg+dgXb3L81XRB01wW1xPaAvc=;
        b=NERpFKBw+9e/7e42VGJJNQw6R3H8Z04MNS8abccgCipquLG0ooIhc3w2IUi3rQW39c
         Xbt0OCK0oZlebmmUumdZGZE1leV+0dfbDfxOPwLQTPYX12P9MqtDJccsO51TN3C2qE8K
         oA5prDZFmNLN/tyUY5pEuGsbMVkxtUQ8ATG7JTSB4xJrwCLajFY2yLag4euTlf9jLizB
         K8TGTtpud/j7Biel+Q8kIFhVIRKhW0Ymv26pbCwxzvRjRFuRN169wyRxVM4+SHJfIyT8
         r243yqX/RW5tH3zuemkQpCXempQIt0zIDaMQPSgb/hF0wnsrayCvfZC6GUmqz/2LyQXR
         QV/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAW0FbZ8COSCaZNdXpBkEjN6R93TBLp9P52VNRDtivXI4uANbY6V
	fzDleGP+mZwPrIN3da5tvr8R6RQ/xTDcBGFbM9T0uEY8EMX7uYEUfNShfnT7aSiatQUflk3WfnD
	QzWQDONq5AdyVIHag7uHCef0mGzwrZqC4+8e11jM6jG6RRIdhS0PFD8Ps/9LhK0Ry0g==
X-Received: by 2002:a50:908a:: with SMTP id c10mr28142669eda.226.1559568125668;
        Mon, 03 Jun 2019 06:22:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZ1i26flQwuhfMuCvZJcFGC1VMPNaIrvZ5E15VDvj7xWCm5dw99kZ04g/eaCUohsK53GNl
X-Received: by 2002:a50:908a:: with SMTP id c10mr28142479eda.226.1559568123606;
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559568123; cv=none;
        d=google.com; s=arc-20160816;
        b=u35H8kYzLjrN/WMyy/5Uw7ryyjmgdel7E9HhZR1pfC9PWrmWPMKCTO/jYn4UgJUoxP
         hdU48l8iLNfxMF9WGzKLRtDUtem6JO09NINJ1vJXK5FSzoGRvo2dNHJPcsBjMpULMMs+
         u1i7zU8uaGtCC0mqgZLXMVBv8SksgqClawQOiKAiOXQ3LtYaMtOondqTyBOY8lzYTDB9
         22jPqIm7AseFRo7BL5G3DE2TrJgC9sig9yW8PYlKiCOshw6NVpj/5hf8lzO5i8lTVQv6
         FMc+ii1pwQzuyera4TrqYOlrbfE7t6BWVlDBupbrsdYgHGVbdcB3td6Sa0m0XsgYr9N/
         ZVEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=aGgl0qNJ4aNC6jFuYzpg+dgXb3L81XRB01wW1xPaAvc=;
        b=CmmNQPDGDuoZ+LOmo+fK8+FjJchlZsoIRsdc6t5epNjmTFkkIKKdYHNKiuo25JE790
         SWlbGu7B3mybW9cWMSfHNFVLGRYTRqUYyQ60lmgXWUV14kpDwBBDQCsQ1r47268egUUQ
         gDAPigBZQi8xGQ3RVXPwQdF6QvGrqXSQdN6XO1wpd+mZe/+i8YZ74Pti8oj1Ek6SISnm
         0CQXafG8sLAFFbbsizfXJK2lQiDIxcbeEb35QFObHexLihxW0Z/nfl6L4oj5bw/pXeog
         fXMMwZN4XokFXKlNryaJTXSfta5S1fktyNfupzowkqdT2Hz+NrmhkhH6xBGnLg4rkv2m
         HwAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14si4207185ejv.124.2019.06.03.06.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 04D2BAD31;
	Mon,  3 Jun 2019 13:22:03 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 50CEE1E3C9A; Mon,  3 Jun 2019 15:22:00 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-ext4@vger.kernel.org>
Cc: Ted Tso <tytso@mit.edu>,
	<linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 2/2] ext4: Fix stale data exposure when read races with hole punch
Date: Mon,  3 Jun 2019 15:21:55 +0200
Message-Id: <20190603132155.20600-3-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190603132155.20600-1-jack@suse.cz>
References: <20190603132155.20600-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hole puching currently evicts pages from page cache and then goes on to
remove blocks from the inode. This happens under both i_mmap_sem and
i_rwsem held exclusively which provides appropriate serialization with
racing page faults. However there is currently nothing that prevents
ordinary read(2) from racing with the hole punch and instantiating page
cache page after hole punching has evicted page cache but before it has
removed blocks from the inode. This page cache page will be mapping soon
to be freed block and that can lead to returning stale data to userspace
or even filesystem corruption.

Fix the problem by protecting reads as well as readahead requests with
i_mmap_sem.

CC: stable@vger.kernel.org
Reported-by: Amir Goldstein <amir73il@gmail.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 2c5baa5e8291..a21fa9f8fb5d 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -34,6 +34,17 @@
 #include "xattr.h"
 #include "acl.h"
 
+static ssize_t ext4_file_buffered_read(struct kiocb *iocb, struct iov_iter *to)
+{
+	ssize_t ret;
+	struct inode *inode = file_inode(iocb->ki_filp);
+
+	down_read(&EXT4_I(inode)->i_mmap_sem);
+	ret = generic_file_read_iter(iocb, to);
+	up_read(&EXT4_I(inode)->i_mmap_sem);
+	return ret;
+}
+
 #ifdef CONFIG_FS_DAX
 static ssize_t ext4_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
@@ -52,7 +63,7 @@ static ssize_t ext4_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (!IS_DAX(inode)) {
 		inode_unlock_shared(inode);
 		/* Fallback to buffered IO in case we cannot support DAX */
-		return generic_file_read_iter(iocb, to);
+		return ext4_file_buffered_read(iocb, to);
 	}
 	ret = dax_iomap_rw(iocb, to, &ext4_iomap_ops);
 	inode_unlock_shared(inode);
@@ -64,17 +75,32 @@ static ssize_t ext4_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
 
 static ssize_t ext4_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
-	if (unlikely(ext4_forced_shutdown(EXT4_SB(file_inode(iocb->ki_filp)->i_sb))))
+	struct inode *inode = file_inode(iocb->ki_filp);
+
+	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb))))
 		return -EIO;
 
 	if (!iov_iter_count(to))
 		return 0; /* skip atime */
 
 #ifdef CONFIG_FS_DAX
-	if (IS_DAX(file_inode(iocb->ki_filp)))
+	if (IS_DAX(inode))
 		return ext4_dax_read_iter(iocb, to);
 #endif
-	return generic_file_read_iter(iocb, to);
+	if (iocb->ki_flags & IOCB_DIRECT)
+		return generic_file_read_iter(iocb, to);
+	return ext4_file_buffered_read(iocb, to);
+}
+
+static int ext4_readahead(struct file *filp, loff_t start, loff_t end)
+{
+	struct inode *inode = file_inode(filp);
+	int ret;
+
+	down_read(&EXT4_I(inode)->i_mmap_sem);
+	ret = generic_readahead(filp, start, end);
+	up_read(&EXT4_I(inode)->i_mmap_sem);
+	return ret;
 }
 
 /*
@@ -518,6 +544,7 @@ const struct file_operations ext4_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= ext4_fallocate,
+	.readahead	= ext4_readahead,
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-- 
2.16.4

