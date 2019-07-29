Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE522C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FC3E20679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:24:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FC3E20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 193BA8E0003; Mon, 29 Jul 2019 19:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11D0B8E0002; Mon, 29 Jul 2019 19:24:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26888E0003; Mon, 29 Jul 2019 19:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4E8C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:24:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so39229966pgc.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=8vQx2SaIluZlxmWU43Ri4IQibJqv9AScVfwsxvrcGOE=;
        b=FHlnuztCEIQYuspFz/88delJGtN+5qYSGXuN5+eMFpZrjpxfN2eaca58Fhk8uA+N+8
         gFYwe8LBYlVUqGR0HWqsQlFAvnXMzNspSuX6ZUmIE4p1hjOVToFdsdunsDtR/oE9xQhq
         7iEJmwzqklFF5OOuvqMA4bCrVVvHqKkmZqFwNiffGRY6+yxHQEMVX04uAsRc3oXa9uec
         Q/3xOXjqWJEiwum2+u2/5w22DOJfKLIyEkx7g8h6AjEtYO78J4sVyazescCjPtkKSVac
         L8uJlWjMzSMVqLywuy+rGDF1cSEkyJl9ptv8DC+n2c3cAU1xZZ+cMBSKIfHcs1zD+vkc
         fxkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVroLLyqazz31AI/NBxyPDiO6JFjVMCmSvzTXCwJTY5dvLRwx24
	slUAeiffWp/2QGed5fBbsFIKEqqm4n2cxRjpUjLqnPnW13MWnDWE1qp6ijD9N+pDwA1ApgaQMh7
	uTb8C7wurnTwzBvsWbwDhbkRwrU1f1Ai5Eysy5XyLWrmbN/r7TTL2aauGgRjPtyNXZQ==
X-Received: by 2002:a63:d34c:: with SMTP id u12mr91901355pgi.114.1564442672207;
        Mon, 29 Jul 2019 16:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpt9PXY7iZEzq4m/3Ps0q0OfXQEteBlfyNzoKRBMPpiqoQ4xFjMo8T39SHCzdRDd7N7H7i
X-Received: by 2002:a63:d34c:: with SMTP id u12mr91901310pgi.114.1564442671388;
        Mon, 29 Jul 2019 16:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442671; cv=none;
        d=google.com; s=arc-20160816;
        b=gJ6XUIutD74xXncgewHfnR2bPy4+LwtG2uS8i9ZoAZ3gxjJN5m+2wi96WWhEEvt6EK
         p5+yBNsxOwW+ztBAEGG4C9C6BmbOOG+GpdNTl8s409CEavtNysAX7UbvKRcVZzecmuZj
         0QDUf/JzRhBoM56NwsHYINwasGCWmb9SVj7G+GOKRuOEqkro0cZzTJMGv6hr/ajWLXTB
         9DkesxC0BNDtvGFTSxncnhOgtR0IAhoyYYHJJ/eKBjHLTMHz9uANUD9yHm2xvn5qY+eI
         sQF6ELPhFddODSNsxDI7hDPxD5tm5BGyYXf/Q1+1HGEbIYu4+zVCJXaidp/jcSGKvSjM
         CpSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=8vQx2SaIluZlxmWU43Ri4IQibJqv9AScVfwsxvrcGOE=;
        b=mNSegnB9d+d9XQ/gly0Xu5cdCcrP9J2SQuFq/WbQGw4O3CLuYEfAMUBqJA7f065yOk
         IRX+Du/VPKTaTsFq0CXH9PhtwmNEDu4XdIjDcGPKm5ShCQbyZI9XMxz4veSNOBeR02be
         p8yEa/dhf2NjMS/H/k+wUXlZ0u5ts0i39R8XdxpcDU4gRIlbDCZnbFV0nHH0+AEXrqqd
         gXJSDEWpnSPvumLu+dCtU/1qhiPub4G1Sb/GG2JWGz3ZWwI+w4m9RNyAPcEKXQTVw0Cg
         iWfE8gCCWsD3kWQdbHi38f3tdmfluTuCZ2ve6c7F8VeMm7m4rad4+8Dm4WJAKv+0uxuo
         X5kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h9si26526092pgp.435.2019.07.29.16.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:24:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jul 2019 16:24:30 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,324,1559545200"; 
   d="scan'208";a="346810144"
Received: from skuppusw-desk.jf.intel.com ([10.54.74.33])
  by orsmga005.jf.intel.com with ESMTP; 29 Jul 2019 16:24:30 -0700
From: sathyanarayanan.kuppuswamy@linux.intel.com
To: akpm@linux-foundation.org,
	urezki@gmail.com
Cc: dave.hansen@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	sathyanarayanan.kuppuswamy@linux.intel.com
Subject: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search criteria
Date: Mon, 29 Jul 2019 16:21:39 -0700
Message-Id: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>

Recent changes to the vmalloc code by Commit 68ad4a330433
("mm/vmalloc.c: keep track of free blocks for vmap allocation") can
cause spurious percpu allocation failures. These, in turn, can result in
panic()s in the slub code. One such possible panic was reported by
Dave Hansen in following link https://lkml.org/lkml/2019/6/19/939.
Another related panic observed is,

 RIP: 0033:0x7f46f7441b9b
 Call Trace:
  dump_stack+0x61/0x80
  pcpu_alloc.cold.30+0x22/0x4f
  mem_cgroup_css_alloc+0x110/0x650
  cgroup_apply_control_enable+0x133/0x330
  cgroup_mkdir+0x41b/0x500
  kernfs_iop_mkdir+0x5a/0x90
  vfs_mkdir+0x102/0x1b0
  do_mkdirat+0x7d/0xf0
  do_syscall_64+0x5b/0x180
  entry_SYSCALL_64_after_hwframe+0x44/0xa9

VMALLOC memory manager divides the entire VMALLOC space (VMALLOC_START
to VMALLOC_END) into multiple VM areas (struct vm_areas), and it mainly
uses two lists (vmap_area_list & free_vmap_area_list) to track the used
and free VM areas in VMALLOC space. And pcpu_get_vm_areas(offsets[],
sizes[], nr_vms, align) function is used for allocating congruent VM
areas for percpu memory allocator. In order to not conflict with VMALLOC
users, pcpu_get_vm_areas allocates VM areas near the end of the VMALLOC
space. So the search for free vm_area for the given requirement starts
near VMALLOC_END and moves upwards towards VMALLOC_START.

Prior to commit 68ad4a330433, the search for free vm_area in
pcpu_get_vm_areas() involves following two main steps.

Step 1:
    Find a aligned "base" adress near VMALLOC_END.
    va = free vm area near VMALLOC_END
Step 2:
    Loop through number of requested vm_areas and check,
        Step 2.1:
           if (base < VMALLOC_START)
              1. fail with error
        Step 2.2:
           // end is offsets[area] + sizes[area]
           if (base + end > va->vm_end)
               1. Move the base downwards and repeat Step 2
        Step 2.3:
           if (base + start < va->vm_start)
              1. Move to previous free vm_area node, find aligned
                 base address and repeat Step 2

But Commit 68ad4a330433 removed Step 2.2 and modified Step 2.3 as below:

        Step 2.3:
           if (base + start < va->vm_start || base + end > va->vm_end)
              1. Move to previous free vm_area node, find aligned
                 base address and repeat Step 2

Above change is the root cause of spurious percpu memory allocation
failures. For example, consider a case where a relatively large vm_area
(~ 30 TB) was ignored in free vm_area search because it did not pass the
base + end  < vm->vm_end boundary check. Ignoring such large free
vm_area's would lead to not finding free vm_area within boundary of
VMALLOC_start to VMALLOC_END which in turn leads to allocation failures.

So modify the search algorithm to include Step 2.2.

Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
Signed-off-by: Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>
---
 mm/vmalloc.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..1faa45a38c08 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -3269,10 +3269,20 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		if (va == NULL)
 			goto overflow;
 
+		/*
+		 * If required width exeeds current VA block, move
+		 * base downwards and then recheck.
+		 */
+		if (base + end > va->va_end) {
+			base = pvm_determine_end_from_reverse(&va, align) - end;
+			term_area = area;
+			continue;
+		}
+
 		/*
 		 * If this VA does not fit, move base downwards and recheck.
 		 */
-		if (base + start < va->va_start || base + end > va->va_end) {
+		if (base + start < va->va_start) {
 			va = node_to_va(rb_prev(&va->rb_node));
 			base = pvm_determine_end_from_reverse(&va, align) - end;
 			term_area = area;
-- 
2.21.0

