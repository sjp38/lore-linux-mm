Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44928C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D16E272E2
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rA9OPVjt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D16E272E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A278A6B0287; Sat,  1 Jun 2019 09:20:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D7536B0288; Sat,  1 Jun 2019 09:20:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ED056B0289; Sat,  1 Jun 2019 09:20:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 566AE6B0287
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so6554773pgo.14
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9XKuHE0MSp7E9qLBkmtAFWmFZ5kzqm2rLcAv0iOzMGc=;
        b=G4MbrGcfx3abzY/eAtLRYnPYvSdoOntAwOp1IG5JXeBUst28o8ibH1qVbEZVo9CLDa
         ynuockL5sQ6gMt5rj+nGhaDDTop7FXRVRHxo6sjc15FmOrfHnHuVCE7owlBjhYHTgI5y
         uv1srUQ+PdcFiZeGm75hW8iVbJnownH18hXsu3+Tdrt9jAkOj7iAs22ShEgslQkr6Wft
         fUJOTCdlmqA2n3TUtuODkWxTfELZQode5oO2BKNHWzvgdlVLc7x4Acbx+EMI4OUpXBGf
         LEvbWxazTsLGFsbJYIWfHj6GX2feUAcPuxxO3YGhOgyRNYYtWl2C2xXtdpyBXOJY+ouM
         DCXA==
X-Gm-Message-State: APjAAAUGLJQrPauUMeZm3YUvf/cWqjzGzu3z4OcOemeg/Gmj9QW2ExLw
	ET69MFATDZwBK/bdX+bq7bCC2kPRAHfeamX/EUmqhkFClDywbcNFsL1sD8tSvjG67WCjAWXbv77
	KMTgi1P3xO5qdP6dWgnNiJ2nnfHWThrOsUy+THJPlT2OtISUnhEnw6Xi1d9Vzc5XtTw==
X-Received: by 2002:aa7:9104:: with SMTP id 4mr17010129pfh.66.1559395234019;
        Sat, 01 Jun 2019 06:20:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYtGiwHnOA/MTXHZVQlsY77PodGVEhYe6QfrEzKeZdo+7Xd6CURvm7mb2CZaKxBGSdrdO9
X-Received: by 2002:aa7:9104:: with SMTP id 4mr17010062pfh.66.1559395233315;
        Sat, 01 Jun 2019 06:20:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395233; cv=none;
        d=google.com; s=arc-20160816;
        b=aWDjmZvCEkZ0hAyOWb4yP+xCXBjQwCgOwPt831cZLtpnn6hxc5YKZ2JVblgtQN8FqC
         WDb4E2DwrU20urfr9Tb123pqaPlGWYYp9NITaEVeGa/6Haepx+DIwkLUFHdFpVLXc0Gy
         WEMaJV5jhZ56BXdPEUxCt2JJTy5beYd0uB9MrUDQhc3iQvKocMj9FAtuqgK29mDagZLQ
         OSMP33PaJXlCCquRfVx90DHOi2jSNOggYOV4tZ03lCJ7+c0bw4GhxNoZHw1nza7sxrI8
         mwpQkEFGAFmp5iyAvhh9lQyMbTvFiZn8wTPLn2V2JGfltiN492iW33V7nopbQY9E/8as
         tERA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9XKuHE0MSp7E9qLBkmtAFWmFZ5kzqm2rLcAv0iOzMGc=;
        b=iMMjTsIUI19PcGrsXjvbqCBcUzwvuf+jOI0ZOy1aiP33ZVf6vL6JnpoDs10BDqAI8J
         STkZIh7n7NZGDJOSnMluw4qspacVVTScnaYhBqhCbvD9SJZgMDhZEgFgjJ7dDtlcJx2a
         lKMP3gHANSJ1YrfGGLBd1uTcxjMn/3Ac/FnQZnryTjjR6yrMRanrH1IMkkVje37j+Zah
         12DmBjl8JBEuiRnoXHb14irx/tWJYVSMkXyBXoDBkUA4e8G0Dyfzn1q+wWuOC+kkNUfU
         cnq5UtoliDaHzv/AwsZjcYuSlBlYlE8Mw/mxm2XhX35YXkytCLRh/XA5JqlB96jUDcVr
         PbhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rA9OPVjt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s7si9573234pji.107.2019.06.01.06.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rA9OPVjt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AE084272DB;
	Sat,  1 Jun 2019 13:20:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395233;
	bh=i2CKDvvI3H1Wdcjf6zDc07VYBcgn+3crgsPxk0chYKw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=rA9OPVjt3HdvnevdKf64evreMsSRwglAN1X6gVGdawdt5e4dWgYiIdXPDgZWhGtEd
	 JI47YgYhtfLr5UdmPK/1/bxwNP1C4KhtHFfVXIVZSjRvjxSgKcD4wL2iEBu0lD4MrW
	 D9FA3A44QyX+bY1SqYb5mziMwvOutgyvT/5Uy8h4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ingo Molnar <mingo@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Laura Abbott <labbott@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 017/173] mm/cma.c: fix the bitmap status to show failed allocation reason
Date: Sat,  1 Jun 2019 09:16:49 -0400
Message-Id: <20190601131934.25053-17-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 2b59e01a3aa665f751d1410b99fae9336bd424e1 ]

Currently one bit in cma bitmap represents number of pages rather than
one page, cma->count means cma size in pages. So to find available pages
via find_next_zero_bit()/find_next_bit() we should use cma size not in
pages but in bits although current free pages number is correct due to
zero value of order_per_bit. Once order_per_bit is changed the bitmap
status will be incorrect.

The size input in cma_debug_show_areas() is not correct.  It will
affect the available pages at some position to debug the failure issue.

This is an example with order_per_bit = 1

Before this change:
[    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=> 638 free of 1024 total pages

After this change:
[    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=> 252 free of 1024 total pages

Obviously the bitmap status before is incorrect.

Link: http://lkml.kernel.org/r/20190320060829.9144-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index f160ce31ef469..0b6d6c63bcef5 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -371,23 +371,26 @@ int __init cma_declare_contiguous(phys_addr_t base,
 #ifdef CONFIG_CMA_DEBUG
 static void cma_debug_show_areas(struct cma *cma)
 {
-	unsigned long next_zero_bit, next_set_bit;
+	unsigned long next_zero_bit, next_set_bit, nr_zero;
 	unsigned long start = 0;
-	unsigned int nr_zero, nr_total = 0;
+	unsigned long nr_part, nr_total = 0;
+	unsigned long nbits = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	pr_info("number of available pages: ");
 	for (;;) {
-		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
-		if (next_zero_bit >= cma->count)
+		next_zero_bit = find_next_zero_bit(cma->bitmap, nbits, start);
+		if (next_zero_bit >= nbits)
 			break;
-		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		next_set_bit = find_next_bit(cma->bitmap, nbits, next_zero_bit);
 		nr_zero = next_set_bit - next_zero_bit;
-		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
-		nr_total += nr_zero;
+		nr_part = nr_zero << cma->order_per_bit;
+		pr_cont("%s%lu@%lu", nr_total ? "+" : "", nr_part,
+			next_zero_bit);
+		nr_total += nr_part;
 		start = next_zero_bit + nr_zero;
 	}
-	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	pr_cont("=> %lu free of %lu total pages\n", nr_total, cma->count);
 	mutex_unlock(&cma->lock);
 }
 #else
-- 
2.20.1

