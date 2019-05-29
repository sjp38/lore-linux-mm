Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A03DC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0F1C21019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="juZrse+P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0F1C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86FAE6B000C; Wed, 29 May 2019 08:39:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8486A6B0010; Wed, 29 May 2019 08:39:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7356C6B0266; Wed, 29 May 2019 08:39:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3036B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 08:39:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so1480963pls.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 05:39:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=/kUApmsHSgHDArihyUOta/cOfsm+uYS/iQzyr+N/nRo=;
        b=sfcONYm4WRacSbEzp6hUq/YnTA9eyYUMer0nywmTeHZneVOZfz129qW+V5ycDeuKSS
         G2LoUC2pOAifZw6LBSlXaKZZy0JTlvoMiUPSC97l4gSbLv6/jHRh0TpBWkHVlCoG7HBh
         aEQrz+AUHWV2kqQn+Md/qeJ+WhiixzIpt31JR8s6ewNcaiq5OI/2F/kvnjxmxZNp4VNO
         5nY+OXC/gyDQZJf090J5Gey0GgsbCPbsVf9/qwGbcZG0ZZwL//rmRfdkAjNl1ACJVum6
         ygmR1Iu70ZEyb+eVsO9wLq0I1szsR04HyaVM9QUWM8UJveZqrij/LZoDQDkobadlMfQ1
         NpHw==
X-Gm-Message-State: APjAAAVT7/AsuwLr3EDksTDNzzb4qr5BroaKXvMLp/NCZeOAKY0JNiIK
	JVnGQIasRPgxdZnBzmae/H2/3+SZY19oBV+cN67JtpJOXFF8XCG6BwFMz2BhsHWdrjv8gIgZeqC
	LRLNbB+kgogm+VSo9SToKQtpoieoKcllnR7MISvrDjFapQM7fkK+A0S6w6h47Og0t8g==
X-Received: by 2002:a17:902:122:: with SMTP id 31mr1211913plb.217.1559133577727;
        Wed, 29 May 2019 05:39:37 -0700 (PDT)
X-Received: by 2002:a17:902:122:: with SMTP id 31mr1211801plb.217.1559133576693;
        Wed, 29 May 2019 05:39:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559133576; cv=none;
        d=google.com; s=arc-20160816;
        b=B1nN3BMEuaPiHvwiTTfTS0HWRU2/MrL4pL2F8okL+ji0VHM+QI8OLEPmnpP8iTqRir
         KbZPGFsoXTZQfohDvKoyW1GxG4KyCWicMQIXDqC4EhK0cehABocSbh+evzKl/Do0iI6K
         iDub86pCjSIEpC0ELaC7r97Itynj/qv9GUqW9YO+c+hIkrMSMj8JWe2nDlDwOqzn0gZN
         5uK4V/fO9zUZmaASAZoqdHbxnhvwaPbbbrgcWFwK8VnOZOYNe4iwXo5dQXkWiXaNIsVa
         ry2b21BjzVg+RJi5WFhXgThiLYNQBuqpP0tQ+NsZlPQdrieCpyW0kWT+ymw3EdjeuOfA
         ++lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=/kUApmsHSgHDArihyUOta/cOfsm+uYS/iQzyr+N/nRo=;
        b=FN/71IcQb4d76fRLRDa6cN9svHrU+XbP8lQnM2FphkqLNYA6hprehL0GUSnajNcyQ8
         8vghSiaM04r+CxHCUctpu4eUzpTCB/FIqBlAzmluE1U9NwiAbMLGHpN5hOWv7OihoihK
         bbIrFeyyVuwuvaSmQlf6tCxyZyz0dZVIUhPg60aA4OZb0Nk6ka7UqfTcUOxIJxgDVtRn
         KX0iexYqwDJuLygwRUHDmQD0eusWVu876LrKPj7rrMgAe5UtYiIC5foguv+c3BWV9iHN
         nHGrWDbRLCwTiLkvXlk++VVxWBjkMqVZtBClwr255nUkxLJ1Ka+wa3w4MLkz2poEpfu4
         U/jA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=juZrse+P;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck13sor20893312plb.38.2019.05.29.05.39.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 05:39:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=juZrse+P;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=/kUApmsHSgHDArihyUOta/cOfsm+uYS/iQzyr+N/nRo=;
        b=juZrse+P5GXwZ9Mr9TkKumoLScyloKiktxo5FhhDWNI7LcrTnkDaRqPI33pWp7lXci
         4Ogtx/AQdl1KsvONOwuev6kNPUPM7CSDW1fzkPN+LGbHwi7km0sPP4OMeR93q1fgBzye
         acY72AJ8WkHQrDvdd8IHCMJnECysgVh5O2ooFvvhKi4JczqhdeEOyMJTbXpGqB8ammkC
         OTDsmGibDQ53bftt6AioXhgzAP2WDApUJVAb6tXG/l01IivWJOuWNv3mwvb48Xi5K71X
         XNHfJPlGTIDtNpYOj+rLNhh01dazq3y2O90/r7WVLu8jPnmVSDPbTRjhO3pUdkogLqLZ
         ISCw==
X-Google-Smtp-Source: APXvYqym4WR0k80SWtZ3I58trWkxoQJvuHmi/gCo6ctyQsvseOeEK4n+4Ibn1SPRYLidkJjLphA2mQ==
X-Received: by 2002:a17:902:bc86:: with SMTP id bb6mr3670959plb.129.1559133576415;
        Wed, 29 May 2019 05:39:36 -0700 (PDT)
Received: from tom-pc.ipads-lab.se.sjtu.edu.cn ([202.120.40.82])
        by smtp.gmail.com with ESMTPSA id 124sm19018905pfe.124.2019.05.29.05.39.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 May 2019 05:39:35 -0700 (PDT)
From: Dianzhang Chen <dianzhangchen0@gmail.com>
To: cl@linux.com
Cc: penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Dianzhang Chen <dianzhangchen0@gmail.com>
Subject: [PATCH] mm/slab_common.c: fix possible spectre-v1 in kmalloc_slab()
Date: Wed, 29 May 2019 20:37:28 +0800
Message-Id: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The `size` in kmalloc_slab() is indirectly controlled by userspace via syscall: poll(defined in fs/select.c), hence leading to a potential exploitation of the Spectre variant 1 vulnerability.
The `size` can be controlled from: poll -> do_sys_poll -> kmalloc -> __kmalloc -> kmalloc_slab.

Fix this by sanitizing `size` before using it to index size_index.

Signed-off-by: Dianzhang Chen <dianzhangchen0@gmail.com>
---
 mm/slab_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba..41c7e34 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -21,6 +21,7 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 #include <linux/memcontrol.h>
+#include <linux/nospec.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/kmem.h>
@@ -1056,6 +1057,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 		if (!size)
 			return ZERO_SIZE_PTR;
 
+		size = array_index_nospec(size, 193);
 		index = size_index[size_index_elem(size)];
 	} else {
 		if (WARN_ON_ONCE(size > KMALLOC_MAX_CACHE_SIZE))
-- 
2.7.4

