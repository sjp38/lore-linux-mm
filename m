Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C47EFC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80EE322C7E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0Tz3Jx8l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80EE322C7E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D2876B000D; Fri, 26 Jul 2019 09:41:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25BD08E0003; Fri, 26 Jul 2019 09:41:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FD5F8E0002; Fri, 26 Jul 2019 09:41:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8B5C6B000D
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:41:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so33160675pfo.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XlEDPeXiFFq0PnDJgasCFxlp8HmFIBxk/IN3V9239Vc=;
        b=Hc3UrDgDLBFHfMhx2EdbFGdZOPUNm5J0dqoyAGA2CxY7QPm2LypBFlG7zbbsm0Yj1r
         45LPh08/Drj91emvaML6ngru1KMCpKdJVKC3Xv/Kwo9Ryw8n0+WKEmwFM2ZjkVPLf0aF
         dEssiJCcB/rIYhjBKFbyF0/li4qxd9wZShcliCKDWptSXUmbNAlobRoEpRtI8cUJGADd
         caUibYJttMq5VDZcsClL8wr8B4EgarZonoY1gMiE6QlkD1Ckx8JOuQNK5+ESzLgGYvLT
         n6hZlnuTsL7EsUOhhCU3VfbUel29qoPVSStLzL2wmNVeZjpd6Je6HHB0BA1vaFcFxWoB
         R9Sw==
X-Gm-Message-State: APjAAAWNUpR5CKtOJXV0yPpCuJJWwI0Okh368/ej+Frlpp8zBxJ7XunM
	+owpJXvzEc6eETBMcA/AOxrPuSfSeZwNvIsFE8b6+RqcFaAVEKATAgDwGlKRiZm/z0FJ3ueuRAh
	5sgZOOkSp2f5BOKdcxTV6Ul6S2xS12XaQn1/6e2q2hrKFpZrAP3C00QBc5BrVmrJ/RQ==
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr97028082pje.124.1564148470484;
        Fri, 26 Jul 2019 06:41:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW1PFVbl0fHsJ1ZnDXMQBRYEYosdmeXClwC4vEx/+FywVamnCe7Y+F/VrwCjnd7eulfy9g
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr97028035pje.124.1564148469757;
        Fri, 26 Jul 2019 06:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148469; cv=none;
        d=google.com; s=arc-20160816;
        b=y5fAAq91fzSf+uGtQcGKHTsBFQeZMLKuI8ma5CTAJEm4DjetswkYFkhSk9SaDyxQU/
         OyeuO35YDT8MPNCuAr/klf2lnzqzzGFx0CMpk7+XPuQltNc+/JVFHVIipYmKvXBzOYt4
         HymDPya/UUMMlX4RCCu9+Ca0A72m0jdBMqGbqJkX7N1H5plqB7NEuVkPsFiaki4Ddosy
         BUYMaAuijpQwEhw7a7bXKmQa8dsUCwPHgNyI9lbBbpPQyq7xJc4yYK45EcjHj97H9zu7
         DCjLdPI4axyUtDruS+eE7fSf6b7mrxYiB0h2QYErMO7LSiGcxsfkVn+jqa5vGu+AtNNG
         8T8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XlEDPeXiFFq0PnDJgasCFxlp8HmFIBxk/IN3V9239Vc=;
        b=E+MPgGXb8ajhCLKQqrRhu+NFWZELMfSzDRvWh+HnEdWmHCyPJD+3HaiNauKRqYpbsS
         O2MUAoXp/sMn5p9THyDfucV0lSssaX4Ua9ElVGcXY9xN1ukKp5+fKMn4jAAi/FjyGllH
         D5KxD2HJI5XAawjMt36JrhjuSLjflk/gPPV7Yzj1ACpt+QZKFUHgezmQKY6Ogn7QQOnS
         kaq7N4zNiaaudMf7ASltBW+wel8J4U0X693+in1Rip9AVr4PCwio/bOP68zYYz2lTAVs
         poOwGFhPjrHcTIICUt2WMzNXPfJGlRmzNrkzDmiYcm22JgUV0UQyN90nFU/E/bYPG+In
         lNuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0Tz3Jx8l;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b73si21079476pjc.53.2019.07.26.06.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0Tz3Jx8l;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0E89522BEF;
	Fri, 26 Jul 2019 13:41:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148469;
	bh=KcjEwut+kBGUorf7XNpfc3U8ssodwP7/ihtxLHD9Rjw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=0Tz3Jx8lc1/SiDsM6As9vagpIX3KhwhzsvtL0A9Q0GAFBcc1gXiN44xbzhSuKmn2X
	 pjbOlXnKigb60mbdSqR8F+LgAHg4kMnyWld0XT0NDwWXndhUYts2atN200C/Fukys4
	 5DwMCPMaqZ5i0SiO8/y5Z2Mu831eMHnI/VZEKrZA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Doug Berger <opendmb@gmail.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Yue Hu <huyue2@yulong.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Laura Abbott <labbott@redhat.com>,
	Peng Fan <peng.fan@nxp.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 56/85] mm/cma.c: fail if fixed declaration can't be honored
Date: Fri, 26 Jul 2019 09:39:06 -0400
Message-Id: <20190726133936.11177-56-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Doug Berger <opendmb@gmail.com>

[ Upstream commit c633324e311243586675e732249339685e5d6faa ]

The description of cma_declare_contiguous() indicates that if the
'fixed' argument is true the reserved contiguous area must be exactly at
the address of the 'base' argument.

However, the function currently allows the 'base', 'size', and 'limit'
arguments to be silently adjusted to meet alignment constraints.  This
commit enforces the documented behavior through explicit checks that
return an error if the region does not fit within a specified region.

Link: http://lkml.kernel.org/r/1561422051-16142-1-git-send-email-opendmb@gmail.com
Fixes: 5ea3b1b2f8ad ("cma: add placement specifier for "cma=" kernel parameter")
Signed-off-by: Doug Berger <opendmb@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Yue Hu <huyue2@yulong.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Peng Fan <peng.fan@nxp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 3340ef34c154..4973d253dc83 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -278,6 +278,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	 */
 	alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
 			  max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
+	if (fixed && base & (alignment - 1)) {
+		ret = -EINVAL;
+		pr_err("Region at %pa must be aligned to %pa bytes\n",
+			&base, &alignment);
+		goto err;
+	}
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
@@ -308,6 +314,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (limit == 0 || limit > memblock_end)
 		limit = memblock_end;
 
+	if (base + size > limit) {
+		ret = -EINVAL;
+		pr_err("Size (%pa) of region at %pa exceeds limit (%pa)\n",
+			&size, &base, &limit);
+		goto err;
+	}
+
 	/* Reserve memory */
 	if (fixed) {
 		if (memblock_is_region_reserved(base, size) ||
-- 
2.20.1

