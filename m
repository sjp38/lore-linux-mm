Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C30C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92A4B22CBA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ry2zmLqy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92A4B22CBA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA396B0003; Thu, 25 Jul 2019 14:43:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 052956B0008; Thu, 25 Jul 2019 14:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3DE18E0002; Thu, 25 Jul 2019 14:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B06826B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:43:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so26792625plk.23
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OxsBtkR8V6+s0OkCC+Hu7HIqYT8kxjr7WRYhfDwWQac=;
        b=fkIAGpSc46Yfv2YYCkRGC0k3DXtaKy0fTAQZLmRtsxPoxpsGNsVjjRhPpcBUPSqst5
         j/+KpoNu7X3UWutrn6Pj3C4mdxwFm+/brgu+kn9Rlr1HrE3aQTiqM60ZvovFYqa8ukql
         5epZzDskUWgrugxLCv5W6RXQicAXv+Q0ICWw1+vkFMDeH4i8hPs14TFRquLnc9ZZW13/
         ZWmzNet4MEgqxlbtpUaB6yUxV0XlZoFq0egOpI2q13knVccRBrjUim0ek5DTgU1ZSvig
         ky/PMAr9vewnN4ep+mN5voUimWkP02s650D+NYTkVpQzwsoyqbRGwZgsHUjMRxqm8mtB
         RWAQ==
X-Gm-Message-State: APjAAAVyn0y0EX3udq3NqU/dcscdO9luqqrLoQxzHczTYFYIfPDt2IQl
	Y4iUyQa+3OO9LbKqsnO5r0w/eaTlING9+IOO+Gm2gDlFl7ma0cBS2tRCOnmwD57QruHUpuerDAx
	G/gAxwzMXTBYqEGHkACkrhkpHvvaDzQsuH9jyCbkX91u9LuIi7shuRw1WUxJpsrwhOg==
X-Received: by 2002:aa7:8481:: with SMTP id u1mr17258059pfn.243.1564080220297;
        Thu, 25 Jul 2019 11:43:40 -0700 (PDT)
X-Received: by 2002:aa7:8481:: with SMTP id u1mr17257988pfn.243.1564080219281;
        Thu, 25 Jul 2019 11:43:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080219; cv=none;
        d=google.com; s=arc-20160816;
        b=pECUN0HvIWN2r19mnTTGYmyhEIa+wplEiV5sRMbu8w+67L7+tunRx1xVdiV3WEeTrd
         yOGHtlw7SWgecaYISOnztbUfLRVkSDqFAmCgAgNRrmrDBz4qpj2b7xrU6JBs7vpzOkAj
         OMNZIiIhUDdyCzSK3OCHjqlhUnVxxKcO9svSv8KYbG2KGdGb33s4ypOp0cs4ckTMCHEJ
         3F1z+HCYmDRUjXRjNeIG9luZ5qg4b3TrfWkZMPTKGykrTCTqq9jNDzGsiDOOVhskIaJa
         gvq8nKPFEzt3Hs6MNCUZaH9DInAPUiQXUHa8Ek2lo8c17HfPctuj7uiW0uahIaoCBIG5
         895A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OxsBtkR8V6+s0OkCC+Hu7HIqYT8kxjr7WRYhfDwWQac=;
        b=jc5HlBI/G7uitWPDDmj71ip4LzU3I5zuJ0ayw1Vlf1BJPoYhrDMd3iMvbCSTcHMRo9
         tV4wWsB20yKei7Ft5SeFrhdgf5qMQD0m8aFwGTCD9PsEuxWh4wJa87rYuBghKha1QhI7
         8zcO0icPiiMKl/WFbyNOxOFupaU5OpQDCD+deG7kYw+/s2vN9aYjnmRK/hSD08y1TctT
         AvKQ6VC7UAD8XYVIjeINDD7Lb2KNTCmwhAYTuYyZtxHoogpoCk3DT/yXzUztUGlLgzXV
         2VZKuEEJyh+JynqhQ/otDmCpeYFDqdsB5kKKQ6OboBDlODZyRo2IcFAgEwIzKuNcC54B
         xZaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ry2zmLqy;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q65sor31793754pfq.38.2019.07.25.11.43.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:43:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ry2zmLqy;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=OxsBtkR8V6+s0OkCC+Hu7HIqYT8kxjr7WRYhfDwWQac=;
        b=ry2zmLqy2lsaOf19QbIYeTpO253PbKl4qzCc1S9mFX+H9n3B+/+5u83D1qe5RePhVE
         TOyPjcoM92ICenSmuv7isTDBNg2TZUX4CZ8vOcuARZ9WvJ5OLO7oE9lip/0QLEmYnyo7
         MpXJTJPjkL2/X2ge8PyV40QreWCZaWZDFQIAy7f+Zb9QR2NiEGbLtQSchU5EFKj7uktJ
         eR3tbUXE5U30f/r8yHwKI2Yth+uYH+Bpn3aWc8EQzx2JVNnRkCZmnpyBvEMr6BHvQOIY
         kEjVrQWbskaEntYS6HGUzlzdlG473FUzeVUnyks1SV5C6E6xKjIzV6Kkh6/5Ps6ytE8c
         A7YA==
X-Google-Smtp-Source: APXvYqx/qV8WrsVV5Jeo7kC8964Q2Z2pSXahBIrPoXsoo219HEPPNsilSeBuWsKIQejpQYkJR+GM7g==
X-Received: by 2002:a62:3347:: with SMTP id z68mr18528585pfz.174.1564080219029;
        Thu, 25 Jul 2019 11:43:39 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.43.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:43:38 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 01/10] mm/page_alloc: use unsigned int for "order" in should_compact_retry()
Date: Fri, 26 Jul 2019 02:42:44 +0800
Message-Id: <20190725184253.21160-2-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Like another should_compact_retry(), use unsigned int for "order".
And modify trace_compact_retry() accordingly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/trace/events/oom.h | 6 +++---
 mm/page_alloc.c            | 7 +++----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
index 26a11e4a2c36..b7fa989349c7 100644
--- a/include/trace/events/oom.h
+++ b/include/trace/events/oom.h
@@ -154,7 +154,7 @@ TRACE_EVENT(skip_task_reaping,
 #ifdef CONFIG_COMPACTION
 TRACE_EVENT(compact_retry,
 
-	TP_PROTO(int order,
+	TP_PROTO(unsigned int order,
 		enum compact_priority priority,
 		enum compact_result result,
 		int retries,
@@ -164,7 +164,7 @@ TRACE_EVENT(compact_retry,
 	TP_ARGS(order, priority, result, retries, max_retries, ret),
 
 	TP_STRUCT__entry(
-		__field(	int, order)
+		__field(unsigned int, order)
 		__field(	int, priority)
 		__field(	int, result)
 		__field(	int, retries)
@@ -181,7 +181,7 @@ TRACE_EVENT(compact_retry,
 		__entry->ret = ret;
 	),
 
-	TP_printk("order=%d priority=%s compaction_result=%s retries=%d max_retries=%d should_retry=%d",
+	TP_printk("order=%u priority=%s compaction_result=%s retries=%d max_retries=%d should_retry=%d",
 			__entry->order,
 			__print_symbolic(__entry->priority, COMPACTION_PRIORITY),
 			__print_symbolic(__entry->result, COMPACTION_FEEDBACK),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..75c18f4fd66a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3940,10 +3940,9 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 }
 
 static inline bool
-should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
-		     enum compact_result compact_result,
-		     enum compact_priority *compact_priority,
-		     int *compaction_retries)
+should_compact_retry(struct alloc_context *ac, unsigned int order,
+	int alloc_flags, enum compact_result compact_result,
+	enum compact_priority *compact_priority, int *compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
 	int min_priority;
-- 
2.21.0

