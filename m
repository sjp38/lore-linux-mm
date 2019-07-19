Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C167BC76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DD5A21852
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:05:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uktFBxLt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DD5A21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8AA8E0008; Fri, 19 Jul 2019 00:05:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 161EB8E0001; Fri, 19 Jul 2019 00:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001CA8E0008; Fri, 19 Jul 2019 00:05:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB0908E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:05:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so17937741pgr.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:05:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IlYVSSUM3HeZAZlw1v/+NkJPM3y4UlBJJ0PYQtVX9y0=;
        b=LkpW0Ck+rol/RvriOreCe/9fecMnvZTjx8Bo3ZtpvRQQeWMzPMd4yQc8U77nKJrr65
         9eLEyzg34QsrhCZX0Hy0xrB5SIO96LgN3wwRgjRmZS2ixCdBeVtUiXmz6BAVwFUMQtM/
         N0SNQp6k8E3hV6P8Eegq2HS6c5fVUseQwnm+DNQYZIHjRD0YGhU1kLiW/x7+L1tEDLMf
         PlsTazMuO0bCx1PWaCvKRIURWAhUqxPrnveRKXYS8dnPhDMret5NSn+MhhR0l0+x2kJD
         pvfY6rwksKxHSFWFdgIpHMB+RshKQg05jfO3t8sUd685BdMNLqQS3iPvuXUalhKby9Qs
         tZxw==
X-Gm-Message-State: APjAAAXIN/1ReZZUjfSF+MCLyiKJ43aHt1eLEqEWY2j3cPKsC6oHAu/9
	VAg26fX4/KF52k98Sr4vEeI7OxNV3Axrc1oweVZfD5/oqTXnd/AxkrQV5blbEDwm+dlRAZdOktu
	S/X56zrWuYY68p41eH83dhWmNyOLjjdEzl4rTvcKA+wACUIDv/wi7FjUgeQyBXJNHqw==
X-Received: by 2002:a17:90a:db08:: with SMTP id g8mr53371636pjv.39.1563509117381;
        Thu, 18 Jul 2019 21:05:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpGeSdYlZjLTGq0QkTtFjH6GnYYQBDM5I5UbojNeXSNjKj7s15D7uxM1wctC5Cr2GYHfXD
X-Received: by 2002:a17:90a:db08:: with SMTP id g8mr53371569pjv.39.1563509116642;
        Thu, 18 Jul 2019 21:05:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509116; cv=none;
        d=google.com; s=arc-20160816;
        b=nqA2lPSfI8GK3ADjLuH45W3LX5c7J+NxiMO9jQcWw8PWn9r1latfIMHy6iaar0Xpy6
         aHF2X2vPJz0PjSq3rbX+D6l8krIqJYL5/RE0PjqERZV39jvW/PZAkptS3RTF8O6RwZur
         QzvYTflewcyo2H094CYCr7KrC3Ps6dWtejBJQFUf9ed9SJ+h6C1hK4elZP9KHIYb+YKS
         dJzp5RVptOPo6XvNm04luLGvBdbWCYh79adRbE8Q8WS5OfN8SJG7mL4ND7pxE9a7Pf6V
         QHeJ/CV2RBPnx178F6svmcChZW33kyDchEumfSgxx6FG/iZvqayKX5+ABSWzFOGFk+5z
         wOzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=IlYVSSUM3HeZAZlw1v/+NkJPM3y4UlBJJ0PYQtVX9y0=;
        b=p5xYDATeeJo2QwdMMW7I5LTj9Ek1rXKBdDra4ALX69pPWkVYqamQm9cN1rYGE2A11w
         ozyXNegYzeuFczdci9YeAd5PO2Vwc0kvlZ996z7MFoR1VWT++wNxXzzbMQUgfy3263z4
         fVt3KwMW7M0OcFNMmkjl5fT3r+4mWAGNeztVSkEazT2R/fyDvpVXEdxzQ3+F+ipduPrU
         7yRwhnMATxDb9qhLJ4NKqzpgnxd/PZHOCZCCVVYTvxFOQ6bpoAUheG4ZeI3i5YJtPzWU
         tuuNRY6GL0Wn2ECIKwjm25JXBDBwqhGrEQ1duhoGFIU0kDGrzrw8j6mfE8p7mQ7Iz7OW
         AmpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uktFBxLt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l1si579164pff.178.2019.07.18.21.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:05:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uktFBxLt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 53F842189F;
	Fri, 19 Jul 2019 04:05:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509116;
	bh=AtzHmvVdtVpCWqkjwWL0y8J0cpmThlCpcbs1wXUCpJA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=uktFBxLtViSjKfTCCaKzPsSwfdkC1Nmvz7jmCbe/wgKf9lJN3Y2WrRtDIjusQW2ps
	 NdVTpkqSNUVj9x0xdyyXHeuQ0iTL1LscojUpn+mYBJzpGwoJtKzjCwl+/afibXjMge
	 QU0aiX7iNHsF0VFwXViK38dxg/YCZ0F95W3lCVjU=
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
Subject: [PATCH AUTOSEL 5.1 078/141] mm/swap: fix release_pages() when releasing devmap pages
Date: Fri, 19 Jul 2019 00:01:43 -0400
Message-Id: <20190719040246.15945-78-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
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
index 301ed4e04320..f018d7c0148c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -739,15 +739,20 @@ void release_pages(struct page **pages, int nr)
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

