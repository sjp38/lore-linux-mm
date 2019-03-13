Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F4CDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D8A217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Duprfr2w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D8A217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0048E000F; Wed, 13 Mar 2019 15:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6506D8E0001; Wed, 13 Mar 2019 15:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53ED98E000F; Wed, 13 Mar 2019 15:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 132AE8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:16:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j10so2479296pff.5
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oYp1fYhBJBMgx8eSv7smWIFYnBy0/RPLel8U6ib5cvk=;
        b=OonxP1g3pCvkhnxf5+nReVE+72fq4a7vDEsZXkk3j27BO5GN9pU8lvwyNRoE/x55Js
         PAzNljnCB/DqSYVgrY7PxS0uWGC37eAGA5AJX4RGwjM/go2OPdkG7ooZTKqbTIn7YSGg
         G1KGLX6jSq9ZcbsjYifeRE5tocFom1BI+8CLiUC8sAYttBa60wwaENXyfLmKlwfl3Jjz
         2SdKlex1g8MqH4qx4PsHSv3y6LIXExLHvB5+fcqU0TbumGEH4KVCKxFg6jYfULB06pGp
         w0l7zuakKK9GXezHcswox0tf7CougDafmIATiWBKGuOnjslI/ZCT9Nr8mIGCCmYr8EJn
         at7g==
X-Gm-Message-State: APjAAAUxlMZlU4/krUocuXsaLKoawjPpOTAEuPT6Z3r2qM/gWGw6HRfR
	9IH0qQiATHU4E/iqn2t92uLE8dZFNCprIOzASzPpuUdMoggbqkgEeWmgUxGEgVJz2kvB6mOHtYJ
	0pH6LFKFaLlHSfQtG7rmpxO34vLhuEXuwfKkSaZME4SHk6Jjnfx69e7nmSqynU4NhjA==
X-Received: by 2002:a17:902:6b8c:: with SMTP id p12mr47912030plk.282.1552504562745;
        Wed, 13 Mar 2019 12:16:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvhdVe99ZeN2tyfRRWBsZZkMvs2+vlbhDZS3X/PL4bUgyo4Xbl661f7RdHq8pbYp9tiIEV
X-Received: by 2002:a17:902:6b8c:: with SMTP id p12mr47911971plk.282.1552504562033;
        Wed, 13 Mar 2019 12:16:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504562; cv=none;
        d=google.com; s=arc-20160816;
        b=Qbf1fwy58TYLG1OgRmSxlbVzaZjkUq+qgJVrbR4znzri1wxri1+K7m3PuYhd80UIG0
         4qzstz3yRTF23JVLacqYK17tj7NfwMcUc6kc2DkNH8CyTadq7+zlhx5wgGxHh7sDVRdt
         B/LKda3cKu6uNd1LcI6cRu2LeIlF8IaEfyBZJtdg3P2jY/GdYYMG47Ofps7ITsll/dZE
         kpNEgNUoMfIiEMH6SEmC1/5Y2dK3ZrDK5Tr2+6ncWYclmfS8WmK/NAPDjAgSo/PrMAnH
         9QQrk3GuFFiKq7vd08oPSonR1CBqq0RlE89tqm030wRjkyxQTNTUkjOH656h5xoPAKq8
         zqjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oYp1fYhBJBMgx8eSv7smWIFYnBy0/RPLel8U6ib5cvk=;
        b=NfWcm3z1L2mMfPvK9+lVC5PSSiI2xIAsQfOoD/j8F5a3xJWhAUuSf5LUH/KrmDtzbG
         U21j16NsvS7jrjEJVWEMGN7zfnbdLE+WWAMSgm49W5u9sRqdV+i4zDdf0N7Tg/zMVOID
         hnMk86JcB/Tb7eicG6FcrqbvVWw0/4Dd/1rNL4kI1/P588NXc1Ywkx38VjsJvYVlGhm8
         +8zY4so8em48RqzkxgXAwnRIWIGPD/yQ1rwjLMCpkCI8SOTkR/TUIPl4MVuAEf0Raxlk
         3dTQO2sR2wHNs7dcl93oHPBDQlVEPUJEhagxmgnFcFgdzmMwpM8164D9WcWyi7bThN0v
         QoMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Duprfr2w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d141si11424768pfd.81.2019.03.13.12.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:16:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Duprfr2w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 95B062183F;
	Wed, 13 Mar 2019 19:15:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504561;
	bh=2KjpwB7nzi6RD//1iTkLzYoTJ2ub1V62WjgveI0bRvo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Duprfr2wZO/XUzMahNPzCketBG5yH1upexlv0ys0HnojHJ9xCHRoLK6wzCrw9knWQ
	 HHCeSAkMu9Whx0WXQz0mU0zZNBYjbxhtFeOmQ1sv5vtgvBA0tPsE5R8eD63VSwpCyy
	 XGIrp9wWk5zpK1x4VCRJp+l8pCqWHGswiswGo5Iw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Kostya Serebryany <kcc@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 19/33] kasan, slub: move kasan_poison_slab hook before page_address
Date: Wed, 13 Mar 2019 15:14:52 -0400
Message-Id: <20190313191506.159677-19-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191506.159677-1-sashal@kernel.org>
References: <20190313191506.159677-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit a71012242837fe5e67d8c999cfc357174ed5dba0 ]

With tag based KASAN page_address() looks at the page flags to see whether
the resulting pointer needs to have a tag set.  Since we don't want to set
a tag when page_address() is called on SLAB pages, we call
page_kasan_tag_reset() in kasan_poison_slab().  However in allocate_slab()
page_address() is called before kasan_poison_slab().  Fix it by changing
the order.

[andreyknvl@google.com: fix compilation error when CONFIG_SLUB_DEBUG=n]
  Link: http://lkml.kernel.org/r/ac27cc0bbaeb414ed77bcd6671a877cf3546d56e.1550066133.git.andreyknvl@google.com
Link: http://lkml.kernel.org/r/cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Qian Cai <cai@lca.pw>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slub.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 220d42e592ef..f14ef59c9e57 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1087,6 +1087,16 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
+static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
+{
+	if (!(s->flags & SLAB_POISON))
+		return;
+
+	metadata_access_enable();
+	memset(addr, POISON_INUSE, PAGE_SIZE << order);
+	metadata_access_disable();
+}
+
 static inline int alloc_consistency_checks(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
@@ -1304,6 +1314,8 @@ unsigned long kmem_cache_flags(unsigned long object_size,
 #else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
+static inline void setup_page_debug(struct kmem_cache *s,
+			void *addr, int order) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1599,12 +1611,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
-	start = page_address(page);
+	kasan_poison_slab(page);
 
-	if (unlikely(s->flags & SLAB_POISON))
-		memset(start, POISON_INUSE, PAGE_SIZE << order);
+	start = page_address(page);
 
-	kasan_poison_slab(page);
+	setup_page_debug(s, start, order);
 
 	shuffle = shuffle_freelist(s, page);
 
-- 
2.19.1

