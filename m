Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95705C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AAD720850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nS5cBo7Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AAD720850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE7AE6B0006; Tue, 14 May 2019 19:51:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D72506B0007; Tue, 14 May 2019 19:51:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B74396B0008; Tue, 14 May 2019 19:51:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 802586B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 19:51:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h14so532835pgn.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=O7eBrs0cmRrFsnBiCjlPOjGDWGcxOa5jMCEdxURKIS8=;
        b=kU97RrLbPqGsTv/hmR21MWnQIp2vzGNlFKz9Pm4eyRFX7Dg7utt1q6brIkH+dzOzZe
         vXpy+i1j5tFI7O/ihXArffZvSFAiNUtl14F1QFZt6Ry2EyDxoM1cQcyN3a81GmNuTjII
         faxl4ET4uNpA6Y9LVOaErVmkXLqeiGSiTs4YSaQq9aUHZHagkA+XwbT5+RNqz3k1SM/p
         g9mCsHlOHVpZtD2LQruOJydm4fqKuNg6svpML7symJDvNx7J9+zmMQJV2cAny9n4gWnp
         9PDxCWM3mJoHVGzmxDKFdv2xIhoux7a3wPIUJbIGERq5A4+FtMKb91zT5O6WxE4esqNS
         XSJw==
X-Gm-Message-State: APjAAAW/BDOsUU7avUmMb9zO35qgGHcyHIbnwKL7QoAg5nfMkFh6iSH0
	Mqif8WHHzEBqv+uHqIOPRkhg6dsiT1Ho5noxMoe7SeQcbQbJ/UETfaKaudWkJp7buJZY3939El6
	GvOewW5k47kucILXuqvamIPeEYzSG5B5oShF/HvdHnmOF7S5APthPRGwiNlf8Ku6bEA==
X-Received: by 2002:a63:555a:: with SMTP id f26mr41304608pgm.197.1557877881005;
        Tue, 14 May 2019 16:51:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ0AH+pD7LisABBa7O4uB065+t/QIJJ1nGUylBQamvCbdibEx3NckAo5xzK+VM7LBVKuIv
X-Received: by 2002:a63:555a:: with SMTP id f26mr41304465pgm.197.1557877878452;
        Tue, 14 May 2019 16:51:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557877878; cv=none;
        d=google.com; s=arc-20160816;
        b=a47ydmEkDR3XOJ5Xu93eTdwZV2LCczAvYCvMfYZyO1E/t74ND3xgX9ziSMvI6OdSb7
         SoqPhXqYzPzhz6CcCcE3ii7DGlOzhInxPDGULO37fOlbGew6sfv3rw0DmDuNKxAzi9px
         tsNQqcd0tuFqA4xj93etGOaBvwT+GzKYWtaoW6e8XNaydTlpBHIXKeIyk9KwKBVcRpTU
         Qjmbrfz7CKd7VEkWa2rMSXlbXvBnBsF9gyUAz9/EBZSBkmbcx0G5gDzJg/qG61sJW30Q
         no4rMIGLjCkNs8EVymDxB6dZrMFt5Y5YZT8LS7rPB2O3e26qZSILlJliEysnkuyH/BFj
         DPmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=O7eBrs0cmRrFsnBiCjlPOjGDWGcxOa5jMCEdxURKIS8=;
        b=pvDSNWpxATDdLSXdi1vLBHSxFSbd7zvmaFmGv8pelp//0bZoh82D7CgIUjI0oRJxJs
         NKsj3hti2SpoTZxwCU31FxxSu7bjTUHamCubzU4HyLzC3wZfZ7nObf2uk0qFgA5fZpvL
         42/VqJybksNPvLnGWkhyvh8OBcB/OlW6Gd9ST+RClzFFniW6cgd7fuPu0lyn+KCcbjAq
         N8pehEg05k+EiVVJBHpsgjxL3LrJBHBU5Qw23MIATYExRMm2FsUkOWpdVA7lvz6WW/ln
         V1SEVV6/UKcEmAbSQt2Ds5Ubc7KzjYrhPBNsbuTJAASjg28/+vFGKnvKBv1M4UXZlNNG
         A12g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nS5cBo7Z;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x141si298963pgx.1.2019.05.14.16.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 16:51:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nS5cBo7Z;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ENhWmx001629
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=O7eBrs0cmRrFsnBiCjlPOjGDWGcxOa5jMCEdxURKIS8=;
 b=nS5cBo7ZXbIbW8vKlx1+2CYmEYbH/oukpPAEDPubpR6q6i6Kmz3pt45EkxkZ7GSqbzZu
 P8S1VqFOtaBkglV9zxTsxNw/5rFS0/BS6JglBD+487wPVRGDPfweYpl1cbATdH47RDSn
 PwPBysBeuv/hXDcbOdZ1G0FUwCEP1g+e2jw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg3k1gvtn-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:17 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 14 May 2019 16:51:16 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id E085912084F48; Tue, 14 May 2019 16:51:15 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin
	<guro@fb.com>,
        Matthew Wilcox <willy@infradead.org>,
        Vlastimil Babka
	<vbabka@suse.cz>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH] mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
Date: Tue, 14 May 2019 16:51:10 -0700
Message-ID: <20190514235111.2817276-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__vunmap() calls find_vm_area() twice without an obvious reason:
first directly to get the area pointer, second indirectly by calling
vm_remove_mappings()->remove_vm_area(), which is again searching
for the area.

To remove this redundancy, let's split remove_vm_area() into
__remove_vm_area(struct vmap_area *), which performs the actual area
removal, and remove_vm_area(const void *addr) wrapper, which can
be used everywhere, where it has been used before. Let's pass
a pointer to the vm_area instead of vm_struct to vm_remove_mappings(),
so it can pass it to __remove_vm_area() and avoid the redundant area
lookup.

On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
of 4-pages vmalloc blocks.

Perf report before:
  29.44%  cat      [kernel.kallsyms]  [k] free_unref_page
  11.88%  cat      [kernel.kallsyms]  [k] find_vmap_area
   9.28%  cat      [kernel.kallsyms]  [k] __free_pages
   7.44%  cat      [kernel.kallsyms]  [k] __slab_free
   7.28%  cat      [kernel.kallsyms]  [k] vunmap_page_range
   4.56%  cat      [kernel.kallsyms]  [k] __vunmap
   3.64%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
   3.04%  cat      [kernel.kallsyms]  [k] __free_vmap_area

Perf report after:
  32.41%  cat      [kernel.kallsyms]  [k] free_unref_page
   7.79%  cat      [kernel.kallsyms]  [k] find_vmap_area
   7.40%  cat      [kernel.kallsyms]  [k] __slab_free
   7.31%  cat      [kernel.kallsyms]  [k] vunmap_page_range
   6.84%  cat      [kernel.kallsyms]  [k] __free_pages
   6.01%  cat      [kernel.kallsyms]  [k] __vunmap
   3.98%  cat      [kernel.kallsyms]  [k] smp_call_function_single
   3.81%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
   2.77%  cat      [kernel.kallsyms]  [k] __free_vmap_area

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmalloc.c | 52 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 23 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..8d4907865614 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2075,6 +2075,22 @@ struct vm_struct *find_vm_area(const void *addr)
 	return NULL;
 }
 
+static struct vm_struct *__remove_vm_area(struct vmap_area *va)
+{
+	struct vm_struct *vm = va->vm;
+
+	spin_lock(&vmap_area_lock);
+	va->vm = NULL;
+	va->flags &= ~VM_VM_AREA;
+	va->flags |= VM_LAZY_FREE;
+	spin_unlock(&vmap_area_lock);
+
+	kasan_free_shadow(vm);
+	free_unmap_vmap_area(va);
+
+	return vm;
+}
+
 /**
  * remove_vm_area - find and remove a continuous kernel virtual area
  * @addr:	    base address
@@ -2087,26 +2103,14 @@ struct vm_struct *find_vm_area(const void *addr)
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
+	struct vm_struct *vm = NULL;
 	struct vmap_area *va;
 
-	might_sleep();
-
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
-		struct vm_struct *vm = va->vm;
-
-		spin_lock(&vmap_area_lock);
-		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
-		spin_unlock(&vmap_area_lock);
-
-		kasan_free_shadow(vm);
-		free_unmap_vmap_area(va);
+	if (va && va->flags & VM_VM_AREA)
+		vm = __remove_vm_area(va);
 
-		return vm;
-	}
-	return NULL;
+	return vm;
 }
 
 static inline void set_area_direct_map(const struct vm_struct *area,
@@ -2119,9 +2123,10 @@ static inline void set_area_direct_map(const struct vm_struct *area,
 			set_direct_map(area->pages[i]);
 }
 
-/* Handle removing and resetting vm mappings related to the vm_struct. */
-static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
+/* Handle removing and resetting vm mappings related to the va->vm vm_struct. */
+static void vm_remove_mappings(struct vmap_area *va, int deallocate_pages)
 {
+	struct vm_struct *area = va->vm;
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long start = ULONG_MAX, end = 0;
 	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
@@ -2138,7 +2143,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 		set_memory_rw(addr, area->nr_pages);
 	}
 
-	remove_vm_area(area->addr);
+	__remove_vm_area(va);
 
 	/* If this is not VM_FLUSH_RESET_PERMS memory, no need for the below. */
 	if (!flush_reset)
@@ -2178,6 +2183,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
+	struct vmap_area *va;
 
 	if (!addr)
 		return;
@@ -2186,17 +2192,18 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = find_vm_area(addr);
-	if (unlikely(!area)) {
+	va = find_vmap_area((unsigned long)addr);
+	if (unlikely(!va || !(va->flags & VM_VM_AREA))) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
 		return;
 	}
 
+	area = va->vm;
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	vm_remove_mappings(area, deallocate_pages);
+	vm_remove_mappings(va, deallocate_pages);
 
 	if (deallocate_pages) {
 		int i;
@@ -2212,7 +2219,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	}
 
 	kfree(area);
-	return;
 }
 
 static inline void __vfree_deferred(const void *addr)
-- 
2.20.1

