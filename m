Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7814C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DCEB22C7B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DCEB22C7B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AE8F8E0002; Thu, 25 Jul 2019 12:02:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 060236B026A; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E41808E0003; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7E08E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so32403391edx.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Ga37T45KGhVxXQV5RRrlrcczMrKoQqBloMP20eWE9yY=;
        b=dBYgDIjqO4yIg6Q0db4voaDbKE9KLyvcxJi381drcKuHLzp+/DYv2YqvFd8F9hoa+c
         Bn76JYZZ+A+/3AikQvgs/2ReRJYGbLcWOUM6OIupGKY0CcEYxlAl31AJE4WwScQMpCYc
         kRSrvEHSAT/fLv7TkrH+fcdfxDkZdp9IoNPO9mGVDBvadqC7Nb5wlEVsY/zj7AVUzcMm
         lRXoHZ002fpeavf9H1xiUQI+32gfm/+nA9OFaRIb0nJtsSD4G5gLfmZ9F6Ufit1zdp6b
         huQPf2WdVni1IYvIIDQ+o7fhAOg+eXt70QyDbpEOE9BuM3uvxI3zmEP1q1NKmW9FYGKq
         hvzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUdCqJF154lnXy6cYaXcwXKHmPR+MQ+ykSxi+tjQssA80NhatWF
	WWlTNBppG/+FBGoeTu8aI6Li6PT4DfzuHv+YmuK+u2if0SbKA+ba/ibzIUuLBj2ACJJPzgtjwyx
	7+nbuZeyaFQb+m6AUBwoZSud+wa4zJ53kpwZMXTv9xT6zacqTa0jtrMOWnYC93fTkAw==
X-Received: by 2002:a17:906:d201:: with SMTP id w1mr37887849ejz.303.1564070538131;
        Thu, 25 Jul 2019 09:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzm8PEPzxtpuIEbnaJCnTjPq7rlzz2RPxHt9P6Xowh99EkA/M3n72ogX+NT9L/RauYD+u0n
X-Received: by 2002:a17:906:d201:: with SMTP id w1mr37887716ejz.303.1564070536716;
        Thu, 25 Jul 2019 09:02:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070536; cv=none;
        d=google.com; s=arc-20160816;
        b=RpuyvjFLMi++oLOazmy4fpgo9KZ2jwLVV6XP7QGtUlcrafqQ6Os0ZQP2sPKunS/kw2
         miM4fbytt3k6CzKzjKNVrUhrqEHBEQG0xsovE2FKOti5RfqBmekJ7B6mgBRfGK+AUlL0
         XyaabWjjBft4klKjAaglNFoMX9UaxGrDWCHkfpxV+JLVstSTGYFdo8ejEUljoH30w9uu
         30xm8ePGFr9Bw/qEDNPigYLmUEtYe6y0oPN6Mro40Y8BGiGElXYt76FJyuwG018Ynlg0
         dPrPs85p6Z3dBgqy3iV7mgQSVonYm4QLFduS8L1icMxo73sIoXGGJtGDg+Rhy+0sAEhm
         X2ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Ga37T45KGhVxXQV5RRrlrcczMrKoQqBloMP20eWE9yY=;
        b=jlgCTTj9Kg+I2lgR20BuAvP2KeK9AVGec5yj65MH7NW8If/ajx5u/7SjJQOz21nbYP
         0oMlTTQ60Jx7caB/Ab7UmCpZRXWaolBpV7PYJDjpq+wnU8FPWE5OUlU4FmkhvU6YD6/s
         a6zFkNlmrBbDxFtfvDqp94yl4kVp2pVZAQLHagsNwwiBFCWoRhdbaPV2xxp8ILWGoo/y
         gEG1cXxJB+2Dsj0v9++fSrDWaDxcyvcqSlu7ei/qQZ+x6HHKUYiVk0sJocoKtzYtGNYr
         hyoM1GYlR7SnQwH+DBDN4CfXBY32x1HAtM8D2xaZkJ3CqY3MPU2SON0rDvNYkvp2bGgJ
         PapQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9si8108600eja.7.2019.07.25.09.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 57D71AFE1;
	Thu, 25 Jul 2019 16:02:16 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 3/5] mm,sparse: Add SECTION_USE_VMEMMAP flag
Date: Thu, 25 Jul 2019 18:02:05 +0200
Message-Id: <20190725160207.19579-4-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
References: <20190725160207.19579-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When hot-removing memory, we need to be careful about two things:

1) Memory range must be memory_block aligned. This is what
   check_hotplug_memory_range() checks for.

2) If a range was hot-added using MHP_MEMMAP_ON_MEMORY, we need to check
   whether the caller is removing memory with the same granularity that
   it was added.

So to check against case 2), we mark all sections used by vmemmap
(not only the ones containing vmemmap pages, but all sections spanning
the memory range) with SECTION_USE_VMEMMAP.

This will allow us to do some sanity checks when in hot-remove stage.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/memory_hotplug.h | 3 ++-
 include/linux/mmzone.h         | 8 +++++++-
 mm/memory_hotplug.c            | 2 +-
 mm/sparse.c                    | 9 +++++++--
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 45dece922d7c..6b20008d9297 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -366,7 +366,8 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_section(int nid, unsigned long pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap);
+		unsigned long nr_pages, struct vmem_altmap *altmap,
+		bool vmemmap_section);
 extern void sparse_remove_section(struct mem_section *ms,
 		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..259c326962f5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1254,7 +1254,8 @@ extern size_t mem_section_usage_size(void);
 #define SECTION_HAS_MEM_MAP	(1UL<<1)
 #define SECTION_IS_ONLINE	(1UL<<2)
 #define SECTION_IS_EARLY	(1UL<<3)
-#define SECTION_MAP_LAST_BIT	(1UL<<4)
+#define SECTION_USE_VMEMMAP	(1UL<<4)
+#define SECTION_MAP_LAST_BIT	(1UL<<5)
 #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
 #define SECTION_NID_SHIFT	3
 
@@ -1265,6 +1266,11 @@ static inline struct page *__section_mem_map_addr(struct mem_section *section)
 	return (struct page *)map;
 }
 
+static inline int vmemmap_section(struct mem_section *section)
+{
+	return (section && (section->section_mem_map & SECTION_USE_VMEMMAP));
+}
+
 static inline int present_section(struct mem_section *section)
 {
 	return (section && (section->section_mem_map & SECTION_MARKED_PRESENT));
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3d97c3711333..c2338703ce80 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -314,7 +314,7 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 
 		pfns = min(nr_pages, PAGES_PER_SECTION
 				- (pfn & ~PAGE_SECTION_MASK));
-		err = sparse_add_section(nid, pfn, pfns, altmap);
+		err = sparse_add_section(nid, pfn, pfns, altmap, 0);
 		if (err)
 			break;
 		pfn += pfns;
diff --git a/mm/sparse.c b/mm/sparse.c
index 79355a86064f..09cac39e39d9 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -856,13 +856,18 @@ static struct page * __meminit section_activate(int nid, unsigned long pfn,
  * * -ENOMEM	- Out of memory.
  */
 int __meminit sparse_add_section(int nid, unsigned long start_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap)
+		unsigned long nr_pages, struct vmem_altmap *altmap,
+		bool vmemmap_section)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
+	unsigned long flags = 0;
 	struct mem_section *ms;
 	struct page *memmap;
 	int ret;
 
+	if (vmemmap_section)
+		flags = SECTION_USE_VMEMMAP;
+
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0)
 		return ret;
@@ -884,7 +889,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
 	/* Align memmap to section boundary in the subsection case */
 	if (section_nr_to_pfn(section_nr) != start_pfn)
 		memmap = pfn_to_kaddr(section_nr_to_pfn(section_nr));
-	sparse_init_one_section(ms, section_nr, memmap, ms->usage, 0);
+	sparse_init_one_section(ms, section_nr, memmap, ms->usage, flags);
 
 	return 0;
 }
-- 
2.12.3

