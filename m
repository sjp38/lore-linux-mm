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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9826AC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D2CB2081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:09:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rzjb4ij1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D2CB2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F07596B0272; Tue, 28 May 2019 08:09:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC376B0273; Tue, 28 May 2019 08:09:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA7816B0274; Tue, 28 May 2019 08:09:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3A426B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:09:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 63so13839812pga.18
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:09:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ebFdeU/x57ZdMACMC1qwFSZewCnBUbRvAij1iV66B8w=;
        b=WSg72844m9wJmE/xHAcVTzYLkArINR2Sj/bi+kp0tPkDG1GayRhJVeLkqG+ulQ8GtS
         t4Yd5taeg1m/9DhrXWIv0KDSWZNjZu3tGEkmtO4CJfl1y6vn4k6PbMyCCcGjYlZcQJ/N
         QDNDWAkoTHQW9bD0pq9fPY9YVD+zBCaFMOs4aI65F7OxWZtmQXsV0uKWLTrHkGgRw5yX
         Im84/dFq9GMvAZo0tDs872wDF/H+nr5VVpm4cO5/aJL3gS32KoaSKNgPfF5H4JcZHM49
         RV0a5eME9NvpGJ9dyMvLwUIITAS2a7+6c9aOHP/SRU/6Tdjqp/+9MorNdy+hKzfJqcfy
         4JEQ==
X-Gm-Message-State: APjAAAUuHnPojJH421vxG6lHBvVvVojY+RDx7s6SpyYwJuPVCyQf1W5W
	UVioXBaMp6a3fCb4eA5gDGQLAXPsiOjcsi4ozitLRy5EpJQThnDV5rxp2B4EefxFuBmJ9pwy3Iz
	AanjwCBfqaUVNo1mldiBoZAtDWMX+rITg7oAqUIfL18qUTZOBkFuch4kydIbq0dbBHg==
X-Received: by 2002:a63:9dc8:: with SMTP id i191mr130702127pgd.91.1559045340218;
        Tue, 28 May 2019 05:09:00 -0700 (PDT)
X-Received: by 2002:a63:9dc8:: with SMTP id i191mr130702030pgd.91.1559045339377;
        Tue, 28 May 2019 05:08:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045339; cv=none;
        d=google.com; s=arc-20160816;
        b=sugCMsy9cR6aI4ALUX9a3nOdr5dO2LGZjNhJcCqYQkGQB7ktgqSvrQ8d6vQGnVKhE4
         sCEjq6ErTw0kU/m1gjHlN3bDJODX8VUxZ7eiU45wrU5CnD2Ac+aNmYJZqf6sZRVW7mB8
         ufcifTPuJOgKm7rM+LloWgFiD1JucxAz8iKjnOlVfMtc9S1RjUDfqFmYBnCEAJMi2OR0
         fRJ+WOdOTiyYdhq2UPGNudHDnWAe+qXrrkVYtiFG1GAqeh+dLXOpP1N4QEzdItk8PKcH
         BR5rpJO720ZrxkYCQbCv7W8TVTbubf+hZt5TO7xkUBSLLhYgBwMPFYjZMBEcoj8Kb9K7
         vXAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ebFdeU/x57ZdMACMC1qwFSZewCnBUbRvAij1iV66B8w=;
        b=AaxxOJi++HXTDwCIegfSaxo8JglSSFFbEPECsI7/IjS6JxW4NaSP0KugNLKuvQHee+
         RGzE3sjdnjYKaF8ycTpbJwNAnxdKN1j35Pp2aBIMCdnYL7/otAkMVyWwCWH8Id+YuQr/
         MpYK1dnAHzEX349kLP2uOnWMve0H1DapERdW5XWeMG2lCpSc/f4Cmpvz0TNfdhPQXPiC
         3dq5OXO2WHtC0rbLLZc233k/ZheiS9Gm8K7hO1GZVTchgSPFsrTsw9S8MMJmas7d5woD
         5k2D5ti9ZDaIFQHDfFQxgboiWQLnaYqtOatujV8nS8gh7uA2+MYhizfKHX6zjY7q7G0+
         Vhxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rzjb4ij1;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q31sor2575335pgm.26.2019.05.28.05.08.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:08:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rzjb4ij1;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ebFdeU/x57ZdMACMC1qwFSZewCnBUbRvAij1iV66B8w=;
        b=rzjb4ij10+/XxoGw4xo1USbcEjpbBtBE67CAkFvaT9rnRvwjnReaCSNwGBTafidpDd
         N2KAZFQmrx3PSfEKRlrzktw3gmIH2OmNKm0hzSG9LR5hM4Eo2CbGrIT8u0BJh/qQBmZR
         QTDWfDr+Ze3TiRRx/z9qozasTMLZECBVBvKtz3g9LsN14GkjdFgbcSwqBPrnbWSFdk4z
         YLILvXkBDdmuFtLGN8yh1V+5gfjBWhFxxxJQ96oOe3WwUrH8xJ4cOCm3K7SmegRz/WJm
         NwPVC/RjxwaMlySFNSNpGXbpE496iOnPSzMUcVJ/ZHkVFLCYpebb8OAaA+R92Of82ReU
         CuNg==
X-Google-Smtp-Source: APXvYqxWlHJ6CGIXx8iWA545z8hn9HZiC2rBd/N0Q5OS/i01zrRYILt795J+oHF1Ho4PVBFyoRgN2g==
X-Received: by 2002:a63:ee0b:: with SMTP id e11mr80785802pgi.453.1559045339023;
        Tue, 28 May 2019 05:08:59 -0700 (PDT)
Received: from bobo.local0.net (193-116-79-40.tpgi.com.au. [193.116.79.40])
        by smtp.gmail.com with ESMTPSA id d15sm37463327pfm.186.2019.05.28.05.08.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:08:58 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arch@vger.kernel.org,
	Toshi Kani <toshi.kani@hp.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Uladzislau Rezki <urezki@gmail.com>
Subject: [PATCH 2/4] mm/large system hash: avoid vmap for non-NUMA machines when hashdist
Date: Tue, 28 May 2019 22:04:51 +1000
Message-Id: <20190528120453.27374-2-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190528120453.27374-1-npiggin@gmail.com>
References: <20190528120453.27374-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hashdist currently always uses vmalloc when hashdist is true. When
there is only 1 online node and size <= MAX_ORDER, vmalloc can be
avoided.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd419a074141..15478dba1144 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8029,7 +8029,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
-		} else if (get_order(size) >= MAX_ORDER || hashdist) {
+		} else if (get_order(size) >= MAX_ORDER ||
+				(hashdist && num_online_nodes() > 1)) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
 			/*
-- 
2.20.1

