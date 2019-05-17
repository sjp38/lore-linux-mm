Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D943DC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9578C2082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9578C2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69B8A6B0005; Fri, 17 May 2019 17:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64B0D6B0006; Fri, 17 May 2019 17:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53AF66B0008; Fri, 17 May 2019 17:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3F46B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:05:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so5271484pfg.18
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OBR65ye90jLch3O/PIhwl9+j28PbZxXAc84K6sUC82E=;
        b=sJt++fiC5j5Pwf4MVTEVZx7WmhZLvGGqgGxFdVmiXx9tM7ntmEedBRjob3W0VM5wUh
         QdqfTBiTA5e51s1WpBxDnv5P+Ocnv5aTbbTtCTtIunL3NLHS329sMEIK4ZKYe461+1pE
         74cJWZtaORWRVI9lPKxOQR+loehsn/X1UCeWE97gvh83SnCJPwZgL4Z1YvUKBu9JQpoA
         oimNwAcV6Ky2TJ9jEeBPjcHxlhgAmOBPHRqPd87G7AfxgLW9fHQbvZi7ojFx7Q0+qDH9
         2ThlPT0rD7QmVoj7qamgcPQvqtpfXNggDudBGvdil57yV7vjcg42PrIWlO8LmJozeQbA
         dN6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUKKhNGH2ZJX66/D9zCdaLpPi/OOvFTO+slV4RQr0QJFPf1X5ml
	s3zzNV9if6BQHJNM+xjsYJik6jXto2ei022TCi2HeAqvXJ11onHVFMF154GTXdYGyItViHmGQ5c
	CkNwuNgyvN/oHVEZNTCyJjaCrl1dxbVBr7IE+aCoSydVibWTytfWr5SiFmptTl7VEwQ==
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr36457396pls.146.1558127111693;
        Fri, 17 May 2019 14:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdN6Y4X9w54/XoMHzuWVMpYh8QcY3p5PuZGC58ZMMKcyCVrikuuYCngUqcH6P/XjOO2mdR
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr36457311pls.146.1558127110708;
        Fri, 17 May 2019 14:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558127110; cv=none;
        d=google.com; s=arc-20160816;
        b=GDO6zrr/vAHyosJKeR004OVmkY5Recl/iyb5Vh9tq6L/Hl1OeLcCvZQltunmt7Eajv
         Di0wSMhbodSVTG20O7ezsbYhxw2IIsBvaT/rB9D8Fe0taJMCX3jrezg36F/2gHXv2fhG
         XpKtEKoyECUOURspxLXCTOCnRfQxr939ckuOYEm7YX5EOnzuWpzgWxdYwlFSORAXx9Rr
         e4+WmGEMxM+F1iEtWN9Iqg38qeLZvlGVVioRYRvG7QJin6hAtoV9HxzJ7rs9fK9b44xn
         scEz27xYb+DB9ZoF/zYJVIK6U3M3zR4ada2Nyh71VVOETQ7P/TOJ9kklGVTEXWubuyZ3
         UWTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OBR65ye90jLch3O/PIhwl9+j28PbZxXAc84K6sUC82E=;
        b=hUR5zRtv9nXLDO1rfyZrc0nc3zf1HS2i6CgT5VdSeISxqfHeYkoVDA1GNCjjDMYax+
         fjuoCPJIMunqhCwGX0pEQTOBQLQ0kMfdLmKttgC9ftzgtk1vpOcndyoiPjDH34ge+qZF
         BhqW2N9+I0HCNcrdkUCUPdoZnLK/ZWbvLjZHL3fMMHbIwAHluliTslR0ikWEosmNcNAv
         q3RwLV2leJTu/7F25Va9D6Vt7JV2ZMi4oljvqGjKVhJZdlk5wWpfVr8IyLZIxHNUFjzV
         Q8pE2rvER6V8oiDeqrJ8k1BzbGlQEPgg11f1O2JjRKYXULc4mB5IeGRw4aayYM/sUKaB
         YQ5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p1si8618089plo.212.2019.05.17.14.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 May 2019 14:05:10 -0700
X-ExtLoop1: 1
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga004.fm.intel.com with ESMTP; 17 May 2019 14:05:09 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: peterz@infradead.org,
	linux-mm@kvack.org,
	sparclinux@vger.kernel.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Subject: [PATCH 1/1] vmalloc: Fix issues with flush flag
Date: Fri, 17 May 2019 14:01:23 -0700
Message-Id: <20190517210123.5702-2-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190517210123.5702-1-rick.p.edgecombe@intel.com>
References: <20190517210123.5702-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Meelis Roos reported issues with the new VM_FLUSH_RESET_PERMS flag on the
sparc architecture.

When freeing many BPF JITs at once the free operations can become stuck
waiting for locks as they each try to vm_unmap_aliases(). Calls to this
function happen frequently on some archs, but in vmalloc itself the lazy
purge operations happens more rarely, where only in extreme cases could
multiple purges be happening at once. Since this is cross platform code we
shouldn't do this here where it could happen concurrently in a burst, and
instead just flush the TLB. Also, add a little logic to skip calls to
page_address() when possible to further speed this up, since they may have
locking on some archs.

Lastly, it appears that the calculation of the address range to flush
was broken at some point, so fix that as well.

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
 mm/vmalloc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 67bbb8d2a0a8..5daa7ec8950f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1531,9 +1531,10 @@ static inline void set_area_direct_map(const struct vm_struct *area,
 /* Handle removing and resetting vm mappings related to the vm_struct. */
 static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 {
+	const bool has_set_direct = IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP);
+	const bool flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long start = ULONG_MAX, end = 0;
-	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	unsigned long start = addr, end = addr + get_vm_area_size(area);
 	int i;
 
 	/*
@@ -1542,7 +1543,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * This is concerned with resetting the direct map any an vm alias with
 	 * execute permissions, without leaving a RW+X window.
 	 */
-	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
+	if (flush_reset && !has_set_direct) {
 		set_memory_nx(addr, area->nr_pages);
 		set_memory_rw(addr, area->nr_pages);
 	}
@@ -1555,22 +1556,24 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 
 	/*
 	 * If not deallocating pages, just do the flush of the VM area and
-	 * return.
+	 * return. If the arch doesn't have set_direct_map_(), also skip the
+	 * below work.
 	 */
-	if (!deallocate_pages) {
-		vm_unmap_aliases();
+	if (!deallocate_pages || !has_set_direct) {
+		flush_tlb_kernel_range(addr, get_vm_area_size(area));
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
 
@@ -1580,7 +1583,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * reset the direct map permissions to the default.
 	 */
 	set_area_direct_map(area, set_direct_map_invalid_noflush);
-	_vm_unmap_aliases(start, end, 1);
+	flush_tlb_kernel_range(start, end);
 	set_area_direct_map(area, set_direct_map_default_noflush);
 }
 
-- 
2.17.1

