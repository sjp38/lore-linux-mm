Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B890EC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AB0E20C01
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AB0E20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134596B000A; Mon, 15 Jul 2019 04:16:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E6E36B000C; Mon, 15 Jul 2019 04:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEF526B000D; Mon, 15 Jul 2019 04:16:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 981AC6B000A
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:16:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so13077619edv.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:16:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kWMxpz/Mp4/cQF0JE/+HE+JA6YesC6EdPlbWWhbxzck=;
        b=OVe9EcCKMSmJpdoxXqTWgif7XMjVRfJVDjuJ7tebgjTe1gjwd3CB/Pfan8Z9yWoaAQ
         l8eNFf8zj9pPb7iRt4D5EsHEGz7lTKXML/bCFLhkVLefG/Y3+xq8tN0F/zsg4RtHKMEa
         j6uSutWh9RLvkglZtL5xh8pCLwWxbv3nXtimnp1gJIsYPV8MXbxVJUSdTH3xNi5fPXat
         mXr7nb76B57bQJStKOiTYHXMBDrv2nHPBWtCX0dAows4HCbTGXz3u7eTPBM6ZUosXKhS
         2ZmLLz6QzdZzd+MvfdobpwsBekdlbe8MgN/FVPhTTH0Y99HmBa7CbCzyVuOUODz/PeBg
         Wmwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVk8EKq/i8+S9hzQii9FawDvnjrLpOZCgO86CR/9+Wnid5pFibx
	CToIu2p4XYOGPATN+rFIGkH+2DDYh3Znb5u/mRHpsqK6TM5LqOOvc0Bzrl20qB+bhK22RItC/hN
	FmMMdtx8KhQ55bqd6OFVL+w6yRp1rN4XlotE2Q+yP8uFyiQHXaAceImjBZpHchyY6Qw==
X-Received: by 2002:a17:906:710:: with SMTP id y16mr19726094ejb.58.1563178560187;
        Mon, 15 Jul 2019 01:16:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweaM8X2P6AxQSzkVI5+P5SfboV/7MYXUHSoV4IL1YIn2Tsv9HdgV4VZ6se7kgNz2JlhwIH
X-Received: by 2002:a17:906:710:: with SMTP id y16mr19726006ejb.58.1563178558844;
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563178558; cv=none;
        d=google.com; s=arc-20160816;
        b=Brjy64hUVMIckoqSJFjcz1tXp0C45JX0d0enOLAOxOkYmfxhdwai0sxXr/XBzbnMt0
         0FvAHGeK+KT3LimUyLYXIwPlJrLTBsZo7x/d9WrwmoKfGySMbg4IPCnzbQFtKVEeMO8H
         5O8aeX9FFa+pQgP04DayffnlazxJplUFcD8XAVhTkNgBYBBS4MsLX2lbbiCmJZt9fsYc
         LqiVcaCG5S9kVA26kko9V2pM6njBvg2VrDRQXPt+7TrKfMvF/XD2xDj4Jzv5vbQ3gll9
         muDrsVegYKe/cvTHEF1ToBbnf2P7p0ei4o1Q7rad4xoXADlI4flpJkdJ9b5D7wUu/Rzl
         u5HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kWMxpz/Mp4/cQF0JE/+HE+JA6YesC6EdPlbWWhbxzck=;
        b=JJ/xSYdJQFR9FeRT5UN2ueQ5gvnWlwPInTnuzzSvbJk9SRjrEqN1MYoK4RF4xz2IoD
         7afqXYJoiebtzYzdCJakMwLeg3tGa/4ozTynerVomY3oWQk6OmybNcu1j2dK5xBfFkfa
         09uBCCdAAhvQybNRbQROazOnj6o2T5SXe0HtKaVGZ8CY3geWZBRJfI1eAWb/Esv+S2Vg
         lHhlZzD71xQNyeEJopKaEIYO87gOxBR9BYyB192/QtHJv2xyI7e1mkKpXqsDTaP8G72X
         +eK9AzvJA+NsU7AHyq204H8qcpO8djzwk1JDiI/dJJy5gezEkCiwwkY3j4zuonO63q21
         7ltA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b21si9403737edw.264.2019.07.15.01.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 788A2AD1E;
	Mon, 15 Jul 2019 08:15:58 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	aneesh.kumar@linux.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Date: Mon, 15 Jul 2019 10:15:49 +0200
Message-Id: <20190715081549.32577-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190715081549.32577-1-osalvador@suse.de>
References: <20190715081549.32577-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION granularity.
The problem is that deactivation of the section occurs later on in
sparse_remove_section, so pfn_valid()->pfn_section_valid() will always return
true before we deactivate the {sub}section.

I spotted this during hotplug hotremove tests, there I always saw that
spanned_pages was, at least, left with PAGES_PER_SECTION, even if we
removed all memory linked to that zone.

Fix this by decoupling section_deactivate from sparse_remove_section, and
re-order the function calls.

Now, __remove_section will:

1) deactivate section
2) shrink {zone,node}'s pages
3) remove section

[1] https://patchwork.kernel.org/patch/11003467/

Fixes: mmotm ("mm/hotplug: prepare shrink_{zone, pgdat}_span for sub-section removal")
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/memory_hotplug.h |  7 ++--
 mm/memory_hotplug.c            |  6 +++-
 mm/sparse.c                    | 77 +++++++++++++++++++++++++++++-------------
 3 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f46ea71b4ffd..d2eb917aad5f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -348,9 +348,10 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_section(int nid, unsigned long pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
-extern void sparse_remove_section(struct mem_section *ms,
-		unsigned long pfn, unsigned long nr_pages,
-		unsigned long map_offset, struct vmem_altmap *altmap);
+int sparse_deactivate_section(unsigned long pfn, unsigned long nr_pages);
+void sparse_remove_section(unsigned long pfn, unsigned long nr_pages,
+                           unsigned long map_offset, struct vmem_altmap *altmap,
+                           int section_empty);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9ba5b85f9f7..03d535eee60d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -517,12 +517,16 @@ static void __remove_section(struct zone *zone, unsigned long pfn,
 		struct vmem_altmap *altmap)
 {
 	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
+	int ret;
 
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
 
+	ret = sparse_deactivate_section(pfn, nr_pages);
 	__remove_zone(zone, pfn, nr_pages);
-	sparse_remove_section(ms, pfn, nr_pages, map_offset, altmap);
+	if (ret >= 0)
+		sparse_remove_section(pfn, nr_pages, map_offset, altmap,
+				      ret);
 }
 
 /**
diff --git a/mm/sparse.c b/mm/sparse.c
index 1e224149aab6..d4953ee1d087 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -732,16 +732,47 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap)
+static void section_remove(unsigned long pfn, unsigned long nr_pages,
+			   struct vmem_altmap *altmap, int section_empty)
+{
+	struct mem_section *ms = __pfn_to_section(pfn);
+	bool section_early = early_section(ms);
+	struct page *memmap = NULL;
+
+	if (section_empty) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (!section_early) {
+			kfree(ms->usage);
+			ms->usage = NULL;
+		}
+		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
+		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
+	}
+
+        if (section_early && memmap)
+		free_map_bootmem(memmap);
+        else
+		depopulate_section_memmap(pfn, nr_pages, altmap);
+}
+
+/**
+ * section_deactivate: Deactivate a {sub}section.
+ *
+ * Return:
+ * * -1         - {sub}section has already been deactivated.
+ * * 0          - Section is not empty
+ * * 1          - Section is empty
+ */
+
+static int section_deactivate(unsigned long pfn, unsigned long nr_pages)
 {
 	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
 	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
 	struct mem_section *ms = __pfn_to_section(pfn);
-	bool section_is_early = early_section(ms);
-	struct page *memmap = NULL;
 	unsigned long *subsection_map = ms->usage
 		? &ms->usage->subsection_map[0] : NULL;
+	int section_empty = 0;
 
 	subsection_mask_set(map, pfn, nr_pages);
 	if (subsection_map)
@@ -750,7 +781,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 	if (WARN(!subsection_map || !bitmap_equal(tmp, map, SUBSECTIONS_PER_SECTION),
 				"section already deactivated (%#lx + %ld)\n",
 				pfn, nr_pages))
-		return;
+		return -1;
 
 	/*
 	 * There are 3 cases to handle across two configurations
@@ -770,21 +801,10 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
 	 */
 	bitmap_xor(subsection_map, map, subsection_map, SUBSECTIONS_PER_SECTION);
-	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
-		unsigned long section_nr = pfn_to_section_nr(pfn);
-
-		if (!section_is_early) {
-			kfree(ms->usage);
-			ms->usage = NULL;
-		}
-		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
-		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
-	}
+	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION))
+		section_empty = 1;
 
-	if (section_is_early && memmap)
-		free_map_bootmem(memmap);
-	else
-		depopulate_section_memmap(pfn, nr_pages, altmap);
+	return section_empty;
 }
 
 static struct page * __meminit section_activate(int nid, unsigned long pfn,
@@ -834,7 +854,11 @@ static struct page * __meminit section_activate(int nid, unsigned long pfn,
 
 	memmap = populate_section_memmap(pfn, nr_pages, nid, altmap);
 	if (!memmap) {
-		section_deactivate(pfn, nr_pages, altmap);
+		int ret;
+
+		ret = section_deactivate(pfn, nr_pages);
+		if (ret >= 0)
+			section_remove(pfn, nr_pages, altmap, ret);
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -919,12 +943,17 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-void sparse_remove_section(struct mem_section *ms, unsigned long pfn,
-		unsigned long nr_pages, unsigned long map_offset,
-		struct vmem_altmap *altmap)
+int sparse_deactivate_section(unsigned long pfn, unsigned long nr_pages)
+{
+	return section_deactivate(pfn, nr_pages);
+}
+
+void sparse_remove_section(unsigned long pfn, unsigned long nr_pages,
+			   unsigned long map_offset, struct vmem_altmap *altmap,
+			   int section_empty)
 {
 	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
 			nr_pages - map_offset);
-	section_deactivate(pfn, nr_pages, altmap);
+	section_remove(pfn, nr_pages, altmap, section_empty);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
-- 
2.12.3

