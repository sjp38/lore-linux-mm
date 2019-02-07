Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03446C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 11:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD85A21904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 11:23:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD85A21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41BCE8E0028; Thu,  7 Feb 2019 06:23:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CA838E0002; Thu,  7 Feb 2019 06:23:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BA9C8E0028; Thu,  7 Feb 2019 06:23:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4C9E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 06:23:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so4250961edq.4
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 03:23:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=74HDbQSN7id1zXcHbDXGMCaERzBK2fKHJ5lT6+g2fSM=;
        b=RFmMfF+iOBasXGBWNlpU2buO987ima1EdXwlTJFvNXRhtux8cWMEYHIWk/WgTr9PbZ
         Nd7MqbIv66bvArSWlascNa+YqyPByQCgf61ITwzGjt/U75Zhju2+IgT7dkniMnCo28Wn
         jIB1bA4+hcN5IcMDHjOXCgiFpJd0WJHKDC2yx5HPpjdOh/VmTlVBpdOwhA9diY9WD273
         FQAqmBDy0kYizCwphhJ7RtuC9jUcYRyWJFQnnUqCiDDBao7ew8LLYShqfw/6zkedsr+U
         JfuwEQbDvJ/Lh2F5bUnoAGJx6LF+HjoKoTrzZXgTUmB1S06N1vvmQo48/pNqiNY0DBZi
         wfjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuaXswXwA5GnXMgGvWDA32nxcRGnlSiNLERp0ypK+3A3tIjXe+uk
	9rdTr5zGOvrGGb8c4EzTcULZ2QBRGibQjrxGLIVfkXnDF/akuv5MVySAk79JwBDoGiuD0LQ1ITN
	69wXZcN4LlUhcWD2W6Aet+sG2fTaSl74pwJ1ARwbQsUs3tMN5NF/f4PZsRHPrzT9yvQ==
X-Received: by 2002:a50:d6c5:: with SMTP id l5mr12133316edj.145.1549538602235;
        Thu, 07 Feb 2019 03:23:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblUPX7cUCVSUTztC/qm/hGfRR8/+Ndz6SjaBR7J2dmBgH8nnPm5I1uRit0EaWe1mh0BGZV
X-Received: by 2002:a50:d6c5:: with SMTP id l5mr12133250edj.145.1549538601264;
        Thu, 07 Feb 2019 03:23:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549538601; cv=none;
        d=google.com; s=arc-20160816;
        b=o855iyJMw9twPp1eE728nO5vY4ht8LTWeVBalJYSL5f/06C+BYKbYFwMBMqRDijSFi
         OWZ5oiF5IkID2sokNTZPs3PrzPRAnEkNR6fT7mz45/nnL0cuJlX7XJ3lpBdDOIHjZ6NK
         gVvHixc8hZyc4MdZSD3+ezRjc3IaGjUZ10aXzoqlbOpKJHOpH+CeP45mhTiKjJ/qMkAQ
         J7bsDQ2OVFgQJiZnfz899iUIXPiHfuoDZZUMnv3ED27NvQYKKShc6btFH5L47/UiASQt
         9holQ4LsxiENtWmzDJHo0hKI847KBhcYagiamNRSOTBNEWr8z13GBdWJ1b/ma+MsoOu9
         kzog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=74HDbQSN7id1zXcHbDXGMCaERzBK2fKHJ5lT6+g2fSM=;
        b=C5R9eV1NqC4GhgKiaX9zmqlYC2Xgz46wQBmnlYKnd24mZPHrBSaZbEkghGubB8E7Wu
         vGKzl8TPvHA8dmp1w5NTUfpIwSl3pDCRWlmS3exBkkCiD8cnlVZ+6BVMhxCp2bnL58y6
         yC+rQ2lKqDHw6d+eHQLAxO62VGz6cFDJwNwB1UF90BqBNyV1c1InxCPCbIM/28zqYvOi
         JYHppP7WsyTyupNVdF+sV0w2WF+2K42PMpx2+WHmr80BBYazO4rH1AXEpln2WUVl6vlR
         np2GZnTwtPEvRhGKFBFh2xexmHyFLVgbYuGkzpLgjIpYKmhSSnbzE7TX+Etu4wF3GXMS
         6xdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si1743857ejk.236.2019.02.07.03.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 03:23:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60A3FB04A;
	Thu,  7 Feb 2019 11:23:20 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C7F721E3DB5; Thu,  7 Feb 2019 12:23:19 +0100 (CET)
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Cleanup expected_page_refs()
Date: Thu,  7 Feb 2019 12:23:14 +0100
Message-Id: <20190207112314.24872-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea has noted that page migration code propagates page_mapping(page)
through the whole migration stack down to migrate_page() function so it
seems stupid to then use page_mapping(page) in expected_page_refs()
instead of passed down 'mapping' argument. I agree so let's make
expected_page_refs() more in line with the rest of the migration stack.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..fd2f7cec98ce 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -374,7 +374,7 @@ void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
 }
 #endif
 
-static int expected_page_refs(struct page *page)
+static int expected_page_refs(struct address_space *mapping, struct page *page)
 {
 	int expected_count = 1;
 
@@ -384,7 +384,7 @@ static int expected_page_refs(struct page *page)
 	 */
 	expected_count += is_device_private_page(page);
 	expected_count += is_device_public_page(page);
-	if (page_mapping(page))
+	if (mapping)
 		expected_count += hpage_nr_pages(page) + page_has_private(page);
 
 	return expected_count;
@@ -405,7 +405,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	XA_STATE(xas, &mapping->i_pages, page_index(page));
 	struct zone *oldzone, *newzone;
 	int dirty;
-	int expected_count = expected_page_refs(page) + extra_count;
+	int expected_count = expected_page_refs(mapping, page) + extra_count;
 
 	if (!mapping) {
 		/* Anonymous page without mapping */
@@ -750,7 +750,7 @@ static int __buffer_migrate_page(struct address_space *mapping,
 		return migrate_page(mapping, newpage, page, mode);
 
 	/* Check whether page does not have extra refs before we do more work */
-	expected_count = expected_page_refs(page);
+	expected_count = expected_page_refs(mapping, page);
 	if (page_count(page) != expected_count)
 		return -EAGAIN;
 
-- 
2.16.4

