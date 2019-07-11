Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E7FAC74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D518F20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D518F20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB738E00BE; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B79628E0032; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85DD88E00BF; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 323FD8E00BE
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:00:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so4766373ede.0
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=1pb0fF7x3AUZ7sT3Hdxp01Lg2ofbqblakH9rhiFJp7c=;
        b=YCaoMrxIHSNRM7NzRbhZKKkKDG80ULnVD883khaPgBW9Vl2tXeBlNxLJ4I7Xjtvf7a
         obuuorMzimLyEJTte2+wHLDLZSCIFPmYVXMbCAuD+uRCG5UvpdrKV0ZxcrhNdExVU1Bt
         R5iVQe45sYjA2H5EXHo35KTVzmNTswFT6UcFh8++dSFTso6XajQXtLGh9dxphr/0CaEP
         s2bWb1wQnck6Q9wWuQSVuNVuzVeXI6a/EOVUdNrJx+k/OTnvC9sbSR44RuWJ+CsrYEUM
         H2MWktxOe+vJzKWIoahfqOcSgCLMIntVYykVbHjn9T++EmOi1XTHrYcleOrdCdEnwXq4
         K7+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVFFWLsgH2p1ApULaX5X9e4kUASUbjZotpx7FWTgpN268x1JgDM
	2vayTBmw58PENjEv0M7yF2G/D/QfWzJ302gLaggoF8wHwbeFO5woPn+J9spvEW4+yBXf/M/tdsl
	7LNMpbfrGJDA3AdLH/NCvM1QGwGdRPrfuWM4nRMWT8P8ztu3Myd4Ha2eli6puQg9dzA==
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr3210041ejd.99.1562853618777;
        Thu, 11 Jul 2019 07:00:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYGl7UEME7iSR0ZEiv3KrxBIROxo3pXaQRg6FVYOYzeZPEtj4K5oKuvrDJG+CwKWWSk/XH
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr3209924ejd.99.1562853617668;
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562853617; cv=none;
        d=google.com; s=arc-20160816;
        b=bl50RqOlA9Ex4GCaeEBHipwPvFvJTVk2DvWGYmUQXE4sUjlgaEpKp0/9Y4NDCDrANU
         V+zq0A8HaEybgoNkcoXja/jjGKGfIhj8h2MtUs1qIQ8/xCTDfzLeaytAhuNrpKgeVkFh
         RYe/DbUjEqcN4V0EvXL/iDsYztsHGYEUtu2l6rqmzW7rD2pUszJ2W261RKF0EvpHAORJ
         ZjX+BEj/gauCy3Sp2eJ/hgSBCL7v/HEZbFGYBDuqXumYiyx/gYfmno7gOOz2n8lU3qQU
         L0Q3L54Cllh7xkx2Y+ejjmBz2I+bYirEgI3VNC7GkAvej7zBYAOqol78fXKYIV0lYusr
         y7cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=1pb0fF7x3AUZ7sT3Hdxp01Lg2ofbqblakH9rhiFJp7c=;
        b=MyI8Zqj19mw86THMQlq5bgRjxeYrZnTATpCBUYEOi6CeNTOD7MYBIX82bIAGUdKa+U
         KNuFCuyMvN8z1Oc3cbVicbWO8rr/SQw1+CCrW10JiMYIFRXJ+XQkXr4s4QcuYL3mA9FX
         rmjWHjnOd224hTcugEVzBWK0pfDi0zXNDn1f6bQQE4dnySfEC1CbCGbVUgiljJfFSfnz
         OVJsjNLWZlEzioF2S783TYW8oZU3I+pVstl3zrbuIIHX64NZ6oGein8kNN4mjUdZ6527
         UtfGO+Y/wll/jI2WQ9PhHcN4wICCtrKp3W3GjnCDjb+Kq92OH8cv9v7SYYXEDav5F0NM
         P4wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e27si3607877edd.353.2019.07.11.07.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F330AAF1B;
	Thu, 11 Jul 2019 14:00:16 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 291371E43CC; Thu, 11 Jul 2019 16:00:16 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	<linux-xfs@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 2/3] fs: Export generic_fadvise()
Date: Thu, 11 Jul 2019 16:00:11 +0200
Message-Id: <20190711140012.1671-3-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190711140012.1671-1-jack@suse.cz>
References: <20190711140012.1671-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Filesystems will need to call this function from their fadvise handlers.

CC: stable@vger.kernel.org # Needed by "xfs: Fix stale data exposure when
					readahead races with hole punch"
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h | 2 ++
 mm/fadvise.c       | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d..2666862ff00d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3536,6 +3536,8 @@ extern void inode_nohighmem(struct inode *inode);
 /* mm/fadvise.c */
 extern int vfs_fadvise(struct file *file, loff_t offset, loff_t len,
 		       int advice);
+extern int generic_fadvise(struct file *file, loff_t offset, loff_t len,
+			   int advice);
 
 #if defined(CONFIG_IO_URING)
 extern struct sock *io_uring_get_socket(struct file *file);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 467bcd032037..4f17c83db575 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -27,8 +27,7 @@
  * deactivate the pages and clear PG_Referenced.
  */
 
-static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
-			   int advice)
+int generic_fadvise(struct file *file, loff_t offset, loff_t len, int advice)
 {
 	struct inode *inode;
 	struct address_space *mapping;
@@ -178,6 +177,7 @@ static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(generic_fadvise);
 
 int vfs_fadvise(struct file *file, loff_t offset, loff_t len, int advice)
 {
-- 
2.16.4

