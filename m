Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6E39C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B28221734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AMv18hDC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B28221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3378E6B026A; Wed, 27 Mar 2019 14:03:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BD3C6B026B; Wed, 27 Mar 2019 14:03:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 138596B026C; Wed, 27 Mar 2019 14:03:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C30946B026A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o4so14563260pgl.6
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Jr+PzPGb0B6CDRISq/SwheQLQ1nMXSDO/cNUisVg5MA=;
        b=T/cu5/cRMamm+W/61Heueide0MEdz2MfSTljuVTicxYAObbh3NGYPpYppPfqDjkfm5
         /1J2/MgYjguPUlyWrBvbumJczj7+yqwPbLWDuh6KMOv76Rh0HALbZVQiX/A1RvgmDBBg
         M5g+2rqGwwfr80N61XYus35UBUZ/bEMVSd2Fcjw8BjXcVyOaRi30jIL512Nb7WPjj4VG
         3hv5s/zWooj40q9XBc0peiQyL+DDCcigwc9nmVQlNTzAnf0qcExynRU323jDg/4JCE7p
         HQpf/2fI0nbpH7qiJZvYbUBRK6f4GjNKItl9ucmckJa2NwmKPLRxVsKj78uXjg0L2ky9
         ODRg==
X-Gm-Message-State: APjAAAU06w5CJALTAil2HE/QBJi9mqnrS8YYPnzLb5hLatP/UUp6HDDd
	PJxhpHrDqxRUpf7D1yiWJg4dtmf3LYlcjwaUEsVRD4gBxQ/03EYhD2D/Pao2PlXWE19HTB8Lpjp
	VpzVqzKymuhdpXcht9p+wOCXsTA+XEQ+sBMjvhoYa+TAhVDOzQTCnRFPY+II+ImYWeg==
X-Received: by 2002:a63:d444:: with SMTP id i4mr35999935pgj.149.1553709802462;
        Wed, 27 Mar 2019 11:03:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5zYj0i/HUrwkf0SfHFggn3oVR5jUJCq/s7mkApBYcARDCWbKVQ+irxiI+Xh9wpfEcoVdg
X-Received: by 2002:a63:d444:: with SMTP id i4mr35999856pgj.149.1553709801629;
        Wed, 27 Mar 2019 11:03:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709801; cv=none;
        d=google.com; s=arc-20160816;
        b=TTidOhWIqoj1BKqk1VrhiOuaCwGsp3SgR9x0SMZ0c5YEvtECrkVLvdVsJaJTTdyatc
         5I7LRKgTK2EvA5yZr/BZtBKJjvRL+GxldGGpBtlzTLQEbo2IsYSPZdAjc6DIqhr2wwM9
         JSZcdLSQEgbI0BVQPDTiH1urpyJxlvBrFR7SliQDWAmptdg2qlaLMH6Y4E39wJ9mPdBJ
         eh/dmw49nGzAM3Fbkb7bUjW14g+v9JSywYSXXtwBl6q7L8HiLwTX1oPEA9B+cptgpENg
         o2TfUA2up3Vzt+Cu4OYoN9IbH9KZSZR0AIooU0zrhW3Cx2DYlUQHlX7r+Ev4wFjEr0ZB
         fMRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Jr+PzPGb0B6CDRISq/SwheQLQ1nMXSDO/cNUisVg5MA=;
        b=JuKRXlngfY16vAaLPnp15Sc7mwJtDLOxDOVRMVsv9vW2jnWAzHbe6k2g4rYFnp8gbA
         Yg+YaT69ejYX6Kocgn3VT8+M276tmEPTpZmhUMQTYfD1bBlHSnUmB506y7+gpQMZtBWP
         5Bk2OYnxXTqtBf/sAu1xqhFt6q0CQqehe3yzDkwySWCHl2mG4Ky/D23TAH8C50MSo1EH
         fuDz6sQYl3obeJU2lpE3GERTrd4+vZ8RJRU4DSSNExeVuRzF5oRt/1F+NVm9WRMaoID8
         eSV18aO6u163nEH7DZpSvJNa9TmcxB0IS+5WkRW4Z5lYDNVDw3/5lUQLjMsBL7Omnl2E
         oyGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AMv18hDC;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x4si18299164pgp.370.2019.03.27.11.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AMv18hDC;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 792E92147C;
	Wed, 27 Mar 2019 18:03:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709801;
	bh=FRAKY1CotUHVxCnDmq5Ek+oJvURhXLmI4VPfroxhSlY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=AMv18hDClKoNkxSJW4rz3ZQgQoO79fQhRGIqlyrVYdFChnGnPqjqSzNkYrLxM3HWB
	 a6Z23nvL/Ed9S7W1P0cC8Fi++Bc0/dL9U6n7dOJGaBjd4Php5asdUF66fMNINCTgD2
	 4QD5B91VT3m/U3Ck2aeqO3vpKE1in4vEfULnUNmM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 044/262] page_poison: play nicely with KASAN
Date: Wed, 27 Mar 2019 13:58:19 -0400
Message-Id: <20190327180158.10245-44-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 4117992df66a26fa33908b4969e04801534baab1 ]

KASAN does not play well with the page poisoning (CONFIG_PAGE_POISONING).
It triggers false positives in the allocation path:

  BUG: KASAN: use-after-free in memchr_inv+0x2ea/0x330
  Read of size 8 at addr ffff88881f800000 by task swapper/0
  CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc1+ #54
  Call Trace:
   dump_stack+0xe0/0x19a
   print_address_description.cold.2+0x9/0x28b
   kasan_report.cold.3+0x7a/0xb5
   __asan_report_load8_noabort+0x19/0x20
   memchr_inv+0x2ea/0x330
   kernel_poison_pages+0x103/0x3d5
   get_page_from_freelist+0x15e7/0x4d90

because KASAN has not yet unpoisoned the shadow page for allocation
before it checks memchr_inv() but only found a stale poison pattern.

Also, false positives in free path,

  BUG: KASAN: slab-out-of-bounds in kernel_poison_pages+0x29e/0x3d5
  Write of size 4096 at addr ffff8888112cc000 by task swapper/0/1
  CPU: 5 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc1+ #55
  Call Trace:
   dump_stack+0xe0/0x19a
   print_address_description.cold.2+0x9/0x28b
   kasan_report.cold.3+0x7a/0xb5
   check_memory_region+0x22d/0x250
   memset+0x28/0x40
   kernel_poison_pages+0x29e/0x3d5
   __free_pages_ok+0x75f/0x13e0

due to KASAN adds poisoned redzones around slab objects, but the page
poisoning needs to poison the whole page.

Link: http://lkml.kernel.org/r/20190114233405.67843-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c  | 2 +-
 mm/page_poison.c | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b9f577b1a2a..10d0f2ed9f69 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1945,8 +1945,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
-	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	kernel_poison_pages(page, 1 << order, 1);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index f0c15e9017c0..21d4f97cb49b 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -6,6 +6,7 @@
 #include <linux/page_ext.h>
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
+#include <linux/kasan.h>
 
 static bool want_page_poisoning __read_mostly;
 
@@ -40,7 +41,10 @@ static void poison_page(struct page *page)
 {
 	void *addr = kmap_atomic(page);
 
+	/* KASAN still think the page is in-use, so skip it. */
+	kasan_disable_current();
 	memset(addr, PAGE_POISON, PAGE_SIZE);
+	kasan_enable_current();
 	kunmap_atomic(addr);
 }
 
-- 
2.19.1

