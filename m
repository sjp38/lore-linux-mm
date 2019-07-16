Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D57AC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04D42217D9
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nUXSP/Uj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04D42217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94CF58E000B; Tue, 16 Jul 2019 11:27:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D5738E0006; Tue, 16 Jul 2019 11:27:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750A98E000B; Tue, 16 Jul 2019 11:27:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4B58E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:27:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j22so12538497pfe.11
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:27:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bgQ4RhrQ8SIWyyg74Fp++hfL4YmAINorli25JMx+HLI=;
        b=gQ4/vJ3aGkVtkK4e9qYHuMTbt4zMnP+EU4uWH5LKi3g8yVR3PvcyY+Eeo2uOlO0bVb
         7nqPXp0UseknkLeaMxRntad94V+RUXb/fSrmIk+FsYPJ+GYJNUsiDkzy+S/ey0TPsoM7
         WLbA5Tex7ULnUeJdH0+2YgkrHAjvl+71YhVGGuXYliMe8Xz/B0jeensm8J6TOouI8qzE
         +BSbPpC1tebZ3OtIuPJS7d3GWf0z+rc3taUoTqCoXl+O36Qi37011c2C5QXm7dJDBQn9
         hPcDu2jB6cxiWVDlyR3bRu4UFvZxNwRqr74RZ8rVYSYoO5yAyk060Y30xzH9aPRNaMve
         w90Q==
X-Gm-Message-State: APjAAAUXgoHG7lBMzIixdTWlApi4ZsqCatIDiT+2Ofl2qQHM9neYfG07
	6SciEkVIRFiT83+28UbrXYzOzwOooLjympl4Kq3Po8FZvT5ZArY7LlYxp0aBsSM1F5QHZWiNpBH
	4Y9BKSL7uhVd6bqKKuihcMQD5V1VWMA12BEBiHIZ5+GPTeTkQeitx9fwF4iCRqHXuAQ==
X-Received: by 2002:a17:902:1129:: with SMTP id d38mr36823030pla.220.1563290855769;
        Tue, 16 Jul 2019 08:27:35 -0700 (PDT)
X-Received: by 2002:a17:902:1129:: with SMTP id d38mr36822918pla.220.1563290854943;
        Tue, 16 Jul 2019 08:27:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563290854; cv=none;
        d=google.com; s=arc-20160816;
        b=jIP9DzinNnXmencvxdiP1O0RvRisQf39/PNt5/SYlLURz6/t86ld00pxOHGtk0S3fr
         AL/BG/eujreClvudsBzlvhNnhQFEVwQfrPaXIaP9THkAoMGHg3NMSgaDfZvkCaXTXKgE
         WGCze9nLff2HU3orNoOrv8YfwpfTgbcAtw6RIVutYyMSke52MCII5tRUETft8IaP1l+W
         Rsa0TRcglA01G88DksqtGZtBC4j61/fNeqYP0+1SaeA2QnbeD8/6FT5/Yk1Wl5ajQA3Y
         mYADGeiGzdQqyIiaTm2G7ApQwgK51jMCCoWdggLkm3eT5lPptv3p53VPPo3FmPSB/Xi/
         /hkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bgQ4RhrQ8SIWyyg74Fp++hfL4YmAINorli25JMx+HLI=;
        b=GQGomeTifCATWKQffeMxtpkoKiq8zS1DaIwWMvS4/+rsMD7xAwDN1fSDqMXRdYr3K9
         UArZ0JUtqVSKSjrYSZrxworW5/foKUyFE+D+bwfGGHsvMuQeUO5OgrOZVS70ngvrowrW
         AmhyX7J7Qjry8ebu+df954d29/V8b024Jp22s3GhmS/9NJeXDl5HeB00u48lvNFtdS3k
         2zWJuDkzY6Rh8GKd8n5fIXLCWtEBfSdYEpPKRFvGogvIg29eW/seqomUj0vv8mvh+Edy
         GJ2A9lPSgKgRmCKh5xO4QEbrfu49uRMV/ee3twfpHKaWP7zOKauQ19wU887Siao2UUBz
         lXEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nUXSP/Uj";
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h29sor11023530pgb.21.2019.07.16.08.27.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 08:27:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nUXSP/Uj";
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bgQ4RhrQ8SIWyyg74Fp++hfL4YmAINorli25JMx+HLI=;
        b=nUXSP/UjVBYnWfyc4jlTs17JCc4taGD4zuIrEeMGCF2WE+YIc+d9FCDUzwatPo11yk
         HqC2h0chM/jepzjVBnURfdXKh25VLjxtjN/1Tz5ItpxKTcc9RlV2PUirx3R4MZ9atRtb
         jyoXVRhJYBvPOEsGIB+nAUr7ZtpzCFFjGenYYTgHkBxW9uDiT3Dlx7b4aRQe0wp41XBY
         OuKAUTgog5do0B51QJf+rsa0Ov9x9yXWySU4JP0CceKvQ6e9ynLGij7c7rE5pru5YcFI
         pSbKRZWDZtwkjTvmMa0g1ddOEPzMaYf4yutzX5TuXocttkvGc1syuWblapRkwporyYFy
         6FqA==
X-Google-Smtp-Source: APXvYqxqz7gSTFnrIhbMahLYP5IFtDrisUyyl7qIFt4erygqkCZSe869LC+F7nOwyncv1f9NyEyjzg==
X-Received: by 2002:a63:490a:: with SMTP id w10mr34021506pga.6.1563290854559;
        Tue, 16 Jul 2019 08:27:34 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id h9sm27453651pgk.10.2019.07.16.08.27.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 08:27:34 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v6 2/2] mm/vmalloc: modify struct vmap_area to reduce its size
Date: Tue, 16 Jul 2019 23:26:56 +0800
Message-Id: <20190716152656.12255-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190716152656.12255-1-lpf.vector@gmail.com>
References: <20190716152656.12255-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Objective
---------
The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Description
-----------
1) Pack "subtree_max_size", "vm" and "purge_list".
This is no problem because
    A) "subtree_max_size" is only used when vmap_area is in
       "free" tree
    B) "vm" is only used when vmap_area is in "busy" tree
    C) "purge_list" is only used when vmap_area is in
       vmap_purge_list

2) Eliminate "flags".
Since only one flag VM_VM_AREA is being used, and the same
thing can be done by judging whether "vm" is NULL, then the
"flags" can be eliminated.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 include/linux/vmalloc.h | 20 +++++++++++++-------
 mm/vmalloc.c            | 24 ++++++++++--------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 9b21d0047710..a1334bd18ef1 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -51,15 +51,21 @@ struct vmap_area {
 	unsigned long va_start;
 	unsigned long va_end;
 
-	/*
-	 * Largest available free size in subtree.
-	 */
-	unsigned long subtree_max_size;
-	unsigned long flags;
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
-	struct vm_struct *vm;
+
+	/*
+	 * The following three variables can be packed, because
+	 * a vmap_area object is always one of the three states:
+	 *    1) in "free" tree (root is vmap_area_root)
+	 *    2) in "busy" tree (root is free_vmap_area_root)
+	 *    3) in purge list  (head is vmap_purge_list)
+	 */
+	union {
+		unsigned long subtree_max_size; /* in "free" tree */
+		struct vm_struct *vm;           /* in "busy" tree */
+		struct llist_node purge_list;   /* in purge list */
+	};
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 71d8040a8a0b..2f7edc0466e7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -1115,7 +1114,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	va->va_start = addr;
 	va->va_end = addr + size;
-	va->flags = 0;
+	va->vm = NULL;
 	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 
 	spin_unlock(&vmap_area_lock);
@@ -1922,7 +1921,6 @@ void __init vmalloc_init(void)
 		if (WARN_ON_ONCE(!va))
 			continue;
 
-		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
@@ -2020,7 +2018,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
-	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
 }
 
@@ -2125,10 +2122,10 @@ struct vm_struct *find_vm_area(const void *addr)
 	struct vmap_area *va;
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA)
-		return va->vm;
+	if (!va)
+		return NULL;
 
-	return NULL;
+	return va->vm;
 }
 
 /**
@@ -2149,11 +2146,10 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 	spin_lock(&vmap_area_lock);
 	va = __find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
+	if (va && va->vm) {
 		struct vm_struct *vm = va->vm;
 
 		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -2856,7 +2852,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -2936,7 +2932,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -3466,10 +3462,10 @@ static int s_show(struct seq_file *m, void *p)
 	va = list_entry(p, struct vmap_area, list);
 
 	/*
-	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
-	 * behalf of vmap area is being tear down or vm_map_ram allocation.
+	 * s_show can encounter race with remove_vm_area, !vm on behalf
+	 * of vmap area is being tear down or vm_map_ram allocation.
 	 */
-	if (!(va->flags & VM_VM_AREA)) {
+	if (!va->vm) {
 		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
 			(void *)va->va_start, (void *)va->va_end,
 			va->va_end - va->va_start);
-- 
2.21.0

