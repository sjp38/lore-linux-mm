Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18F3DC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C96C3208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:46:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OP0W8yRl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C96C3208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721956B0010; Thu, 13 Jun 2019 06:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AC2C6B0266; Thu, 13 Jun 2019 06:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54B6A6B0269; Thu, 13 Jun 2019 06:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 152EE6B0010
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:46:00 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so7714439plp.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:46:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=uCwWLrWN30s9tONuGry7ZPwH/e/7xLPMQjqyo7O5eBk=;
        b=G4bbsHUvE12jV68huhwUgzoHH4opSGn266Q5FZzqB4YEEba/nWf+D0sh64ci/yjPk3
         FhsLmfZwcUxvoWxT4N1rQm1YKTnuBU9HJHRWIdNmkORM7dDqQjwZ7diI54yBqf+mIDDp
         frA0MPxjmVOMIW0ng5Y7q6IZOBrmCFvjSSiqdHfd72/GpUmPnr3c2MomGB9ulnqn4wm2
         vWnPb7N0VVwzcSxZUL/0/GgWY8sP4Fh7asNOmOe+IagIfS6dTgXVC18N3AgVlfZ0PsIu
         xD7thuMWSGdrqnf7RJDV4LIuAc5D0qqkeUBBqVO6wEtQCa3t+uzRuF605qWE4ELf5Afq
         qmVA==
X-Gm-Message-State: APjAAAX3grM1gMOHr6IOaFlvoYRBrb/0S5H64JkxmqxqqOJWheBIQ3rj
	VHVeRV1ZCw/GKunwMqonlTDu4BuCVkHCp7cB9c7QuiKHyazV6mW7Wh1CywaJgr2gqN5FIzd3x7k
	avx+FEdaCqZXwxih8Few+AjTIOuhtTcKzF59blAbAqKQqxGlSZk8Pz4D4fzPll9bCaw==
X-Received: by 2002:a62:5e06:: with SMTP id s6mr95120015pfb.193.1560422759757;
        Thu, 13 Jun 2019 03:45:59 -0700 (PDT)
X-Received: by 2002:a62:5e06:: with SMTP id s6mr95119954pfb.193.1560422759188;
        Thu, 13 Jun 2019 03:45:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422759; cv=none;
        d=google.com; s=arc-20160816;
        b=0vaW532rLSzvNqfyRJsbS/8QDK2yBtJyVVyv3vEOvtFH4Pfhy+KM8tjndQKsFp+eeE
         suir04RbhoSwRAy286eDBTZGpoZeVgQFPXHh85h9EQauwRGtkw71PUXbschFjj6aqqpE
         9HaU6MyXh0FnovPfQHTdD2xTtCbbsvMdD+W5cASwynqZpoQlI8mC1Qq9hO0sXN+CIjLk
         6W2x2H0jF0XHncTb8JerJTZV/4uvIbHRBUvGLtozAfj4feIwqC2BP3Ueddze1QIHjGHt
         cXcXUCO4ytj2soSz7pqjbhrZzrh4NjWfzDqXlKcEpw/9d0T8XLDUkQUO+5LQFnd+JL/t
         uoZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=uCwWLrWN30s9tONuGry7ZPwH/e/7xLPMQjqyo7O5eBk=;
        b=UjO7jDkofulH2nVzZqgUczoqT7AdWHeoos/VxCb3t18nP+9eIDO42oOERafVmN6Pdg
         LpYS4NCR8T4oKwrzpHruIzbpF/4thmegwUNe0kcCCV3yKqzqHcbG8zwCR3wnjINuZods
         kLlj8gvN5ABt1wjG8Ka0SA5KC9n6lrw4UkYnpmXKI66VWEokhQ7kNxUqHK/0oDqzKetM
         EpETahMJGUOPw7LYHSzaglEDATyl61o2g6YQKZDBJAqzsi67dAC1aMZNWMI9LS1W3IPG
         Z56G19AS6d0KckDOqXp+/hcHrIf8QU4mVbfQ3QMDYTEiHDC2zzqPX74Zxt3/5vc49fZc
         LnxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OP0W8yRl;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m37sor2664059pla.6.2019.06.13.03.45.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 03:45:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OP0W8yRl;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=uCwWLrWN30s9tONuGry7ZPwH/e/7xLPMQjqyo7O5eBk=;
        b=OP0W8yRlUthFREqCxHMZcGfrR7ObjX7GSg3sDYQOctNsRHbm2Lqcb/opmbujosV95J
         Kh99aG4N5q3cD8Qe5BzWR9WJEMlx27hM+S6fiT/SGbKF6lFXXfH5hU2LKUg7g4jKajV7
         i+CpumuA89UHiI+0KEwM0sEc8xCFxvGVPnOo/wSJ+eHrjcMmDLkXIKzRiOrMhUlW3xX2
         0j2845eItLsOowqgOEDPMtCStDCTisuEjva0X94eD9UD6KLLzhjtMkuZ7kqhppDiaS4C
         nwXrzRFqbHigTy4SOi86TzPaELfID3cNgUHIFdnNBPTaW8jZPP1i+VQqes+JkhBDgzO0
         JNAw==
X-Google-Smtp-Source: APXvYqz9LfQKa/wrOUIWnFUFZ/wGYmdDsdGq/Xe0dgLwb9nKtqXnSonygBcQvBArP0L1tEzTp904NA==
X-Received: by 2002:a17:902:a506:: with SMTP id s6mr12547789plq.87.1560422758789;
        Thu, 13 Jun 2019 03:45:58 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7825:dd90:9051:d949:55f9:678b])
        by smtp.gmail.com with ESMTPSA id a13sm2813285pgh.6.2019.06.13.03.45.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:45:58 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv4 2/3] mm/gup: fix omission of check on FOLL_LONGTERM in gup fast path
Date: Thu, 13 Jun 2019 18:45:01 +0800
Message-Id: <1560422702-11403-3-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

FOLL_LONGTERM suggests a pin which is going to be given to hardware and
can't move. It would truncate CMA permanently and should be excluded.

FOLL_LONGTERM has already been checked in the slow path, but not checked in
the fast path, which means a possible leak of CMA page to longterm pinned
requirement through this crack.

Place a check in gup_pte_range() in the fast path.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 766ae54..de1b03f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1757,6 +1757,14 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 
+		/*
+		 * FOLL_LONGTERM suggests a pin given to hardware. Prevent it
+		 * from truncating CMA area
+		 */
+		if (unlikely(flags & FOLL_LONGTERM) &&
+			is_migrate_cma_page(page))
+			goto pte_unmap;
+
 		head = try_get_compound_head(page, 1);
 		if (!head)
 			goto pte_unmap;
@@ -1900,6 +1908,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	if (unlikely(flags & FOLL_LONGTERM) &&
+		is_migrate_cma_page(page)) {
+		*nr -= refs;
+		return 0;
+	}
+
 	head = try_get_compound_head(pmd_page(orig), refs);
 	if (!head) {
 		*nr -= refs;
@@ -1941,6 +1955,12 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	if (unlikely(flags & FOLL_LONGTERM) &&
+		is_migrate_cma_page(page)) {
+		*nr -= refs;
+		return 0;
+	}
+
 	head = try_get_compound_head(pud_page(orig), refs);
 	if (!head) {
 		*nr -= refs;
@@ -1978,6 +1998,12 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	if (unlikely(flags & FOLL_LONGTERM) &&
+		is_migrate_cma_page(page)) {
+		*nr -= refs;
+		return 0;
+	}
+
 	head = try_get_compound_head(pgd_page(orig), refs);
 	if (!head) {
 		*nr -= refs;
-- 
2.7.5

