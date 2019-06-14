Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51041C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C402177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 10:01:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C402177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 703476B000A; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C6D6B000E; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 505BD6B0266; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14E686B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:01:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id j128so1560686qkd.23
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 03:01:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XUeHS9AZadK84qxFCdY83begAnJlSImfQEMVyNXLF2M=;
        b=o/6Ymepm9xHjx77xxl9ZorLpK3QCOGIViEHcP5ZVDaqWCrD5cchA1rZJWyyswIjtQr
         XGpDKGc8PyuaPTSnpiNfoH98WPbCHG52Te/1IJX7l6WkRmFyvsTKyfh4kD0dyDYblrKp
         4mmBdbHYjcxHgpnQ6lq0+0oV1DpopPkrMsXFQwNSXBM6qADe7vBdlJS+A+KkakXHNgDf
         e/JJvfMYkUwJNQuJky8B86yt4c/04Mj4xlVxi55lKmBygOaynoqy+1L7tBvYZLnX7Kfn
         +/5obHeewLKPfsf+4ZRlB9HazwKi6fK4ADQwaSJMFTBxVg17tBJPP4b+VmZ5jq916Zet
         FqOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV27vt+5Hoe8KcpeZOLm/zcJs4VmXsyZMi5BrYoIUVJ6YsZjIPX
	fXOqbSw15fqY6SseK+hIlxERXcPzoydF7VLm2kX+mhpc7TsETwO/g0itQdBE/Gc2t+ZJZc4JjPZ
	hMm03GU7n2J4BlE3tn0I1hKN5q7UOrwI5l06jO0orjvkFW5WkuWQMw/TCysacO5jwaA==
X-Received: by 2002:a05:620a:10b2:: with SMTP id h18mr9879402qkk.14.1560506514780;
        Fri, 14 Jun 2019 03:01:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztQ84lBxOahUEsygA0qwZpMQU495nI/eD6Tpvdu18LQzTdUpRBgQimiWt7CDngfHauxaXy
X-Received: by 2002:a05:620a:10b2:: with SMTP id h18mr9879319qkk.14.1560506513792;
        Fri, 14 Jun 2019 03:01:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560506513; cv=none;
        d=google.com; s=arc-20160816;
        b=Khy8HWz9A94xXje495XGEpQeWpLsFrm8buCS/eDKAaeiPF2Eexcb3L9kxecSPhV2a2
         Fcfp1Krnj3+unPVuRaaXsZzBgqhLRXMEOQJYJYZbQkL2MUMfYB05ypwW7SQB225TGY0B
         sUG2QW7QOe4CE8jmEzPdQW8TZLsVUV4Om4N0q3byVlhrtuITNjQ1PN54VrZcQEaP/rkw
         bkUeAcdv6HoBcij8vuKURPvW+Xg62XycET6D8uOPNjpCctkSEgBoqwYGcIMwCCF3Ty5f
         hrc9KYvnid5TFGemirox+UD0b4erqIcQ5kgKGtDZzYbmdDdnX8f48M9JP6+rwkdYYIOO
         rXKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XUeHS9AZadK84qxFCdY83begAnJlSImfQEMVyNXLF2M=;
        b=HQq2R4Ibxz1z/+cRAWOEntek5IbAjVQ8qyK4tcGKwMhbQAxcZeE5Zb9B+6gpDLGpYM
         x1vU0eKrMHve8qBmvDgM3qyQmp1lNkA53CsBwX4epfbzX5AgDxEJcOUBZyWB6JVsjIgJ
         r3vsMsw9bMBdVMEQb+PyPaS/yetEhxH52CERaBxbiY2PKRa0DJqPP1Nx1U+qr1Lm/Zjy
         UlW21eHxeRlsQFOgdZXhKFKNMpgvEzD2Nx4+aF1EhVn+EtgoLZy529Xy4gdhOwbaXORu
         fVXtLF8CkrMq/N9xII9XzkwC/+g7kqrhwcrckeAEeDk0nxeH3xnf3L3uKfxMa93iHtNn
         wZfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f13si1331333qve.55.2019.06.14.03.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 03:01:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6C2B1356DA;
	Fri, 14 Jun 2019 10:01:42 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-252.ams2.redhat.com [10.36.116.252])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC6615D9D2;
	Fri, 14 Jun 2019 10:01:33 +0000 (UTC)
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
Subject: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
Date: Fri, 14 Jun 2019 12:01:09 +0200
Message-Id: <20190614100114.311-2-david@redhat.com>
In-Reply-To: <20190614100114.311-1-david@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 14 Jun 2019 10:01:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We are using a mixture of "int" and "unsigned long". Let's make this
consistent by using "unsigned long" everywhere. We'll do the same with
memory block ids next.

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
 drivers/base/memory.c  |  9 +++++----
 include/linux/mmzone.h |  4 ++--
 mm/sparse.c            | 12 ++++++------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 826dd76f662e..5b3a2fd250ba 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -34,7 +34,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 static int sections_per_block;
 
-static inline int base_memory_block_id(int section_nr)
+static inline int base_memory_block_id(unsigned long section_nr)
 {
 	return section_nr / sections_per_block;
 }
@@ -691,10 +691,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
 	return ret;
 }
 
-static int add_memory_block(int base_section_nr)
+static int add_memory_block(unsigned long base_section_nr)
 {
+	int ret, section_count = 0;
 	struct memory_block *mem;
-	int i, ret, section_count = 0;
+	unsigned long i;
 
 	for (i = base_section_nr;
 	     i < base_section_nr + sections_per_block;
@@ -822,7 +823,7 @@ static const struct attribute_group *memory_root_attr_groups[] = {
  */
 int __init memory_dev_init(void)
 {
-	unsigned int i;
+	unsigned long i;
 	int ret;
 	int err;
 	unsigned long block_sz;
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

