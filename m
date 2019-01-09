Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32416C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E124C214C6
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:40:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E124C214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4CAC8E0038; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FAAB8E00A1; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C3578E0038; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4138E00A1
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:40:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so3167790edm.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:40:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8Q1tkEMTNRczIaBkNm7NIRCjVZixCbZcVfNzV8TIEeg=;
        b=k+2wujrikKWgS0iWvn2Jnl8Y7pAoQ3ZNr28ZWd1LJPCfJ31F7U4zklmoP5gOHFWp8K
         wuWxYTbcqwAPiWfkdYs3xMmvtzBX6QluFSpm+BZo4hu516DKdfMW+prg2mvrb5U9k18O
         F46ExHzY7kQczHsukDzMyl1yl0rMBuc0L+xAbj6tKjL9lLcnkAMj4Opx+FBl4z02R8O0
         kgGtPSaCHMoGU/lONhcniLulT9TcNxy/1FBtWQDge6zfthjqES7OckaG8V8DI6cQmJL6
         2WLYC3UCoKBJ3g3nQdYOzKNouZabCpUjC67RHzomTMMvXe5QiZH4mXQGCyuiQNO/JFib
         N2sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: AJcUukfGrr72/gsy4F1lbXBxuus2GhZiqxbufoUQfFUQyorD/BgEAkWN
	AYqAKuvAoDjMoqxjz8phfbcQJtVbggjgdrt1fv2D//l812JAbAeuCgeFj2Ix+rCkKmwOMi8AUpA
	7RM8RCmnN+CdbryoAiMmo9GobiPMA0ZEiScySASUz8+VCzEo8k3Zy1CAmKU4XvdGqXA==
X-Received: by 2002:aa7:ccc8:: with SMTP id y8mr6283458edt.118.1547052039637;
        Wed, 09 Jan 2019 08:40:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN70G/+cA0sIue0/DSI0PnlO+i76lxy1MIDKp50vaBe4BjJOGtw7KdyvTf0BxyuyZjiIYj5i
X-Received: by 2002:aa7:ccc8:: with SMTP id y8mr6283379edt.118.1547052038087;
        Wed, 09 Jan 2019 08:40:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547052038; cv=none;
        d=google.com; s=arc-20160816;
        b=lni2e1bKAtdLqzubK9pyDaa1a7rZTtReHPHb7dQlXYF/ah/bm0R2gN0uRhfAt+ftA0
         neugBH2biYVYFIAYJ+QK4QSXbMmbcAQQbcfPuDImNwQDGHqhZozj2A4anLZjT9lk9FPh
         72+1hCf7yoH6q90+3yg5MPdKe7Ex3QSg1qPMtbyFIk7QDhv7tlhKaHSMpgS3ePrxkmTA
         3eq/te1TSiM4R2BwTZA1nqqyhPHNsZPSdJvrbvNmUHCs8h8b2rVJNUeYZxR22F/a3Zpl
         V3t8IxAIc+uxyHtCfVQftkNOdSBL28SQtEw9asTvQjjJnmixHiKQiCoXsJdS6SN0Q3iY
         DFag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8Q1tkEMTNRczIaBkNm7NIRCjVZixCbZcVfNzV8TIEeg=;
        b=HnCpjjwspRlfFgvUW8fBKIB6LJsjOpfRTm4N1kM8Q0uYBIbM1PAiBTfBjpGGlW9A87
         h49POxxZJB15u9AUeomIkdksBaiv2lmqezyKTeUmFGkUuzWsbWSY0wYMUar4Ap8mUVMK
         KyAbJ2Q7/0TZgs0URZeISB0bUaxDNAY2/4CybKXgbJZYP5GXt2uOyheGRntUDzfUuYLq
         9/SlRH335xTpUDZMWCAQFbnC9rg01lSeAwBcrGEqBzVSPZ+l/8/HgU4A59qXw2fi3y9+
         eYC1A0uSKO2pJT+6BY266REybfzXZfH962A7JcWX6BiGb0USBqrZlrUBOVfUp6rOv2d9
         rIqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q24-v6si368444ejb.146.2019.01.09.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:40:38 -0800 (PST)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A926DAF82;
	Wed,  9 Jan 2019 16:40:37 +0000 (UTC)
From: Roman Penyaev <rpenyaev@suse.de>
To: 
Cc: Roman Penyaev <rpenyaev@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH 03/15] mm/vmalloc: introduce new vrealloc() call and its subsidiary reach analog
Date: Wed,  9 Jan 2019 17:40:13 +0100
Message-Id: <20190109164025.24554-4-rpenyaev@suse.de>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190109164025.24554-1-rpenyaev@suse.de>
References: <20190109164025.24554-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190109164013.PdIO-9tQiMkSDxCtgIsc2zVV1CgyV0gWLdPf5fbiaiU@z>

Function changes the size of virtual contigues memory, previously
allocated by vmalloc().

vrealloc() under the hood does the following:

 1. allocates new vm area based on the alignment of the old one.
 2. allocates pages array for a new vm area.
 3. fill in ->pages array taking pages from the old area increasing
    page ref.

    In case of virtual size grow (old_size < new_size) new pages
    for a new area are allocated using gfp passed by the caller.

Basically vrealloc() repeats glibc realloc() with only one big difference:
old area is not freed, i.e. caller is responsible for calling vfree() in
case of successfull reallocation.

Why vfree() is not called for old area directly from vrealloc()?  Because
sometimes it is better just to have transaction-like reallocation for
several pointers and reallocate all at once, i.e.:

  new_p1 = vrealloc(p1, new_len);
  new_p2 = vrealloc(p2, new_len);
  if (!new_p1 || !new_p2) {
	vfree(new_p1);
	vfree(new_p2);
	return -ENOMEM;
  }

  vfree(p1);
  vfree(p2);

  p1 = new_p1;
  p2 = new_p2;

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/vmalloc.h |   3 ++
 mm/vmalloc.c            | 106 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 78210aa0bb43..2902faf26c4f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -72,6 +72,7 @@ static inline void vmalloc_init(void)
 
 extern void *vmalloc(unsigned long size);
 extern void *vzalloc(unsigned long size);
+extern void *vrealloc(void *old_addr, unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
 extern void *vzalloc_node(unsigned long size, int node);
@@ -83,6 +84,8 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller);
+extern void *__vrealloc_node(void *old_addr, unsigned long size, gfp_t gfp_mask,
+			     pgprot_t prot, int node, const void *caller);
 #ifndef CONFIG_MMU
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 static inline void *__vmalloc_node_flags_caller(unsigned long size, int node,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ad6cd807f6db..94cc99e780c7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1889,6 +1889,112 @@ void *vzalloc(unsigned long size)
 }
 EXPORT_SYMBOL(vzalloc);
 
+void *__vrealloc_node(void *old_addr, unsigned long size, gfp_t gfp_mask,
+		      pgprot_t prot, int node, const void *caller)
+{
+	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
+	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?	0 :
+					__GFP_HIGHMEM;
+	struct vm_struct *old_area, *area;
+	struct page *page;
+
+	unsigned int i;
+
+	old_area = find_vm_area(old_addr);
+	if (!old_area)
+		return NULL;
+
+	if (!(old_area->flags & VM_ALLOC))
+		return NULL;
+
+	size = PAGE_ALIGN(size);
+	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
+		return NULL;
+
+	if (get_vm_area_size(old_area) == size)
+		return old_addr;
+
+	area = __get_vm_area_node(size, old_area->alignment, VM_UNINITIALIZED |
+				  old_area->flags, VMALLOC_START, VMALLOC_END,
+				  node, gfp_mask, caller);
+	if (!area)
+		return NULL;
+
+	if (alloc_vm_area_array(area, gfp_mask, node)) {
+		__vunmap(area->addr, 0);
+		return NULL;
+	}
+
+	for (i = 0; i < area->nr_pages; i++) {
+		if (i < old_area->nr_pages) {
+			/* Take a page from old area and increase a ref */
+
+			page = old_area->pages[i];
+			area->pages[i] = page;
+			get_page(page);
+		} else {
+			/* Allocate more pages in case of grow */
+
+			page = alloc_page(alloc_mask|highmem_mask);
+			if (unlikely(!page)) {
+				/*
+				 * Successfully allocated i pages, free
+				 * them in __vunmap()
+				 */
+				area->nr_pages = i;
+				goto fail;
+			}
+
+			area->pages[i] = page;
+			if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
+				cond_resched();
+		}
+	}
+	if (map_vm_area(area, prot, area->pages))
+		goto fail;
+
+	/* New area is fully ready */
+	clear_vm_uninitialized_flag(area);
+	kmemleak_vmalloc(area, size, gfp_mask);
+
+	return area->addr;
+
+fail:
+	warn_alloc(gfp_mask, NULL, "vrealloc: allocation failure");
+	__vfree(area->addr);
+
+	return NULL;
+}
+EXPORT_SYMBOL(__vrealloc_node);
+
+/**
+ *	vrealloc - reallocate virtually contiguous memory with zero fill
+ *	@old_addr:	old virtual address
+ *	@size:		new size
+ *
+ *	Allocate additional pages to cover new @size from the page level
+ *	allocator if memory grows. Then pages are mapped into a new
+ *	contiguous kernel virtual space, previous area is NOT freed.
+ *
+ *	Do not forget to call vfree() passing old address.  But careful,
+ *	calling vfree() from interrupt will cause vfree_deferred() call,
+ *	which in its turn uses freed address as a temporal pointer for a
+ *	llist element, i.e. memory will be corrupted.
+ *
+ *	If new size is equal to the old size - old pointer is returned.
+ *	I.e. appropriate check should be made before calling vfree().
+ *
+ *	For tight control over page level allocator and protection flags
+ *	use __vrealloc_node() instead.
+ */
+void *vrealloc(void *old_addr, unsigned long size)
+{
+	return __vrealloc_node(old_addr, size, GFP_KERNEL | __GFP_ZERO,
+			       PAGE_KERNEL, NUMA_NO_NODE,
+			       __builtin_return_address(0));
+}
+EXPORT_SYMBOL(vrealloc);
+
 /**
  * vmalloc_user - allocate zeroed virtually contiguous memory for userspace
  * @size: allocation size
-- 
2.19.1

