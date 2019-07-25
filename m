Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9EEFC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A429722BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dlyJ1Kob"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A429722BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 340F46B0008; Thu, 25 Jul 2019 14:43:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F2F36B000A; Thu, 25 Jul 2019 14:43:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E19B8E0002; Thu, 25 Jul 2019 14:43:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFD2D6B0008
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:43:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so31437493pfj.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=75v+7kFOX3fDCU6QmGh0HhSEpSdixRD3VTEDmH00T24=;
        b=l0AlyB99Cy8IjPkMfqbRJl2VtI5ABtbLAaXwF2JE3cpZREGzLYJHXCWvfrfZJr2HBA
         b2jxHkth6/CaYky0ezYnRAbR5l559Gc76vAeU/PN6s7cxHMq3zv8lsMrBG+W1IxyQfCW
         ITT/IGTnE2NY76OvDwWw9Oz/kDRvGRXyyNfuukqAdEwxMyM6WTOgUeiUls9W5PNCPIIL
         9wkVR/i5/vQzP6VYHD1IGQuuGGAZhJn9fbEy8YmgMGEgBTTrpusEW0nDtmslAD7t+sPL
         0dolLju6H32QbTc9fAVwpTxKaZsZxD/4NO2wbDK8SnhGoadcN6pGN/UTSRMXShSuJ8jL
         5/7Q==
X-Gm-Message-State: APjAAAWt2f4yw3RkcvjTY/FjwEWrq6ICrfcK89Z9E+Hq8aq0mW3GLzYy
	S4wWypwaDWi8ZsFFIdSIu+5HtkF250Y6N5FMmB0Q2wD571v2lz6xwKvsuSsMys2GfuTijuOseRa
	DzVpB3Beg4Zv1SEPHBBaaeiCR9JDgl12DVMokIJZhYcNmsVvkIj7Zllj0b64soI9uyg==
X-Received: by 2002:a17:902:124:: with SMTP id 33mr94438104plb.145.1564080228609;
        Thu, 25 Jul 2019 11:43:48 -0700 (PDT)
X-Received: by 2002:a17:902:124:: with SMTP id 33mr94438043plb.145.1564080227608;
        Thu, 25 Jul 2019 11:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080227; cv=none;
        d=google.com; s=arc-20160816;
        b=lr0B//GW6AjhnJDuASHmL1emroHB3YSHjWeKLnUGXKmkdnctLLoS6XP+60BhR/QLv1
         RCRuffZZfBzQHVdGkxxdvTm4bv6qnaNMAV4q1VVKr99hpJ5RdNDGkKhSvcvpT0LvjGqB
         meJW6PGO8xtzWW/DB9jviBsG2iH0NvU0zVDr5dLOOerscocdaya88+i0QgxL38bTgLZB
         iwx7FjySu9xg/GjTFz+bjLM2dUlMJy7xBSpAh2KV8FPPQMbdJviL4xNHe2XLe+bRXCYl
         jjQH2PY2HNwozt7yeVmyFneyUPQiM/OelmUj0uvg/AauHaFyYzmvR8u2z70+UCdqC911
         o5hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=75v+7kFOX3fDCU6QmGh0HhSEpSdixRD3VTEDmH00T24=;
        b=QG9WJX4xzv6z3BJxCXImxRp9/LRCBxhsKUer62C19rnoBLKWHfSF1Rdx/YTRRZaOcn
         xOmcm23O986TUiFYh5/tAbBjdY7Gq8jA/iHVc4w3pA9h87J1LFDeFhSvPrNknRELpEKB
         Qv/SqVigqSS0CQfvD6oLd1YFrsouENrvoBNYncfrBiTbpM1/mEDTOwu9+6siKiSWwtnr
         AwjyAhk4g/O5q4Wmj7WWZOuTBjLXekH3va9t3kfB3kUkqs+08N/PHq8BQudhZnT9+xg5
         cEy7FdKM+re0bH0PDfqr5TI4k4CqObirP6G3lfDGrGVSmLGr9TuQCcktpBWLWcAiQGKZ
         Rv2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dlyJ1Kob;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor30015911pgp.54.2019.07.25.11.43.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dlyJ1Kob;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=75v+7kFOX3fDCU6QmGh0HhSEpSdixRD3VTEDmH00T24=;
        b=dlyJ1KobmoWLtFv7IcNUQJNez9fMahwQ5BinTISnEvaeniV2pgG2noG7Q17DcQHHhe
         kv1BWR9vH2jTvOCKHrFyHl2Z7FSzGX7IPCY1DtjJnKYZr9ao4LPqqwI/qzKZUmlfxxj9
         gWoQjCwtrBIwL1CotH8OwPNZxE9sm3Gals+8TapRsll0joD1XmNmjoyhW2vel99FHMLl
         +v2xNA2JhyFRoDDtSggDSTjUFy4qrEY7KYIupvhwaByb4Y46kYtK2z4ns4C1yqY7zYyU
         ILNBVtcrVmOqkgkdWurIguRB5tzt0l1D6fPe1Y8dpyE5iGLmrtcwqAub4syvDoI9McrV
         GsEQ==
X-Google-Smtp-Source: APXvYqyJ16tErcZCd6V50Gl8u2liDc4czpUPjNQ0NEfS8/hL14rWy3Alcf4zsPe/54zld/LC6CpQZw==
X-Received: by 2002:a63:b555:: with SMTP id u21mr89025235pgo.222.1564080227314;
        Thu, 25 Jul 2019 11:43:47 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.43.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:43:46 -0700 (PDT)
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
Subject: [PATCH 02/10] mm/page_alloc: use unsigned int for "order" in __rmqueue_fallback()
Date: Fri, 26 Jul 2019 02:42:45 +0800
Message-Id: <20190725184253.21160-3-lpf.vector@gmail.com>
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

Because "order" will never be negative in __rmqueue_fallback(),
so just make "order" unsigned int.
And modify trace_mm_page_alloc_extfrag() accordingly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/trace/events/kmem.h | 6 +++---
 mm/page_alloc.c             | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eb57e3037deb..31f4d09aa31f 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -277,7 +277,7 @@ TRACE_EVENT(mm_page_pcpu_drain,
 TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
-		int alloc_order, int fallback_order,
+		unsigned int alloc_order, int fallback_order,
 		int alloc_migratetype, int fallback_migratetype),
 
 	TP_ARGS(page,
@@ -286,7 +286,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_STRUCT__entry(
 		__field(	unsigned long,	pfn			)
-		__field(	int,		alloc_order		)
+		__field(	unsigned int,	alloc_order		)
 		__field(	int,		fallback_order		)
 		__field(	int,		alloc_migratetype	)
 		__field(	int,		fallback_migratetype	)
@@ -303,7 +303,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 					get_pageblock_migratetype(page));
 	),
 
-	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
+	TP_printk("page=%p pfn=%lu alloc_order=%u fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
 		pfn_to_page(__entry->pfn),
 		__entry->pfn,
 		__entry->alloc_order,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 75c18f4fd66a..1432cbcd87cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2631,8 +2631,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
  * condition simpler.
  */
 static __always_inline bool
-__rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
-						unsigned int alloc_flags)
+__rmqueue_fallback(struct zone *zone, unsigned int order,
+		int start_migratetype, unsigned int alloc_flags)
 {
 	struct free_area *area;
 	int current_order;
-- 
2.21.0

