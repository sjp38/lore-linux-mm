Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66D25C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A02F2067C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:48:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A02F2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78E66B026C; Wed,  5 Jun 2019 17:48:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B29F56B026F; Wed,  5 Jun 2019 17:48:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17DF6B0270; Wed,  5 Jun 2019 17:48:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4C26B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:48:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so139904plr.19
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:48:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=t/zBI68Op3lCQqBzvXOYSWLgNzoopSUj9ETQdNbQEqI=;
        b=CCxUYf/SYjNzIuXirNm99OwVAi53DROK5rDnArng2rv6QdK5Pgvs/jJcAd94Bcxuks
         oAOxTeffKI4fIkEqCb/pvxHdkmow9cwcoQ83TyB9WKPQeicwyKnJOfIyU6xed77nt2q+
         tbT2B4ZKOuUbt9tMH/SbrsdoILP205RzGk5Eh+hzriDsJ8qrk5EHuwn9KgLqtuUSmegC
         Pdj2hPwXeAPCUnqog/QbYqlepuwDE8li5mYNAt5C7uoB6uH8kIQoDDcjvXFzLAqjASbP
         SwB8pAod0zkO1udBng2SUYPVLvWhiCOdDFfxnfuzSG8UII4MEOtGTqRjzrKpP81odr2O
         1t0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXSysS2V1gWZIhOgTS7rzDwP9XTqDR/TBDyeXWWGjeKiMBdsP64
	V7IOscnTfxiqKC9UUHdwj4Yz0i80IVB9/B5uKlApQjYuJlMIat+ZbEHDbDvL+A4GnJkP0cFmaAE
	dWsoASpGSrZmGEZVfjqkPwZDXeX+PdV/MbmhVZo1i3C2YvrTUQZFswzkc+EMPB62TCg==
X-Received: by 2002:a17:902:9a82:: with SMTP id w2mr28668794plp.291.1559771296080;
        Wed, 05 Jun 2019 14:48:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxb6YgHJPTvwojX5kN11SPFuJnb02prSUccNF1egryJZX2Lqb7fhK3R5yqUPPa4ewU+iuMX
X-Received: by 2002:a17:902:9a82:: with SMTP id w2mr28668738plp.291.1559771295028;
        Wed, 05 Jun 2019 14:48:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559771295; cv=none;
        d=google.com; s=arc-20160816;
        b=ylmvqKcj1cC3CCbAZr0jfRRrv0YocPFAad5muW72mGE1R6w3nAn8oxmR3XTwsuIbKl
         WOqs0cHEzS3wfhJtSGIa2psAfer7A4+yVdkBcYJPN7UBMmeY5VFNcAHM95GVyj00QWjV
         khOe8xxlSvvnUzhQMwybq6A+zgzyZr2+qpdes34J4JK1bUWwqL8PXoZN3j9xRpk4Z/ip
         uml22NTgCstxMB5vSnlmvkxxNK9D3wLS13rc4EOO8UFf7xq42KcGc8rMvREvbh5/X7Qc
         zwKxXxYjyyDkxHxSj27aN5Tbhcl/OmVdiSt5TPXnP3f+IZT9iAs0xjBd0EWAZuWbNLYM
         GyvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=t/zBI68Op3lCQqBzvXOYSWLgNzoopSUj9ETQdNbQEqI=;
        b=lE24upPva7WOXWWZjKJTZ3lLOmw26TakgAjk1gqHmiWQZz5G589apfQqUHTuLO5bIr
         7mcgHO6HSfvowAbjYmEQrXknggi60bSR5mT52FBBCzw9BFQ7ceANuA6K+9Iwy18dj54h
         H4SkCcuSqBg5Vs5RvlJ+Q5kN3cd+olkNZEDfJb5aqpj1leE4D0oJ9M6Y4cwGRPLjEpVq
         pjS38EDr53V9PdNDc/nJG0qv4/8FxJvOwtEquYlo+7fRuNyYXlLvu8nbITVQp8JCPIAL
         4Z3VXKIKEMnMieKW94qFGL7bIskUh9UZ140lEQkLcyfW3C8mut9Nosfj8bwx2/F6RbMk
         uuNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w4si28205868plz.27.2019.06.05.14.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 14:48:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 14:48:14 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 05 Jun 2019 14:48:13 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v4] mm/swap: Fix release_pages() when releasing devmap pages
Date: Wed,  5 Jun 2019 14:49:22 -0700
Message-Id: <20190605214922.17684-1-ira.weiny@intel.com>
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
Changes from V3:
	Update comment to the one provided by John

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
index 7ede3eddc12a..607c48229a1d 100644
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
+			 * ZONE_DEVICE pages that return 'false' from
+			 * put_devmap_managed_page() do not require special
+			 * processing, and instead, expect a call to
+			 * put_page_testzero().
+			 */
+			if (put_devmap_managed_page(page))
+				continue;
 		}
 
 		page = compound_head(page);
-- 
2.20.1

