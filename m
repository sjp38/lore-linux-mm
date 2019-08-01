Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB4AAC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:01:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D69B20B7C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:01:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D69B20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F9738E0014; Thu,  1 Aug 2019 09:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AAC28E0001; Thu,  1 Aug 2019 09:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDD178E0014; Thu,  1 Aug 2019 09:01:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8528E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 09:01:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so44735098edd.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 06:01:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=32t4TJh0NZgeAJY9E8eHs80VsmDIVnSsQFGdoC7KDSk=;
        b=OhV1tRbWM9S6bkBSrFrtGCvYlI9C+NlOPmbzDKzunxolXgcg4KNKz/Ed5o3S0wbqw3
         SFYkv/4lQpQWQQMTu90rbWRjc4cP+p7qlPMSRNvzcyc6GwtzNyZxIfmclreATK1JlaoC
         ZLZrvX0xHFbD4BpgKPnTrqz4Z/1Fhq15+0zUirVjSvIktUYUYeyG3jHB1d0Z+hGcjIZh
         mwA6DL3faoSrztHSkDiPAsgpZG+niU8izMETIv8t6UnCEnYhaX9zYyfjoASIDaYx/w7G
         /A5xjB/YCqZ93KDNVBdpkWcBJLdvP7EpPcc7AscB5OuuNcJaYVcTFU5WiGn8juJTWmPZ
         U8tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVHt9Ava5HW1k1ieqjDPj0ooCV5yGYW+lOCN3jWrBBf8oSh5d4z
	uHCEcJe8OiggZjYgnXWBoTNHl+HsfYQej3d4mqKAlY+g8twIkWRRLsRU5jtwigfDEcL/Vs1p0O0
	PGWOV62+F2JvhFNWE7doe+rNuJiT/nZXCx+jG/0wu4G0ikGysMzZwaII5p+WMKDF/vQ==
X-Received: by 2002:a50:97c8:: with SMTP id f8mr112791450edb.176.1564664509183;
        Thu, 01 Aug 2019 06:01:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6LgbHl4bJrl3vbMDTDgT0glhJPAVi8/Cd8WDplxnDfFguhkVX1O9emiho2dgXcCc7R4Kd
X-Received: by 2002:a50:97c8:: with SMTP id f8mr112791328edb.176.1564664508146;
        Thu, 01 Aug 2019 06:01:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564664508; cv=none;
        d=google.com; s=arc-20160816;
        b=tygsaz/5VVIOA7/erRsV+vFrm4u82gA+Ptrx7JAW5hvJOOVZil5eclL4mhrw68FPke
         GmtFNYJwqEdPE77Qvvij9ZLOIo7Pn7JF/xXvr7QlDppldUErLeVBVJimwlvTF37OC+Dp
         RBRA5Aa5Lj4nGtsPeZJUdQGUk0VBkVT9mCywVDfe+AMVSyY17GPTAwM4r7912GHvJJ5i
         LB6WPXgs+zrd660KnO1nsWVD8VGfUVWCmyQRj2I4sNRF5zjxNA827Gt0DadG9NE0sX5O
         9yHeii8K78eYRYGd8ZZ0EOjm4tiR+EBvMSmkgSUIHPTqiCuaQGghcJy8kKcK4IM3uy/r
         bkcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=32t4TJh0NZgeAJY9E8eHs80VsmDIVnSsQFGdoC7KDSk=;
        b=gZitGvGw1Ti2Z8GmCLarYV70nhHP1sZWHngT15SLdBujutR8EW+bmUQiULcPsGdZoL
         acWmKeQpuDcTkxyLFqp+He9G5h85bXyy5LLA5lmf9LsiuYVAdpzJAb+bXxWpdeD8xGFR
         fyKMHL6BcNthAxlQzSM91vBFdDEjA1mE1UMTMh4dB09AC5tB+fQhmYo6b7BXW1s8b56K
         F3UAqL7BdEdqNQTf0KPJKANb4+47lwAj41W5cr7aPdxduTaTRc2LJgeufITcopGNzgI5
         9xXFsJZMvWbqWgSbermK6KK0b9VbWZy0Vlc/yZkwPqBWgnpTqyPzZEFaeRqckRdQ+d1j
         SL3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si20312774ejb.61.2019.08.01.06.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 06:01:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 742EAB6AB;
	Thu,  1 Aug 2019 13:01:47 +0000 (UTC)
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
 <278da9d8-6781-b2bc-8de6-6a71e879513c@suse.cz>
 <0942e0c2-ac06-948e-4a70-a29829cbcd9c@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <89ba8e07-b0f8-4334-070e-02fbdfc361e3@suse.cz>
Date: Thu, 1 Aug 2019 15:01:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <0942e0c2-ac06-948e-4a70-a29829cbcd9c@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 10:30 PM, Mike Kravetz wrote:
> On 7/31/19 5:06 AM, Vlastimil Babka wrote:
>> On 7/24/19 7:50 PM, Mike Kravetz wrote:
>>> For PAGE_ALLOC_COSTLY_ORDER allocations,
>>> MIN_COMPACT_COSTLY_PRIORITY is minimum (highest priority).  Other
>>> places in the compaction code key off of MIN_COMPACT_PRIORITY.
>>> Costly order allocations will never get to MIN_COMPACT_PRIORITY.
>>> Therefore, some conditions will never be met for costly order
>>> allocations.
>>> 
>>> This was observed when hugetlb allocations could stall for
>>> minutes or hours when should_compact_retry() would return true
>>> more often then it should.  Specifically, this was in the case
>>> where compact_result was COMPACT_DEFERRED and
>>> COMPACT_PARTIAL_SKIPPED and no progress was being made.
>> 
>> Hmm, the point of MIN_COMPACT_COSTLY_PRIORITY was that costly 
>> allocations will not reach the priority where compaction becomes
>> too expensive. With your patch, they still don't reach that
>> priority value, but are allowed to be thorough anyway, even sooner.
>> That just seems like a wrong way to fix the problem.
> 
> Thanks Vlastimil, here is why I took the approach I did.

Thanks for the explanation.

> I instrumented some of the long stalls.  Here is one common example: 
> should_compact_retry returned true 5000000 consecutive times.
> However, the variable compaction_retries is zero.  We never get to
> the code that increments the compaction_retries count because
> compaction_made_progress is false and compaction_withdrawn is true.
> As suggested earlier, I noted why compaction_withdrawn is true.  Of
> the 5000000 calls, 4921875 were COMPACT_DEFERRED 78125 were
> COMPACT_PARTIAL_SKIPPED Note that 5000000/64(1 <<
> COMPACT_MAX_DEFER_SHIFT) == 78125
> 
> I then started looking into why COMPACT_DEFERRED and
> COMPACT_PARTIAL_SKIPPED were being set/returned so often. 
> COMPACT_DEFERRED is set/returned in try_to_compact_pages.
> Specifically, if (prio > MIN_COMPACT_PRIORITY &&
> compaction_deferred(zone, order)) {

Ah, so I see it now, this is indeed why you get so many
COMPACT_DEFERRED, as prio is always above MIN_COMPACT_PRIORITY.

> rc = max_t(enum compact_result, COMPACT_DEFERRED, rc); continue; } 
> COMPACT_PARTIAL_SKIPPED is set/returned in __compact_finished.
> Specifically, if (compact_scanners_met(cc)) { /* Let the next
> compaction start anew. */ reset_cached_positions(cc->zone);
> 
> /* ... */
> 
> if (cc->direct_compaction) cc->zone->compact_blockskip_flush = true;
> 
> if (cc->whole_zone) return COMPACT_COMPLETE; else return
> COMPACT_PARTIAL_SKIPPED; }
> 
> In both cases, compact_priority being MIN_COMPACT_COSTLY_PRIORITY and
> not being able to go to MIN_COMPACT_PRIORITY caused the
> 'compaction_withdrawn' result to be set/returned.

Hmm, looks like compaction_withdrawn() is just too blunt a test. It
mixes up results where the reaction should be more reclaim
(COMPACT_SKIPPED), and the results that depend on compaction priority
(the rest), and then we should either increase the priority, or fail.

> I do not know the subtleties of the compaction code, but it seems
> like retrying in this manner does not make sense.

I agree it doesn't, if we can't go for MIN_COMPACT_PRIORITY.

>> If should_compact_retry() returns misleading results for costly
>> allocations, then that should be fixed instead?
>> 
>> Alternatively, you might want to say that hugetlb allocations are
>> not like other random costly allocations, because the admin
>> setting nr_hugepages is prepared to take the cost (I thought that
>> was indicated by the __GFP_RETRY_MAYFAIL flag, but seeing all the
>> other users of it, I'm not sure anymore).
> 
> The example above, resulted in a stall of a little over 5 minutes.
> However, I have seen them last for hours.  Sure, the caller (admin
> for hugetlbfs) knows there may be high costs.  But, I think
> minutes/hours to try and allocate a single huge page is too much.  We
> should fail sooner that that.

Sure. We should eliminate the pointless retries in any case, the
question is whether we allow the MIN_COMPACT_PRIORITY over
MIN_COMPACT_COSTLY_PRIORITY.

>> In that case should_compact_retry() could take __GFP_RETRY_MAYFAIL
>> into account and allow MIN_COMPACT_PRIORITY even for costly
>> allocations.
> 
> I'll put something like this together to test.

Could you try testing the patch below instead? It should hopefully
eliminate the stalls. If it makes hugepage allocation give up too early,
we'll know we have to involve __GFP_RETRY_MAYFAIL in allowing the
MIN_COMPACT_PRIORITY priority. Thanks!

----8<----
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..b8bfe8d5d2e9 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -129,11 +129,7 @@ static inline bool compaction_failed(enum compact_result result)
 	return false;
 }
 
-/*
- * Compaction  has backed off for some reason. It might be throttling or
- * lock contention. Retrying is still worthwhile.
- */
-static inline bool compaction_withdrawn(enum compact_result result)
+static inline bool compaction_needs_reclaim(enum compact_result result)
 {
 	/*
 	 * Compaction backed off due to watermark checks for order-0
@@ -142,6 +138,15 @@ static inline bool compaction_withdrawn(enum compact_result result)
 	if (result == COMPACT_SKIPPED)
 		return true;
 
+	return false;
+}
+
+/*
+ * Compaction  has backed off for some reason. It might be throttling or
+ * lock contention. Retrying is still worthwhile.
+ */
+static inline bool compaction_withdrawn(enum compact_result result)
+{
 	/*
 	 * If compaction is deferred for high-order allocations, it is
 	 * because sync compaction recently failed. If this is the case
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..3dfce1f79112 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3965,6 +3965,11 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (compaction_failed(compact_result))
 		goto check_priority;
 
+	if (compaction_needs_reclaim(compact_result)) {
+		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
+		goto out;
+	}
+
 	/*
 	 * make sure the compaction wasn't deferred or didn't bail out early
 	 * due to locks contention before we declare that we should give up.
@@ -3972,8 +3977,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * compaction.
 	 */
 	if (compaction_withdrawn(compact_result)) {
-		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
-		goto out;
+		goto check_priority;
 	}
 
 	/*

