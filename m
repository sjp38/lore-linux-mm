Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A51C4C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61BE523CE7
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:47:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61BE523CE7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DAC46B0270; Tue,  4 Jun 2019 12:47:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08BA06B0271; Tue,  4 Jun 2019 12:47:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBC806B0272; Tue,  4 Jun 2019 12:47:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B101C6B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:47:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7so16514541pfq.15
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:47:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=3RVoF1MXiXuJ49Ze8MqtY7JBy4Fets813n9NzKPP+sg=;
        b=JCSc9JEgs5EidnvMIOkZKqwx5UH+JpVnPF96/o+kLICtnM0oBby53l8sAbP0BURicz
         vpYuoGcyNSdlQkaWvFgWRPKsc5YEC+IT0EYyTQzTy/vThvxeRdz1a10Co570aVTEvvJ/
         ZQYmqQl5QyTHpE6yetP8Hst2ElrRXumshC1o+R6X9Z7s3eT2DaY682MVLgwxPQwYluor
         o+oqeqkor2hzbiyPJwGESvaZfHD9scNsAM5T/Z3ZyKgjzEVk/7yEpvMASsZ0RQu3m6h/
         6omIESzSYOygODMiXaNnxei7ogxINsFHf6xHrW9eGTbeXgnkmQ6PZ9NmkO6FpK6dVmFa
         CLYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgmXyfG4VJ9OGxzw6CmhIL+p3ZP8eAjHXKVTeUDbawNe+V/Siw
	+xU22mFrhbZNt1eW1fnW4yF2ijYmbrwbOqRg2kXXD+T6/LLmH5vl2cmoqXRbTWnsRyNcdXwcF5H
	9SI+PWCSBlaVgDjXap3Uu9CMaWILckrMgbfzCHs6xxEJ5x8l170esyqjvtPMBAZVkQA==
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr38273748plb.258.1559666830349;
        Tue, 04 Jun 2019 09:47:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTVbbRAXsBYPMP67YF45lVjrjM5x5yx1sC23pywgpDfQCelrUE8wRYyk+CHquUcxCQHE6V
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr38273688plb.258.1559666829247;
        Tue, 04 Jun 2019 09:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559666829; cv=none;
        d=google.com; s=arc-20160816;
        b=aXUeFIl5O5Za/r94IuefykUiXd0CBB1iKSiOe0o9xos8emmZeF0I5GS8g9UjngNCmf
         +cknbZShfYHn01tklgtSMMAnDbEIP3kYIPcRnBZ8jU/Eom7YdW7UVcGMldprhNt8kPv2
         X83AjyHO8rkS6WjjXhdXYyPkYFFkZwlnPayLs0smJ85kXH6ip7Dqp5KkkBulqFg8gcFr
         v7tvRYlrBZH7beSgrwflHfD9dcIbnI5lbKhJ7bZdmJVI+s/jX6cZC3l1dfhYd3syCwUW
         /ZTkfUu9xZ11oFcXl8lEG2wvW2O5uCQrC2QbHdIj9PgLjT46Y0kWDE2SadUDNlITU/p9
         0nnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=3RVoF1MXiXuJ49Ze8MqtY7JBy4Fets813n9NzKPP+sg=;
        b=JUN5iVffassMs/OZmgeJwaXhgYjVrTymPp7sB4Q3hPbV/Ilt2LZ9WlTcyDhKQnLcmH
         D0wxHvnupLkLHXh/ZDpdbNrf1FgVMQyOFlQEWfQJJX2H3ZRSmr/Dhg/nCWS0eOoYAN8l
         vTLVUrpH4Qp/yDDpqG0sjmqJo8317NoYuMTgCTMxfxJxgUfMZDrOtmEW7kikJlxxkqba
         eKmRu9TlKrll6VfQLUS8AfEj/fX4L/Q3iPHGJzrkU3XVET+Fm/DHouS6lvDvwf+dCh+9
         pRXaE9H6KaAVey7UyfgQIAB6g5Y/X2AqH9EXn91Hbc4PPp1dwENSBI3TjcB+JMnPzn4k
         lP2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v31si24720909pjb.22.2019.06.04.09.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 09:47:08 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 04 Jun 2019 09:47:08 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap pages
Date: Tue,  4 Jun 2019 09:48:13 -0700
Message-Id: <20190604164813.31514-1-ira.weiny@intel.com>
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

release_pages() is an optimized version of a loop around put_page().
Unfortunately for devmap pages the logic is not entirely correct in
release_pages().  This is because device pages can be more than type
MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS
DAX, and PCI P2PDMA.  Some of these have specific needs to "put" the
page while others do not.

This logic to handle any special needs is contained in
put_devmap_managed_page().  Therefore all devmap pages should be
processed by this function where we can contain the correct logic for a
page put.

Handle all device type pages within release_pages() by calling
put_devmap_managed_page() on all devmap pages.  If
put_devmap_managed_page() returns true the page has been put and we
continue with the next page.  A false return of
put_devmap_managed_page() means the page did not require special
processing and should fall to "normal" processing.

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.[1]

[1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.intel.com/

Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2:
	Update changelog for more clarity as requested by Michal
	Update comment WRT "failing" of put_devmap_managed_page()

Changes from V1:
	Add comment clarifying that put_devmap_managed_page() can still
	fail.
	Add Reviewed-by tags.

 mm/swap.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 7ede3eddc12a..6d153ce4cb8c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
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
+			 * Not all zone-device-pages require special
+			 * processing.  Those pages return 'false' from
+			 * put_devmap_managed_page() expecting a call to
+			 * put_page_testzero()
+			 */
+			if (put_devmap_managed_page(page))
+				continue;
 		}
 
 		page = compound_head(page);
-- 
2.20.1

