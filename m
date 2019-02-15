Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDBA7C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D201222D9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="KNcQRgco";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="VqdFBUXY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D201222D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 212F58E0007; Fri, 15 Feb 2019 17:09:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 169878E0004; Fri, 15 Feb 2019 17:09:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFE378E0007; Fri, 15 Feb 2019 17:09:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B71FD8E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:11 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s65so9319696qke.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=902xFr+JOntSJP1cg0P3STe45DXLaJ7bWFq0OYVQRqQ=;
        b=BrvcTPbEMFo3VHE7oUn+m/OwUgd91lrwLzLWoPin0Lh8Zh9WEklm973+36KOB6Xj7c
         aSQSqt9JlPXWXcVHrwq9vjlEJjJfYjBOGgTKeu/BBtPjvxDwfcdWUASQ8Gxlfj1DEJa2
         dHq2hUmJHL3+RQkIQOHZ3Uzuuupk1N2oBEJzUDdKML16Ht1/bRNrZ/IB0+iOn3lVMgWM
         k7rj29kVq4KD62C0dqjyaiwrpCd5VDHNCWKRnI1fePwWbm1e8WxQEOAszVIPH4K3GSuF
         FS7nkx+KmL8WHZ6I48hTIIz0mjw8ncuZcVnq9rU9TLDFJt90yq2g9gbkrHu5Qa5lpFTw
         8IHA==
X-Gm-Message-State: AHQUAuZZIMEkEeTRkIRFWcXr12q0gqyVd7H1w2sHzG7cFIgH6YCfmlsZ
	l/yrOsp2YoH4RKdy5I4tAZ2jIUQugeCwmGVo8TX5xSWS7xEIK6knsd06jQsnaVRQM6+1i8BY1c8
	9/YvM/I18tLf5ysqB7Kekwfm2wIOd1sFu1ZjUZiR7WmFPNGMU4cZ2QeV6pFfSjBiycg==
X-Received: by 2002:ac8:1a56:: with SMTP id q22mr9316885qtk.59.1550268551474;
        Fri, 15 Feb 2019 14:09:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYYIlioFxUnrsnaY/86CEpEfgS0DEze8dNvNQ9K30WcpjLGFNlksVRBwTG2YKIbfk8ZhJkI
X-Received: by 2002:ac8:1a56:: with SMTP id q22mr9316834qtk.59.1550268550668;
        Fri, 15 Feb 2019 14:09:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268550; cv=none;
        d=google.com; s=arc-20160816;
        b=Q0dsbRjKRdsswLF1oABt4UHGg4HJpmzL5z18RFfs3KQJZzNBYl0ZR9lgnIQF+nFlwh
         Nstcv5JPgLjCj7XE4q+av+MHICYg7XbOBzCKkPaWr/ewP0vIQZfAD1Ukprt7aHNRX5V6
         jp5bUH2SLJkjJ9RGyBV1omc8j97fRWpPbcRaGt2/8U9KUGDIDpsbRObivW8fKHpNTrVO
         VT3pxgeuU/NBmAABVj7JB+5yXcAF0kH0Uc8RP8EvPNClR+RjugPkxqYOYRPyGb3jMGaV
         klIGDQPJl+8/3orbZhNe4fDa6ai6Ff1Yw2MOqfolOkRl43EzQIaDuM353SDXfXZ6F2YT
         a7sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=902xFr+JOntSJP1cg0P3STe45DXLaJ7bWFq0OYVQRqQ=;
        b=K/LfMernB4MSacw8cxILlPutdd1otJigD60797oHssnz0PcJiXhxdMX09LJnfh6ANe
         nWWprHrwZFNl78zxYhHSmXP3gsqZbKqOXgCzMVaplKVBsnsCgMC+M1V+pkmBx1vCEmog
         bN8OgmP9/534OvwQLXoXNjSThFp+Khc0I9sTBgWh5VZpMGW5dWVQBGJu8ML28kM88Uas
         XsIIRgbqjHWurrWsWDV4VcOYBbdl3WopiNSPqTQUumCsGzGUew/HWFDwanaPZFAC3FYq
         7VQ4ymD4q1Jh9faquAqYSRO/ZyhQ9Z8hIQ/C753a7EzMf36Sfo5s0OIDQxDnWFUonjyq
         SnVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=KNcQRgco;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=VqdFBUXY;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id d32si1504612qtd.307.2019.02.15.14.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:10 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=KNcQRgco;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=VqdFBUXY;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id D84D2329C;
	Fri, 15 Feb 2019 17:09:08 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:09 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=902xFr+JOntSJ
	P1cg0P3STe45DXLaJ7bWFq0OYVQRqQ=; b=KNcQRgco65nLK8HcP4rreHPMghTtD
	tbAicuwBbTE1FHBK/mt1I3d7CrhIMayrxJ7vIYABDxqxw244SAuoqDpERuzwc21A
	/lenuvOPKvu41G7xdU1zJQKfmGI3Z3Eqwe77Qm7YCFQo7c2UAZsR3TdLMNRLadV1
	viPsvHoH32VRO5hDpT7PE08kVsGqwhj9ja219+Z/ckfW0t6cDOfW0xf1GAyPFSQ9
	qX12ECY2+hbG5EpEudUaVecKVJnIEyYGGywK7RL8ez/ZkDvv05hlxLtbYDapTgyP
	SuiDA0rOE78fPWsjpeLtTPfcFQ54n8nA3rvb3S+mQAtbpi5n4KOBvfyhw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=902xFr+JOntSJP1cg0P3STe45DXLaJ7bWFq0OYVQRqQ=; b=VqdFBUXY
	WLb1yElVXLoPwOR5wnvkIS2U9RfZpTs95eMz6DgbT6jN9jlUWm+08d6hcyXPJbF8
	iAP/a7c1WbBagMx/3a+9kAkRRWiZLCeWmaMN9J1RC9ferz+shh6Zu2FATorUpCEG
	j+LPn15EmNthHAmK/HAWfOxSkgV/UMjCNgrYIakQjJSDSHiWTj9KbxL8+o6LeYnh
	8V7xtwgYcdAotJTRPsoJDnssnGkBe8oXLSEPQ3zCk/+TYvaZYXWyW9wUyIusaeDv
	CaGE46LCYxcqdViEhGJhm1IZm0y5a9ByEsEx3QsuuWKVVvF6FqqE0X8MuKDDlUWi
	jeQzH7SrN1/WeA==
X-ME-Sender: <xms:hDhnXDXlNNHgjP7XW5CgPzWKWwTh3lm22HEPEuB5huQ_22J_AQ8iFA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedu
X-ME-Proxy: <xmx:hDhnXGVGezRAIuoxdauOvlra77qO0ZByp1wBHrS4Xl7jIfwGa7LzvA>
    <xmx:hDhnXOSGeqElYX8O5JButLC1ld98et4n-0JU8n5lXQ_cvFLsaAnQjg>
    <xmx:hDhnXFGg1IS5PHBUdn2Iz_2mKWpiIy3v2n6AOx7Hv1vuWjyBb1dQWg>
    <xmx:hDhnXBe1z_-A27Cj76HsJ8HZ0-BOv-HTWT9MIU1IiFHqH60_Uq7bvQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1E32EE4511;
	Fri, 15 Feb 2019 17:09:07 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 05/31] mem_defrag: split a THP if either src or dst is THP only.
Date: Fri, 15 Feb 2019 14:08:30 -0800
Message-Id: <20190215220856.29749-6-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

During the process of generating physically contiguous memory, it is
possible that we want to move a THP to a place with 512 base pages.
Exchange pages has not implemented the exchange of a THP and 512 base
pages. Instead, we can split the THP and exchange 512 base pages.
This increases the chance of creating a large contiguous region.
A split THP could be promoted back after all 512 pages are moved to the
destination or if none of its subpages is moved.
In-place THP promotion will be introduced later in this patch serie.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/internal.h   |   4 ++
 mm/mem_defrag.c | 155 +++++++++++++++++++++++++++++++++++++-----------
 mm/page_alloc.c |  45 ++++++++++++++
 3 files changed, 168 insertions(+), 36 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 4fe8d1a4d7bb..70a6ef603e5b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -574,6 +574,10 @@ void expand(struct zone *zone, struct page *page,
 	int low, int high, struct free_area *area,
 	int migratetype);
 
+int expand_free_page(struct zone *zone, struct page *buddy_head,
+	struct page *page, int buddy_order, int page_order,
+	struct free_area *area, int migratetype);
+
 void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags);
 
diff --git a/mm/mem_defrag.c b/mm/mem_defrag.c
index 414909e1c19c..4d458b125c95 100644
--- a/mm/mem_defrag.c
+++ b/mm/mem_defrag.c
@@ -643,6 +643,15 @@ static void exchange_free(struct page *freepage, unsigned long data)
 		head->num_freepages++;
 }
 
+static bool page_can_migrate(struct page *page)
+{
+	if (PageAnon(page))
+		return true;
+	if (page_mapping(page))
+		return true;
+	return false;
+}
+
 int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long start_addr, unsigned long end_addr,
 		struct page *anchor_page, unsigned long page_vaddr,
@@ -655,6 +664,7 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 	int not_present = 0;
 	bool src_thp = false;
 
+restart:
 	for (scan_address = start_addr; scan_address < end_addr;
 		 scan_address += page_size) {
 		struct page *scan_page;
@@ -683,6 +693,8 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 		if ((scan_page == compound_head(scan_page)) &&
 			PageTransHuge(scan_page) && !PageHuge(scan_page))
 			src_thp = true;
+		else
+			src_thp = false;
 
 		/* Allow THPs  */
 		if (PageCompound(scan_page) && !src_thp) {
@@ -720,13 +732,17 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 
 retry_defrag:
-			/* migrate */
-			if (PageBuddy(dest_page)) {
+				/* free pages */
+			if (page_count(dest_page) == 0 && dest_page->mapping == NULL) {
+				int buddy_page_order = 0;
+				unsigned long pfn = page_to_pfn(dest_page);
+				unsigned long buddy_pfn;
+				struct page *buddy = dest_page;
 				struct zone *zone = page_zone(dest_page);
 				spinlock_t *zone_lock = &zone->lock;
 				unsigned long zone_lock_flags;
 				unsigned long free_page_order = 0;
-				int err = 0;
+				int err = 0, expand_err = 0;
 				struct exchange_alloc_head exchange_alloc_head = {0};
 				int migratetype = get_pageblock_migratetype(dest_page);
 
@@ -734,32 +750,77 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 				INIT_LIST_HEAD(&exchange_alloc_head.freelist);
 				INIT_LIST_HEAD(&exchange_alloc_head.migratepage_list);
 
-				count_vm_events(MEM_DEFRAG_DST_FREE_PAGES, 1<<scan_page_order);
+				/* not managed pages  */
+				if (!dest_page->flags) {
+					failed += 1;
+					defrag_stats->dst_out_of_bound_failed += 1;
 
+					defrag_stats->not_defrag_vpn = scan_address + page_size;
+					goto quit_defrag;
+				}
+				/* spill order-0 pages to buddy allocator from pcplist */
+				if (!PageBuddy(dest_page) && !page_drained) {
+					drain_all_pages(zone);
+					page_drained = 1;
+					goto retry_defrag;
+				}
 				/* lock page_zone(dest_page)->lock  */
 				spin_lock_irqsave(zone_lock, zone_lock_flags);
 
-				if (!PageBuddy(dest_page)) {
+				while (!PageBuddy(buddy) && buddy_page_order < MAX_ORDER) {
+					buddy_pfn = pfn & ~((1<<buddy_page_order) - 1);
+					buddy = dest_page - (pfn - buddy_pfn);
+					buddy_page_order++;
+				}
+				if (!PageBuddy(buddy)) {
 					err = -EINVAL;
 					goto freepage_isolate_fail;
 				}
 
-				free_page_order = page_order(dest_page);
+				count_vm_events(MEM_DEFRAG_DST_FREE_PAGES, 1<<scan_page_order);
 
-				/* fail early if not enough free pages */
-				if (free_page_order < scan_page_order) {
+				free_page_order = page_order(buddy);
+
+				/* caught some transient-state page */
+				if (free_page_order < buddy_page_order) {
 					err = -ENOMEM;
 					goto freepage_isolate_fail;
 				}
 
+				/* fail early if not enough free pages */
+				if (free_page_order < scan_page_order) {
+					int ret;
+
+					spin_unlock_irqrestore(zone_lock, zone_lock_flags);
+
+					if (is_huge_zero_page(scan_page)) {
+						err = -ENOMEM;
+						goto freepage_isolate_fail_unlocked;
+					}
+					get_page(scan_page);
+					lock_page(scan_page);
+					ret = split_huge_page(scan_page);
+					unlock_page(scan_page);
+					put_page(scan_page);
+					if (ret) {
+						err = -ENOMEM;
+						goto freepage_isolate_fail_unlocked;
+					} else {
+						goto restart;
+					}
+				}
+
 				/* __isolate_free_page()  */
-				err = isolate_free_page_no_wmark(dest_page, free_page_order);
+				err = isolate_free_page_no_wmark(buddy, free_page_order);
 				if (!err)
 					goto freepage_isolate_fail;
 
-				expand(zone, dest_page, scan_page_order, free_page_order,
+				expand_err = expand_free_page(zone, buddy, dest_page,
+					free_page_order, scan_page_order,
 					&(zone->free_area[free_page_order]),
 					migratetype);
+				if (expand_err)
+					goto freepage_isolate_fail;
 
 				if (!is_migrate_isolate(migratetype))
 					__mod_zone_freepage_state(zone, -(1UL << scan_page_order),
@@ -778,7 +839,7 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 
 freepage_isolate_fail:
 				spin_unlock_irqrestore(zone_lock, zone_lock_flags);
-
+freepage_isolate_fail_unlocked:
 				if (err < 0) {
 					failed += (page_size/PAGE_SIZE);
 					defrag_stats->dst_isolate_free_failed += (page_size/PAGE_SIZE);
@@ -844,6 +905,8 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 				if ((dest_page == compound_head(dest_page)) &&
 					PageTransHuge(dest_page) && !PageHuge(dest_page))
 					dst_thp = true;
+				else
+					dst_thp = false;
 
 				if (PageCompound(dest_page) && !dst_thp) {
 					failed += get_contig_page_size(dest_page);
@@ -854,37 +917,56 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 				}
 
 				if (src_thp != dst_thp) {
-					failed += get_contig_page_size(scan_page);
-					if (src_thp && !dst_thp)
-						defrag_stats->src_thp_dst_not_failed +=
-							page_size/PAGE_SIZE;
-					else /* !src_thp && dst_thp */
-						defrag_stats->dst_thp_src_not_failed +=
-							page_size/PAGE_SIZE;
+					if (src_thp && !dst_thp) {
+						int ret;
+
+						if (!page_can_migrate(dest_page)) {
+							failed += get_contig_page_size(scan_page);
+							defrag_stats->not_defrag_vpn = scan_address + page_size;
+							goto quit_defrag;
+						}
 
+						get_page(scan_page);
+						lock_page(scan_page);
+						if (!PageCompound(scan_page) || is_huge_zero_page(scan_page)) {
+							ret = 0;
+							src_thp = false;
+							goto split_src_done;
+						}
+						ret = split_huge_page(scan_page);
+split_src_done:
+						unlock_page(scan_page);
+						put_page(scan_page);
+						if (ret)
+							defrag_stats->src_thp_dst_not_failed += page_size/PAGE_SIZE;
+						else
+							goto restart;
+					} else {/* !src_thp && dst_thp */
+						int ret;
+
+						get_page(dest_page);
+						lock_page(dest_page);
+						if (!PageCompound(dest_page) || is_huge_zero_page(dest_page)) {
+							ret = 0;
+							dst_thp = false;
+							goto split_dst_done;
+						}
+						ret = split_huge_page(dest_page);
+split_dst_done:
+						unlock_page(dest_page);
+						put_page(dest_page);
+						if (ret)
+							defrag_stats->dst_thp_src_not_failed += page_size/PAGE_SIZE;
+						else
+							goto retry_defrag;
+					}
+
+					failed += get_contig_page_size(scan_page);
 					defrag_stats->not_defrag_vpn = scan_address + page_size;
 					goto quit_defrag;
 					/*continue;*/
 				}
 
-				/* free page on pcplist */
-				if (page_count(dest_page) == 0) {
-					/* not managed pages  */
-					if (!dest_page->flags) {
-						failed += 1;
-						defrag_stats->dst_out_of_bound_failed += 1;
-
-						defrag_stats->not_defrag_vpn = scan_address + page_size;
-						goto quit_defrag;
-					}
-					/* spill order-0 pages to buddy allocator from pcplist */
-					if (!page_drained) {
-						drain_all_pages(NULL);
-						page_drained = 1;
-						goto retry_defrag;
-					}
-				}
-
 				if (PageAnon(dest_page)) {
 					count_vm_events(MEM_DEFRAG_DST_ANON_PAGES,
 							1<<scan_page_order);
@@ -895,6 +977,7 @@ int defrag_address_range(struct mm_struct *mm, struct vm_area_struct *vma,
 								1<<scan_page_order);
 						failed += 1<<scan_page_order;
 						defrag_stats->dst_anon_failed += 1<<scan_page_order;
+						/*print_page_stats(dest_page, "anonymous page");*/
 					}
 				} else if (page_mapping(dest_page)) {
 					count_vm_events(MEM_DEFRAG_DST_FILE_PAGES,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a35605e0924a..9ba2cdc320f2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1855,6 +1855,51 @@ inline void expand(struct zone *zone, struct page *page,
 	}
 }
 
+inline int expand_free_page(struct zone *zone, struct page *buddy_head,
+	struct page *page, int buddy_order, int page_order, struct free_area *area,
+	int migratetype)
+{
+	unsigned long size = 1 << buddy_order;
+
+	if (!(page >= buddy_head && page < (buddy_head + (1<<buddy_order)))) {
+		int mapcount = PageSlab(buddy_head) ? 0 : page_mapcount(buddy_head);
+
+		mapcount = PageSlab(page) ? 0 : page_mapcount(page);
+		__free_one_page(buddy_head, page_to_pfn(buddy_head), zone, buddy_order,
+				migratetype);
+		return -EINVAL;
+	}
+
+	while (buddy_order > page_order) {
+		struct page *page_to_free;
+
+		area--;
+		buddy_order--;
+		size >>= 1;
+
+		if (page < (buddy_head + size))
+			page_to_free = buddy_head + size;
+		else {
+			page_to_free = buddy_head;
+			buddy_head = buddy_head + size;
+		}
+
+		/*
+		 * Mark as guard pages (or page), that will allow to
+		 * merge back to allocator when buddy will be freed.
+		 * Corresponding page table entries will not be touched,
+		 * pages will stay not present in virtual address space
+		 */
+		if (set_page_guard(zone, page_to_free, buddy_order, migratetype))
+			continue;
+
+		list_add(&page_to_free->lru, &area->free_list[migratetype]);
+		area->nr_free++;
+		set_page_order(page_to_free, buddy_order);
+	}
+	return 0;
+}
+
 static void check_new_page_bad(struct page *page)
 {
 	const char *bad_reason = NULL;
-- 
2.20.1

