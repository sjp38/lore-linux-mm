Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4CE7C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABB19218A6
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:00:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wXKrDihp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABB19218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473D96B0005; Fri, 19 Jul 2019 00:00:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4251A8E0003; Fri, 19 Jul 2019 00:00:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 314198E0001; Fri, 19 Jul 2019 00:00:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC83A6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:00:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so17901282pfy.20
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:00:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YvEHPnn/zpRhRupCuXxSJl3Y6LuNCXnr5gToKfaOAT8=;
        b=tp3aZf+mxRRbJfNre6re3vB4fSF8yKkISzp/UuWodicN3raEkkDpZlrSQL4gAqDUpm
         +UHw1LwM5tkU6LqcjzJWvYbmBFJZsDursSC9hr9ihn1tuGgwAtERt17DfSKAK9ByPnU5
         Y2WLPiM8T33BNHjzPSFVKfvI2EYjXc/ghA8dneonYIUqDBrdFi1s/OSvoN+1Wqh8zzT/
         WjoYsapL1Mkk9zxyQ+hMoGVgaepKdQVQlBWUTQSK/NvGjEtOcxuffpHHI+CfoRkWuSMt
         9/pkL3QIRtmTrHZl7JDD3N9frxBkCkyGEbu7H5su9DDlmrmuqCofHfz8D9gUXudUkPRl
         qYiw==
X-Gm-Message-State: APjAAAXqjd01anLAZmnSP/K4byBGCEX82NDuTQHN+4tWw2mbGpap+G+K
	sJfAa/aYAY6jqj34lQ5kflmIjjNnMSIq6VFLW314eTgCqaZuEl7hWiIt/UU/Z5diqwa6gZs07U8
	F0HuQLDcY+97Ckn9TtwqEEfAGjoLIKXy4W28YiXvetW88THeaBLPNDc8dZnrpRn68fg==
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr5452404plo.42.1563508810604;
        Thu, 18 Jul 2019 21:00:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5sHL0tfXYEOEbljhZSkx2C6X5/soQUcl6ZzdzuW3vy/wmyJWAlPCcFUEZPnk1jkN6p5wt
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr5452325plo.42.1563508809749;
        Thu, 18 Jul 2019 21:00:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508809; cv=none;
        d=google.com; s=arc-20160816;
        b=IEJ2IJHnHNnVFHWpqA5tV082BtNHaXBZdpsoiC8Jo18bxN0pgOI8wJylm8HHdpbho9
         Rbq6UWGkYZ2WefRZPvV8YF6Xj8JZmt6TwFAZNE6qltw37uMCv0XLsz8SKP4VHGsUoWlv
         0tidyOXgRYxQUHo4XZgCu8vDoYNjsiC26/sN15Wv7S2k3RHuAMprMaJLye65P/0fQhmN
         fyMhudzwC5fjXqBBdDGjKJYghjjobP936A5XwpyDq5I58LR6tG3bUuVkrSQT4snTehMt
         IDPmQUhad7wsNr3XPc/3YMwydhwRD/rLa9PoX3tI9XmgCVSlrFCeXujjzO2hLNGgrSHS
         GfOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YvEHPnn/zpRhRupCuXxSJl3Y6LuNCXnr5gToKfaOAT8=;
        b=Gkx6KUeFKoBcfJT0qpXlWfn7uyFA6u/ZUOxlXaeJWourFHURwKAk1oehAMR6+A4Dug
         cvS0Cb6EW7+mXSpBhiCLWOcVoV4kK93JtdSygno8w0oIF7H8bWrdImc0bmQQr+b15sXn
         FtUZh9zIE13GuZY2pN1nXWgXX1AdHkoKy+EZpSoA4Nz6r7asXhwjnQh1E6SYWDWU9vPa
         0fnriFAf0lBi/QA/k+KJ+VB8OjazPMm6+vJPFjrbzkO7ZqmZov/2N/KoXpFUFtYRlGlI
         cmMCyS00GVj+JTdH2glVbV1rBmnkhQAkj4P16URT3k5odF/2+hQNUSUiAW9kpVIN0myg
         svgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wXKrDihp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g10si431156pjp.74.2019.07.18.21.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:00:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wXKrDihp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 65DD821852;
	Fri, 19 Jul 2019 04:00:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508809;
	bh=NGAEa7nxCla6yeOxFjos63IrCBcidctWmzU3WpluPhM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=wXKrDihp/S1cVan7L4zfjmAgAIzXlz6fMWnxvGRTLBM8R1Dk3lWkTAvYLkcXDUbvS
	 llI5C0scOH1cTUGYr8VC+JvcJHNLtbVmDeq/2JOUHnx/UwhuPELJgHtDPXdKpzRPpa
	 9cFOvOfWe+SrDKyVuEwpMHFmr7ukTzxcgb2ssKjs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Ira Weiny <ira.weiny@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 102/171] mm/swap: fix release_pages() when releasing devmap pages
Date: Thu, 18 Jul 2019 23:55:33 -0400
Message-Id: <20190719035643.14300-102-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

[ Upstream commit c5d6c45e90c49150670346967971e14576afd7f1 ]

release_pages() is an optimized version of a loop around put_page().
Unfortunately for devmap pages the logic is not entirely correct in
release_pages().  This is because device pages can be more than type
MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS DAX,
and PCI P2PDMA.  Some of these have specific needs to "put" the page while
others do not.

This logic to handle any special needs is contained in
put_devmap_managed_page().  Therefore all devmap pages should be processed
by this function where we can contain the correct logic for a page put.

Handle all device type pages within release_pages() by calling
put_devmap_managed_page() on all devmap pages.  If
put_devmap_managed_page() returns true the page has been put and we
continue with the next page.  A false return of put_devmap_managed_page()
means the page did not require special processing and should fall to
"normal" processing.

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.[1]

[1] https://lkml.kernel.org/r/20190523172852.GA27175@iweiny-DESK2.sc.intel.com

Link: https://lkml.kernel.org/r/20190605214922.17684-1-ira.weiny@intel.com
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
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

