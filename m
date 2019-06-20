Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64673C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2268E20665
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 18:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2268E20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC8696B0006; Thu, 20 Jun 2019 14:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA11B8E0003; Thu, 20 Jun 2019 14:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A41938E0002; Thu, 20 Jun 2019 14:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC06B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:32:22 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so4795849qtn.14
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:32:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PicruJ+VHEPybZvyUaTHSXSbDBs5YreqCwZ14euAQts=;
        b=UvLMHUntMOjZa0lEJvNyPm3ldTyg3szMg7m9QWLE7xdPlO0L+hrTKjvzxvNrYxbj4t
         vpHNArHE1YL1eBvrW3teT+5V63mFTt4Hy6v4lAFfKwMC34yDUGaFtSpy39kYsr4t4lGN
         0aSf4dfTM1fPq46shEsinHkbwneLYHPCH68X3+4SuxkZQ6s3rv2M6uxcIaTFz4YGIsQ8
         9oYNJVa+XWjtYt2Ne6zFheJzdqrXLLIcMmJ87AsjLYGQAv4Mgb5IpnHJWdJZCbei+UPr
         rjkUE6t7vTIBhBg/7TAA4BJ9tsZid5qpj5hc4tIbZTn+dVaDA3RQXlQcDgtAmzk4sdRl
         crFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWDEQCEpSir3oNhPCHIDwgEBOY+vLBlU+/ldguMMi0TfKp1pOBJ
	n7LG//k9mdOZRpU7BzT73PWxUXKvtvfRZIAiIWquNh3BZJbZ8PN6MES5kaSRQWxnXIxY08mhzAt
	FmIGEp054DzUAgMw2x33arkFZiXx68zO8bA9PuYm04Ht1N87RL6JvMumV5ACUjgVZlg==
X-Received: by 2002:a0c:8aaa:: with SMTP id 39mr41144882qvv.17.1561055542259;
        Thu, 20 Jun 2019 11:32:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwac4mbNsCBlhDqyecFOI5XA//glC71rAjJe7umkZUrNjFToBps1KnuPYD3BC6z80rqsP1Q
X-Received: by 2002:a0c:8aaa:: with SMTP id 39mr41144798qvv.17.1561055541293;
        Thu, 20 Jun 2019 11:32:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561055541; cv=none;
        d=google.com; s=arc-20160816;
        b=bxjgvf/EJ/qkEfbcHgWog48t/6wXZiwy56q0SshvIM0+NDQFlG0z2/bIdepuydEC9g
         gZ4+Xi1PNYwaztlaqCmnC71TwQhxQRyUyP+uORQ4zD2pLRG/OCX5mjiAzLVuxr8opp9/
         15WJwjgPnjDfGDU4C7pdOzSrQlgWHzbaadp9rWILvW/srieCsWj5NrM+CgsOA+isfWGq
         ZKN5Cnnl203vaWaApEBJQ79Tr/MDGJRxJBpLu3GFvPdYHd2XRNlqlEb6alApG5AVmD2r
         PyDhv3CEFerx9+LhkrFn0xKxL7Bh5O/PlL56sU7As2rBZLhZ2W2IzrCTyhv1muf4mfox
         a8mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PicruJ+VHEPybZvyUaTHSXSbDBs5YreqCwZ14euAQts=;
        b=uQpYfz0QcLti9TlGeSmXAQpZv1J1992Ia3MIWMYdwBAtf1bfVyS0NFl4qpqUojGTpa
         GXeFe7f2WvaCWSfNCG3vWA263Hmejx7xdmBh+SNUnfRsOB2p83dIeXm9Y/ghWjgyPlQz
         GPiEydadZgcypZ03P+xkksBjxmEZdfDA3NjfZKnXjTWhAZ2OUyUxvme/OgGBVMkYlIxS
         K0bbhaA8pJY2M2InODR+gNKXp04oZEJvcYVjDEoKSGwQ46PxqnA95tF8+G0GEn8Y9/Fw
         S4Vu+IPNWqv8oyyvoiVoxqkNzBk6iHlPgIDUBIlp216jLkf0Ij302RGqCi7Bs6DtiqNX
         NhQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g187si127981qkc.5.2019.06.20.11.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 11:32:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 37276C18B2EB;
	Thu, 20 Jun 2019 18:32:04 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-71.ams2.redhat.com [10.36.116.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4FA1619C5B;
	Thu, 20 Jun 2019 18:31:58 +0000 (UTC)
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
Subject: [PATCH v3 1/6] mm: Section numbers use the type "unsigned long"
Date: Thu, 20 Jun 2019 20:31:34 +0200
Message-Id: <20190620183139.4352-2-david@redhat.com>
In-Reply-To: <20190620183139.4352-1-david@redhat.com>
References: <20190620183139.4352-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 20 Jun 2019 18:32:06 +0000 (UTC)
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

