Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0E08C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A33D20665
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:14:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A33D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2413C8E0003; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF976B000A; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 091EE8E0001; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4E806B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:14:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so17447268eda.3
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=q5k3+gcYubZ7T/g6o53+F1W99oG/lraAHoxlon+CyWg=;
        b=AMsY3axQsl5zoc5BSUbl2XTj2UiA06t14QSi/G88/txHGRBbuvpvsRh9VkqekfYR5U
         2NfCnQfRjJ+AcvqTAJ1494aLJDXd8JaLUT4bdsQvplG6tJkh9d62gsTqdTbX1Z1zp3L6
         MkNxik/aKxHypJ22iEJAB1qkHAQZjhuCMAi3WtGQnHm7iEe+ZQbNvdxHJjw/71Zum+aF
         f0OPK85X1GXqrLrRElh7vp+1Vpgd2MaNMA0HWoc2ONvBs9khwCwYDy1TLIdzRiCznsr3
         OWQY8cQFfSwZU5b1ijRo7DsZhoqCy4j70m40OygXbzx3xWPDyZz5ZMC9icGEhvsYy8o1
         20eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAXzl9Ep5y8I9ZcwB3k3qFwGQQ4kc0NVMdgLS21LnSmkqGFMqFG2
	K/txSEEJGFr1J0BvLPO8t/eKe2lno+6qdqiZPz5V0HUYuimft4sOdT0FsYY1ARBI+QZj84dLfqS
	dYd58AaeRPJhZ4r57jgTr+wRDUGAP8xj0QdLx/DiLhbjUzAOdwAdYlVwVvW+WUP9M2Q==
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr30445108eju.57.1563347693392;
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVSf3653kEOUktTLwEVo68YDGnMuFDwFNAnRQWXvN8R2/y0K7rCdsX2Te08bSsIeDsHAcK
X-Received: by 2002:a17:906:4e92:: with SMTP id v18mr30445061eju.57.1563347692573;
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563347692; cv=none;
        d=google.com; s=arc-20160816;
        b=ZniRpl8EC1SKtT2piC69+VIg7Wkm7puNjmOaFJvPcEg1tHwq+99em5fuSAcNs8WB+3
         na+YUyG7KBTThJ/IG0uv1AiQPNkp6L1ERUV/1pTCr5KOQcZXFZZUdKYajXQOWhrAfDYu
         X9KlX9X21Dg3HsRDcN9VuAeErsV93xf+mV1qp6Ow1YitQnGOmafYjJjYg9VzJ4b3Rw4Q
         U389eySvzWNB0Osu4SR+fkSTw5XRCi0ZF8Ll3BQlUCUJQOnHVqDgzcteDnX8YY/6VSyc
         811XPLAUhWqu80YO27CzDc5FtDQBsDh2g6k3vBQkI0q5TlnqsukRHYGQNUsK7KSdOK8f
         /kiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=q5k3+gcYubZ7T/g6o53+F1W99oG/lraAHoxlon+CyWg=;
        b=BDSw3N0mZlk7EQCKLleqmH73+ZA9dJSUXHZrbfchC6TiDW1BLl7WnBRTas6GCebnZR
         nAcSo6CHd6eBYQuPXg8DfmJEyZwjxptPfZUFu387WuUED2KCETykG9bxU8ZPhmEwJacU
         7Kw7NY8o41xhkvhk/mgxN350d68w+YUv8BdFJ4kSe/AJaqzS7+9StZ9iSe5sE4AZ8LyX
         yocADAibM2gzJwczVlWrpsW8KUuv3iXjO2/rYbUkSKZuZbQCOqVJOJzm9MIV8mfUxPPO
         28LfWiaVzAAg/PT8u9mN0DJ5fLCObmfiJPA99lDGmItkkzO+5VT/mKJ1S/8zWpmVRbAD
         Hg4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id s18si14384582edd.291.2019.07.17.00.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 00:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id D0A89260; Wed, 17 Jul 2019 09:14:51 +0200 (CEST)
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
Date: Wed, 17 Jul 2019 09:14:37 +0200
Message-Id: <20190717071439.14261-2-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190717071439.14261-1-joro@8bytes.org>
References: <20190717071439.14261-1-joro@8bytes.org>
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
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/fault.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 794f364cb882..4a4049f6d458 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -200,7 +200,7 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 	if (!pmd_present(*pmd))
 		set_pmd(pmd, *pmd_k);
 	else
-		BUG_ON(pmd_page(*pmd) != pmd_page(*pmd_k));
+		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
 
 	return pmd_k;
 }
-- 
2.17.1

