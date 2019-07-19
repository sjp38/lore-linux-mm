Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13E7BC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5ED021872
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:13:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1Mw5q8zi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5ED021872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 729318E0010; Fri, 19 Jul 2019 00:13:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DA6E8E0001; Fri, 19 Jul 2019 00:13:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A2508E0010; Fri, 19 Jul 2019 00:13:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25AB18E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:13:00 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so15152944plp.12
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:13:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Yt0cijjvguaGTcDcCWzQKe8b0ogqE525NNdsB76BIXQ=;
        b=rscDZV+u7W1adLhB059zLlDXkW5p71AjkzCDsrfn006SrH2UGQtEaD+1VwZm7A1hHb
         R5t1AjRZnmtKst71KUt2JGByto70fvXSzjGvNpiEwZm9qX1xIGVegsjg2BuBRo4svofc
         fJDcbJ5s4AEhxFgxbnUdG4iUM3LdzRE8wlPcJYZ+fQbfHOdeiuLz37ve728yvQ9T1dwl
         uaSmD/wajx9GmhWLiWb0oQWkcfLj8MT3dHDWLr8Ged4wdRrDI2KKeQ8FIoVLPAqT4/pE
         lBB1lMs7fDaZzFkqZdRAi2OnXOdRabjW3b9Gf7V4SqaqBuWJrUezLoAOgQ/3dziR63Ow
         XCaw==
X-Gm-Message-State: APjAAAWukQAV0/9U06f5Har8HCyAJjVqANwCWl/E/JLCfUUIoreSIkOD
	EKdEWxBoqs+WzP7DhJwQvOl6UI0QIvkuaz/HvDvlt6/tLkjBZVTjrpOhaLM7n5JMAG/ETRpzdHa
	QOamaV4TWQRNGMZsKc7uejCypsqjWuNSk4xm6jT+3lF4X2/Hw0rilrwJdGtQ8WhOW6g==
X-Received: by 2002:a17:90a:9a83:: with SMTP id e3mr54228069pjp.105.1563509579840;
        Thu, 18 Jul 2019 21:12:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlh5MqkAnAYXRLmYFb7H02DJvFV4coCbTY9dsEMERnzTNE3xUF3mLjO5vcu29ZYchc2htI
X-Received: by 2002:a17:90a:9a83:: with SMTP id e3mr54228022pjp.105.1563509579164;
        Thu, 18 Jul 2019 21:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509579; cv=none;
        d=google.com; s=arc-20160816;
        b=GwWD9QWP7KORiKvUDaMnX0rU+gmzqTFfQkA/mBF/s/uIv5sh2ON/y+oJMCV/zMH4be
         +ZPNPCAs6mPHdh2BfADR37K7zNitaEraUiALkLESykINEVV9J9I9uSnpnQUtrqBcbVEQ
         lqZRuWhOakDUjoBe8Plod46BIBbTRMFOP1kB39O18GE3RMDGMU5Z1Cmy+EfUrkSS9GpA
         CnWKx0g3/y+zBiQa2D4bxbnwh5LjJTS3loSs7JsYaDNtLo+qT74sKwwBIbbvvhnZGtaV
         HrFYRwEpCNSsJO1yzEB51kEQed4QgaqjyMS0t1g3U9lszGDAsp/wJ0KRHK+GXT6HINnq
         wOAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Yt0cijjvguaGTcDcCWzQKe8b0ogqE525NNdsB76BIXQ=;
        b=wohcqykZeOMMCQP18WvG5VV9BioVLSE91/y/6IL1n1NFLAnJ4FjBgapz9h4SGRsoqT
         PM7FF9cuAHmjUodavQtHqfw79Sj+v/5vgLJyCaVTJd2WSRL4i3VPHooUXnKeeytg7axk
         9NqqMJUqifGAd7ezfTR6VLMz70k7v9mP8sINcG2aQ9moIY3cLN0JnRlMEV/i2gdtCMmi
         5ng4/kTHAiwVhEHr+s8Vgixlg4UH6AXW4J/Tr+9i+4ul5KWph20mSr3acpfzddRfm9kA
         /MwWmshPU2CLQJO5DDVnqe76B6BivkUdNIaCsIkNzZgfiHSOZ8jN+yNYv1UVTcquSptT
         QHwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1Mw5q8zi;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d19si1096233pgl.53.2019.07.18.21.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1Mw5q8zi;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CABF2218D9;
	Fri, 19 Jul 2019 04:12:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509578;
	bh=x8AKJLvmaofzajFpXXOgSMt3oKinJpXRzauS1ds9IuY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=1Mw5q8ziNm0ExuYixXYiDPe86VXjdnFEdVJWfbJLGEvs3biL01WA5ip6G58Xre41U
	 2poxe/ydv4UnethyIkFC43ftYvmGwA7xlEXOBMuM2A8Tra5P4JCPzEe+cH/aOUkd/q
	 wlmbYe1LvfdSvXte8RFT8S0dcYr0qUv/pqSAnNBA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Florian Weimer <fweimer@redhat.com>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 58/60] mm/gup.c: remove some BUG_ONs from get_gate_page()
Date: Fri, 19 Jul 2019 00:11:07 -0400
Message-Id: <20190719041109.18262-58-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041109.18262-1-sashal@kernel.org>
References: <20190719041109.18262-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

[ Upstream commit b5d1c39f34d1c9bca0c4b9ae2e339fbbe264a9c7 ]

If we end up without a PGD or PUD entry backing the gate area, don't BUG
-- just fail gracefully.

It's not entirely implausible that this could happen some day on x86.  It
doesn't right now even with an execute-only emulated vsyscall page because
the fixmap shares the PUD, but the core mm code shouldn't rely on that
particular detail to avoid OOPSing.

Link: http://lkml.kernel.org/r/a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Florian Weimer <fweimer@redhat.com>
Cc: Jann Horn <jannh@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index cee599d1692c..12b9626b1a9e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -442,11 +442,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		pgd = pgd_offset_k(address);
 	else
 		pgd = pgd_offset_gate(mm, address);
-	BUG_ON(pgd_none(*pgd));
+	if (pgd_none(*pgd))
+		return -EFAULT;
 	p4d = p4d_offset(pgd, address);
-	BUG_ON(p4d_none(*p4d));
+	if (p4d_none(*p4d))
+		return -EFAULT;
 	pud = pud_offset(p4d, address);
-	BUG_ON(pud_none(*pud));
+	if (pud_none(*pud))
+		return -EFAULT;
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return -EFAULT;
-- 
2.20.1

