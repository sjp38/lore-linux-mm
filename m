Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D72B1C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96AB22184D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2qNSng/b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96AB22184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3515F6B0282; Wed, 27 Mar 2019 14:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D9716B0284; Wed, 27 Mar 2019 14:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17A026B0285; Wed, 27 Mar 2019 14:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBB996B0282
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:16:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so3318222pff.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:16:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sJjYUUyizNaseNBGfmcN9oxUBkXNEnOhRdrUQ3ESK5k=;
        b=CVy2xHNd2HRvR1kFjb9PCCFEcYvm/hegk6BoLYSctAL+tZRHQ4FRggcEKx/7exCRZK
         N9aI7iTTABT/QNm68rT/hgr1SEAdw40mPvKFCDM4UWVfDmT6v8IQBDm/EHk884nfgArD
         k1h4eA2ZBESMM0f4mCZYsPqPFLmCtXJQHN4JZOkIuWDv1LGVW76NFsdj5pYQfTli1Lwl
         NrxFSSAN4lXMt6LXpz84CHSK3t6cxYNaFe022CXaoseFx2TVgBwVLqXlYGHbfVmeGIUI
         chjj+lF02G3fBo+/b4EaAzjIjvTwhWyCGMz2xDMn9p5OYdUf0HCP09+yV6ika2j5XvtL
         dexg==
X-Gm-Message-State: APjAAAULR3iDGw6wmSbf9t9obI7+91JQkSlSRnQNirgRwJ5zcZIxx3lY
	goMtKQRk638i7z2fyn9I6JbzAKrg3zMUpPICmClQLqRTSkNUWM6XqvpoOgjgdbGwpA8f4ucCr+B
	0nd93iithVs4CmLeRo59gVwWk+xXHCgxJxFUHLuFtZgq16kyKkscNkSQftTX9Od6ylA==
X-Received: by 2002:a62:484:: with SMTP id 126mr37089200pfe.91.1553710615480;
        Wed, 27 Mar 2019 11:16:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3yC+r8fk++Cjbrh9y23H9m+qZX2RCgtA1DUD1bL2B2EHPkSKyan72bE7hoyMLF0jbQZYL
X-Received: by 2002:a62:484:: with SMTP id 126mr37089157pfe.91.1553710614820;
        Wed, 27 Mar 2019 11:16:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710614; cv=none;
        d=google.com; s=arc-20160816;
        b=0HiNbT6K3p8gRgzIk5X9dsMKwN6CU4hVqhlSipkkVuxWyBFYre11ASvAsOorrz0xCm
         jaEAUozlWYjpTeTjy5vRdd3xlS72MCoBdEeA2RVAFlys1nGRvlZqvuq0bEuxvAVdVtFH
         gF4sadjz2DDqaQzzAEvSzYwNpTitbnI3Df881nB6uf5b0ofVWqlR7FLmd2/ZONDiJhG0
         QlmHQ8tOxBtdr5/J8/Dk1e8mlcxTxxnllp7FuoFXsUneVvDGv6LiZafAuA964hDqalQ5
         QErEBnqR1+K2UsZk+2aBMMBKvWkXIcil0Zr7ZYSQd5nyY+8zJYZsHC/5/xqWCDhZoUwJ
         dRXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sJjYUUyizNaseNBGfmcN9oxUBkXNEnOhRdrUQ3ESK5k=;
        b=JLaL2zfe3koGF946Rz11sqYbQjiNvyIPr9tDYPJHd47ImPE2MszdXrJhC3tLzLTLS3
         YlNwWZHkKae/cWZKmdzy0vi0nD6nElJwBY+ZrjkPnH00SX5DWb6iFIuf/MrLm+zIVMAF
         hWGjDcRZgySrR+HxdCgILUHSDf/uGEpdW0BdOOusPmdSVq+lX+EwDs2PLR4AzMKP5lJc
         bGixVTOGWUvpVWRVYrScmmIz7i44b5ya7uTjTXpr7E3gRETR4TnHyamG7GJQX1Zuxttz
         +tDloTpINQK6hq0otoievw624Omb4YCQH9bD4xmlzn58ndJqg4NegEPbl4vlEMfVD6Sn
         oeOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="2qNSng/b";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p22si3882840pgh.468.2019.03.27.11.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:16:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="2qNSng/b";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 251F320449;
	Wed, 27 Mar 2019 18:16:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710614;
	bh=xhmyjVLWB9/1dhPMm1HxjR32xkWZ8z3CmeWxjGX22oQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=2qNSng/bK00GPrOrfytU/otKJMeYQfcpSAOK1y9C3yh2gHfCTXJzA3QoHvG2d5pF+
	 LO3yLgIhfMlxNL2a5dygSmIBLh9OtjifJdKsZpUMfhRyiKC2N4URKVJRkZPRxXE9jX
	 TEVEjQ8Cmyn6oe8NFDCuEZyF2gpfRIzoRRXz3rO0=
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
Subject: [PATCH AUTOSEL 4.14 015/123] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 14:14:39 -0400
Message-Id: <20190327181628.15899-15-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181628.15899-1-sashal@kernel.org>
References: <20190327181628.15899-1-sashal@kernel.org>
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
index 022e52bd8370..5749c9b3b5d0 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -348,12 +348,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
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

