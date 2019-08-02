Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66444C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35E0F217D6
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:06:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35E0F217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9F9B6B0006; Fri,  2 Aug 2019 08:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4FFF6B0008; Fri,  2 Aug 2019 08:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3FB96B000A; Fri,  2 Aug 2019 08:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 638686B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 08:06:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so46777380edd.22
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 05:06:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9fqR+wzp5nPz+1eABmakW8wGp2kAXtqKkhmmgURv470=;
        b=T0rwA369/JPfFSj8a8vK3ph1dCU+Hdk7ZPn2ME0mqnYhg2X5uxtaYIl6wjeAb6IuF4
         ZYRHwmPMCYP2m6y93hfotxNtng/3SlPigY3NH7rpXiXB9/gIduTiWQrz0UOrZUDn36FG
         MQihbZznR4lFP/L0MjKywvrYJDR7Xei59p+GwHUkueodesD5xdXMgo0IR1qVpJgdb89g
         MVorjcb6HqIY1nkQ+b/8SRnI+kQ7z44jFxtt6ozyNHGN0qIpd11FjMxEynnVeXQovuVa
         g7YdzPXkUiKgDe3j2XWlmQTuTPluaJ50dDjZvfRWZUOKVUSt6oW5jctEH/F6xItMNvU7
         0UdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUJyXnMP3Qy8aY7BOPtpQwFJJhkv+T5WZg/5L8KIgk39w34jVB9
	mCxfyf9lZmbWxIj+gqjOHkelpNi6PkAyJrpYMykyttc0gXahBDqeicGrKkeCv+s4b35Np0Dw6j7
	LtSUdg9xNyhSsAbTwGUAOfojS13lX4uwgy8dRWPHVTzP7FKunFTWgR360Vek47xUvqQ==
X-Received: by 2002:a17:906:f211:: with SMTP id gt17mr103800514ejb.263.1564747562864;
        Fri, 02 Aug 2019 05:06:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZnXP1Cn5UyxlpXoFxknfsKAdV7jV54qkMRVTDblvk5IvzGZ8SLn9zPMmNgNEtzaQBcHPE
X-Received: by 2002:a17:906:f211:: with SMTP id gt17mr103800347ejb.263.1564747561250;
        Fri, 02 Aug 2019 05:06:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564747561; cv=none;
        d=google.com; s=arc-20160816;
        b=SYv6Coj8IdBsw5q3NtW5N+SUveQuTKABTmVi8YpS0pJ/7Sgml0KhVAZ3/lBpjkH4Kv
         VYsCTDDZyCX2bFKIyq85+SZrbVPw4teAlxfXRHBl0NbuELNgRRdNIaFg8O6BIjUsIefB
         ayFbPqAa94JpxHfp8Ju2EBOw0FwhTvSUuxNC/TjLBeH5Z3muwDnC0neQ9UOPFZoLco7+
         NJzNmSkGJ5WYwotIA5LG+frtnXrzZELAjcc7XC3ekgSt805KEMz/reJVHZF7lo3dm7BN
         iE+HKmzvWd+k1EPTf7Xz/TDAKD9mslqhIifU3HQkRXHFKzWHEwXv4+sRaPJBXAja13c/
         lOfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9fqR+wzp5nPz+1eABmakW8wGp2kAXtqKkhmmgURv470=;
        b=VDjyWVTw9Zdvl10mC+LIcGBxgIi4zH0Wu8h1bhNSU8eIpeqXiU2EpV9X0eBtk1dhli
         bcmf2X4+j6wl8IT3ZBPL2L2OgXzyH0aVhs+06nn8FpmbC99prariwTrODbtIqHSsZJiE
         mJDSbdoWs2WNTfAP9Tfi+8Z3WoqmO8Ne+DZh5eEjnfSSdkU8HBiWmPwgkpAadVa0GpfQ
         nDdmSSIK4qdCa9yV/RUzuol7EUwnOlLOc53gHPTr1CdhOdUXFkrJVDM9Dn9LVd1ctlUR
         yyB0gjY4jz0GhoqwArHxqZGI4D9N8mBL93EQqnP8CTmsRTPmG7SCPV4bCNESrKhTtLEg
         NYcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w20si4469494ejn.18.2019.08.02.05.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 05:06:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DBCD3AE50;
	Fri,  2 Aug 2019 12:05:59 +0000 (UTC)
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
 <278da9d8-6781-b2bc-8de6-6a71e879513c@suse.cz>
 <0942e0c2-ac06-948e-4a70-a29829cbcd9c@oracle.com>
 <89ba8e07-b0f8-4334-070e-02fbdfc361e3@suse.cz>
 <2f1d6779-2b87-4699-abf7-0aa59a2e74d9@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <88e89521-9be2-3886-2155-c7f8d9c22bbb@suse.cz>
Date: Fri, 2 Aug 2019 14:05:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2f1d6779-2b87-4699-abf7-0aa59a2e74d9@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/1/19 10:33 PM, Mike Kravetz wrote:
> On 8/1/19 6:01 AM, Vlastimil Babka wrote:
>> Could you try testing the patch below instead? It should hopefully
>> eliminate the stalls. If it makes hugepage allocation give up too early,
>> we'll know we have to involve __GFP_RETRY_MAYFAIL in allowing the
>> MIN_COMPACT_PRIORITY priority. Thanks!
> 
> Thanks.  This patch does eliminate the stalls I was seeing.
> 
> In my testing, there is little difference in how many hugetlb pages are
> allocated.  It does not appear to be giving up/failing too early.  But,
> this is only with __GFP_RETRY_MAYFAIL.  The real concern would with THP
> requests.  Any suggestions on how to test that?

Here's the full patch, can you include it in your series?
As madvised THP allocations might be affected (hopefully just by stalling less,
not by failing too much), adding relevant people to CC - testing the scenarios
you care about is appreciated. Thanks.

----8<----
From 67d9db457f023434e8912a3ea571e545fb772a1b Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 2 Aug 2019 13:13:35 +0200
Subject: [PATCH] mm, compaction: raise compaction priority after it withdrawns

Mike Kravetz reports that "hugetlb allocations could stall for minutes or hours
when should_compact_retry() would return true more often then it should.
Specifically, this was in the case where compact_result was COMPACT_DEFERRED
and COMPACT_PARTIAL_SKIPPED and no progress was being made."

The problem is that the compaction_withdrawn() test in should_compact_retry()
includes compaction outcomes that are only possible on low compaction priority,
and results in a retry without increasing the priority. This may result in
furter reclaim, and more incomplete compaction attempts.

With this patch, compaction priority is raised when possible, or
should_compact_retry() returns false.

The COMPACT_SKIPPED result doesn't really fit together with the other outcomes
in compaction_withdrawn(), as that's a result caused by insufficient order-0
pages, not due to low compaction priority. With this patch, it is moved to
a new compaction_needs_reclaim() function, and for that outcome we keep the
current logic of retrying if it looks like reclaim will be able to help.

Reported-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/compaction.h | 22 +++++++++++++++++-----
 mm/page_alloc.c            | 16 ++++++++++++----
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..4b898cdbdf05 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -129,11 +129,8 @@ static inline bool compaction_failed(enum compact_result result)
 	return false;
 }
 
-/*
- * Compaction  has backed off for some reason. It might be throttling or
- * lock contention. Retrying is still worthwhile.
- */
-static inline bool compaction_withdrawn(enum compact_result result)
+/* Compaction needs reclaim to be performed first, so it can continue. */
+static inline bool compaction_needs_reclaim(enum compact_result result)
 {
 	/*
 	 * Compaction backed off due to watermark checks for order-0
@@ -142,6 +139,16 @@ static inline bool compaction_withdrawn(enum compact_result result)
 	if (result == COMPACT_SKIPPED)
 		return true;
 
+	return false;
+}
+
+/*
+ * Compaction has backed off for some reason after doing some work or none
+ * at all. It might be throttling or lock contention. Retrying might be still
+ * worthwhile, but with a higher priority if allowed.
+ */
+static inline bool compaction_withdrawn(enum compact_result result)
+{
 	/*
 	 * If compaction is deferred for high-order allocations, it is
 	 * because sync compaction recently failed. If this is the case
@@ -207,6 +214,11 @@ static inline bool compaction_failed(enum compact_result result)
 	return false;
 }
 
+static inline bool compaction_needs_reclaim(enum compact_result result)
+{
+	return false;
+}
+
 static inline bool compaction_withdrawn(enum compact_result result)
 {
 	return true;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..bd0f00f8cfa3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3965,15 +3965,23 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (compaction_failed(compact_result))
 		goto check_priority;
 
+	/*
+	 * compaction was skipped because there are not enough order-0 pages
+	 * to work with, so we retry only if it looks like reclaim can help.
+	 */
+	if (compaction_needs_reclaim(compact_result)) {
+		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
+		goto out;
+	}
+
 	/*
 	 * make sure the compaction wasn't deferred or didn't bail out early
 	 * due to locks contention before we declare that we should give up.
-	 * But do not retry if the given zonelist is not suitable for
-	 * compaction.
+	 * But the next retry should use a higher priority if allowed, so
+	 * we don't just keep bailing out endlessly.
 	 */
 	if (compaction_withdrawn(compact_result)) {
-		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
-		goto out;
+		goto check_priority;
 	}
 
 	/*
-- 
2.22.0

