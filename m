Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62157C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 20:07:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0611820815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 20:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0611820815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542F26B0005; Mon, 20 May 2019 16:07:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2D56B0006; Mon, 20 May 2019 16:07:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36D7A6B0007; Mon, 20 May 2019 16:07:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F20846B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 16:07:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p124so10397819pga.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 13:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=qowZ2i4k4nLKiOpM66jf6dGGC4HkFcJRHZmVLzfMaho=;
        b=kG45poS1F3Z5w1bgLaMzXi6OdcZLNSW6YwSE9/iFlUsxjNz435nKAVtB8i4zampkUw
         MFpWR8WUXDqdRYA1dShIgvQqFhQdJK6NFinRX3B5/HB7cSBpBAg8NoCcT3Bz0Cnaob5C
         DTWOfp3G5ec0aYoKLwfpZKXG8mBn980Ipnxe6+DdpD7I8R991kvT99tmHFQsTV2VWH/3
         hAIsC6/ozO2iM8lbAUjHoZZY2e0dvy5FczznFE3MUMg4qZhj3YJ/sG97T24levcfvZAz
         MHohagwtFsQdhppGwyCrZP9aMWAd1Fm7qYhwpoqvBCJJEEIL46/X9P+eBDOgrROevokx
         0XcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXveLKZ3LP9yj560z8HY1Q+s6ivhk4hl7gWGoZLSnU9s8h68LEG
	SpWrcBkWm7ycFiPB9gLUOASbF4H3sfl2gyNkHBtg36MuJlfswGU+oXbG5AmjS4msMrW6axD8kj1
	yUFx5yq5MYysH7QYexGG9W3dGCgCMECUXTFD7YAC0zHmJTcsyzvtc1drCmH2onbESnw==
X-Received: by 2002:a63:db4e:: with SMTP id x14mr62249450pgi.119.1558382871349;
        Mon, 20 May 2019 13:07:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAMzKQ3twhEpPw/RjqssR6a0e/VPNo2hDVqqlLM2hlZbm3eAy/jtD2grmb8wrvQ8mn4Zo9
X-Received: by 2002:a63:db4e:: with SMTP id x14mr62249375pgi.119.1558382870478;
        Mon, 20 May 2019 13:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558382870; cv=none;
        d=google.com; s=arc-20160816;
        b=QJTf3G2WdkeWpPOFh5dKOgg8G6G6u4+S0PQOxIEuggC3AplgquuG+uVh4GuOpV4yLX
         u5aXwCeamd42PWpTj9snnq82u6aFxqc82soOsiwwkOm+xSQvWuC3CtXFsdB1Gi8gjcht
         t5w5GxBK1yg9Fj1pddVZhTWvPEn86pM+409K4WQpPOOh56ardr89iKFGKMNLP0KH2/Q7
         PefIF8rmZ/tjZ22BoOSJxjBdwpye1fCDvY0+UsMwKZsdq1o8qJRoTmy4uY776IGpm3Ov
         D5HR+LC1W2xzeRrhfsJRjadpSWPh6Z7m03qjLMOS5KUOhWmQ8uumDxZs6tBnHsMGbWFW
         lOWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=qowZ2i4k4nLKiOpM66jf6dGGC4HkFcJRHZmVLzfMaho=;
        b=SaDTOCXtbtOQniFzYqtHIrOSbcvoF7KQ/2s3Y1al9jtSk5qmRx0JyuGMVHkF0hNdR7
         2oPcyunvU5pFcfrHQEHk0E7eqKmnG4CWUMOSJMqu5rQ2/KU097B0VFn4B4jt3LPkgvAC
         5pbXr34xG6X7MWTWZmXUsR9ZquJq2e0+djcJlu9e9lcIbQaTM5awDm+dsclI3MMsyHXQ
         LMJSneTcebMA1xjL9PPpGCRMPwz5viYNNsRSWp0EAplp2qP+TdWTR+HwFEDW81iqp6tT
         m/J3SdsBWodIvdEsVe3tSaH1MY3NGpyCcI9a2CTfH3nXXKcuXv2YP3QS2WyM95tGfmop
         uyhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i16si1001194pgh.549.2019.05.20.13.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 13:07:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 13:07:49 -0700
X-ExtLoop1: 1
Received: from cavannie-mobl1.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.114.95])
  by fmsmga007.fm.intel.com with ESMTP; 20 May 2019 13:07:48 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v2] vmalloc: Fix issues with flush flag
Date: Mon, 20 May 2019 13:07:03 -0700
Message-Id: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch VM_FLUSH_RESET_PERMS to use a regular TLB flush intead of
vm_unmap_aliases() and fix calculation of the direct map for the
CONFIG_ARCH_HAS_SET_DIRECT_MAP case.

Meelis Roos reported issues with the new VM_FLUSH_RESET_PERMS flag on a
sparc machine. On investigation some issues were noticed:

1. The calculation of the direct map address range to flush was wrong.
This could cause problems on x86 if a RO direct map alias ever got loaded
into the TLB. This shouldn't normally happen, but it could cause the
permissions to remain RO on the direct map alias, and then the page
would return from the page allocator to some other component as RO and
cause a crash.

2. Calling vm_unmap_alias() on vfree could potentially be a lot of work to
do on a free operation. Simply flushing the TLB instead of the whole
vm_unmap_alias() operation makes the frees faster and pushes the heavy
work to happen on allocation where it would be more expected.
In addition to the extra work, vm_unmap_alias() takes some locks including
a long hold of vmap_purge_lock, which will make all other
VM_FLUSH_RESET_PERMS vfrees wait while the purge operation happens.

3. page_address() can have locking on some configurations, so skip calling
this when possible to further speed this up.

Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
Reported-by: Meelis Roos <mroos@linux.ee>
Cc: Meelis Roos <mroos@linux.ee>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---

Changes since v1:
 - Update commit message with more detail
 - Fix flush end range on !CONFIG_ARCH_HAS_SET_DIRECT_MAP case

 mm/vmalloc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..8d03427626dc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2122,9 +2122,10 @@ static inline void set_area_direct_map(const struct vm_struct *area,
 /* Handle removing and resetting vm mappings related to the vm_struct. */
 static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 {
+	const bool has_set_direct = IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP);
+	const bool flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long start = ULONG_MAX, end = 0;
-	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	unsigned long start = addr, end = addr + area->size;
 	int i;
 
 	/*
@@ -2133,7 +2134,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * This is concerned with resetting the direct map any an vm alias with
 	 * execute permissions, without leaving a RW+X window.
 	 */
-	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
+	if (flush_reset && !has_set_direct) {
 		set_memory_nx(addr, area->nr_pages);
 		set_memory_rw(addr, area->nr_pages);
 	}
@@ -2146,22 +2147,24 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 
 	/*
 	 * If not deallocating pages, just do the flush of the VM area and
-	 * return.
+	 * return. If the arch doesn't have set_direct_map_(), also skip the
+	 * below work.
 	 */
-	if (!deallocate_pages) {
-		vm_unmap_aliases();
+	if (!deallocate_pages || !has_set_direct) {
+		flush_tlb_kernel_range(start, end);
 		return;
 	}
 
 	/*
 	 * If execution gets here, flush the vm mapping and reset the direct
 	 * map. Find the start and end range of the direct mappings to make sure
-	 * the vm_unmap_aliases() flush includes the direct map.
+	 * the flush_tlb_kernel_range() includes the direct map.
 	 */
 	for (i = 0; i < area->nr_pages; i++) {
-		if (page_address(area->pages[i])) {
+		addr = (unsigned long)page_address(area->pages[i]);
+		if (addr) {
 			start = min(addr, start);
-			end = max(addr, end);
+			end = max(addr + PAGE_SIZE, end);
 		}
 	}
 
@@ -2171,7 +2174,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * reset the direct map permissions to the default.
 	 */
 	set_area_direct_map(area, set_direct_map_invalid_noflush);
-	_vm_unmap_aliases(start, end, 1);
+	flush_tlb_kernel_range(start, end);
 	set_area_direct_map(area, set_direct_map_default_noflush);
 }
 
-- 
2.20.1

