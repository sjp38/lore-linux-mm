Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DB4EC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FDF020665
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FDF020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 722B56B0008; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DB978E0001; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 573E68E0006; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20A068E0001
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so17452632edb.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OPVNf1Z/jEqzPnDbfZdzm520W9qSF3lMG0lCY2gLoj0=;
        b=PCRnYYWzLyrFcf2BOmudDZRQXd27uXXp1tNCFEsDie6f6I7a2UOJlwYeAhZOhj6di1
         QDjlhrPiA+o01C3K+AZK6GOwJYx++Oiqh33hhmKwCyM7kwmlq4Z4Gj4QZsIn/9Pbt+3H
         +wN7476BAQbh7uEJKNnKIIJobepnNe1bUZOS4ggsIO/DPhTt/bcg5HDtwMRPPk34z82M
         43y5q4LWYxNPxY1fcrHsXbtSXI15ZNm/KFXvwq7brqklHXnt3qTG+XmwdnRQCqG6jy7q
         XrgpZbMRC7eIb7fQ7Pixqc4qARcrSuGdmPTLIE5FQ/sORTSm7mdY7ahFOmftQMg73+PM
         r1bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAXk1iWi+DJ49p9nXLJbuDbKRfMraCXyLeuFz+cvTiQvQvSXkn9b
	VUqMFo++zmvAMYKpz5qxVj1W1o0Oaly6H/8j+erVFB0kQG32SrD/ZQx4N6+fxsYtxKrLskRC2r8
	vaeRF2xsX26ROfQ8wSnx0SltCuMGFS4bcn6vZlhUa6F//VZmuYAS79ZraS1vM1zST2Q==
X-Received: by 2002:a05:6402:8d7:: with SMTP id d23mr32880996edz.17.1563347693725;
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3vuFjlmT6d5MBK0MUNex3gfqRU4xOdQ/BHbUrsXB0Mpf2cscBc2yTA4LQfyDpiZjkw97V
X-Received: by 2002:a05:6402:8d7:: with SMTP id d23mr32880947edz.17.1563347692864;
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563347692; cv=none;
        d=google.com; s=arc-20160816;
        b=nAh4H3+2z+VrRP+KhDtMJ2ImuNHd5MtfMkpqEMLZHYbW79ZN8q91JwtJKh/fcxXrbI
         gX67hafC/nbbfbfXIxuqQ0SW7nA8q8bED4Hvzbdma0TmyetgkNehGTzsl7KMINQ2UOEA
         qJshift4EVhoxRZsPffI8Qm5DMyvFBL0OF38NsWjtkESz4TsUiBZ0jkCMUNkL2gx3FjW
         z7cwmTGnBocmkp0sZaOuLJ5sHj5OhxsXnb/kr+GHCotisbWMy7WvCAG76BXhdxuooFyd
         gGwj67jlf9UxU+zXLOfLpGittGq5g+m5wc4pdLNlelo1WtOiMej6X1my8wNksonVnQmZ
         oIjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OPVNf1Z/jEqzPnDbfZdzm520W9qSF3lMG0lCY2gLoj0=;
        b=VyOU+BdttuUNw9lyhzlEc/2z24Gd92ZryTnJ0PjL+lF+6N43PlC8eJ72PLfu324+I2
         s/lkaOZC1JlxcZIbZ/RjjAtOwSaPA9fcDWyWPzL9L7A0MTZlShdeUEwGnrZXFVPBV273
         rttS/AprAKdq++nvpF6KE9IDYXLQvcu5MwR7P3CVNi7wsVa53yu0TrCa7nRN6geCDMgm
         SPeBi8JlMhK7JVW2H1E2KrDoHoer8BtBhB6bpZKwVTMx/sJp/PUe4D7+RQPtz92dJvn6
         +grH8T/erbCgsF8spI9EPyLudcmNXDxsDV7doVAD3p/R843lUzJF5XVE1Ix9hXfgBAVW
         +3UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id h18si11237867eja.313.2019.07.17.00.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id F382241D; Wed, 17 Jul 2019 09:14:51 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <jroedel@suse.de>
Subject: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Date: Wed, 17 Jul 2019 09:14:38 +0200
Message-Id: <20190717071439.14261-3-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190717071439.14261-1-joro@8bytes.org>
References: <20190717071439.14261-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

With huge-page ioremap areas the unmappings also need to be
synced between all page-tables. Otherwise it can cause data
corruption when a region is unmapped and later re-used.

Make the vmalloc_sync_one() function ready to sync
unmappings.

Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/fault.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 4a4049f6d458..d71e167662c3 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -194,11 +194,12 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 
 	pmd = pmd_offset(pud, address);
 	pmd_k = pmd_offset(pud_k, address);
-	if (!pmd_present(*pmd_k))
-		return NULL;
 
-	if (!pmd_present(*pmd))
+	if (pmd_present(*pmd) ^ pmd_present(*pmd_k))
 		set_pmd(pmd, *pmd_k);
+
+	if (!pmd_present(*pmd_k))
+		return NULL;
 	else
 		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
 
-- 
2.17.1

