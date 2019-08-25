Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 445E9C3A5A3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0801C206E0
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0NeMK/2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0801C206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B415B6B050A; Sat, 24 Aug 2019 20:55:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACD3A6B050B; Sat, 24 Aug 2019 20:55:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992036B050C; Sat, 24 Aug 2019 20:55:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 721C96B050A
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:55:12 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 15E6D500F
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:12 +0000 (UTC)
X-FDA: 75859131264.11.front74_4a77dcb843819
X-HE-Tag: front74_4a77dcb843819
X-Filterd-Recvd-Size: 3707
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:11 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5A08A22CE3;
	Sun, 25 Aug 2019 00:55:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694510;
	bh=S/u5w9NhTrxsivl7K1Z35nRC16DrJe8DW84Y81s14Ew=;
	h=Date:From:To:Subject:From;
	b=0NeMK/2CHmHw3+DMaZZFpHW8Mf6T5HpVKVEEKfxxXpW/b96pn1PoLhJXX3cPT/xSR
	 5oWlU7eMMuZWy+ASalzhjDt9s6bdjcz1NVaO+R3FzAlIpXI4mTvBQeeZAOd2r8MB/G
	 DmSO8pOg2NaZdUHYs6KO1V7mwrzGk0sY4w++Vq/M=
Date: Sat, 24 Aug 2019 17:55:09 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, andreyknvl@google.com,
 aryabinin@virtuozzo.com, catalin.marinas@arm.com, dvyukov@google.com,
 glider@google.com, linux-mm@kvack.org, mark.rutland@arm.com,
 mm-commits@vger.kernel.org, stable@vger.kernel.org,
 torvalds@linux-foundation.org, walter-zh.wu@mediatek.com,
 will.deacon@arm.com
Subject:  [patch 11/11] mm/kasan: fix false positive invalid-free
 reports with CONFIG_KASAN_SW_TAGS=y
Message-ID: <20190825005509.BW17vfLCd%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: mm/kasan: fix false positive invalid-free reports with CONFIG_KASAN_SW_TAGS=y

The code like this:

	ptr = kmalloc(size, GFP_KERNEL);
	page = virt_to_page(ptr);
	offset = offset_in_page(ptr);
	kfree(page_address(page) + offset);

may produce false-positive invalid-free reports on the kernel with
CONFIG_KASAN_SW_TAGS=y.

In the example above we lose the original tag assigned to 'ptr', so
kfree() gets the pointer with 0xFF tag.  In kfree() we check that 0xFF tag
is different from the tag in shadow hence print false report.

Instead of just comparing tags, do the following:

1) Check that shadow doesn't contain KASAN_TAG_INVALID.  Otherwise it's
   double-free and it doesn't matter what tag the pointer have.

2) If pointer tag is different from 0xFF, make sure that tag in the
   shadow is the same as in the pointer.

Link: http://lkml.kernel.org/r/20190819172540.19581-1-aryabinin@virtuozzo.com
Fixes: 7f94ffbc4c6a ("kasan: add hooks implementation for tag-based mode")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reported-by: Walter Wu <walter-zh.wu@mediatek.com>
Reported-by: Mark Rutland <mark.rutland@arm.com>
Reviewed-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/kasan/common.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- a/mm/kasan/common.c~mm-kasan-fix-false-positive-invalid-free-reports-with-config_kasan_sw_tags=y
+++ a/mm/kasan/common.c
@@ -407,8 +407,14 @@ static inline bool shadow_invalid(u8 tag
 	if (IS_ENABLED(CONFIG_KASAN_GENERIC))
 		return shadow_byte < 0 ||
 			shadow_byte >= KASAN_SHADOW_SCALE_SIZE;
-	else
-		return tag != (u8)shadow_byte;
+
+	/* else CONFIG_KASAN_SW_TAGS: */
+	if ((u8)shadow_byte == KASAN_TAG_INVALID)
+		return true;
+	if ((tag != KASAN_TAG_KERNEL) && (tag != (u8)shadow_byte))
+		return true;
+
+	return false;
 }
 
 static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
_

