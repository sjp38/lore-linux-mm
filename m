Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48903C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06C0B21479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06C0B21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A71ED6B0006; Mon, 20 May 2019 19:39:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FCB26B0007; Mon, 20 May 2019 19:39:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827416B0008; Mon, 20 May 2019 19:39:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4741B6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:39:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id k22so10925211pfg.18
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:39:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SUkKraibMrZtEOva2Ju4+/lYb/xxL31HUziInpZ9l+Y=;
        b=I4SQABen2/XLHy44B/PXqJy7YcYD7YTOrCndET+Y+kKxukefc51Xq6fgKtDbcdoibu
         h4PlP98R+3/OdZoF4sdlCU/2A6UW0cMvkaTZPOiubVcN4IzYba+VnF487PYgXO8VepNy
         gJiy6TDG3yIW2/HDM7FIt2qNcIEoIcHdUKaVAUcS2w07YaiJc22TiU8BecXNFwVCJAK/
         JsJlleMxd6XStkARqJfUbwi/yUSGBLRQVPWuOK25VP4lV/GmkjAul9JYutAwJDeMyVfn
         lQe629CJyPMA8xQqFLILMdhcd7CxIKR7V8Dzz96dh3/B5OP16ae1wyuvW2sZJRWeF+FW
         N/dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXHvqa1aXyhMefM+cHgxtZtryjY+bi4atfJS+SwuxRbRNcY24dw
	jKdwBn0hygV9LAiFoy/ouZiUgiGGB4hDf5LnhyBA7P/Gu6BNKF49DRrKmOPC7FzXgbxbPHY8Ltr
	DM3Ze6heiFVIELGLmuimu2t2SCQbtFh/YzFyGKglIJYlxXq+1GBfNJRGekcNH3kraqQ==
X-Received: by 2002:a63:5608:: with SMTP id k8mr78447516pgb.393.1558395547940;
        Mon, 20 May 2019 16:39:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjyeg9ZCcsWmGbAxm9HeqkqoOmTchPzaHhvK2XBibD2nWgn70G4FTn0s8HuK1wDkBVfa6P
X-Received: by 2002:a63:5608:: with SMTP id k8mr78447429pgb.393.1558395546702;
        Mon, 20 May 2019 16:39:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558395546; cv=none;
        d=google.com; s=arc-20160816;
        b=GCklXJSkphEBCBss0/hVjy354+zfvGxEaj2NKggqlN4Dvmy4c9FX7sNPkX1JSEL5ut
         QONU8KQSO/aMg+YUyqvExPrhRjvUKDaUP5vE4m8hlCXGIm/CnLAz0EHKVmug/GmCsX0A
         BpPdzYoASKXgZbB8CI+c62+qyfenIAekuInu1iCTBF+WoD4DdK5e455v1zoA7wqPjm1B
         HQ4kdiyiMnBoYKzKmQAlBg4rVFdgGwZ/UIxeXOAy7eCNgBnupq7/RK1OEKMBz1hIy2Av
         JtyDN8EU8Inz5a4oC/uBd63Ljhopk1WiomO/DJrGA1qJ47W2kxe1z7rqVMqOF8s0WyOF
         /lng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SUkKraibMrZtEOva2Ju4+/lYb/xxL31HUziInpZ9l+Y=;
        b=zf61gOakpRznuG0DTfdyFDuF3bpSJvKGS14b6ZeuTH/ht7nSzkk/ceRB2b8Bprmwx5
         wNyxYUIwUuDSUSj9Kd5JNT9GFilDyqHlk6Ckam960J2bsAM6Tbm01qQXnjWdXxkyK0Ky
         02/oMaT6UjG3voK7iSPHLSkIV63omcrgN7OR35paiCXfbYGZvbHvcpl06q90GyQkq+Hj
         bQkjl2mpSQK3tkqjYRfwlc02NMzbutK5CKYeri+WzG903rQc2O4nW3FDvSauA5ot8gOu
         PeDisTKU62leC9uAT1CNGtXMGBtf3h47jPh/zQ5y1LRiBuPvliIdic9n3gFYh5XtUODk
         DkJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g90si19915577plb.140.2019.05.20.16.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 16:39:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 16:39:06 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.114.95])
  by fmsmga008.fm.intel.com with ESMTP; 20 May 2019 16:39:05 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@amacapital.net
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	davem@davemloft.net,
	Rick Edgecombe <redgecombe.lkml@gmail.com>,
	Meelis Roos <mroos@linux.ee>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 2/2] vmalloc: Remove work as from vfree path
Date: Mon, 20 May 2019 16:38:41 -0700
Message-Id: <20190520233841.17194-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <redgecombe.lkml@gmail.com>

Calling vm_unmap_alias() in vm_remove_mappings() could potentially be a
lot of work to do on a free operation. Simply flushing the TLB instead of
the whole vm_unmap_alias() operation makes the frees faster and pushes
the heavy work to happen on allocation where it would be more expected.
In addition to the extra work, vm_unmap_alias() takes some locks including
a long hold of vmap_purge_lock, which will make all other
VM_FLUSH_RESET_PERMS vfrees wait while the purge operation happens.

Lastly, page_address() can involve locking and lookups on some
configurations, so skip calling this by exiting out early when
!CONFIG_ARCH_HAS_SET_DIRECT_MAP.

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
 mm/vmalloc.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 836888ae01f6..8d03427626dc 100644
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
@@ -2146,17 +2147,18 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 
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
 		addr = (unsigned long)page_address(area->pages[i]);
@@ -2172,7 +2174,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * reset the direct map permissions to the default.
 	 */
 	set_area_direct_map(area, set_direct_map_invalid_noflush);
-	_vm_unmap_aliases(start, end, 1);
+	flush_tlb_kernel_range(start, end);
 	set_area_direct_map(area, set_direct_map_default_noflush);
 }
 
-- 
2.20.1

