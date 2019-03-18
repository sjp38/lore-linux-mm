Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7380BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17E6F20854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17E6F20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE0F6B0003; Mon, 18 Mar 2019 08:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 985AA6B0006; Mon, 18 Mar 2019 08:22:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FFF76B0007; Mon, 18 Mar 2019 08:22:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 219BC6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 08:22:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o12so6264060edv.21
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:22:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Aiv6boU+471cQ+NGAunxlTiiAuCpCDZlv8VbxZBboEE=;
        b=J7UHTHtlRd/CUoOBPy8LE3UkaQ5/ktRE2LNzZUSpUgOIv1/JtsR4ni3vFBDFKZlqSs
         F7odQNicWo/jJqL2IRjiVLbiR0vvwaWQ4OfPgz439zGeMm3Qj2QsH6pgeeXv8nvniMvl
         egzF97GMgyf17MvozBvC/TYp4iwDKvj4uo3GDJ8caq67W9SYth9nbTkMFzkPytaXso1P
         lwX3aT6VfO8h+SFQFEEy3XvoAvZiYCTXEyYFdBsxM4YR0XbF8J51kWKSAX19ENfFcGiv
         ftiTca4tIXZ5cDIw6DDHkc1GXrZ9AF6pNngO5GsqTnZzSoo9ZyHTTXrGurzfztDl4d4V
         jTrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVxgfNsLFtaxwcp/FCWGcMc2lPJpjxAchvnylwxCEWFnC3dGATp
	uFJN0tkcztnXqyPSOdVgtUR16324clbsEluR8mQUSx/wgUY9iTLTzfBbN8Hvn9Pzsvbi7/HI4Aq
	GaEib2MWMhFy/zfufSZ6x3uHw6PfDmyQRaWD6HN1y5S82oObxAym7EOo/d5jTBuP/oA==
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr2208347ejv.57.1552911721634;
        Mon, 18 Mar 2019 05:22:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjY38rqa1YB8rUBug7PLk1RtOTDpuRUo4bEwbxpw+UC8eAyjKjtnZmC1gixY3jsqU/qXeo
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr2208298ejv.57.1552911720656;
        Mon, 18 Mar 2019 05:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552911720; cv=none;
        d=google.com; s=arc-20160816;
        b=WrsCWQdz6ipZIaVr5ZxZn5KlLjzEgD19oCajdQo4f6baSVcPVooRsegIAN0sbvdHGw
         WkxqwhEBJnhFQ+iAF4keNBvI1iJMmLRGZetsEsJqbmfepJHH6qDNChUNw4NOB/Z/T5iA
         RNE1/EypH38Dscw4bcVZSgcvnvWDsy9L5aRO8/JGThhbMTo1pBudcMoHUuRNC+7tuxrN
         3Mp/AltdTnKkFtIiQp8Izg9l+WNgwEzn49gm12DCCAT1lzc6+/EdUKWOOEIO8o7o7bJC
         Ed56oBk1S906g8Fax51PN7qz2VBkFDTyOs61tDgXGG7AsCMpZtWNtuJM0KtUt9uYA6Td
         vaww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Aiv6boU+471cQ+NGAunxlTiiAuCpCDZlv8VbxZBboEE=;
        b=wK55Bwvlc0RDWCXVHUULCmuhUN9nIKpaPGZnLkP4XChrBkghp+DJYVtYL5W1TECPN6
         KpdufdbRr2w2yLbFibpd4eIhDpcHRZSflT1QtZHCQnca7JX+ATOHWwoXemFKcbTSRGUU
         ZP5Ieq0m9KRqzxvXCYMdI6gLW9clxHBZx1gLjQk3QUtUxSEgC4a4rQc2j2q4fmxcnY40
         MdWZ1qryvfJvYp0Sh94rPWP2ycePBFp5UeCkcv95mSRE8QtrT9Y/CifSezrhpP4IfLbq
         nVg8r3tWFiWBuePMuBWoMzmYczY1/ZJyNtuhXtO1GrRCCcOmVyj3Ft+nsEXc4wi+z+9m
         /Jaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16si1109242edc.81.2019.03.18.05.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 05:22:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AF4B4AEC2;
	Mon, 18 Mar 2019 12:21:59 +0000 (UTC)
Subject: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Mel Gorman <mgorman@techsingularity.net>, Takashi Iwai <tiwai@suse.de>,
 Hugh Dickins <hughd@google.com>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
Date: Mon, 18 Mar 2019 13:21:59 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190314094249.19606-1-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

OK here's a new version that changes the patch to remove __GFP_COMP per
the v2 discussion, and also fixes the bug Kirill spotted (thanks!).

----8<----
From 1fbc84c208573b885f51818ed823f89b3aa1e0ae Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 14 Mar 2019 10:19:30 +0100
Subject: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()

alloc_pages_exact*() allocates a page of sufficient order and then splits it
to return only the number of pages requested. That makes it incompatible with
__GFP_COMP, because compound pages cannot be split.

As shown by [1] things may silently work until the requested size (possibly
depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.

There are several options here, none of them great:

1) Don't do the spliting when __GFP_COMP is passed, and return the whole
compound page. However if caller then returns it via free_pages_exact(),
that will be unexpected and the freeing actions there will be wrong.

2) Warn and remove __GFP_COMP from the flags. But the caller may have really
wanted it, so things may break later somewhere.

3) Warn and return NULL. However NULL may be unexpected, especially for
small sizes.

This patch picks option 2, because as Michal Hocko put it: "callers wanted it"
is much less probable than "caller is simply confused and more gfp flags is
surely better than fewer".

[1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b9f577b1a2a..123d9a407599 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
 /**
  * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation
+ * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
  * This function is similar to alloc_pages(), except that it allocates the
  * minimum number of pages to satisfy the request.  alloc_pages() can only
@@ -4767,6 +4767,9 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	unsigned int order = get_order(size);
 	unsigned long addr;
 
+	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
+		gfp_mask &= ~__GFP_COMP;
+
 	addr = __get_free_pages(gfp_mask, order);
 	return make_alloc_exact(addr, order, size);
 }
@@ -4777,7 +4780,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
  *			   pages on a node.
  * @nid: the preferred node ID where memory should be allocated
  * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation
+ * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
  * Like alloc_pages_exact(), but try to allocate on node nid first before falling
  * back.
@@ -4785,7 +4788,12 @@ EXPORT_SYMBOL(alloc_pages_exact);
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
-	struct page *p = alloc_pages_node(nid, gfp_mask, order);
+	struct page *p;
+
+	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
+		gfp_mask &= ~__GFP_COMP;
+
+	p = alloc_pages_node(nid, gfp_mask, order);
 	if (!p)
 		return NULL;
 	return make_alloc_exact((unsigned long)page_address(p), order, size);
-- 
2.21.0


