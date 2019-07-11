Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34F68C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0777F20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:00:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0777F20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4D538E0032; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACFDA8E00C1; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ABC18E00BF; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 215AA8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:00:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c31so4761490ede.5
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vL2nsiM2ddjwtUcwsMFcppuOiio9MXKDv4ZgGyw46eE=;
        b=dpiW+va/yU69bLew7mnNr+rp2v7nnB5vUFA2TsmLe/f3/nQ2t9Srz1CRfV+j1aJ64l
         wyBsvUqXimO5NZZ7tM2DsVbnf9h4FE3xYEHfjAZ+yZDBQgfvQREoMBcWk4LVzMNoZxSo
         2zXlikuvqWIQCUSpc/kQQzGeZdWAV+eVCzx7kSadhRcuT9JVXqG5Mgxtrk1FV8waCJts
         XOPttFNuwQIYitlwt0sm9ncVVFgzc+r3I8nhJ8Fxq4CQ/L5kwFZgoWVKNk9f9ZAVOCxb
         X9/Httj7Fk5SZd1JZpByauT6dd5OZ9v6gP/IHkyRd2YNb0LT3aWkXh2JVLlF8EWXE0q4
         ODcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWjA0V7K+FjTmr+UmYa9mQ7naqDHbioAsODV6tsS9VtRBIpY0AQ
	q3LSEtQEO/ryEvTFMAwX7zZTN0vEcaGia+jHjjWeoNZJmttM/ILuhXlrw+1OjvNrTqRaH3h82T2
	GTNzZHRwNaj9VLobOwZHIVDhr5Hb+5MQwVr3lWfEEr2skq3zYSdP2vm6I62OOLYuaQw==
X-Received: by 2002:a17:906:1281:: with SMTP id k1mr3389782ejb.212.1562853619700;
        Thu, 11 Jul 2019 07:00:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBl9WcqF6mdpPIo1kgARY3dzZ0eYueLZN38Ji+XL3qnP1MTkFV35dFJ2Ng5m6cgagWdNRS
X-Received: by 2002:a17:906:1281:: with SMTP id k1mr3389569ejb.212.1562853617665;
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562853617; cv=none;
        d=google.com; s=arc-20160816;
        b=AAzwXspK2KeAaShVdRgqKpA2dlupLmw9TJwheWz1cbCmHEnL1y1si0j4HwlgSkYNU5
         TX2fQID/CFK+zCMGdzRxB5VZ6dQXdFSKHuyPACklQ0Go5jtkCuD50UgeR+DDmTZnOy2n
         +7JnGuSI0NLJgatyFKXf2buvrRbLUjEwqFl8NmlC6k9xOABFltI1B4GlwLmHbLImlvqT
         lrtsRIRJzlnUzKuQF5hH1X5HTJvubVx04abNfrJGtBZjFAL0QyI2Navn4lfQ3gswKRX6
         YsRx673usGPQAbGh6g+ZJwW/OubGdZWY0aUfdyZY+h0jEl9hzx3obPsBiVOcTvt7xHP/
         gcGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vL2nsiM2ddjwtUcwsMFcppuOiio9MXKDv4ZgGyw46eE=;
        b=k4cA7GvkmTtxOt05k4pouAiSHIZXR2fxaObOVZsFlx1i824Aw2ik/mu+07ykJIMBQ2
         enzI5y3QkEcQScke6fsRjD+fNc8DZ03JJvm6me271fmOEfwo8QuGbkhexicl3GTrPncJ
         e+sRF7ep23ofGe6EWlBZSRElyi/ZRYRV19k7sIrwYGmrH+xv/Uhy1mw9FL7eeJDPRgbB
         YEXNQimGdYeLMgFCbSar9EH5JbKpKMuRaCsXlz6KboG5nROfcSDPFJQLHQdJJJfWM3Jp
         tnomgXBATOhO5EUjt78bnZezBk3birb8IkfZSOwfImCxFu+SjVpeq3m5562I3j8mb018
         rILQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m34si3400766edc.296.2019.07.11.07.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F326BAF10;
	Thu, 11 Jul 2019 14:00:16 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 274F01E43CA; Thu, 11 Jul 2019 16:00:16 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
	<linux-xfs@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
Date: Thu, 11 Jul 2019 16:00:10 +0200
Message-Id: <20190711140012.1671-2-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190711140012.1671-1-jack@suse.cz>
References: <20190711140012.1671-1-jack@suse.cz>
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
CC: stable@vger.kernel.org # Needed by "xfs: Fix stale data exposure
					when readahead races with hole punch"
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/madvise.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..ae56d0ef337d 100644
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

