Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B53BC76192
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BA062081C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BA062081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D9F6B0006; Mon, 15 Jul 2019 07:02:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBEAF6B0008; Mon, 15 Jul 2019 07:02:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD55B6B026B; Mon, 15 Jul 2019 07:02:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5B516B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:02:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so13338676edx.10
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:02:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6EvDuo1ssdDG8objEAwreorjmyHHeKgaqNxghdZyXWs=;
        b=Se5u1Fb1upcb0O5mLNptOKNa8pKhsi+LH4UqnOPNymp675dK99t/1+geJHKGnT3Nc8
         j1mmaZ2z+ZQTMWVrJRvuvak2nRJod1ydeUJFefpECt2hhvBSljoqIfRDcVzkYL9s0ZZy
         EsLVl5uHtP0MWv2ISExB16ZK5P7T1R+4hA0ybgTMk1VVKDOK8ikIH4mb+V/X6Xp10Xrf
         cObUnvbgdMLZ/QQFjH+CgTrCfCthgx+NSPLlHt4WzPIMxK8MF4uT6AQiOJoe38VKkToC
         pNzhFTHcmApxw6oxsYDI0Di9YNqzTB6PEpm9qAYv/Ca2WiLo6Jpd5xinTey/qw387vev
         tKNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAVz4XQhIPGFnSNtxqOsMCL/0YULosO0dTMVvfmZMgdG8ZCEgHKj
	vMXc8GdvwRuHx4DHTyAiB8cTaDTJMSPEZVTXtf7rFBcY5PXFrhp8lGzZvSjbPd0p5aYsu5evTas
	w+jveEKfkr7IDG7sYjKdIPBrjvBgRk14dxIHPxLB03jESUsULnFBBnZ/+sRaQNdphfA==
X-Received: by 2002:a17:906:454d:: with SMTP id s13mr20112597ejq.255.1563188543894;
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7WIPdeNkqcDY6K6T7jMZ6sgJaVAXlpTCnGgtwPoH8LUdDbC8uQfvrWpMBnVPDye/xYt5I
X-Received: by 2002:a17:906:454d:: with SMTP id s13mr20112522ejq.255.1563188543139;
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188543; cv=none;
        d=google.com; s=arc-20160816;
        b=ol8rhV/4IvcyKvw3T9laU+X9EbrR6sAw89DMY7ldGOZ7QYMzIRtfZCGwLaC/6+hZWV
         HuN1Pbfh/F5n1KicJYYI70ucSJNcrM2sSdmgxxRghkRXn82TzysEs+KMKpXQNYDig7ug
         RGCisDp0Y/WzblRBJIb+I/wDVgR/kiwghIuo/cd1Ftfi9RLbnE4Fki7FLgtEe3CLvL9H
         J51cbohBFvofVO6oMOBPHRa0+SNWzPxtQwD53k7JNFhbYPPFm6luY9Ie0EHLhOzFnZhc
         Ppv8hal04buU3nuV5anO/jW8yQ6UpeCDbSrXTu6GzKFSD12Z6h6QuUAbml6zID4L+fwt
         27fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6EvDuo1ssdDG8objEAwreorjmyHHeKgaqNxghdZyXWs=;
        b=wQTkM8H0bGYdfngP7KyT0eRjfjTwxH8DO0QR503pWwD6rntcOuvmGQUiYp7cErOke0
         OYugith94PbYW46YB/3nekwuFcP16oD5NufmV/nK29tB+uXwIc8We9BN3GnEJXWWQxcG
         Y5QAHdfIBdjKAIeGbIxuJdeBRqHuucLygy4AuwprcCYmHvHcAk92zixPcOmPyUY8Rt+/
         evNJoy/0HeDkgCPKfSec8jnso+tkjWOV4eo6Bgv9h+SpCzx+9fZp1gT9yq5diD6nM49k
         4PWao356feOhAxsRuS1SZeD5uHfiQAXlZ7DqTd0hxesOK2sCe5FOtx0r/Oi6tdTwdEVM
         FcnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id y2si11033628edb.188.2019.07.15.04.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 48BD0133; Mon, 15 Jul 2019 13:02:22 +0200 (CEST)
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
Date: Mon, 15 Jul 2019 13:02:10 +0200
Message-Id: <20190715110212.18617-2-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190715110212.18617-1-joro@8bytes.org>
References: <20190715110212.18617-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

Do not require a struct page for the mapped memory location
because it might not exist. This can happen when an
ioremapped region is mapped with 2MB pages.

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

