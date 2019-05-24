Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7285BC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:36:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F392184E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:36:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F392184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D27B6B0277; Fri, 24 May 2019 13:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 882486B0278; Fri, 24 May 2019 13:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 771676B0279; Fri, 24 May 2019 13:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3FE6B0277
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:36:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r4so7451503pfh.16
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=PKI4YfKx4JUOr32uCjvDAzGjPav8r1bjv373hdqyqNY=;
        b=TIUEmrExozpdZtvv0gpyEcxuM2hTWIhrEA6v9GMEdxYC6mIhvCwtkWaK9Ny4SIRWS1
         dJVyFE2vLcy8YvHVWObYsBnCXrg3JchsMEX2LvbthZw2CTBYADDUCvZGjmZCKtdc9rA5
         wrbjYU1NfGHoDCWJwuqjEn5EgXjrIC9jvSlOp0A09XuFQK2ksDfgJN8W2vGhAE4W2LbO
         wBJ+m285slJtkmTUSDlpjZp+BsABDkbR1kE85YVQEWmGCwGh7t29QYaEVdG21l6H5+Qc
         fpc4lR9TAVMgVSuFhZKxjqZuBBkJ9TO9VdFSPGlBKfkdw7E9Bpw/zei+pLgfLpK1UKiJ
         D+tQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX+W/wD/LxAZbJjbui/OftnRfyGl2cJmIZp0Yck6aIYpgjJz2n2
	JsgR08n/tKkS1ZTEVuSWJP5DPZ1AzSxm+2JWJOyTcowWHwCOCxgwjfdmC3kjhGCGRsPj7deMALB
	JAxB9kNmer86GfofnUh3Q1gThM6L3nrxJyDv5/0hAQXHwFtpCKl9OA6AvZ868rXGHyQ==
X-Received: by 2002:a65:4c07:: with SMTP id u7mr103584370pgq.93.1558719366936;
        Fri, 24 May 2019 10:36:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2jjdVl1UrVdBj6QOvI869pIfTqThfc2kOKMOW3r5GKLpUL0mVCpZOLhZtbi20xE4nbhOw
X-Received: by 2002:a65:4c07:: with SMTP id u7mr103584304pgq.93.1558719365802;
        Fri, 24 May 2019 10:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558719365; cv=none;
        d=google.com; s=arc-20160816;
        b=UDS1G/BX/nwKHk94I5zmJDVxeioBKIOGzyZIJNT0oJfTDxLe35uZlE2TZ90B7ddPhl
         FFSCMX9xQJyjeug7hYe4U/syLZWPiO1k15L/PkFdCYkbfTTeQTL/2p27ouzqXm3Hu/LH
         HmsgqapawpQdpOuhPaC1SuTumfewzJDFZxPetO7umXmcQJWp4SB9WPlhO8NW7CjbdRv/
         Dn+I7eVpT2QroqIQLHKJrKNHzj/Tq6i+255x1/8R2UjoQOl7Yl03QtltgamHL3QhhZPa
         UfjkhdUx9UynYdUHjOioah4k+SHDWBJwxGL6p3tZ5eyMiyRuo4FSAv5Frh1Dnm4/Orng
         a5jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=PKI4YfKx4JUOr32uCjvDAzGjPav8r1bjv373hdqyqNY=;
        b=NEcaD7Y+wpGoZmGTkkhkBLoT9SVRvgbZ9tzGE4yyM5WyK372JWxmefudwq2Dt/R+Bw
         ui3uvVeg+HXNWPErn6qFERexAL4nlMPmTvItSwosWrWa66jR50XLbZd4108KlMyb0OPZ
         qsQrf1WkePihgNsNGnEYWqfWNtuvpOmKJ/ULP5mqJ7LPMe+f8yKaCEn5PC08hyXK0w7G
         7BY4199Essbpzo2WlU/q8S7is9hUa1fSI2VWctU0/XYFgf+uoiiML91Uw2C2RoVa4pCM
         ZskxDs/Y0w8Or7U+lGPxbPXK4XuRi0zr+fTxCG0D28ijVUmFFic4aEOqfA2B8D4AGaXR
         U6HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i22si4967072pfd.84.2019.05.24.10.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 10:36:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 May 2019 10:36:05 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 24 May 2019 10:36:04 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2] mm/swap: Fix release_pages() when releasing devmap pages
Date: Fri, 24 May 2019 10:36:56 -0700
Message-Id: <20190524173656.8339-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Device pages can be more than type MEMORY_DEVICE_PUBLIC.

Handle all device pages within release_pages()

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.

Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V1:
	Add comment clarifying that put_devmap_managed_page() can still
	fail.
	Add Reviewed-by tags.

 mm/swap.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9d0432baddb0..f03b7b4bfb4f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -740,15 +740,18 @@ void release_pages(struct page **pages, int nr)
 		if (is_huge_zero_page(page))
 			continue;
 
-		/* Device public page can not be huge page */
-		if (is_device_public_page(page)) {
+		if (is_zone_device_page(page)) {
 			if (locked_pgdat) {
 				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
 						       flags);
 				locked_pgdat = NULL;
 			}
-			put_devmap_managed_page(page);
-			continue;
+			/*
+			 * zone-device-pages can still fail here and will
+			 * therefore need put_page_testzero()
+			 */
+			if (put_devmap_managed_page(page))
+				continue;
 		}
 
 		page = compound_head(page);
-- 
2.20.1

