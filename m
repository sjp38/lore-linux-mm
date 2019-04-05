Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51E90C282DC
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF2A52186A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XG38YpTI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF2A52186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6366B0010; Fri,  5 Apr 2019 18:12:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A556B0266; Fri,  5 Apr 2019 18:12:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EE676B0269; Fri,  5 Apr 2019 18:12:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 063356B0010
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 18:12:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 102so5086614plb.20
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 15:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=G12Kq6AqytAmvUYvKgWRSsHxwaZfUjEmXsdn1Ujj/lQ=;
        b=HijFyjBTveRJvwfs7EdW7anLYwzhrhRSdmbamZk5P7xpt5kWkW5KfrHwL2rTKZ3See
         /0e8Earxx7iDBmH6qCzYQfZFjCk+o/l+DtQkilv6pgXJTh29npg6vVA+qi29PmiC78mS
         pekp3Xx48adELY6caVo/07nU0UKlcQc+2W4x95dwBJKqwdTsxaPQIk2PvLdOSUcJKbGn
         3zOVsF1xXLIo9RDYgTxqBiJG4wIC7U+LwRrw3XX1HTtxg9Ah7x9dNu7kgjZp1iPLycle
         tveGhirXxB6Y5v3XvOXLP93K9whR2UEI+TaVL2dILeiMeNfvnD78NxZwr8e30+1dZG63
         oEPA==
X-Gm-Message-State: APjAAAXNyXCC/TL4rubgm6R8EKgRRUb0GsQLzVvnuPO2InpYDGi/W8oa
	5F1Y7tLfQMPDLWfthNPaafWd8gC4QCyBJViu3Ky2utbEc0/134/3xBwa7leObQEkwZSWedez16S
	6Xiag4RSXd8zInZVltCVq31UikVWerXNbCSXI0Dg3xq8K8bBlxjhIaDkEkS+xoaR95g==
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr15639400plp.179.1554502342624;
        Fri, 05 Apr 2019 15:12:22 -0700 (PDT)
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr15639286plp.179.1554502341149;
        Fri, 05 Apr 2019 15:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554502341; cv=none;
        d=google.com; s=arc-20160816;
        b=nE54rH2pPxugC1muLA6qMkzrLeIonHHgGwQKixCxzuATyanEGXpHxGAkvYr7DxofXF
         81NwEO788k9F6huNUg5V9Z31UdoPashBatDW5yoqhNvvZ9t0OW1a29sYYsG+xueGB9te
         +IXNrWaW1cD37XiohbM5vDwPE0QOT7/mI+LqI6iWtafy+KV06C+xyhXWy5NgWStelJwt
         pXfMBlMWz41jSAZJcAf0Ead05V21m7lYyWBLxLJraJJNaF+Mw50xco2xJStnEgEYagqf
         AGiJ9diEMeWSkfxf/8W5K/L7amqPQR5OzxbDGIh8F4GX++iTBryvsSdsESobsz1zxmwI
         QfdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=G12Kq6AqytAmvUYvKgWRSsHxwaZfUjEmXsdn1Ujj/lQ=;
        b=Vl7486GDXiP7gjeUnl8hqZAKexwccLbjFPiHcoNExaiNeDK7enPN/gYuHNU15VEXHa
         spNWp6ABJVdxiE0fsnJhWi/8qU6+i04/BDCGPoabGk4K8OVGsVXEjYmr4SEFF9y2/vS2
         vccVkPbxc5cc6QJIgmutFIBlbNckxSWTk+reiFdrEnjSiEmv2eaYAP+KJg7ezTpK562a
         ZW2Rp9dH9DOsa2tXUcp38LYsMuahRNfS65mSvISfLm9jY8tTXmi+EGNjNqrzjxX95JEd
         El57XEZty3MY3Gj16qFjJCAsVjP5L0j7esLhKG6ttjtBbIXHYydnTKrSKs6ADRRTZcQA
         hGKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XG38YpTI;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m2sor25641111pgq.36.2019.04.05.15.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 15:12:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XG38YpTI;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=G12Kq6AqytAmvUYvKgWRSsHxwaZfUjEmXsdn1Ujj/lQ=;
        b=XG38YpTI00BwC7KObaPOXNoT0/3aGicw/qoEXT5J9ke838FQZXhTBrBKripeVlQ9Vd
         yoK3ch4YRr/qZAq7Q4/iihliZd8Jck2y2mchzu+u4+pPFwguJE1oafMedNzJyWlXxSpE
         yY+wYtwdKUvaIGV6knDJ6e66/Ptv8oMYhPfSswhRm0d9ZpLUp/OuQtANSM1iKaGcTRhV
         OwyCg74LMwWPMtCOirkiYNg/JdBtLrvH6oguVDMPPUtSfuOWH9NJkkn0flINl+pyFd/L
         z7NgJvX3iIEDuY838PDjJKhJpqNs0VELk852grpRuUrlkmnbxXDU5pmUMwHfSzBF7+8p
         ceeg==
X-Google-Smtp-Source: APXvYqx8yKoHJNenjnCFS6xMZGAPS6NHqwxxDYSwPI5ifsuuBq34/S66jQZo95MrWUZOrgize8leVw==
X-Received: by 2002:a63:2c3:: with SMTP id 186mr14136668pgc.161.1554502340690;
        Fri, 05 Apr 2019 15:12:20 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id w23sm24386014pgj.72.2019.04.05.15.12.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 15:12:20 -0700 (PDT)
Subject: [mm PATCH v7 2/4] mm: Drop meminit_pfn_in_nid as it is redundant
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
 linux-nvdimm@lists.01.org, alexander.h.duyck@linux.intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mingo@kernel.org,
 yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com,
 vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com,
 ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, davem@davemloft.net,
 kirill.shutemov@linux.intel.com
Date: Fri, 05 Apr 2019 15:12:19 -0700
Message-ID: <20190405221219.12227.93957.stgit@localhost.localdomain>
In-Reply-To: <20190405221043.12227.19679.stgit@localhost.localdomain>
References: <20190405221043.12227.19679.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

As best as I can tell the meminit_pfn_in_nid call is completely redundant.
The deferred memory initialization is already making use of
for_each_free_mem_range which in turn will call into __next_mem_range which
will only return a memory range if it matches the node ID provided assuming
it is not NUMA_NO_NODE.

I am operating on the assumption that there are no zones or pgdata_t
structures that have a NUMA node of NUMA_NO_NODE associated with them. If
that is the case then __next_mem_range will never return a memory range
that doesn't match the zone's node ID and as such the check is redundant.

So one piece I would like to verify on this is if this works for ia64.
Technically it was using a different approach to get the node ID, but it
seems to have the node ID also encoded into the memblock. So I am
assuming this is okay, but would like to get confirmation on that.

On my x86_64 test system with 384GB of memory per node I saw a reduction in
initialization time from 2.80s to 1.85s as a result of this patch.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |   51 ++++++++++++++-------------------------------------
 1 file changed, 14 insertions(+), 37 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c53807a2943..2d2bca9803d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1398,36 +1398,22 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 #endif
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-static inline bool __meminit __maybe_unused
-meminit_pfn_in_nid(unsigned long pfn, int node,
-		   struct mminit_pfnnid_cache *state)
+/* Only safe to use early in boot when initialisation is single-threaded */
+static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	int nid;
 
-	nid = __early_pfn_to_nid(pfn, state);
+	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
 	if (nid >= 0 && nid != node)
 		return false;
 	return true;
 }
 
-/* Only safe to use early in boot when initialisation is single-threaded */
-static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
-{
-	return meminit_pfn_in_nid(pfn, node, &early_pfnnid_cache);
-}
-
 #else
-
 static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	return true;
 }
-static inline bool __meminit  __maybe_unused
-meminit_pfn_in_nid(unsigned long pfn, int node,
-		   struct mminit_pfnnid_cache *state)
-{
-	return true;
-}
 #endif
 
 
@@ -1556,21 +1542,13 @@ static inline void __init pgdat_init_report_one_done(void)
  *
  * Then, we check if a current large page is valid by only checking the validity
  * of the head pfn.
- *
- * Finally, meminit_pfn_in_nid is checked on systems where pfns can interleave
- * within a node: a pfn is between start and end of a node, but does not belong
- * to this memory node.
  */
-static inline bool __init
-deferred_pfn_valid(int nid, unsigned long pfn,
-		   struct mminit_pfnnid_cache *nid_init_state)
+static inline bool __init deferred_pfn_valid(unsigned long pfn)
 {
 	if (!pfn_valid_within(pfn))
 		return false;
 	if (!(pfn & (pageblock_nr_pages - 1)) && !pfn_valid(pfn))
 		return false;
-	if (!meminit_pfn_in_nid(pfn, nid, nid_init_state))
-		return false;
 	return true;
 }
 
@@ -1578,15 +1556,14 @@ static inline void __init pgdat_init_report_one_done(void)
  * Free pages to buddy allocator. Try to free aligned pages in
  * pageblock_nr_pages sizes.
  */
-static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
+static void __init deferred_free_pages(unsigned long pfn,
 				       unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	unsigned long nr_free = 0;
 
 	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+		if (!deferred_pfn_valid(pfn)) {
 			deferred_free_range(pfn - nr_free, nr_free);
 			nr_free = 0;
 		} else if (!(pfn & nr_pgmask)) {
@@ -1606,17 +1583,18 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
  * by performing it only once every pageblock_nr_pages.
  * Return number of pages initialized.
  */
-static unsigned long  __init deferred_init_pages(int nid, int zid,
+static unsigned long  __init deferred_init_pages(struct zone *zone,
 						 unsigned long pfn,
 						 unsigned long end_pfn)
 {
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
+	int nid = zone_to_nid(zone);
 	unsigned long nr_pages = 0;
+	int zid = zone_idx(zone);
 	struct page *page = NULL;
 
 	for (; pfn < end_pfn; pfn++) {
-		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
+		if (!deferred_pfn_valid(pfn)) {
 			page = NULL;
 			continue;
 		} else if (!page || !(pfn & nr_pgmask)) {
@@ -1679,12 +1657,12 @@ static int __init deferred_init_memmap(void *data)
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		nr_pages += deferred_init_pages(nid, zid, spfn, epfn);
+		nr_pages += deferred_init_pages(zone, spfn, epfn);
 	}
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		deferred_free_pages(nid, zid, spfn, epfn);
+		deferred_free_pages(spfn, epfn);
 	}
 	pgdat_resize_unlock(pgdat, &flags);
 
@@ -1716,7 +1694,6 @@ static int __init deferred_init_memmap(void *data)
 static noinline bool __init
 deferred_grow_zone(struct zone *zone, unsigned int order)
 {
-	int zid = zone_idx(zone);
 	int nid = zone_to_nid(zone);
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
@@ -1766,7 +1743,7 @@ static int __init deferred_init_memmap(void *data)
 		while (spfn < epfn && nr_pages < nr_pages_needed) {
 			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
 			first_deferred_pfn = min(t, epfn);
-			nr_pages += deferred_init_pages(nid, zid, spfn,
+			nr_pages += deferred_init_pages(zone, spfn,
 							first_deferred_pfn);
 			spfn = first_deferred_pfn;
 		}
@@ -1778,7 +1755,7 @@ static int __init deferred_init_memmap(void *data)
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
-		deferred_free_pages(nid, zid, spfn, epfn);
+		deferred_free_pages(spfn, epfn);
 
 		if (first_deferred_pfn == epfn)
 			break;

