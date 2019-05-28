Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5743C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ABEC2081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gePFim6z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ABEC2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19A156B026F; Tue, 28 May 2019 08:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14BFE6B0272; Tue, 28 May 2019 08:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A756B0273; Tue, 28 May 2019 08:08:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD6F66B026F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:08:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d22so5958964plr.0
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:08:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=eTusNcynv/bdHJGyOGAguPJgIGBXkK8mZssjLj2XyYA=;
        b=JcLwILsZTLHj2mnaC8wiWHloURpnNKavoJjhMWOX0pv0H3GbKNDM9h4CX5YtRrtAXh
         JuZy3ApuwK4SHl4LdHH6aQVrZCwQ+KUXMJGXrMbFxgVr9DIv+nVkPxB0g1kYAjpvfvJ/
         EAKrF9xw110WdOHmWQ7K5tO85IjQJzKOdVEkB0WB7cAXXDsVhaiKZyLQsIYsz7J8qyug
         F0EiGBZAfE5Po8khFFsHyGEXbdGC0+mCySqc0HWpWeV3ZaPgSHMahdg2jrgtiIhi5ltp
         Qajp3K7znG2eVG5bx8IIIieOqjywQKtECuQyaWKw7slHDcZz70fYeSq76EPp1tVJVhbD
         OGuA==
X-Gm-Message-State: APjAAAVQOnXHFGPIWSFjl8XEwwzEgf0k8GlmBlJ+/Xp8kzfB9QHt+Jlc
	aL45l8iHOJi6tiTocY/n/YdkCVtH9PkMnUksTKQSteZOAF8CInRSRQWCUDR/gyYCvmsnjiUZ5DT
	2NbGgIstat23kBXFq1QVhkKwAPYMpdovJWtUDF24Vr7fsLdwNMe4y3pY5P2i19toViA==
X-Received: by 2002:a63:4621:: with SMTP id t33mr131670323pga.246.1559045337305;
        Tue, 28 May 2019 05:08:57 -0700 (PDT)
X-Received: by 2002:a63:4621:: with SMTP id t33mr131670232pga.246.1559045336571;
        Tue, 28 May 2019 05:08:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045336; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/QtoO0egxaM4oYPNuKGZ8rYcY72Ihky+XiNhhayAT7Tc4ihBmeK4FUvRmXu3Hw1ji
         K1JxOhO5AW9F2vte4LGSFa1fd8UP+JuF8wlc6G0f7YdGLnZA2DCmUcc0y1uWLTtlu5IA
         x1vLmGV0lTI/kEDSE87VwIfavonoOCIDuqB7+st88L1Hb0HF9B30I4Flr2t0OOZr8OAF
         gRmBheqcWlHJWYqxj07AcWyXdWqsGL1av1n+sn94za10VDTPPKOqtFoVSSK0OzsJmMZ8
         ZB4YhEqs3A+HZ8Vz5D1KzQPMGrKdfMJeVBos4ZjzYaiKlnFHkr00rmic9yXel7Kki9K8
         vflg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=eTusNcynv/bdHJGyOGAguPJgIGBXkK8mZssjLj2XyYA=;
        b=gItL5JO7syJfH0H+2sN0nQI0PmTShoqx3Ju3ACyF0EpYmKPHFNfYRbAt0z0+UFUZO1
         vqJVRi9bHKC9blaFOReiNHJ4i7EXo64Bn3FTX3RuZtKZih4rrsyd8AAqoFwnECHJtALE
         TXY50xi6ieGKP+hqe3iuuWJUKG/q75YAUfkc6kcHR9+WzlZ2txY8TC54P6JLsEOIzIfN
         D/VPQR+5eusTjmVmIDxEYHMDqH9Xjh/mjOTg0P8EnGvmQ8HJWY4jaeoab6ZG+65LtF1A
         ogBWg4RtLEvLyYVubWjNm+Jpq/V2F/U0Whjb6Gew+fIJXF99sPjKVCDWfwcVbJbFbuFR
         vFvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gePFim6z;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor14183486pfe.20.2019.05.28.05.08.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:08:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gePFim6z;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eTusNcynv/bdHJGyOGAguPJgIGBXkK8mZssjLj2XyYA=;
        b=gePFim6zy/Px8intSzG3g1lUm9vIEviqyResVqM6CMdmkHMLPZyzYcfuwwNOxWJfyT
         PrAf+88EhsQYxRofAWQhwIpvu02BtlRxH6B7y9bPp7IW4+Pw9hlXglaG+/T1Rl7dEf2c
         Ig3Z4yWui4X8BvFJKwhblZtN94P9o9ze/YWo3gZ4Y/oLOWaOth0PPKAWRL02FmRw+ZhO
         eCyYQZ5uc/WVq9pca8eZV/pt/jB5V+O/cby5U0eP2B94eRM+PQasAlPHQZ/0QI2iJOch
         MXkQGbR47WKp7efgV3Z9hfcGZr2aRt3ImGKBmxlbUwF+NHv7L3aSaV9JLouvyVVxraO8
         wbxQ==
X-Google-Smtp-Source: APXvYqxouyX+FBCZ+/B4VzV3O/6LZwxnEZp2c8WyrjNaNIPzurMIp7er5TLrN3wxXTQP4ciUsmcvow==
X-Received: by 2002:a62:38d8:: with SMTP id f207mr82932613pfa.131.1559045334758;
        Tue, 28 May 2019 05:08:54 -0700 (PDT)
Received: from bobo.local0.net (193-116-79-40.tpgi.com.au. [193.116.79.40])
        by smtp.gmail.com with ESMTPSA id d15sm37463327pfm.186.2019.05.28.05.08.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:08:53 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arch@vger.kernel.org,
	Toshi Kani <toshi.kani@hp.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Uladzislau Rezki <urezki@gmail.com>
Subject: [PATCH 1/4] mm/large system hash: use vmalloc for size > MAX_ORDER when !hashdist
Date: Tue, 28 May 2019 22:04:50 +1000
Message-Id: <20190528120453.27374-1-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel currently clamps large system hashes to MAX_ORDER when
hashdist is not set, which is rather arbitrary.

vmalloc space is limited on 32-bit machines, but this shouldn't
result in much more used because of small physical memory limiting
system hash sizes.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..dd419a074141 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8029,7 +8029,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
-		} else if (hashdist) {
+		} else if (get_order(size) >= MAX_ORDER || hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
 			/*
@@ -8037,10 +8037,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 			 * some pages at the end of hash table which
 			 * alloc_pages_exact() automatically does
 			 */
-			if (get_order(size) < MAX_ORDER) {
-				table = alloc_pages_exact(size, gfp_flags);
-				kmemleak_alloc(table, size, 1, gfp_flags);
-			}
+			table = alloc_pages_exact(size, gfp_flags);
+			kmemleak_alloc(table, size, 1, gfp_flags);
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 
-- 
2.20.1

