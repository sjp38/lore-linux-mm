Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18E00C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B03FD208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:13:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r80m0NId"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B03FD208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 640056B0003; Tue, 25 Jun 2019 10:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CA098E0003; Tue, 25 Jun 2019 10:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4432A8E0002; Tue, 25 Jun 2019 10:13:47 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC376B0003
	for <Linux-mm@kvack.org>; Tue, 25 Jun 2019 10:13:47 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h27so11915894pfq.17
        for <Linux-mm@kvack.org>; Tue, 25 Jun 2019 07:13:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=nqUjvEpbHa4bmVVbiNY3TsSLDN/ESHjmI3nWhtZpm64=;
        b=p5uSNv0+D+48uXWbnDAFxxZWS0ByXvmHtROiU/YqvL13+FS994GRvngkmm/nD9XP4b
         khz6m2NiATRh6VQBpp5g0M3IsoCr5A5wA9I57o2iGMwFosidajTH3apeWNyzemxI+bMJ
         dzr6cNE0G02kYLPSApf2n5N1pWeOOSQVESkBu4SvpZ1DwYvrs474utmr3aBsQhU9AsJD
         GOdPLyjtE/zJToum1M3G5xkvjSEihF1pIEfVECD3nebT5qzgQC/kL9LGawvu4r/V1sUW
         E5qdR5Jyc7Dy4yVBLv6h59+ignH5DbjFGcoxqy82Tsu7j03DJ55dszr9YuWMuEQzvtrV
         sZiQ==
X-Gm-Message-State: APjAAAW3QZacjJcWmgRXw+uCRblIGAQJagF9YoDhdobuQXuDAy+VdL/N
	AIfmdRagUgfdRXrTA1NKXdOrE3v3GVEaUJtX1dQfCdQI41WcH3BgfHo+MSpVT02kfQG2JyqGX9I
	NTBBgUe4nJwW2WsfXcSAbbZMjXMC3AqNGvdCXpi+kwYI9r5B9yoT0Le8FbCE6GpD3wA==
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr31777232pjb.21.1561472026700;
        Tue, 25 Jun 2019 07:13:46 -0700 (PDT)
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr31777158pjb.21.1561472025872;
        Tue, 25 Jun 2019 07:13:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561472025; cv=none;
        d=google.com; s=arc-20160816;
        b=uiIXjBahhww4oAAzvrcMv3CYs2SCd76sP1rd7e+JuBuaTWMhyq+SAOmUDLZTQY7CtT
         JqYBLC9aNUF78rZYzwzDbNwHnc7fVnuER03N6IveivX7EgNgmbBTc6KM0Ar+APjXhULx
         B/BcZZVZRtbiCgtjQmholOJ2+ufteMZ1+quA8H2DljM81ab/c8KQzWZ6s1Yt6wqe4wAs
         D/pNzYq6akq/Hu+CTpgAkNl4HVXDUWBQlWmRVyuNqgUDvrEp8uHWFelGkJK6oHNGBCTT
         LVoqIn0RbeYqNSDePojcT9QX5FfDhqvV88EExb27EUkxTSy+wRHN7wMYHLhb9PkS8bUf
         Lgmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=nqUjvEpbHa4bmVVbiNY3TsSLDN/ESHjmI3nWhtZpm64=;
        b=aTHwUlP3VFWcg3jOQxFVapor9r2TiQg90Q+iQ+t1fDKu5PJQFAfSLiMfPT6PN6nyXT
         NXj6JswS5FnZlv4YZ0eTr0EqC8OQpZQWB2FTCw5bFtioTDX2i5cIxd/YMT/zVE160aho
         2Z9WoIVx6UHWElsV1opxxqtyjCyezlcHAF0kb7cVOO46MUeh689WAe3wa3n21pZ0rtbp
         832uh+2YA605o7ErxVJAcZiuKJaOmkF1p13O3P9Fze6+mVINDPg27d/cNwC01WvUPbg2
         vXLKybPEVaouFS4NJsKTsZOK/6L78dZP6PRpv6rmQ4CRtodTJqVdCEfzHWxN+Tv1Ehbr
         q7QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r80m0NId;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65sor8847049pfb.30.2019.06.25.07.13.45
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 07:13:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r80m0NId;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=nqUjvEpbHa4bmVVbiNY3TsSLDN/ESHjmI3nWhtZpm64=;
        b=r80m0NIdXLhEvaCqjUKhJX37qFh2W1g6cDf7weUm9jbNptPWp80pEUI9opw6H9gm50
         dNmhZXvCVB7xW0waafhq+LNBKV0JsgcA+qJLihBKEqAxTl87fkXs4vfs5m1RU6Ny1EUw
         xzHPIbBFyf5f0niEY2MbY1DGMxmKWiAaYEZLHWvQXKC6NDcTNZnPWnviqEIe2vTnY2I8
         v71WGhMfREL1Z5sxRTnGFOLtHP+T7LaFHL+uUCVZ+eGH8HuKVjbuAh7ZTJAEM7He/MYd
         r3R2cpD5S2eqqQPrPqIOM5OJ1ikTC7a4MnE9EfCIyVJrY8VYTEmwMnScWHDiyGbLNS/r
         46eA==
X-Google-Smtp-Source: APXvYqwBAkDTfGiLDfKt1+XLvKyU+gy/E6/TGdVcHhUhqGlY5n9j0/Z2+O2ED2nwS5zoHJYeucBMew==
X-Received: by 2002:a63:4f46:: with SMTP id p6mr7708849pgl.268.1561472025302;
        Tue, 25 Jun 2019 07:13:45 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7826:5c10:8935:c645:2c30:74ef])
        by smtp.gmail.com with ESMTPSA id d9sm15953790pgj.34.2019.06.25.07.13.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 07:13:44 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: Linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>,
	Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: [PATCHv3] mm/gup: speed up check_and_migrate_cma_pages() on huge page
Date: Tue, 25 Jun 2019 22:13:19 +0800
Message-Id: <1561471999-6688-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both hugetlb and thp locate on the same migration type of pageblock, since
they are allocated from a free_list[]. Based on this fact, it is enough to
check on a single subpage to decide the migration type of the whole huge
page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
similar on other archs.

Furthermore, when executing isolate_huge_page(), it avoid taking global
hugetlb_lock many times, and meanless remove/add to the local link list
cma_page_list.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux-kernel@vger.kernel.org
---
v2 -> v3: fix page order to size convertion

 mm/gup.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097..03cc1f4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 	LIST_HEAD(cma_page_list);
 
 check_again:
-	for (i = 0; i < nr_pages; i++) {
+	for (i = 0; i < nr_pages;) {
+
+		struct page *head = compound_head(pages[i]);
+		long step = 1;
+
+		if (PageCompound(head))
+			step = 1 << compound_order(head) - (pages[i] - head);
 		/*
 		 * If we get a page from the CMA zone, since we are going to
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
-		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
-			if (PageHuge(head)) {
+		if (is_migrate_cma_page(head)) {
+			if (PageHuge(head))
 				isolate_huge_page(head, &cma_page_list);
-			} else {
+			else {
 				if (!PageLRU(head) && drain_allow) {
 					lru_add_drain_all();
 					drain_allow = false;
@@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 				}
 			}
 		}
+
+		i += step;
 	}
 
 	if (!list_empty(&cma_page_list)) {
-- 
2.7.5

