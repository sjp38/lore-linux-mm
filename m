Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0571C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C73D2147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fznpo+A/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C73D2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E9036B000C; Mon,  5 Aug 2019 18:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44BA36B000D; Mon,  5 Aug 2019 18:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 338616B000E; Mon,  5 Aug 2019 18:20:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F03416B000C
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:20:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h3so53594596pgc.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:20:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=dddtpYCweWi4pCnNFoY2sIr1e25VgEHOJLpB1rZZFG/1HKiKAhFMAtdEYUwU3Xoyir
         lYjm/6RerSOSFp63KJWd3G02o6SSqqLTX4bOequAxe9t0YYbdPnWzplSwmEPP8mHoQpB
         xj7me6i3wF7kSTnIvDC/NOwcjug1Ja0zNCrclKXZrPGQMJoGotyPYcYxuki4CDpCmY6O
         HEGDA9roZsDqrGTiuPdVW+1qA379uiH6/RBxG6wU3wvRiPGaUkaCHKjvPNg3tJ4lR0OD
         OFXPg79DQlfltxtl4CILuMsaLTiWOaSxm6/30YfhazZzp0tHtar01igMDqz7qSQEoqOX
         Rheg==
X-Gm-Message-State: APjAAAU071H1v2ub+MVPS9ofn3VKu2tq8xukfN+S0K/1Y4FAMV9xYAW6
	kC1PXXPbkKOz7qtVoq2b5TAVFcdYu0wMsurv5NVZUW56B4JLtKAj0OxgZtOP060Pbmwu966Blh1
	VYqOIRl5IR5BFEDi9TN9BfaNEsqUELTDI/918lMp2M7YhSr/nQa+0Y18VzQfCuAFhnQ==
X-Received: by 2002:a63:7106:: with SMTP id m6mr143268pgc.2.1565043625969;
        Mon, 05 Aug 2019 15:20:25 -0700 (PDT)
X-Received: by 2002:a63:7106:: with SMTP id m6mr143212pgc.2.1565043624811;
        Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565043624; cv=none;
        d=google.com; s=arc-20160816;
        b=hZY7Ez86yJl+F8dIxYVZ6wtuFaHdAYB15ZKE3dRwOlRMmX9qZ2kGDlDQwoIzi0QYNY
         QRglYP+UYwObmt9Rbwt0jKDR8cOt1YWAD+pAuOW6fwb5EnaTgNExw5vrTjhwslGF1AC6
         7HI1v07/ZpQZsdY8DBdPFwOj0/7XVM7OCRrn3uEEHavjVwRJNJ6g+vb/5HJfm+8CuyDx
         G5yX4MghZUSLVJmDn80mh0f+g++G3aZtmmvGQ4Fujg8FsFXQmiiJZR66DSEgTk7GWnu0
         A8Ss5KE18kLyxQ0V2FRBUPx91XcAnquXz7/7sHRRhEyz2cbQSmCcGJCZc55Pw1F2FZVS
         59OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=ft/kJEIWN5ZFfGMYdte4UOlucASF9O1HHOGa8kDS7XSsyg8gtxEEoIxZhZc+5xnps3
         PbxdtzUwMqqmhxesGp2HbzkGLNQuVz2GYuXr7mQ9uLD2a8vegNyrGKKD6Qt9++bNA/F7
         NZBcSDoaQxSt6hKSTqrYR2toSCry2KOAW6n9PnG/I5yPKVzRkQ5/f6OyW2IKYn6DaXrv
         2OPy518U0WWK7CzS4+vRsEW2ppsLNuK3P6PU9aPY0mfCTvdFiEq8Re1OtKXuEyeNEKa4
         DYW+sdXTlAjAN9dFjTi1nVRUj4nTe4ik8TBzrktEoZBNelEl+5nZYt1QYgkn98icnA9G
         Zulg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fznpo+A/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor66686023pff.71.2019.08.05.15.20.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fznpo+A/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=fznpo+A/CwxRLIpM6ZFeQpQfbkwnXpV6MuOXxJtZ2Ve009RQdttmK51WGcum5QprYM
         AZQ7iviUpS0sDa6G1kPFVIds247iKuX80oSi8PYrG+Pz5HqI59Mr3aKQtGX7pDi7o4RM
         RWmp5UtwQ1cDvdrDvxECL3XMDq4qYx1FWnuPOJcQNsZrf6hsFTq4Xs2nIFRial0iIn3j
         3r8qecmsdUZFU0thRgD2fb91wcvPi1mWP2+4yCICzHHq6R6yoN35mdoA+M+YlUBaQjwP
         07wXykKNUg8r+Z9HQlNi01R18SqGl82U9FDKRed0aaErkd94vNQLksFmYUD5sjigWhBQ
         0FIg==
X-Google-Smtp-Source: APXvYqzEcxttqkABL1O/lcCnkyPEMLulzfgv4nN04dLirBIxyXJLvEBAWtWhQxnW9RRVVqiC+jWtUA==
X-Received: by 2002:aa7:914e:: with SMTP id 14mr284735pfi.136.1565043624587;
        Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 185sm85744057pfd.125.2019.08.05.15.20.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] mm/ksm: convert put_page() to put_user_page*()
Date: Mon,  5 Aug 2019 15:20:19 -0700
Message-Id: <20190805222019.28592-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190805222019.28592-1-jhubbard@nvidia.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/ksm.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 3dc4346411e4..e10ee4d5fdd8 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -456,7 +456,7 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
  *	if (get_user_pages(addr, 1, 1, 1, &page, NULL) == 1)
- *		put_page(page);
+ *		put_user_page(page);
  *
  * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
  * in case the application has unmapped and remapped mm,addr meanwhile.
@@ -483,7 +483,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
 		else
 			ret = VM_FAULT_WRITE;
-		put_page(page);
+		put_user_page(page);
 	} while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | VM_FAULT_OOM)));
 	/*
 	 * We must loop because handle_mm_fault() may back out if there's
@@ -568,7 +568,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
-		put_page(page);
+		put_user_page(page);
 out:
 		page = NULL;
 	}
@@ -1974,10 +1974,10 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 		parent = *new;
 		if (ret < 0) {
-			put_page(tree_page);
+			put_user_page(tree_page);
 			new = &parent->rb_left;
 		} else if (ret > 0) {
-			put_page(tree_page);
+			put_user_page(tree_page);
 			new = &parent->rb_right;
 		} else if (!ksm_merge_across_nodes &&
 			   page_to_nid(tree_page) != nid) {
@@ -1986,7 +1986,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 			 * it will be flushed out and put in the right unstable
 			 * tree next time: only merge with it when across_nodes.
 			 */
-			put_page(tree_page);
+			put_user_page(tree_page);
 			return NULL;
 		} else {
 			*tree_pagep = tree_page;
@@ -2328,7 +2328,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 							&rmap_item->rmap_list;
 					ksm_scan.address += PAGE_SIZE;
 				} else
-					put_page(*page);
+					put_user_page(*page);
 				up_read(&mm->mmap_sem);
 				return rmap_item;
 			}
-- 
2.22.0

