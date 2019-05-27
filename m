Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7376CC072B1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B23B208CA
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:32:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B23B208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BCFC6B0272; Mon, 27 May 2019 06:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83B786B0273; Mon, 27 May 2019 06:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68EEA6B0274; Mon, 27 May 2019 06:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE0956B0272
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:32:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so27389315edi.20
        for <linux-mm@kvack.org>; Mon, 27 May 2019 03:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=8CGFP6Qn2xvR/4ig5R52dtdRE57fbpM5XHPmlSASgvE=;
        b=TsSYGsPDUHv8AMkiX6RNt9Xbb0OMf61CsGjA0pRzf5Yusds/wEG5NMna8HTGDxpo1a
         pq/ZGdq0N8zy8gy4xxV5yXk+tI9xscCZ2E0yqZeuSxffNZRqgxaGPYFQLEEWvGELm5SP
         joaVrXrxTw+02NTYOFAPqxupFsoj4VktNtMApQn1RKvt93wEyiQEiv1Cgs2i8Jm+9zPK
         fUjKHaodTSCdtYrAWzMqjOz7SFTA69AsgUTbqZxcJIGiulFfMeGhyhjS3qgKFq7oazYg
         vGp3PYMvR35fF3BR+H9/1h9ax/n3CphvkVfA4NAswEOER7nSfM0P3/wjOb//xzGxzM6Q
         0PCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAXDS85np+yUX6i+/79lB2/NFp3Wrt0/CFPXJkGio3ad0wHO0GDG
	BI584zFfRHCEB8Um37wLAjswEKlyneC1o7k0C/gpmh2X9UHqCqPeTBlp1dJirmQ1jJtTswAF0Xb
	ZijDIqtbOQhI/G0dlEcTv28gGb1wStkQraKSuOsXMNHpvM7r9iCrw4cUPAcOa61J2Xw==
X-Received: by 2002:a17:906:4e87:: with SMTP id v7mr89361594eju.150.1558953134290;
        Mon, 27 May 2019 03:32:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8f5RVzHm9dpqaO3nZ4eayaRInAJ8Q6exxd31CB6aEc4PGYPNxGWFupbBEzmfch7BZBqsI
X-Received: by 2002:a17:906:4e87:: with SMTP id v7mr89361515eju.150.1558953132925;
        Mon, 27 May 2019 03:32:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558953132; cv=none;
        d=google.com; s=arc-20160816;
        b=e1OhV4Nyjy7T1XlIbKD8NbWJ7XoDsOcK+2PFjG/udNn9j93vlG55kiFb5NXCyrlRlG
         D/HUlKz54yMVhh9mVX6jDohe+WwQUjv+h6zQqTPw+ytw78Zgz262KeNbND+PnYFgBxvg
         hBzp1ZEI+Ckh4k0E9yAYIIifsJGjxzCFegUEhAtJIIVSvPGdIZUpjwNe4lD4C2QPovzx
         K9drAWXl4z7sxWjShp5cA0xIF28bbDRISLEGFMTRh2LNkfP/09hLOYvTAuXcz8Fmr89X
         Or2rkyZPeljCfDehYnGi7/Y2c2Ki2atxhduW8zogzy5IqxSZ/Qgb2eN5ZE1bviArYOxT
         /VBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=8CGFP6Qn2xvR/4ig5R52dtdRE57fbpM5XHPmlSASgvE=;
        b=OhgQj/OPpTG3i3kIcB+q16FPX4GshpQXWJ20xNxZGGNcwWeoLGeZVqN2BCOomY/eX6
         /LNbKr+oFS4t+I+tbb5V68ZbnEvCcEsMB13i/Zv5fxxX4s9Gmf4/PZJmeDytW39CdWxl
         gfSEiVaZFfC6kHYoMmhMt9gDBMIHR2qrPREPxRwB0gfnS6PwG9R7DeVGwI7KYp7atx0R
         Nb1Fo0c2rms0ICFR4KsPw4ujL4tsYZ2J7p+FXQzMeI67xD6kIzX83SmfYkRkFmtbW4/M
         Q0SH87gc8+itWHG7PrDBZfbxGIe34D+spP2yH5MB7f4PYovrThc6UvmoT5BsFPxLMKue
         T+0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si8482193edb.358.2019.05.27.03.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 03:32:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 00898ADE6;
	Mon, 27 May 2019 10:32:12 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 3/3] mm: remove tmem specifics from frontswap
Date: Mon, 27 May 2019 12:32:07 +0200
Message-Id: <20190527103207.13287-4-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190527103207.13287-1-jgross@suse.com>
References: <20190527103207.13287-1-jgross@suse.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The frontswap module contains several parts which are specific to
tmem. With that no longer present those parts can be removed.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 Documentation/vm/frontswap.rst |  17 +----
 include/linux/frontswap.h      |   5 --
 mm/Kconfig                     |  16 ++---
 mm/frontswap.c                 | 156 +----------------------------------------
 4 files changed, 7 insertions(+), 187 deletions(-)

diff --git a/Documentation/vm/frontswap.rst b/Documentation/vm/frontswap.rst
index 511c921bc8d2..2c674c0c6a77 100644
--- a/Documentation/vm/frontswap.rst
+++ b/Documentation/vm/frontswap.rst
@@ -19,7 +19,7 @@ for a detailed overview of frontswap and related kernel parts)
 Frontswap is so named because it can be thought of as the opposite of
 a "backing" store for a swap device.  The storage is assumed to be
 a synchronous concurrency-safe page-oriented "pseudo-RAM device" conforming
-to the requirements of transcendent memory (such as Xen's "tmem", or
+to the requirements of transcendent memory (such as
 in-kernel compressed memory, aka "zcache", or future RAM-like devices);
 this pseudo-RAM device is not directly accessible or addressable by the
 kernel and is of unknown and possibly time-varying size.  The driver
@@ -113,21 +113,6 @@ many servers in a cluster can swap, dynamically as needed, to a single
 server configured with a large amount of RAM... without pre-configuring
 how much of the RAM is available for each of the clients!
 
-In the virtual case, the whole point of virtualization is to statistically
-multiplex physical resources across the varying demands of multiple
-virtual machines.  This is really hard to do with RAM and efforts to do
-it well with no kernel changes have essentially failed (except in some
-well-publicized special-case workloads).
-Specifically, the Xen Transcendent Memory backend allows otherwise
-"fallow" hypervisor-owned RAM to not only be "time-shared" between multiple
-virtual machines, but the pages can be compressed and deduplicated to
-optimize RAM utilization.  And when guest OS's are induced to surrender
-underutilized RAM (e.g. with "selfballooning"), sudden unexpected
-memory pressure may result in swapping; frontswap allows those pages
-to be swapped to and from hypervisor RAM (if overall host system memory
-conditions allow), thus mitigating the potentially awful performance impact
-of unplanned swapping.
-
 A KVM implementation is underway and has been RFC'ed to lkml.  And,
 using frontswap, investigation is also underway on the use of NVM as
 a memory extension technology.
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 6d775984905b..052480aa3756 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -24,11 +24,6 @@ struct frontswap_ops {
 };
 
 extern void frontswap_register_ops(struct frontswap_ops *ops);
-extern void frontswap_shrink(unsigned long);
-extern unsigned long frontswap_curr_pages(void);
-extern void frontswap_writethrough(bool);
-#define FRONTSWAP_HAS_EXCLUSIVE_GETS
-extern void frontswap_tmem_exclusive_gets(bool);
 
 extern bool __frontswap_test(struct swap_info_struct *, pgoff_t);
 extern void __frontswap_init(unsigned type, unsigned long *map);
diff --git a/mm/Kconfig b/mm/Kconfig
index 5166fe4af00b..971b615ad3a6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -436,20 +436,14 @@ config NEED_PER_CPU_KM
 	default y
 
 config FRONTSWAP
-	bool "Enable frontswap to cache swap pages if tmem is present"
+	bool "Enable frontswap to cache swap pages if zswap is present"
 	depends on SWAP
 	help
 	  Frontswap is so named because it can be thought of as the opposite
-	  of a "backing" store for a swap device.  The data is stored into
-	  "transcendent memory", memory that is not directly accessible or
-	  addressable by the kernel and is of unknown and possibly
-	  time-varying size.  When space in transcendent memory is available,
-	  a significant swap I/O reduction may be achieved.  When none is
-	  available, all frontswap calls are reduced to a single pointer-
-	  compare-against-NULL resulting in a negligible performance hit
-	  and swap data is stored as normal on the matching swap device.
-
-	  If unsure, say Y to enable frontswap.
+	  of a "backing" store for a swap device.  The only user right now is
+	  zswap.
+
+	  If unsure, say "n".
 
 config CMA
 	bool "Contiguous Memory Allocator"
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 157e5bf63504..e3370e46a0a5 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -33,23 +33,6 @@ static struct frontswap_ops *frontswap_ops __read_mostly;
 #define for_each_frontswap_ops(ops)		\
 	for ((ops) = frontswap_ops; (ops); (ops) = (ops)->next)
 
-/*
- * If enabled, frontswap_store will return failure even on success.  As
- * a result, the swap subsystem will always write the page to swap, in
- * effect converting frontswap into a writethrough cache.  In this mode,
- * there is no direct reduction in swap writes, but a frontswap backend
- * can unilaterally "reclaim" any pages in use with no data loss, thus
- * providing increases control over maximum memory usage due to frontswap.
- */
-static bool frontswap_writethrough_enabled __read_mostly;
-
-/*
- * If enabled, the underlying tmem implementation is capable of doing
- * exclusive gets, so frontswap_load, on a successful tmem_get must
- * mark the page as no longer in frontswap AND mark it dirty.
- */
-static bool frontswap_tmem_exclusive_gets_enabled __read_mostly;
-
 #ifdef CONFIG_DEBUG_FS
 /*
  * Counters available via /sys/kernel/debug/frontswap (if debugfs is
@@ -167,24 +150,6 @@ void frontswap_register_ops(struct frontswap_ops *ops)
 }
 EXPORT_SYMBOL(frontswap_register_ops);
 
-/*
- * Enable/disable frontswap writethrough (see above).
- */
-void frontswap_writethrough(bool enable)
-{
-	frontswap_writethrough_enabled = enable;
-}
-EXPORT_SYMBOL(frontswap_writethrough);
-
-/*
- * Enable/disable frontswap exclusive gets (see above).
- */
-void frontswap_tmem_exclusive_gets(bool enable)
-{
-	frontswap_tmem_exclusive_gets_enabled = enable;
-}
-EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
-
 /*
  * Called when a swap device is swapon'd.
  */
@@ -280,9 +245,6 @@ int __frontswap_store(struct page *page)
 	} else {
 		inc_frontswap_failed_stores();
 	}
-	if (frontswap_writethrough_enabled)
-		/* report failure so swap also writes to swap device */
-		ret = -1;
 	return ret;
 }
 EXPORT_SYMBOL(__frontswap_store);
@@ -314,13 +276,8 @@ int __frontswap_load(struct page *page)
 		if (!ret) /* successful load */
 			break;
 	}
-	if (ret == 0) {
+	if (ret == 0)
 		inc_frontswap_loads();
-		if (frontswap_tmem_exclusive_gets_enabled) {
-			SetPageDirty(page);
-			__frontswap_clear(sis, offset);
-		}
-	}
 	return ret;
 }
 EXPORT_SYMBOL(__frontswap_load);
@@ -369,117 +326,6 @@ void __frontswap_invalidate_area(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
-static unsigned long __frontswap_curr_pages(void)
-{
-	unsigned long totalpages = 0;
-	struct swap_info_struct *si = NULL;
-
-	assert_spin_locked(&swap_lock);
-	plist_for_each_entry(si, &swap_active_head, list)
-		totalpages += atomic_read(&si->frontswap_pages);
-	return totalpages;
-}
-
-static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
-					int *swapid)
-{
-	int ret = -EINVAL;
-	struct swap_info_struct *si = NULL;
-	int si_frontswap_pages;
-	unsigned long total_pages_to_unuse = total;
-	unsigned long pages = 0, pages_to_unuse = 0;
-
-	assert_spin_locked(&swap_lock);
-	plist_for_each_entry(si, &swap_active_head, list) {
-		si_frontswap_pages = atomic_read(&si->frontswap_pages);
-		if (total_pages_to_unuse < si_frontswap_pages) {
-			pages = pages_to_unuse = total_pages_to_unuse;
-		} else {
-			pages = si_frontswap_pages;
-			pages_to_unuse = 0; /* unuse all */
-		}
-		/* ensure there is enough RAM to fetch pages from frontswap */
-		if (security_vm_enough_memory_mm(current->mm, pages)) {
-			ret = -ENOMEM;
-			continue;
-		}
-		vm_unacct_memory(pages);
-		*unused = pages_to_unuse;
-		*swapid = si->type;
-		ret = 0;
-		break;
-	}
-
-	return ret;
-}
-
-/*
- * Used to check if it's necessory and feasible to unuse pages.
- * Return 1 when nothing to do, 0 when need to shink pages,
- * error code when there is an error.
- */
-static int __frontswap_shrink(unsigned long target_pages,
-				unsigned long *pages_to_unuse,
-				int *type)
-{
-	unsigned long total_pages = 0, total_pages_to_unuse;
-
-	assert_spin_locked(&swap_lock);
-
-	total_pages = __frontswap_curr_pages();
-	if (total_pages <= target_pages) {
-		/* Nothing to do */
-		*pages_to_unuse = 0;
-		return 1;
-	}
-	total_pages_to_unuse = total_pages - target_pages;
-	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
-}
-
-/*
- * Frontswap, like a true swap device, may unnecessarily retain pages
- * under certain circumstances; "shrink" frontswap is essentially a
- * "partial swapoff" and works by calling try_to_unuse to attempt to
- * unuse enough frontswap pages to attempt to -- subject to memory
- * constraints -- reduce the number of pages in frontswap to the
- * number given in the parameter target_pages.
- */
-void frontswap_shrink(unsigned long target_pages)
-{
-	unsigned long pages_to_unuse = 0;
-	int uninitialized_var(type), ret;
-
-	/*
-	 * we don't want to hold swap_lock while doing a very
-	 * lengthy try_to_unuse, but swap_list may change
-	 * so restart scan from swap_active_head each time
-	 */
-	spin_lock(&swap_lock);
-	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
-	spin_unlock(&swap_lock);
-	if (ret == 0)
-		try_to_unuse(type, true, pages_to_unuse);
-	return;
-}
-EXPORT_SYMBOL(frontswap_shrink);
-
-/*
- * Count and return the number of frontswap pages across all
- * swap devices.  This is exported so that backend drivers can
- * determine current usage without reading debugfs.
- */
-unsigned long frontswap_curr_pages(void)
-{
-	unsigned long totalpages = 0;
-
-	spin_lock(&swap_lock);
-	totalpages = __frontswap_curr_pages();
-	spin_unlock(&swap_lock);
-
-	return totalpages;
-}
-EXPORT_SYMBOL(frontswap_curr_pages);
-
 static int __init init_frontswap(void)
 {
 #ifdef CONFIG_DEBUG_FS
-- 
2.16.4

