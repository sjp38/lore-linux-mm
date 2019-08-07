Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FB7FC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:41:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A17182238C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OlUPUw8O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A17182238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D716B0003; Wed,  7 Aug 2019 04:41:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB79C6B0006; Wed,  7 Aug 2019 04:41:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D30FE6B0007; Wed,  7 Aug 2019 04:41:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98A586B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 04:41:43 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so50609708pla.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 01:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EyvgUT/mHFqMk636dxzLzzgFDS37eM5CM15yX+1C0h4=;
        b=TRdRUwvvDJy0x8IumVKLz1Cg0jRczBNrS/S0OGi7ckF7x+ojb3xz3yOCSKuKVaqK3P
         s7cZu9t01kR63ddF5jYBFfoNCRP1b+xa/qB1NXG5Ro/ulVGP3T5XsYw6JzqqKLd4JQ5R
         nYarBQ+MlGMhbX1mUaCQlwTS9JUqU21Tb+pCqW/CN5nI2AZnuI6gTfUo//2bdMhqMxEN
         BpPyPSTlcVQMK0CKzPLDEkVfGpUXBUXRtpma8wThpDQLoZFSRFP4G1xX7o5ygzSZF2QA
         kXl9j6zJ1E6AIzrBJDgpJte9nOmOTMwSNffTU/Ska8o7Iy7GAL3nnDFOYGjm+2D0bvt4
         Cfgw==
X-Gm-Message-State: APjAAAVtMxD7rXNsk9/bjlDoPIeuKcrPqzwZoqgBIWMJZ2FPBx/UoT5c
	xSumu8KXJ7//Z/sS4R4AE3iTF2uoaUtmBCyqhHnqn6N1qguWmW/1Q+Gbr9N6B98kRxyEHKqV1Zc
	2uqZbC0bPx8PD/vOmUdCnkY8qVOi+lDdACbwmJ3l0qNi06jHxM0WSLIIQ+yf7NXshPg==
X-Received: by 2002:a62:7890:: with SMTP id t138mr8055523pfc.238.1565167303214;
        Wed, 07 Aug 2019 01:41:43 -0700 (PDT)
X-Received: by 2002:a62:7890:: with SMTP id t138mr8055478pfc.238.1565167302572;
        Wed, 07 Aug 2019 01:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565167302; cv=none;
        d=google.com; s=arc-20160816;
        b=AfDSWXqXDwYnpTiKBjJiCVeVICCei1aG/EV9cYWzc5FrS7QIqwJP4ggd/rwHUSyei8
         Y6hQliNY8jbW3fG9vqH/gjsde1Io+AZ5TLlZyKKGFItCCg2Askv3vOVBcctToc81iPmw
         83OnOHwUvr752Iub+be00cgsEZ3eOMRJ/lHJyIu3u0Z9YM+Rxx3bvEw4rV/uDC7KdigX
         V3x+QRNkC03ofZremGSScvezBpv27DpYDUoPCfVrS4qetxySUIAu/uTwjov15m0S7w+M
         e6C5N2xkzrxWjjr7t89H9vQJOKikfyqlC1cTTyC7MLW6cxSiyp36sfvuUWEgw2G9G9wq
         k2FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EyvgUT/mHFqMk636dxzLzzgFDS37eM5CM15yX+1C0h4=;
        b=TH/A/m2Hp7y3OeTvtHLH4WscvFxJIcuuDG8INAL3hl8aNznhbp3dk1z9YSMSF3c8eE
         JRgmimHyioru9Gxqs3ocMHKPxte90HuoO8ud/8IRenOPgX9P4EPAHHcLjfGjZQcyzMXq
         6iyaCX3Asnz7teAFOP5apCPJ0/jAJy8XxXwN25VIzdpOo7zwbgZJpvx5VhbVS+Th1Ilx
         nRJfZdhuZYQrVpKUOM1dKm5LtqqOalIdoywvDM3aQl+/CC27DymwlO7CrSQaHyrSLYdy
         ZSepvh2UGl0BdcVZvvBs0SN4o8heEycAvVBHSQ9CFja2LjZbTRUkv+g6HbmD7InulVyg
         C0XA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OlUPUw8O;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w190sor15410928pgb.8.2019.08.07.01.41.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 01:41:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OlUPUw8O;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EyvgUT/mHFqMk636dxzLzzgFDS37eM5CM15yX+1C0h4=;
        b=OlUPUw8OMiKKCWaFUHD6Ldd8xeESIBSCde7fJSBGlkMgtMtAXAF0V5RYNm/uBNjNWk
         SccP1cbUdZ1EMPUBm8h4Wqkr76glmchV0EXc+DlVxTNTNUWLZ2ZuSIcm2KyNqzBmoR53
         CANTzvzY66eGU1DHo0OhI/Pna9FHVKCFPxPBSxoiMZNTSCn7Mi9iSqn/u4D3mVWELc07
         g6J5hQQJK3EK5PAUyg3ZNM4KKjC/cfggdgAjUhK8PwHfdyjNAk8tCfyfAOhWZLkIdqBB
         P3RBckcsZrkxQEJ925kS0ZzxNlibQDNST4aGHHnFvSj7lYJsBj5VAhRVhwO8nRdeveDd
         Ytjg==
X-Google-Smtp-Source: APXvYqw/n0QlPhHlhzhx9MFD9LDM+HAokHgsvQnV1xpG/W+ICmOn7xen/JNe40OAfwcvozRxSVEMcQ==
X-Received: by 2002:a63:f048:: with SMTP id s8mr6613569pgj.26.1565167301983;
        Wed, 07 Aug 2019 01:41:41 -0700 (PDT)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id f19sm135030521pfk.180.2019.08.07.01.41.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 01:41:41 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv2] mm/migrate: clean up useless code in migrate_vma_collect_pmd()
Date: Wed,  7 Aug 2019 16:41:12 +0800
Message-Id: <1565167272-21453-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <20190807052858.GA9749@mypc>
References: <20190807052858.GA9749@mypc>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Clean up useless 'pfn' variable.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/migrate.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741..d483a55 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2225,17 +2225,15 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pte_t pte;
 
 		pte = *ptep;
-		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
 			mpfn = MIGRATE_PFN_MIGRATE;
 			migrate->cpages++;
-			pfn = 0;
 			goto next;
 		}
 
 		if (!pte_present(pte)) {
-			mpfn = pfn = 0;
+			mpfn = 0;
 
 			/*
 			 * Only care about unaddressable device page special
@@ -2252,10 +2250,10 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			if (is_write_device_private_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
+			pfn = pte_pfn(pte);
 			if (is_zero_pfn(pfn)) {
 				mpfn = MIGRATE_PFN_MIGRATE;
 				migrate->cpages++;
-				pfn = 0;
 				goto next;
 			}
 			page = vm_normal_page(migrate->vma, addr, pte);
@@ -2265,10 +2263,9 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 
 		/* FIXME support THP */
 		if (!page || !page->mapping || PageTransCompound(page)) {
-			mpfn = pfn = 0;
+			mpfn = 0;
 			goto next;
 		}
-		pfn = page_to_pfn(page);
 
 		/*
 		 * By getting a reference on the page we pin it and that blocks
-- 
2.7.5

