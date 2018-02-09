Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48FF96B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 20:54:29 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f1so984578plb.7
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 17:54:29 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id z5-v6si806209pln.677.2018.02.08.17.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 17:54:28 -0800 (PST)
Received: from mail.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.codeaurora.org (Postfix) with ESMTP id C75DF6079C
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 01:54:27 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 08 Feb 2018 17:54:27 -0800
From: pdaly@codeaurora.org
Subject: [Question] zone_watermark_fast & highatomic reserve
Message-ID: <93189939f16287f89a64691cf31a74fa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I am trying to understand the comment in zone_watermark_fast() that for 
the case
of an order-0 allocation, it is ok to return true without considering
zone->nr_reserved_highatomic.

Suppose that:
1)CONFIG_CMA = n
2)zone_page_state(z, NR_FREE_PAGES) > zone->watermark[WMARK_MIN]
3)There is only one page which is MIGRATE_MOVABLE; all others are 
MIGRATE_HIGHATOMIC.
4)There is one zone, so zone->lowmem_reserve = 0

For an order 0 GFP_KERNEL allocation:
zone_watermark_fast() returns true due to not considering the amount of
highatomic memory. rmqueue() finds the page in the MIGRATE_MOVEABLE 
freelist
and returns it.

But I was expecting that the last available pages in the system would be
reserved for allocations with ALLOC_HARDER/ALLOC_HIGH set. For example,
order-0 atomic allocations.
What am I getting wrong here?


Regarding assumption 2&3)-
For an device with 2Gb memory:
the table above init_per_zone_wmark_min() shows that min_free_kbytes = 
5792k.
This would be ~1448 pages.
reserve_highatomic_pageblock() caps highatomic pages at 1% of zone. This
would be 2^31/(2^12 * 100) ~= 5242 pages.

--Patrick

-- 
  The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
  a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
