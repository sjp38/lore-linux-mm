Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A325C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B55221773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B55221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE7576B0010; Wed, 24 Apr 2019 06:26:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C97BE6B0266; Wed, 24 Apr 2019 06:26:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5F536B0269; Wed, 24 Apr 2019 06:26:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 969E36B0010
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:26:09 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so15545931qkf.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:26:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6alr3xAWbp/4sFY4rIt7l7CbtIsbDy+NJtgQONgCG9U=;
        b=tupqHzxJCNMATs6nsr451eHD/55oCHrsecqBO3bq0xJZ2MSQNz2HO+CW31/AKpxe6l
         n+yxs+aIo5MokdQrom2QDxTv3yfLVbX2IzI1UDfcZIeEZ0zetZCjdSQpmbac7O7xDZvc
         x765Q56fdGNXvU/aOzC8TPMUsdpVOxo5BXcfjUeoQfSHFFya3v1E2Rn41yVdT1fMIyW1
         Ui1cF9wWenWEZFvJ3kl2cHJ1GeWAdhoI3jkQGtLpJ1/iyJDSua9Eo9RklUora9BGmBKy
         jap4BQ13+oyEkwpClMwFIstr7oYep9JZZAXosi57XRpctktWvEZMe36D4MZmYklyxUuY
         Jaxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/9X09WlQlWm2dBUpioWMSzkYst6T8JDrgCAuE7LepAc+hw/M6
	PgZ+EVbqACQK3XqiV5yQZQ48r8wjMlBiEFZIPPmKUrv7A3AYqMMnAXqeurTcee1Oo8gS58WBnIH
	42YgJI2YRJIrmizHQev4tp/AIIuHDR5N3NsOY1EGIXK75flB++prUwMOENBUHQoEP7A==
X-Received: by 2002:ac8:3f78:: with SMTP id w53mr11638765qtk.317.1556101569363;
        Wed, 24 Apr 2019 03:26:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEtv4HEn/k8shoSMNEdFtsCyVElk0yGR0p+mi37z2LhfvZvlNQYXR+N+SxNg1s2oHJfhkX
X-Received: by 2002:ac8:3f78:: with SMTP id w53mr11638690qtk.317.1556101568182;
        Wed, 24 Apr 2019 03:26:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101568; cv=none;
        d=google.com; s=arc-20160816;
        b=mx2nfk+Kq919e46jbbhhIRn2O+vUyjRq3EqJbSRFGNvELpWXcOogL/uBS3aFPQLkV4
         CQiYQzXWHA0sqhQsQOad/V2Yu4ioRuvok/mg7LJvlk3c8kN1uHh00WPmoDqYdf6aOZPD
         wDrGNPqwNR3FGWfGwqLLgFTFjGe3/OZ8JHBZpJ2wCQzNdDIAZV40cuMF/d7LcQeSiL8m
         nzEBnMXqinPXasjPjVh/0/9qxQv3E4089qu+rOxcoQSd8e8F/zx1xQna04KQ5YGBZAql
         OweEFUYtVAvaLQrH9X/HD4EwhOmdkcuu1XWMzOKBLPkZpDEDGWHpmL0FNVm2TTQE5dHO
         xdEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6alr3xAWbp/4sFY4rIt7l7CbtIsbDy+NJtgQONgCG9U=;
        b=EPmzDiM0iDEXUf0bcgVTPdWqNZAG3Slex4SxJ0E2Pm5wpkmoezD2k9kc8nNLnxXXj/
         puuKfn9NQLnZTaFpHv5tX/Zdoo9Sulr67/zIRk25VnSH3CEfSl+pf7BOEMlO1KQKQ+YR
         I4BKL6ORXPMNIQjptJeywta2FXz5zBZ5PFgVkYIBbx3br/hwJ4CFWKXEOGYpJArbOtrz
         ZYtquYPI/pvFe9Aj+Vaqc/mfVkVuxaDeChYd4CiNDVyCtMYeFPpceGzcCTHBpgbO5XB3
         6qzlwA3mp3U6lmNIealoBDtTnuPRVuogx3aQw5YtOCMTZDopn+g/zPSuA783Hn65ulVB
         eEIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l21si818727qtj.365.2019.04.24.03.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:26:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 27BA088AB9;
	Wed, 24 Apr 2019 10:26:07 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 12CE1600C4;
	Wed, 24 Apr 2019 10:26:00 +0000 (UTC)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 6/7] mm/memory_hotplug: Remove memory block devices before arch_remove_memory()
Date: Wed, 24 Apr 2019 12:25:10 +0200
Message-Id: <20190424102511.29318-7-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 24 Apr 2019 10:26:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's factor out removing of memory block devices, which is only
necessary for memory added via add_memory() and friends that created
memory block devices. Remove the devices before calling
arch_remove_memory().

This finishes factoring out memory block device handling from
arch_add_memory() and arch_remove_memory().

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 39 +++++++++++++++++++--------------------
 drivers/base/node.c    | 11 ++++++-----
 include/linux/memory.h |  2 +-
 include/linux/node.h   |  6 ++----
 mm/memory_hotplug.c    |  5 +++--
 5 files changed, 31 insertions(+), 32 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 862c202a18ca..47ff49058d1f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -756,32 +756,31 @@ int hotplug_memory_register(unsigned long start, unsigned long size)
 	return ret;
 }
 
-static int remove_memory_section(struct mem_section *section)
+/*
+ * Remove memory block devices for the given memory area. Start and size
+ * have to be aligned to memory block granularity. Memory block devices
+ * have to be offline.
+ */
+void hotplug_memory_unregister(unsigned long start, unsigned long size)
 {
+	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
 	struct memory_block *mem;
+	unsigned long pfn;
 
-	if (WARN_ON_ONCE(!present_section(section)))
-		return;
+	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
+	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
 
 	mutex_lock(&mem_sysfs_mutex);
-
-	/*
-	 * Some users of the memory hotplug do not want/need memblock to
-	 * track all sections. Skip over those.
-	 */
-	mem = find_memory_block(section);
-	if (!mem)
-		goto out_unlock;
-
-	unregister_mem_sect_under_nodes(mem, __section_nr(section));
-
-	mem->section_count--;
-	if (mem->section_count == 0)
+	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
+		mem = find_memory_block(__pfn_to_section(pfn));
+		if (!mem)
+			continue;
+		mem->section_count = 0;
+		unregister_memory_block_under_nodes(mem);
 		unregister_memory(mem);
-	else
-		put_device(&mem->dev);
-
-out_unlock:
+	}
 	mutex_unlock(&mem_sysfs_mutex);
 }
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..04fdfa99b8bc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -801,9 +801,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 	return 0;
 }
 
-/* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-				    unsigned long phys_index)
+/*
+ * Unregister memory block device under all nodes that it spans.
+ */
+int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
@@ -816,8 +817,8 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
 
-	sect_start_pfn = section_nr_to_pfn(phys_index);
-	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
+	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
+	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 95505fbb5f85..aa236c2a0466 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -112,7 +112,7 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 int hotplug_memory_register(unsigned long start, unsigned long size);
-extern void unregister_memory_section(struct mem_section *);
+void hotplug_memory_unregister(unsigned long start, unsigned long size);
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
diff --git a/include/linux/node.h b/include/linux/node.h
index 1a557c589ecb..02a29e71b175 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,8 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-					   unsigned long phys_index);
+extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
 						   unsigned int cpu_nid,
@@ -176,8 +175,7 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
-						  unsigned long phys_index)
+static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 107f72952347..527fe4f9c620 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -519,8 +519,6 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
 
-	unregister_memory_section(ms);
-
 	scn_nr = __section_nr(ms);
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);
@@ -1844,6 +1842,9 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
+	/* remove memory block devices before removing memory */
+	hotplug_memory_unregister(start, size);
+
 	arch_remove_memory(nid, start, size, NULL);
 	__release_memory_resource(start, size);
 
-- 
2.20.1

