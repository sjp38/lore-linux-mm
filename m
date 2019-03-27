Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2246BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F002082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HmFP0tSU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F002082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683766B0290; Wed, 27 Mar 2019 14:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 631286B0292; Wed, 27 Mar 2019 14:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5204F6B0293; Wed, 27 Mar 2019 14:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16CAB6B0290
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:21:00 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so14661920pfl.16
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:21:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0BlteLIeMJ49y1WH1smPLNi4IEzArFU7Tulm0vkDYIg=;
        b=X8YWijyYsGJo/MXx41h1uHPA/FldN1YtaO1XgEgaN3TMCNIyar/fBKP+AvifZwMi87
         jFU2U1qG62VzgGyAUi6lQKG8VT9dvd6qSJeaumlgShXTqoVF1VSpHe0MN9/jIiggk2i2
         fqd1isR5XkuC+bu1rDNNOPxTETjsbOK31RnqmqouA7/D/ZUFNK/+d5ntq9k01CGAMkHG
         6g88FXassdWSjBl81hctDyQeIqnPmFh8jHpPJguLkizeU0LQc7Y75uzX5xwgIHEgS2uU
         2ScJ5Bn7FEjBkMV2ZLcAoil4A1BCci23px+SVJbDMTmIjn+ISWQlHjIIgilPPZes76hI
         v4WA==
X-Gm-Message-State: APjAAAVY2kyyy3R864WnplJ89LWHDJuVHFjBtnmXdHnvb59rXiygkxlZ
	57RC21pn05VvrdzOaOQpUB1a5q9Uz6H1a62Cm1d/I5Dc+ldVpHubo/RXRLNhzIs1rblfakaYila
	IuM/HSSbltUDta7wV/0TFnxAyG33SXWkwu5Q+5R9qag8Xjx2WctKZ5Shlf75bvkfGCQ==
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr37908684plv.173.1553710859731;
        Wed, 27 Mar 2019 11:20:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygAZRBHyV9JBJqRVc1qahWFpmtasMNi9zfGqps2ah6R4ySnzb+TzSyEejxACVV8jAQveT+
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr37908628plv.173.1553710859078;
        Wed, 27 Mar 2019 11:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710859; cv=none;
        d=google.com; s=arc-20160816;
        b=kG+a0CXsSVVy5f8MqvRllys9z7l7fnX4MSjGb8/sDNINnCin7XUA2+C+f0BKS71cM1
         XP3bCQ/j5/5dy4FZh5O6tSBZmTARGPGSMk0jFaLmFgD1YCXhrlTfROSB/QJ59fRbFoGQ
         SYMjMw4E80xNNfEU7cf4E/FO6svYMXN+5DBgy9ZCcn2nxSs99HLGRBkU2bEsLBA+he7z
         QnD2FvrLajSN75K3137hwPIAP1MV2JLv48zXJ7K3aAovKqkARHZVyBVkcpkD1q4hY760
         MdGot5moDXtDO98kyYdE8UGuxS8TAnNp1lbmd17940iUOIebFw3tnR5AnBKag1cBxuET
         1YVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0BlteLIeMJ49y1WH1smPLNi4IEzArFU7Tulm0vkDYIg=;
        b=CPp5GFfQ0PuWSlPDl4f2RAOJYCQQPsTHXcEfOzRKb9GGOm6LxQLSgzLdB3oN92FGev
         bJ35wzo12Dia9GRtnxd/nats2Kn4QPg+ozdZ3Wq2OkFKY64RNAYpCPVAK3bcZb+558aO
         SI3cRm9O31P5jgmDhTpbkEXM2JtwY7fcd5r9nvryEVaHMxa0+BP/9bNqgcc9f3RcH9rv
         iCPnQ6pfWg8CsMSCCW+6rTY6SvMRaL1r6XZrKm7qV5lCPRs+UbUOkIT0tN2rNiMgqBku
         LWv0qMV/yYUzbLKMJWJFFE51z6rwtE8zo1sk4l6rRaedZn/X1M73nVKlX+bbOMycvp7u
         nNxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HmFP0tSU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 61si20072338plc.134.2019.03.27.11.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HmFP0tSU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 64CE92070B;
	Wed, 27 Mar 2019 18:20:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710858;
	bh=tsEwdK4bz9q3pOh9P+soQ2+50/Ss0lGmLcWF6Ak5pRc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=HmFP0tSU11W96Yllejv+omo0Q2DcErdfDO6XU3S0k6TlRipOTpt+OoUwbXQm9F2Yl
	 KnrqlOqHmZFErX/sVQ7CdtzM+CT0fC5xzKkw1zSFTeog82b5kRjZmvIV38CvTCiZ5r
	 poZBVyVuDuOSfa5RspzMu3k7S+SEXAO/oLJm6lak=
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
Subject: [PATCH AUTOSEL 4.9 10/87] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 14:19:23 -0400
Message-Id: <20190327182040.17444-10-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182040.17444-1-sashal@kernel.org>
References: <20190327182040.17444-1-sashal@kernel.org>
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
index 397687fc51f9..b5d8847497a3 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -339,12 +339,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
 	ret = cma_init_reserved_mem(base, size, order_per_bit, res_cma);
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

