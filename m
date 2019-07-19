Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4572C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:47:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F6221849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 18:47:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F6221849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 549816B0007; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BE3D8E0001; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EBDA6B000A; Fri, 19 Jul 2019 14:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF7726B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:46:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so22582509eda.9
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=frhztlN5AYKYRdcM3ZCTEqvQvVkkG6CWbRdHoyjRbAE=;
        b=RAA1tsrxHNtAHDKfiVcbmdKE+TPy7jL5Z8bTec7HDtDoVXIctXbpEvS2btmfsO2RjT
         ay03RnAQgO1on++RKwdiVIhB947Ov1OarxmMUmvfEVoMv5dzsuHNjbue+AedLvMOmEoR
         EiTpSdmfBNdlbt7LWm/JYHMBv1WQ7qLP4VUzy+cCXb1yUZIjN6sRz42reK9cE2FTPCBd
         OyiwFGRNrdk9SLt/usUTRX5KH3esbC/oOD/C9dbFiRjOsqepMNMjoGd51I1t7S6O5q8X
         YNZQ/gOMvf/A9aj1zVhvrksCIeCOJRWCR2hwybxfsNE0r1Qk5nEDpBt3gSIUMCv2LPT9
         gAew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAVi2QQ0H6J+3Wgpc1X/R9Q98cN1lx9Aps3AbUnqKQp3OoTARDNb
	gpqUpe1AKhvWi9RsxMLXOlTpWqFY1Cop60r30nbzXfP5rgpvrdDXdW3zQ4xCmMoceaUbE/KlQbr
	9naRGOH5EAp5A1iq0nJJkEGbBemJPsMdeVNJn2uvZLeFdBpM8TsTRvwNa5nty541eCQ==
X-Received: by 2002:a17:906:a417:: with SMTP id l23mr30717293ejz.20.1563562017356;
        Fri, 19 Jul 2019 11:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjgtrWT/UikRyRwWz7dAU9AIfMNj/CtBjpzOO1MjUmIokPiYkXFzrKObibcbs0CqXdtZ3b
X-Received: by 2002:a17:906:a417:: with SMTP id l23mr30717227ejz.20.1563562016260;
        Fri, 19 Jul 2019 11:46:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563562016; cv=none;
        d=google.com; s=arc-20160816;
        b=dwwVnvrsK8tP7V01aXM9hR25Vn8IojU3tS5pDM8OfPWlVb1SjjMKG62ep1uPmX2CDp
         /1CrPWc1pYcoencjG60Y9T/MKWjw4KInoWBYUnNb5GoXLGsFfQ4v0Tlu62Y1BLOTIpyc
         n9Okj83vrqQwUT9CmtGoMo3vO4+Qvy6FArtu4GhnM5Rcu7VjhT0eiQjXdY3L4NzUH2c0
         TlArsFtb+MS/IIZAEPJKAbR2OU6iAynf5cGp6TfV+yKfkHKPDu/MDTouXU+QDZmtvylM
         BrvUGCXF+JNznloRcSV+ouoeHP98ZTqJt+jYzWvwASYUMfLdQ2+R5OOPo8/0MMe0lGwe
         /5Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=frhztlN5AYKYRdcM3ZCTEqvQvVkkG6CWbRdHoyjRbAE=;
        b=G56QaFCfXmlmksVgarRyhCzIfcBYDOjslclE4BmdfWkoOdiEmWu5Kc4jyOyJxP/qHS
         xk4f1MCf1LuUyeQSvR+Oez/cRyckLcxOBLERJB8AsIBEJFzfkdJywZ1+stena6PSfZre
         F5rnB8YX9prURsJZRmBLtlbiAbKm3de9qlH441hL21Rp25ZopbrUE9nyMjL2GNmJfs3Y
         0BIjjqb3Icr6BZ97oZUaI8U6xd/veenOADDhW2PsDSH+YHWiHjRbR1RvQQ5rHqLAjEYO
         91mRPwA2zPsTs9nGqEs4/TAHqnomicfwVwY79L++Xs3wTQfHtjdjVr81M3vMmnWSwyfW
         WaEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id f13si858693eda.21.2019.07.19.11.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 19 Jul 2019 11:46:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id B973B273; Fri, 19 Jul 2019 20:46:54 +0200 (CEST)
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
Subject: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_all()
Date: Fri, 19 Jul 2019 20:46:51 +0200
Message-Id: <20190719184652.11391-3-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190719184652.11391-1-joro@8bytes.org>
References: <20190719184652.11391-1-joro@8bytes.org>
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
unmappings and make sure vmalloc_sync_all() iterates over
all page-tables even when an unmapped PMD is found.

Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/fault.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index d69f4e4d6918..8807916c712d 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -177,11 +177,12 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 
 	pmd = pmd_offset(pud, address);
 	pmd_k = pmd_offset(pud_k, address);
-	if (!pmd_present(*pmd_k))
-		return NULL;
 
-	if (!pmd_present(*pmd))
+	if (pmd_present(*pmd) != pmd_present(*pmd_k))
 		set_pmd(pmd, *pmd_k);
+
+	if (!pmd_present(*pmd_k))
+		return NULL;
 	else
 		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
 
@@ -203,17 +204,13 @@ void vmalloc_sync_all(void)
 		spin_lock(&pgd_lock);
 		list_for_each_entry(page, &pgd_list, lru) {
 			spinlock_t *pgt_lock;
-			pmd_t *ret;
 
 			/* the pgt_lock only for Xen */
 			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
 
 			spin_lock(pgt_lock);
-			ret = vmalloc_sync_one(page_address(page), address);
+			vmalloc_sync_one(page_address(page), address);
 			spin_unlock(pgt_lock);
-
-			if (!ret)
-				break;
 		}
 		spin_unlock(&pgd_lock);
 	}
-- 
2.17.1

