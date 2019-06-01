Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 896A9C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4424327357
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l8uMPua9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4424327357
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7F4B6B02A4; Sat,  1 Jun 2019 09:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D58316B02A6; Sat,  1 Jun 2019 09:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1DF96B02A7; Sat,  1 Jun 2019 09:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 898966B02A4
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i123so9606663pfb.19
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Wid4ykAbikMrh1GX5t69q1sli7/bGgNXaipdRPIBSU0=;
        b=ldnGOHPhonx5+pg5Fz9wdLv64VB2HzmaQFCw2QYTDFm3WX+QId4ASA02LxA9UVUH3i
         Ot/8vlN0k3HdNBPstYCMFq7IWxp1RafLBdPjeXYh1fTxAECp9QSLsSwJ5XKXzDxiwVT6
         vxLSUT6QHvahbqrvHaiKwz6aDmIjUxa4l5Jux8zaDWltehfa5GjqbKSX2odXCB3TyVsS
         AEB3bR2jVcFkfOiz1vICDsVPThxBMVJMwJnZnBqry5YniLqn7BAI70czTtOniOTzHZHA
         lArQLrOvxoyxw708PJMt1ffs1kRKKQmz+asnXruRxF9fEYjuaEFdoBD5xp2WLLnHrIni
         RZfw==
X-Gm-Message-State: APjAAAU7cXB8HTfgpeZtoVC7xW2M/MDhKON9yEs8b6RFAruAuI++ZzoI
	OSJOZSmqrNFbM6P1u6eWkIjwRFDerwNEHoJUDGtOTwWZI7Toxq/rs50WnpvXLt67Thb9Q7K4nvU
	/LdjiG+9KnXljC1DqkOjMHKa6Wv6VwBSIH0Ueqlm7fDp6l6MiM4J9nsrLCWmcRuBoQw==
X-Received: by 2002:a17:90a:35c:: with SMTP id 28mr15538040pjf.110.1559395447230;
        Sat, 01 Jun 2019 06:24:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLGjXAoDBnb+NYpbHIq62WQfPr5ydCsL0vMhdWAoMNLuKRlcAF+2BoUumkdp2M8vwfM6AL
X-Received: by 2002:a17:90a:35c:: with SMTP id 28mr15537960pjf.110.1559395446586;
        Sat, 01 Jun 2019 06:24:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395446; cv=none;
        d=google.com; s=arc-20160816;
        b=tEccYHwKU9HKah2YK8x8nAa1MoS2Mq88lNWIWp3rG9Otmogj6n51/Sfwu9xAShqXZJ
         aVhiE3cpNY/hUn7YzXVDUu6UXvE9FoVoqaBeWKXDkYcKaLak14cl88EyOCEdo1nIEh2N
         Fqd2T18Ge51u8H9eyNgQINUwSG4NdFPsNuHv9LBKzGwz5x0YkEl3f7G9bV/DtPrzu5Sx
         PN2Anhdnxuw3uf4tOE1yOkUAZ08ajAcA9A7z44y+Pov14w6eA0jKqQ9qV0H5yRw8B3ng
         YLACfMEMJY0ljnWov4Sdsc560PoXUw00XV/SxJw2GgYB9Mn9OugoFWnOpYdQGKuTiaXs
         uWEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Wid4ykAbikMrh1GX5t69q1sli7/bGgNXaipdRPIBSU0=;
        b=jcitBALkRrRlJXpGT/R7RHqfxaucu34XStFQrGWB2sPlCRKI6RvHjuNFOhphWK7BPR
         VhEl/PemnB83DdtOEj1sa4C1MQ2sPoTiqbxtxE3wbgoXsxwUR/SHF6A5OqC5eSMtEPnS
         iGnyUmeZul+nCk9aOCq+hs15ieW8aH0ZJUcGRwFMLSDZBp86Mm9SaNuCtiwMHEw17yJZ
         GHoOzEaOmjpfAeB/hByVDgz3yWgHkWQWix5CoyRRNRc6ue8lqgjr//SDNpOktYXZReox
         FhZN0jn4pPrTUFmwO0ZozyPDRi9QGgXtWlm4cbtWhiDIdKtQYYPOPt6DHC0k0W4qPh3F
         ruuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l8uMPua9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j1si10651668pld.399.2019.06.01.06.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l8uMPua9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 19B3D27333;
	Sat,  1 Jun 2019 13:24:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395446;
	bh=OTPTXRE+XDoW9UeWQydQqGzAVFJydQDHPoql3bTFqg8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=l8uMPua9iDbJeAqUpahIsFE7/Xg2SNRneCQXe2Wnac4KllaQqzqm0G391bPvNaFVb
	 mUmpXvEIdCHRCfFzw30Io7t8QD5QmR6oiIU6I41keN/YnnSeoBuNAbfbvpEWcbAfd0
	 +PTi9Gxj2Oh+9rz/JkpE+Q6Yyy5C9om+Uwf+yOrI=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 07/99] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:22:14 -0400
Message-Id: <20190601132346.26558-7-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132346.26558-1-sashal@kernel.org>
References: <20190601132346.26558-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Kravetz <mike.kravetz@oracle.com>

[ Upstream commit 0919e1b69ab459e06df45d3ba6658d281962db80 ]

When a huge page is allocated, PagePrivate() is set if the allocation
consumed a reservation.  When freeing a huge page, PagePrivate is checked.
If set, it indicates the reservation should be restored.  PagePrivate
being set at free huge page time mostly happens on error paths.

When huge page reservations are created, a check is made to determine if
the mapping is associated with an explicitly mounted filesystem.  If so,
pages are also reserved within the filesystem.  The default action when
freeing a huge page is to decrement the usage count in any associated
explicitly mounted filesystem.  However, if the reservation is to be
restored the reservation/use count within the filesystem should not be
decrementd.  Otherwise, a subsequent page allocation and free for the same
mapping location will cause the file filesystem usage to go 'negative'.

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G -4.0M  4.1G    - /opt/hugepool

To fix, when freeing a huge page do not adjust filesystem usage if
PagePrivate() is set to indicate the reservation should be restored.

I did not cc stable as the problem has been around since reserves were
added to hugetlbfs and nobody has noticed.

Link: http://lkml.kernel.org/r/20190328234704.27083-2-mike.kravetz@oracle.com
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/hugetlb.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 64a62584290c4..584f089ac79b1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1271,12 +1271,23 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under its
-	 * minimum size if the reservation is not restored after page is free.
-	 * Therefore, force restore_reserve operation.
+	 * If PagePrivate() was set on page, page allocation consumed a
+	 * reservation.  If the page was associated with a subpool, there
+	 * would have been a page reserved in the subpool before allocation
+	 * via hugepage_subpool_get_pages().  Since we are 'restoring' the
+	 * reservtion, do not call hugepage_subpool_put_pages() as this will
+	 * remove the reserved page from the subpool.
 	 */
-	if (hugepage_subpool_put_pages(spool, 1) == 0)
-		restore_reserve = true;
+	if (!restore_reserve) {
+		/*
+		 * A return code of zero implies that the subpool will be
+		 * under its minimum size if the reservation is not restored
+		 * after page is free.  Therefore, force restore_reserve
+		 * operation.
+		 */
+		if (hugepage_subpool_put_pages(spool, 1) == 0)
+			restore_reserve = true;
+	}
 
 	spin_lock(&hugetlb_lock);
 	clear_page_huge_active(page);
-- 
2.20.1

