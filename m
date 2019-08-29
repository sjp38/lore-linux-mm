Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A450C3A5A7
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47AEA20828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47AEA20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFD3E6B0006; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A86B16B000C; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99C266B000D; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0032.hostedemail.com [216.40.44.32])
	by kanga.kvack.org (Postfix) with ESMTP id 7514B6B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0DBD3759A
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:42 +0000 (UTC)
X-FDA: 75875499924.08.honey48_232e4b2214617
X-HE-Tag: honey48_232e4b2214617
X-Filterd-Recvd-Size: 2601
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 50966B03D;
	Thu, 29 Aug 2019 13:10:40 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id BFDA81E43A8; Thu, 29 Aug 2019 15:10:39 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-xfs@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	Amir Goldstein <amir73il@gmail.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	<linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 2/3] fs: Export generic_fadvise()
Date: Thu, 29 Aug 2019 15:10:33 +0200
Message-Id: <20190829131034.10563-3-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190829131034.10563-1-jack@suse.cz>
References: <20190829131034.10563-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Filesystems will need to call this function from their fadvise handlers.

CC: stable@vger.kernel.org
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/fs.h | 2 ++
 mm/fadvise.c       | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 997a530ff4e9..bc1b40fb0db7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3531,6 +3531,8 @@ extern void inode_nohighmem(struct inode *inode);
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


