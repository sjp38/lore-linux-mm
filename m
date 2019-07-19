Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EFF7C76197
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D79D421849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:46:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D79D421849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07C716B0005; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1F606B000A; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA5C76B0005; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 941AC6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so22565456edr.8
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=U8VhW7NMRWIw2lQUClIkQJ0jdR5sgitKIPURN1A8TyA=;
        b=RtXX4W/lrheDEOLw5KJ4pSDwiJSe+dMj6NVZlhgRv90TZ7Ulvt8y7hiVeJcLwpx31N
         JExlTe2uDf3K6OGe/tW+FmmHLHhWZ3vFp+Ya/MjeLNcfg1/YWYauCRHyrs+vZAylEhov
         6hCCnLnsIo0XCVQYGfezMp8pdbjcPBM6Bk4uJeceqPnGRMnRbIFRHoMwlnc4LD2ds8SP
         2X+Ws2UqiiCYDLR7kr8be1DdIyS18SqtsOJLz0xF4Bcf9lPfg47NnanqEC3nz9FpnUOd
         swVDOLtNDSHjC3tmQtcpsn9X5iZ+T9LNT39o5iAZDRRr96DRMVoBUfsC+jFhSLSdLuUd
         cy1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAUbMWkIvfG7OEWxy0kLRZUhtJrQhkTadU86Qg9XfEaxiPYeOAvd
	RAm4ouIa0rKpKEdzjqE+lLp23C25KVzey080Muoe6zqvfkgHmYUjjen4dvxmmNVNTqNUHZ/0MwG
	Z7TgSq/0m/2gJmZssx6DPR296Ql9YpOHz6v8kpaSbjBjSZVo1ytbxnXlEnwezSB4i4w==
X-Received: by 2002:a50:9999:: with SMTP id m25mr48467005edb.183.1563562017136;
        Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzhrVL+c+Jc6MA0dE5AHB9vzq2por6vrfwTlZKRdMeMtrHdFvDoufgEVHmvJapaBjETDx0
X-Received: by 2002:a50:9999:: with SMTP id m25mr48466921edb.183.1563562015853;
        Fri, 19 Jul 2019 11:46:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563562015; cv=none;
        d=google.com; s=arc-20160816;
        b=QWlFNR+lSNwDKPinCkMZMJuepEqpT+B1ZbFm2BgLjm5ItiwwYa/PiZ6xuBlmfS465B
         BUcgFUgf874O7rYpZNzljJfTbpnpBr5ZEL3Zh5OJyhZ1As67E7+sHCBP3tZt8fv90q2o
         cn7zi1jFMpm0TjbSA08KRNQWArkqMsERPsof2f9AaFV9RPF449k+/vMNRFbMARcrF4lC
         ORKMD53pSvxewFDC7zTuUI9n+4BekFFHeb6OUJPaFL8lZ5UHpC+sfgQDSCUNh8b4+8pR
         AED8ScUfXmCeZJa7HkZqQkEPK8cTvzfPWtnRfp/SuSsW7JUVqIX+1BZb7iWw2bVVZQ/d
         rwwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=U8VhW7NMRWIw2lQUClIkQJ0jdR5sgitKIPURN1A8TyA=;
        b=HEfmBce82zRDcuniokHbK6fQGg0c/fmr+7Z9ybQOUuosTgrmIpCI3qvq9dMjNZrucA
         SJ1tjfuGp1kGl/9oXyKuoGnHQP5/h2ZZgrXPa/TMkX5PFhGnvKWpy+EVRYMR1jV+OOPV
         uCoe8A9ojAi1c6AwppQMcGZMyyr/BJ3BJ56TlqJoQzp73HmwxKLE0M20Hf8k0QUJtFlO
         lzhjoqc0YYD67dFO7l65NuxbT90flRuCCoRXP93EP9eDt6Ys1owu1a8WZR8VkL5gBdx9
         GrnGv3U8coNrVfnhKgnIvLPxgnpQ8uQBrwG5evOP51qRnM/howcoziyB7NHAgIMh1uMN
         2CqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id t23si143787eju.143.2019.07.19.11.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 19 Jul 2019 11:46:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 89FE81D3; Fri, 19 Jul 2019 20:46:54 +0200 (CEST)
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
Subject: [PATCH 1/3] x86/mm: Check for pfn instead of page in vmalloc_sync_one()
Date: Fri, 19 Jul 2019 20:46:50 +0200
Message-Id: <20190719184652.11391-2-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190719184652.11391-1-joro@8bytes.org>
References: <20190719184652.11391-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

Do not require a struct page for the mapped memory location
because it might not exist. This can happen when an
ioremapped region is mapped with 2MB pages.

Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/fault.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index d1634c59ed56..d69f4e4d6918 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -183,7 +183,7 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 	if (!pmd_present(*pmd))
 		set_pmd(pmd, *pmd_k);
 	else
-		BUG_ON(pmd_page(*pmd) != pmd_page(*pmd_k));
+		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
 
 	return pmd_k;
 }
-- 
2.17.1

