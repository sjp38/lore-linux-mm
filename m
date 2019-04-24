Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E133C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DBF421773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DBF421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9DCA6B000E; Wed, 24 Apr 2019 06:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4BD36B0010; Wed, 24 Apr 2019 06:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9681B6B0266; Wed, 24 Apr 2019 06:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72D286B000E
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:26:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so17287910qtz.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1AHud2ZD6tXhbo4XTIHImH/7A+j/bT1tgyCj7c12ovw=;
        b=b7M2DWA8mZ6e25mvXbPRedANDWjQdOEfKt5J1dm5swsYy7HQseidVUBwgneA1x+tSn
         5ox73Eox3bFgXZ92aBo3ysihGsW967Vlx5QDBnpJRVec93++ukrpETB8ZA4kdtvg8YBo
         JIH2fAj6+QheEH7bsJqkkJJZsn2b/QlJs78aDTRssyxrdzIsJ79E2gmNwvjTJX1Mrjo2
         QBBU6NRGd+Td5y2YgxnOER7YyptqwKDhFeMO3UZ05VxSr8IHl83H+sdmob7bP6IUusOj
         hnXZTzFQIlBE6a8PtKVWr481Psyf0DK/7poQsrHGaXOjR0/KXhpP4pFKw+tkd+y3PelW
         vazw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWiGQBNJBURdrm/lLwFiMYU5h3TflUkkhbbWr1ktdfx4WMuyGPe
	uskvyisDPaeSKPt3B6bZS0yhyS0DNPgnvBDpWql0mfNWTKqi8J2x0lqMvoet20ffDZ1p5XLII08
	R61IG1YMUwNBWF3naqnBArQ8OS0MtE2I/Z/ZCEV4w41DOzeItQuWLxtmcKM8PqYbJHQ==
X-Received: by 2002:ae9:f00e:: with SMTP id l14mr24180692qkg.127.1556101562235;
        Wed, 24 Apr 2019 03:26:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwDOqvJqpBoUGUCEKgAIj9gvr9W+EXAm8uSmW1ebFfA/D2LWN2S6YofR/ubbkVzfUAw7tK
X-Received: by 2002:ae9:f00e:: with SMTP id l14mr24180649qkg.127.1556101561615;
        Wed, 24 Apr 2019 03:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101561; cv=none;
        d=google.com; s=arc-20160816;
        b=ZHhSAEEq0uBw9CV+mBPE+zwgQOAcTVSiRV43ATepFeJrhBHSnpALFsOyL3LCTIjOcJ
         LKwF4PTe9rHU29ld2cNlBManZxzmVsWQeqy4x/c1sotW+XBtgnvXT0uRYbBG6odnTxaP
         NgpKFN3bkN+BEskLK4c/Qp0z1yGjC7fMszzkXyWX2WdbfEBZRO9xJd4WZsh+bvyd5MeK
         IPWw42JihkRc4tYj+Yg+qsWI2QIErwQvnekl9CHyyznSUzzJyuUzcFYRBdbQCDqe2OAM
         cNP36pUuzOeDmG0f03OmXR7PrEvcU+tVhMfo5EtskLIs3xmTvBf+gsL9Vp9D5hZq+WvY
         8bQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1AHud2ZD6tXhbo4XTIHImH/7A+j/bT1tgyCj7c12ovw=;
        b=fb8msNhvZTMTZrdIQjp/twkhkwKUd74XEXHCdHScsoxik0UCcZi+TUvwIrhoocpzPF
         C3noyAZJ70s/7vxlicbeoweiYiiN+SftwGrHcxgaVyIca7TksHFTDGx7ISrA3796vUAf
         QDeQHmsW5ap7gfxfBWFNznVQiqYJkmBqVvTkvxvrJdvOOtDL5nY9pzAy99gJxV/UdGIK
         AwzjE2ZPhDHp8DGlH0pTZRbLrvQOe25pufGg/xmLNsB4UYjz6GcPnIlS3wuJWfC9V1ie
         Wm1c1qTFYpQlSXSPf/Uh/k5XwTmPCghgMtSHa2prqr7qIG78/ZlQpYwrEc7q3WO3PANW
         cDqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4si1207581qkb.139.2019.04.24.03.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B2E9F8AE76;
	Wed, 24 Apr 2019 10:26:00 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 776E0600C4;
	Wed, 24 Apr 2019 10:25:55 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 5/7] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Date: Wed, 24 Apr 2019 12:25:09 +0200
Message-Id: <20190424102511.29318-6-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 24 Apr 2019 10:26:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer needed, the callers of arch_add_memory() can handle this
manually.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 8 --------
 mm/memory_hotplug.c            | 9 +++------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2d4de313926d..2f1f87e13baa 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
 extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
 			   unsigned long nr_pages, struct vmem_altmap *altmap);
 
-/*
- * Do we want sysfs memblock files created. This will allow userspace to online
- * and offline memory explicitly. Lack of this bit means that the caller has to
- * call move_pfn_range_to_zone to finish the initialization.
- */
-
-#define MHP_MEMBLOCK_API               (1<<0)
-
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		       struct mhp_restrictions *restrictions);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e1637c8a0723..107f72952347 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		struct vmem_altmap *altmap, bool want_memblock)
+				   struct vmem_altmap *altmap)
 {
 	int ret;
 
@@ -293,8 +293,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				restrictions->flags & MHP_MEMBLOCK_API);
+		err = __add_section(nid, section_nr_to_pfn(i), altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1066,9 +1065,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  */
 int __ref add_memory_resource(int nid, struct resource *res)
 {
-	struct mhp_restrictions restrictions = {
-		.flags = MHP_MEMBLOCK_API,
-	};
+	struct mhp_restrictions restrictions = {};
 	u64 start, size;
 	bool new_node = false;
 	int ret;
-- 
2.20.1

