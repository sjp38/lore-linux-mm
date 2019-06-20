Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56DF5C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CD252082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:35:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CD252082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE6B88E0001; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A71626B0008; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E95C8E0001; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 540C46B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:35:49 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x17so3027998qkf.14
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:35:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PicruJ+VHEPybZvyUaTHSXSbDBs5YreqCwZ14euAQts=;
        b=Fq54nB5yOA5rlokACv2MbAOSljiN43IAwnQYiPnZBKZHzuGwcddl1H+D817bsUxNBA
         clQCtI9AoDnBFiahs29cCGLf+jXddQdquCR19x43CeiSToLYQ3PRrP5LSWRsPzhd2je2
         MaPQOW42fy+3aK18DwcL6kWgX21fFP9dX9/tft3oVKYAAu6Ll8Hk0upIFH4osxjPm52N
         KDMGGPfWnsQ3iVqhLwnLzGiHJsBD7vl/0gNrWQ7mPj5sNtU3XyoF6k/J2b2a3lHdm5GB
         9SYORQgWdOiYtu7ofFgZ9lh9mE+I7nOdovoib3QxNKurav86dehWtu/kkNST/ssCUeff
         DvSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXP3t38GWE2zWRIrjzznzkZ+9AxuiRG+Yj0w3HRf6B5uMfZjJ2s
	v1WmV5cO1KZ7JFBr72dUt9ywIc5ZubVEDxzZKPjYtbhF22KPJCanyk9a9iZIAc3UCgUTFmZI34L
	b80w7ezc5mqctpo/7wkukxgLCIMJOZs26maVMQhWCN2bxBKHX2+4ezIIVcELrGn4YEw==
X-Received: by 2002:ac8:2763:: with SMTP id h32mr113471647qth.350.1561026949111;
        Thu, 20 Jun 2019 03:35:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3bVu90bXC7PqwuV84c1X2R4qlk4IpBI043kvqvgbVtzE3q1qm0clEMGCYeNTeMCzG6crC
X-Received: by 2002:ac8:2763:: with SMTP id h32mr113471569qth.350.1561026948067;
        Thu, 20 Jun 2019 03:35:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026948; cv=none;
        d=google.com; s=arc-20160816;
        b=zUOEeiyJsjrv2dWxx9xeYVC2hGsyfgLYaoYnvnCRrdisFwgOnmOQk9RFsXna1tu38e
         YrW95kd0CVVD6XunM4iv9CLR0Zc7OeYHAwjfIItoinvcWnN2PlCxBxvFsxKpl1PStBIB
         0S0e9CMrUVsrJxTisot+9kiRvry7ivI9fEQTetFKD9cSwhrk7Dn0FyCtlMrYLsgd0gNm
         yw+cOphaFLdHtTzkJUS4mGgB5ZWS8sXD6cs8T/B72JDAFtiuXvKH/ScFkxkhsu2P6ta2
         2VIeEOa8qiz8vNQM5sVYU+LqeNZHJe0wgfvMPcNgs6cd7HXCpHN8TUT3iF8fVvigDB5/
         Xu7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PicruJ+VHEPybZvyUaTHSXSbDBs5YreqCwZ14euAQts=;
        b=qsJ+SVW2NUKOjadjWUHlgLAcSHzHa+V6oQLqreHtGZ4WYFSMIeqBa122iK1xNde/jI
         imhCsecF2M7nGsRuSrVgi+FhNwb9eYKaBm4puw9mFU9bTb641opG4yh3ZZQpGDXW2rZl
         +seIPvp7kDeAeo1MiH1nAUu0VGLM6BHOeF5jTOZOIi3mnH2zP7P2aW7NiFiAnuZSnZum
         Wmn0yLVrQjP2bdhTVfUCSyXzApJ59bELHlv7JdS12eCX1uGy3uV59ACl1+jP3y47atmr
         n2lJOdFL1tQ/nWOWZX4zACkwx5GI1S8BujhlTNInIZZLSc2kyfKsQOe8JL93Hem5nNf/
         8pcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d32si4673522qtd.116.2019.06.20.03.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:35:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 836851556B;
	Thu, 20 Jun 2019 10:35:41 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3C9D560A97;
	Thu, 20 Jun 2019 10:35:35 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Wei Yang <richard.weiyang@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Arun KS <arunks@codeaurora.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 1/6] mm: Section numbers use the type "unsigned long"
Date: Thu, 20 Jun 2019 12:35:15 +0200
Message-Id: <20190620103520.23481-2-david@redhat.com>
In-Reply-To: <20190620103520.23481-1-david@redhat.com>
References: <20190620103520.23481-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 20 Jun 2019 10:35:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We are using a mixture of "int" and "unsigned long". Let's make this
consistent by using "unsigned long" everywhere. We'll do the same with
memory block ids next.

While at it, turn the "unsigned long i" in removable_show() into an
int - sections_per_block is an int.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Baoquan He <bhe@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 27 +++++++++++++--------------
 include/linux/mmzone.h |  4 ++--
 mm/sparse.c            | 12 ++++++------
 3 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 826dd76f662e..5947b5a5686d 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -34,7 +34,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 static int sections_per_block;
 
-static inline int base_memory_block_id(int section_nr)
+static inline int base_memory_block_id(unsigned long section_nr)
 {
 	return section_nr / sections_per_block;
 }
@@ -131,9 +131,9 @@ static ssize_t phys_index_show(struct device *dev,
 static ssize_t removable_show(struct device *dev, struct device_attribute *attr,
 			      char *buf)
 {
-	unsigned long i, pfn;
-	int ret = 1;
 	struct memory_block *mem = to_memory_block(dev);
+	unsigned long pfn;
+	int ret = 1, i;
 
 	if (mem->state != MEM_ONLINE)
 		goto out;
@@ -691,15 +691,15 @@ static int init_memory_block(struct memory_block **memory, int block_id,
 	return ret;
 }
 
-static int add_memory_block(int base_section_nr)
+static int add_memory_block(unsigned long base_section_nr)
 {
+	int ret, section_count = 0;
 	struct memory_block *mem;
-	int i, ret, section_count = 0;
+	unsigned long nr;
 
-	for (i = base_section_nr;
-	     i < base_section_nr + sections_per_block;
-	     i++)
-		if (present_section_nr(i))
+	for (nr = base_section_nr; nr < base_section_nr + sections_per_block;
+	     nr++)
+		if (present_section_nr(nr))
 			section_count++;
 
 	if (section_count == 0)
@@ -822,10 +822,9 @@ static const struct attribute_group *memory_root_attr_groups[] = {
  */
 int __init memory_dev_init(void)
 {
-	unsigned int i;
 	int ret;
 	int err;
-	unsigned long block_sz;
+	unsigned long block_sz, nr;
 
 	ret = subsys_system_register(&memory_subsys, memory_root_attr_groups);
 	if (ret)
@@ -839,9 +838,9 @@ int __init memory_dev_init(void)
 	 * during boot and have been initialized
 	 */
 	mutex_lock(&mem_sysfs_mutex);
-	for (i = 0; i <= __highest_present_section_nr;
-		i += sections_per_block) {
-		err = add_memory_block(i);
+	for (nr = 0; nr <= __highest_present_section_nr;
+	     nr += sections_per_block) {
+		err = add_memory_block(nr);
 		if (!ret)
 			ret = err;
 	}
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 427b79c39b3c..83b6aae16f13 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1220,7 +1220,7 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
 		return NULL;
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
 }
-extern int __section_nr(struct mem_section* ms);
+extern unsigned long __section_nr(struct mem_section *ms);
 extern unsigned long usemap_size(void);
 
 /*
@@ -1292,7 +1292,7 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
-extern int __highest_present_section_nr;
+extern unsigned long __highest_present_section_nr;
 
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
diff --git a/mm/sparse.c b/mm/sparse.c
index 1552c855d62a..e8c57e039be8 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -102,7 +102,7 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
-int __section_nr(struct mem_section* ms)
+unsigned long __section_nr(struct mem_section *ms)
 {
 	unsigned long root_nr;
 	struct mem_section *root = NULL;
@@ -121,9 +121,9 @@ int __section_nr(struct mem_section* ms)
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
 #else
-int __section_nr(struct mem_section* ms)
+unsigned long __section_nr(struct mem_section *ms)
 {
-	return (int)(ms - mem_section[0]);
+	return (unsigned long)(ms - mem_section[0]);
 }
 #endif
 
@@ -178,10 +178,10 @@ void __meminit mminit_validate_memmodel_limits(unsigned long *start_pfn,
  * Keeping track of this gives us an easy way to break out of
  * those loops early.
  */
-int __highest_present_section_nr;
+unsigned long __highest_present_section_nr;
 static void section_mark_present(struct mem_section *ms)
 {
-	int section_nr = __section_nr(ms);
+	unsigned long section_nr = __section_nr(ms);
 
 	if (section_nr > __highest_present_section_nr)
 		__highest_present_section_nr = section_nr;
@@ -189,7 +189,7 @@ static void section_mark_present(struct mem_section *ms)
 	ms->section_mem_map |= SECTION_MARKED_PRESENT;
 }
 
-static inline int next_present_section_nr(int section_nr)
+static inline unsigned long next_present_section_nr(unsigned long section_nr)
 {
 	do {
 		section_nr++;
-- 
2.21.0

