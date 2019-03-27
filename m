Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85102C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42968217D9
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RS+cOfao"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42968217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1333F6B0270; Wed, 27 Mar 2019 14:11:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E3036B0272; Wed, 27 Mar 2019 14:11:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7A916B0273; Wed, 27 Mar 2019 14:11:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3B286B0270
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q18so638515pll.16
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HXDfhw6wPRD14qqjmekdMFtIqSyX1fjYTQObmBl1eSk=;
        b=GDVii6YUsMetTh9KADWeNMGE9VtyFZqucl/J7LcsulGBAnCz9uhFapejq2B+TOFjmB
         nK4BIj3zls91IWzklXiapE7J1oTFFHobjKwYF88/8KM64/YL3sVMU6adv/5vdvDePwTU
         5HZRcL+gVli/Cy1IScvqE9+Y5+ZsdIPhdrr4y1Rkce2jSz74aEXH5jvTVk4TBpkIXtCQ
         qRVQzkLiyBMeOjZcKO9kNNO9OfjRi74n8yCohevd6NSg08xt7bJucK6eUPedw4gi5qsD
         xuhMrvYlsTdnMpu3Vt9anjTpE/R39UGHU50h50mCgXzxuuuMHMNsoVVgQiikw9oMgTDn
         PFfQ==
X-Gm-Message-State: APjAAAXo+5B/0kSr/Bbu7BBnhXZQt0eyZmYJtCDIOcgf5afGcnrTiZVM
	NL3UR+0cnoWlyMcW9yXLGdgiRdXt2dORNC24AH173Ci2Boml8GUkbXh85Bka/XwUlxxXF9cXdYB
	1ZgowtkZ7FvpIQ2QjBxuHP1gaYb7Gr8rJiXTTd/p/ge95T3WPQRpCButMPnG0sOrr7Q==
X-Received: by 2002:a17:902:9a01:: with SMTP id v1mr38640290plp.34.1553710262319;
        Wed, 27 Mar 2019 11:11:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWAT6zud6wLDIOVb+QFqqsXMaGqfNcyuOzlw03zn1DigwdLSoK915FqUptAUZcM0UiSZcD
X-Received: by 2002:a17:902:9a01:: with SMTP id v1mr38640190plp.34.1553710261336;
        Wed, 27 Mar 2019 11:11:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710261; cv=none;
        d=google.com; s=arc-20160816;
        b=gORdruydBX/K5oJlvNklnoNVD8gdOPRplRiEjgRi5OKewJhJx4l306k6frrLG3ThnV
         yC4rPNRisgn38qru+qQWoxQ2R1hgWixmNNbkKLTa/wD4NagRUlzQ3SIku3AVN4ocyZeQ
         1xQBpWzs+OOOgWb0mo44SqXtNPg4DH3h+DYq5uZwxWa/j2i0NfQ9UpTiiDw/WOXF+tAl
         P6CleGDxQ71o1lHkcWrdzX2DIAr5v44/Wa4/Xi1wh5b9+Glcnxx1Y6lsJSMLQbs2ovAy
         ejlxLlqJAFVyKqB4+EvdF7SFQFy0l9hBZZnnPk+EgfMQkc8mJzkrOlIpKOOKX2PgBnsQ
         6B5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HXDfhw6wPRD14qqjmekdMFtIqSyX1fjYTQObmBl1eSk=;
        b=YNyG1vPBgAXE6vr1WOOMJggve0SZpMnKUGc5lKU5yuT2cyhbImvf9EXYJJ5J0ipdmH
         OtULPnqDGGlcZpJMS0u8fyWgvHoPMYjK0+iuAreblNGCL60BhUZ0ZJ3sCc1Yyv1JMZ0w
         tg6nOquZNtTkA+ZjrWrUJyan8fzEdg+roL8S4PbQM29nHnneozemPxizO3zfaD1qrjPv
         KjX1Bx3J78WZ5Xobp6NMwpy0qp/qQbHHZ2L/iq9ixWgia14Ia9kMK0dLTee9QqPPlJcc
         DbMMWDQckMw/FmYx0glG8Voduh5d8W0xeDzCFK2YPe6Y3jMp5+iTBcK2EInyDWbJ5Ofa
         jgXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RS+cOfao;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x4si18314968pgp.370.2019.03.27.11.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RS+cOfao;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A5A892183E;
	Wed, 27 Mar 2019 18:10:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710261;
	bh=NyTtDPIBkm6qlurWeTu6ZTnO6GtZ+mlWfr07iIpX9As=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RS+cOfaolIOQyeeayn/EVq3MxxlbfTTeY2HRW5eTlxf6lJZiw2HBoofQW6kSB8B/j
	 9mnT1lhbNU5Fpko5EzWxciP35QF0jhsCgmBLOBOCovQHYjl1WhpwEOU7ZTWN8TVuDS
	 2x3AfpmhetvMXw9GsQ8OiG3EW6JoIBnK8W6bWZxE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Peng Fan <peng.fan@nxp.com>,
	Laura Abbott <labbott@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 022/192] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 14:07:34 -0400
Message-Id: <20190327181025.13507-22-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Peng Fan <peng.fan@nxp.com>

[ Upstream commit 0d3bd18a5efd66097ef58622b898d3139790aa9d ]

In case cma_init_reserved_mem failed, need to free the memblock
allocated by memblock_reserve or memblock_alloc_range.

Quote Catalin's comments:
  https://lkml.org/lkml/2019/2/26/482

Kmemleak is supposed to work with the memblock_{alloc,free} pair and it
ignores the memblock_reserve() as a memblock_alloc() implementation
detail. It is, however, tolerant to memblock_free() being called on
a sub-range or just a different range from a previous memblock_alloc().
So the original patch looks fine to me. FWIW:

Link: http://lkml.kernel.org/r/20190227144631.16708-1-peng.fan@nxp.com
Signed-off-by: Peng Fan <peng.fan@nxp.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 4cb76121a3ab..bfe9f5397165 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
 	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
 	if (ret)
-		goto err;
+		goto free_mem;
 
 	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
 		&base);
 	return 0;
 
+free_mem:
+	memblock_free(base, size);
 err:
 	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
 	return ret;
-- 
2.19.1

