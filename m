Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7ACAC3A5A9
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C79D20828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:10:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C79D20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED566B0269; Thu, 29 Aug 2019 09:10:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076026B0010; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2FFF6B0266; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id AC7026B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:10:42 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 53D28878D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:42 +0000 (UTC)
X-FDA: 75875499924.15.sign84_2334dfb67d862
X-HE-Tag: sign84_2334dfb67d862
X-Filterd-Recvd-Size: 3108
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:10:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4F857AFC3;
	Thu, 29 Aug 2019 13:10:40 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id BC3D11E2F9E; Thu, 29 Aug 2019 15:10:39 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-xfs@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	Amir Goldstein <amir73il@gmail.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	<linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
Date: Thu, 29 Aug 2019 15:10:32 +0200
Message-Id: <20190829131034.10563-2-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190829131034.10563-1-jack@suse.cz>
References: <20190829131034.10563-1-jack@suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently handling of MADV_WILLNEED hint calls directly into readahead
code. Handle it by calling vfs_fadvise() instead so that filesystem can
use its ->fadvise() callback to acquire necessary locks or otherwise
prepare for the request.

Suggested-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Boaz Harrosh <boazh@netapp.com>
CC: stable@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/madvise.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..bac973b9f2cc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -14,6 +14,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/hugetlb.h>
 #include <linux/falloc.h>
+#include <linux/fadvise.h>
 #include <linux/sched.h>
 #include <linux/ksm.h>
 #include <linux/fs.h>
@@ -275,6 +276,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	struct file *file = vma->vm_file;
+	loff_t offset;
 
 	*prev = vma;
 #ifdef CONFIG_SWAP
@@ -298,12 +300,20 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		return 0;
 	}
 
-	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	if (end > vma->vm_end)
-		end = vma->vm_end;
-	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-
-	force_page_cache_readahead(file->f_mapping, file, start, end - start);
+	/*
+	 * Filesystem's fadvise may need to take various locks.  We need to
+	 * explicitly grab a reference because the vma (and hence the
+	 * vma's reference to the file) can go away as soon as we drop
+	 * mmap_sem.
+	 */
+	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
+	get_file(file);
+	up_read(&current->mm->mmap_sem);
+	offset = (loff_t)(start - vma->vm_start)
+			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
+	vfs_fadvise(file, offset, end - start, POSIX_FADV_WILLNEED);
+	fput(file);
+	down_read(&current->mm->mmap_sem);
 	return 0;
 }
 
-- 
2.16.4


