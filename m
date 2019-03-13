Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A53C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD5682184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mGjXz3hK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD5682184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7689F8E000B; Wed, 13 Mar 2019 15:14:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1278E0001; Wed, 13 Mar 2019 15:14:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DDF98E000B; Wed, 13 Mar 2019 15:14:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6748E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:14:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 19so3212078pfo.10
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:14:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YvDF7SOYYveu2SvlrD+L0e3zgyHfArMVBYqv9OsvPYM=;
        b=hpDmbBFwT9e4lEVQOW9zcifWp+Vc57yD0vPyBm5eemYkxT8YE8sUk2CvZoTgHgcDDH
         4nnyjl8xOdQ4nxIxi3vFVTRT6KfqXKX0IHAxbezVaLSbSDVyWbj7iwGMSyrT8iecRpef
         Tmt3IUJjszLdt4iZH0szGpwKK9GUmRwS48xhXNjp4G2baEnMJPhtOyfgJRWqHC6JlSRA
         CMlNimONOd/6ZLt7VbIhvHM/l7QI47EeqrOAdz8Ans9+150JNe1tb8GrLeeJGeCcDhqP
         TIciwT7F+KvqlomktSBrkd+86cvkxVUkuKA0l4uBn82E18IYv2CxEl5Xyvl4yQHNYJ7S
         a7rA==
X-Gm-Message-State: APjAAAW/9tkrnpoLNY/27Ni3iEYNTQcGbItE46N/AbwtK38bSe/DHEsY
	hzISlvCVoOG4ZMM6oKawDyIgQzgVjfwOCFKM/YCRGz9YiwTkjlQwBcJcgzbBjgyqi0I/8hk+8VJ
	xbxN8gy2cbRcgS1xFAtqACXtdhyoPYWaVLJbWie8hF2tWRgzPNvfbzWdY2pfjKy5b/Q==
X-Received: by 2002:a62:488a:: with SMTP id q10mr6188944pfi.69.1552504455734;
        Wed, 13 Mar 2019 12:14:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziKXIKeElcK8xg6i9a2HbHdU5znN06Ydk3bglQX9tFq6OD1a9F4ZdFZTpTdU8RYbX62d12
X-Received: by 2002:a62:488a:: with SMTP id q10mr6188881pfi.69.1552504454983;
        Wed, 13 Mar 2019 12:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504454; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUd5BMKciZzjX9UQcVj4LhM+LkcMhWSvzWU6aVGJmH0KVjNY7BHgcv4lz1nlWpcMM8
         yi65bMgX5jMRldEKa89XfG83Ck21mgsCTZCAwpjF+x3vBguSpWBMn5NZXbS8SyuGwCDk
         Xkmt61ANceizTchiWmvuAn6CJRhVgL1VnruSpUYW6HLeyeQ4CC5gF+rGoMflykaJMLQt
         NVWiM0uzcgSd5B9A4SZoH46dNq0ElUBxIEeeaLRJbirIsv883o+++OU6PCMtn6rWwgsU
         qneIEinZl5YSmEmbDyDvhH+jq9Id6t3SX3CdURv7x1J+P8wT5yMMHTsHFYobnkyw0FJf
         lZpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YvDF7SOYYveu2SvlrD+L0e3zgyHfArMVBYqv9OsvPYM=;
        b=fu70WZlWaLZ+USJAso3NXjkUwUmgoIOyWdXPZ1TlLRx/HCpVPeag5PnWjmc/s/x8A0
         oCn+9r5nvFSb7IhSzYYrXnt7dPHnwFvFZAa5hT8kiaR7lh2EhdQhNJSI4Q1y0nIIhteN
         arsG73IldHWEumfFwSqrGq53DQiLzIeafU53ztVwh5wRxqfgTTGpj/DM7ZHPJphknF2a
         ktEDqvnk/2ogJmcvwhVdHbB7wroixU3XRcb6idPOj7UqUl2w7cMsogwiBYBP2zAx7+vI
         G94PspoYzTUJbJ3DWWRTcdMobHGkhBQd57nAR5k6SgVJio8xHv26/3+GpvpjPp2aUtDc
         nm4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mGjXz3hK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id go14si11618890plb.380.2019.03.13.12.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:14:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mGjXz3hK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E657B2173C;
	Wed, 13 Mar 2019 19:14:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504454;
	bh=s3C2mx7yXbv4mU8348fOv48dtoqr2c405gNRPsTyfQs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=mGjXz3hKOZC0SzipCQnZbi2LkBymaOXOm9xpsOlNIWu5EdXZmK/7hvqr+p8u5XAyt
	 cGZjHflG1tMMnKL41xl4Y2qULenk8B6mDBuJnxXDf9CaSMOAXBRzVIgtXH8VnBaai3
	 5C/mF6iN42JGsCamoLPHrvm/zgegi70NA+g48dKE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 31/48] kasan, slab: make freelist stored without tags
Date: Wed, 13 Mar 2019 15:12:33 -0400
Message-Id: <20190313191250.158955-31-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191250.158955-1-sashal@kernel.org>
References: <20190313191250.158955-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 51dedad06b5f6c3eea7ec1069631b1ef7796912a ]

Similarly to "kasan, slub: move kasan_poison_slab hook before
page_address", move kasan_poison_slab() before alloc_slabmgmt(), which
calls page_address(), to make page_address() return value to be
non-tagged.  This, combined with calling kasan_reset_tag() for off-slab
slab management object, leads to freelist being stored non-tagged.

Link: http://lkml.kernel.org/r/dfb53b44a4d00de3879a05a9f04c1f55e584f7a1.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 813bd89c263b..52c0420e4f93 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2381,6 +2381,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
+		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
@@ -2694,6 +2695,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/*
+	 * Call kasan_poison_slab() before calling alloc_slabmgmt(), so
+	 * page_address() in the latter returns a non-tagged pointer,
+	 * as it should be for slab pages.
+	 */
+	kasan_poison_slab(page);
+
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, page_node);
@@ -2702,7 +2710,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
-	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
-- 
2.19.1

