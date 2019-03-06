Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C0EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66C8820663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66C8820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BB308E000D; Wed,  6 Mar 2019 10:51:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693578E0002; Wed,  6 Mar 2019 10:51:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5333E8E000D; Wed,  6 Mar 2019 10:51:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 259E78E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:17 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z198so10229380qkb.15
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=lr5sDzryRlhZMMAhHhPqJXHlWIkKKnsxuIPKEQ27yfs=;
        b=RcK8Afq4bxVGFF0rKVAE+Xw3CwkvU7LCUdNkinZq9j8rIEA1dIGluKqv9JP1K8LgGv
         WwuLrtPZEflCgTJ+gjKAVVJkFzvpA+yNSqFpnnYgQVN+1jAMDRBr9Upoq8Z4Sh5rIdgh
         VngKCuxu/coNWZL/jQElQrq/Tyno6iHp1jmT02K+Wp1PrxS8loZ+X2VHatGzUZ7JGRyt
         uXVltZ3IYN4zOkxZSHRYzeD/F2g3rYuQqqg2P8Ww891bn+lfgBqr4yXiUG6P1Y/oOgYb
         Q/MSAvuUvJLVRLF+86f1eZ/2C6vLMpunrA4P9UmIm1WeF/ym82ltAHaxAU+5iM6TCxjC
         MhqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHd2XrGZsPAIFu4JdkxrDErKLndCYtXsGYgFNwCIJPLWlqqfKb
	olPQxx08BbVyi208E+lTcAs+144TTY6TXQ42zFiFEI64ksjryhWWtxCbXlLxBermnjQLN2A/iCW
	205MsQsGWNkgsuSGIG0jURfgZqF/Ir6VhNRA5WR3l8PhcyOsmK/LC91rflLTFzsLyDQ==
X-Received: by 2002:a0c:86a6:: with SMTP id 35mr6900501qvf.221.1551887476901;
        Wed, 06 Mar 2019 07:51:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqzQpTs/7v4SrW9fsa99a+SXwpOS3uS7cxSaB6GfiXqjCWLgLtzQX7LcO0UZ4JvF0G9jdRyl
X-Received: by 2002:a0c:86a6:: with SMTP id 35mr6900425qvf.221.1551887475668;
        Wed, 06 Mar 2019 07:51:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887475; cv=none;
        d=google.com; s=arc-20160816;
        b=wGrMuWdZFyYT9fZExzxk732ZBtV/2x4c0MTeoB6cVsv2JVsQ1dQMhtW8aTforRSs/b
         2whvzU8Lp++8z4TStjN1so0R1MRCkfU+Clz/uWDzxCibXXSwIG2ce5qp8PgypVSwVbYV
         myDv5KLSHEk2ny9OHsm4kSyvZg5jUFmwlqDWWHAQ35mtxVN/+gbfbaP0pCBzlEjHwyxt
         aVT5/Y3moIVrfRhvIE3CGnH8D2SPKipsGsdQWJOK/4qaBBCgebZM4EWKxTULMyRXeeRa
         +TT3K7nNxKWVnQYC798Z4lGTeJoNDfRIEv/a7+VZupU7AYdAVeFok9yT69ZhRyr7atQZ
         uJ9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=lr5sDzryRlhZMMAhHhPqJXHlWIkKKnsxuIPKEQ27yfs=;
        b=RTbidbWGntUcmeQQfBziotslODKL4wO2Mr4tDVH6n5aVkC5IkU7z+0bqmVuPj8Hq/O
         RiIhIBnhjMpCF+ibU1nxOr4PJDxzNNtlB9BcQb38Vyez+Ib80nQvSrlgZ1vZ3F42fPMl
         AymD2H9OKuWsoWR4r/06PclhV6yy08z3iTwwO7rTAXNqBLJyxRkHZrIUXV5ICWulZmW4
         4wFxelACopTbn9HqmfY7KXCL0AfEz9keFONHeJRFLSSnpw6lJvtr11vWkqg6vbAHlo7W
         kFPL2JBQwGf83iHneXKtePtLo5lpUp/A6eQCAGbDRI8jW6pomzzNyuTNj6Fgy428CgZL
         64ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si774030qve.33.2019.03.06.07.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:15 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CFCDCC05D3E4;
	Wed,  6 Mar 2019 15:51:14 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9A88C1001DFD;
	Wed,  6 Mar 2019 15:51:11 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
Date: Wed,  6 Mar 2019 10:50:44 -0500
Message-Id: <20190306155048.12868-3-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 06 Mar 2019 15:51:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables the kernel to scan the per cpu array
which carries head pages from the buddy free list of order
FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
guest_free_page_hinting().
guest_free_page_hinting() scans the entire per cpu array by
acquiring a zone lock corresponding to the pages which are
being scanned. If the page is still free and present in the
buddy it tries to isolate the page and adds it to a
dynamically allocated array.

Once this scanning process is complete and if there are any
isolated pages added to the dynamically allocated array
guest_free_page_report() is invoked. However, before this the
per-cpu array index is reset so that it can continue capturing
the pages from buddy free list.

In this patch guest_free_page_report() simply releases the pages back
to the buddy by using __free_one_page()

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 include/linux/page_hinting.h |   5 ++
 mm/page_alloc.c              |   2 +-
 virt/kvm/page_hinting.c      | 154 +++++++++++++++++++++++++++++++++++
 3 files changed, 160 insertions(+), 1 deletion(-)

diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
index 90254c582789..d554a2581826 100644
--- a/include/linux/page_hinting.h
+++ b/include/linux/page_hinting.h
@@ -13,3 +13,8 @@
 
 void guest_free_page_enqueue(struct page *page, int order);
 void guest_free_page_try_hinting(void);
+extern int __isolate_free_page(struct page *page, unsigned int order);
+extern void __free_one_page(struct page *page, unsigned long pfn,
+			    struct zone *zone, unsigned int order,
+			    int migratetype);
+void release_buddy_pages(void *obj_to_free, int entries);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 684d047f33ee..d38b7eea207b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * -- nyc
  */
 
-static inline void __free_one_page(struct page *page,
+inline void __free_one_page(struct page *page,
 		unsigned long pfn,
 		struct zone *zone, unsigned int order,
 		int migratetype)
diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
index 48b4b5e796b0..9885b372b5a9 100644
--- a/virt/kvm/page_hinting.c
+++ b/virt/kvm/page_hinting.c
@@ -1,5 +1,9 @@
 #include <linux/mm.h>
 #include <linux/page_hinting.h>
+#include <linux/page_ref.h>
+#include <linux/kvm_host.h>
+#include <linux/kernel.h>
+#include <linux/sort.h>
 
 /*
  * struct guest_free_pages- holds array of guest freed PFN's along with an
@@ -16,6 +20,54 @@ struct guest_free_pages {
 
 DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
 
+/*
+ * struct guest_isolated_pages- holds the buddy isolated pages which are
+ * supposed to be freed by the host.
+ * @pfn: page frame number for the isolated page.
+ * @order: order of the isolated page.
+ */
+struct guest_isolated_pages {
+	unsigned long pfn;
+	unsigned int order;
+};
+
+void release_buddy_pages(void *obj_to_free, int entries)
+{
+	int i = 0;
+	int mt = 0;
+	struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
+
+	while (i < entries) {
+		struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
+
+		mt = get_pageblock_migratetype(page);
+		__free_one_page(page, page_to_pfn(page), page_zone(page),
+				isolated_pages_obj[i].order, mt);
+		i++;
+	}
+	kfree(isolated_pages_obj);
+}
+
+void guest_free_page_report(struct guest_isolated_pages *isolated_pages_obj,
+			    int entries)
+{
+	release_buddy_pages(isolated_pages_obj, entries);
+}
+
+static int sort_zonenum(const void *a1, const void *b1)
+{
+	const unsigned long *a = a1;
+	const unsigned long *b = b1;
+
+	if (page_zonenum(pfn_to_page(a[0])) > page_zonenum(pfn_to_page(b[0])))
+		return 1;
+
+	if (page_zonenum(pfn_to_page(a[0])) < page_zonenum(pfn_to_page(b[0])))
+		return -1;
+
+	return 0;
+}
+
 struct page *get_buddy_page(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
@@ -33,9 +85,111 @@ struct page *get_buddy_page(struct page *page)
 static void guest_free_page_hinting(void)
 {
 	struct guest_free_pages *hinting_obj = &get_cpu_var(free_pages_obj);
+	struct guest_isolated_pages *isolated_pages_obj;
+	int idx = 0, ret = 0;
+	struct zone *zone_cur, *zone_prev;
+	unsigned long flags = 0;
+	int hyp_idx = 0;
+	int free_pages_idx = hinting_obj->free_pages_idx;
+
+	isolated_pages_obj = kmalloc(MAX_FGPT_ENTRIES *
+			sizeof(struct guest_isolated_pages), GFP_KERNEL);
+	if (!isolated_pages_obj) {
+		hinting_obj->free_pages_idx = 0;
+		put_cpu_var(hinting_obj);
+		return;
+		/* return some logical error here*/
+	}
+
+	sort(hinting_obj->free_page_arr, free_pages_idx,
+	     sizeof(unsigned long), sort_zonenum, NULL);
+
+	while (idx < free_pages_idx) {
+		unsigned long pfn = hinting_obj->free_page_arr[idx];
+		unsigned long pfn_end = hinting_obj->free_page_arr[idx] +
+			(1 << FREE_PAGE_HINTING_MIN_ORDER) - 1;
+
+		zone_cur = page_zone(pfn_to_page(pfn));
+		if (idx == 0) {
+			zone_prev = zone_cur;
+			spin_lock_irqsave(&zone_cur->lock, flags);
+		} else if (zone_prev != zone_cur) {
+			spin_unlock_irqrestore(&zone_prev->lock, flags);
+			spin_lock_irqsave(&zone_cur->lock, flags);
+			zone_prev = zone_cur;
+		}
+
+		while (pfn <= pfn_end) {
+			struct page *page = pfn_to_page(pfn);
+			struct page *buddy_page = NULL;
+
+			if (PageCompound(page)) {
+				struct page *head_page = compound_head(page);
+				unsigned long head_pfn = page_to_pfn(head_page);
+				unsigned int alloc_pages =
+					1 << compound_order(head_page);
+
+				pfn = head_pfn + alloc_pages;
+				continue;
+			}
+
+			if (page_ref_count(page)) {
+				pfn++;
+				continue;
+			}
+
+			if (PageBuddy(page) && page_private(page) >=
+			    FREE_PAGE_HINTING_MIN_ORDER) {
+				int buddy_order = page_private(page);
+
+				ret = __isolate_free_page(page, buddy_order);
+				if (ret) {
+					isolated_pages_obj[hyp_idx].pfn = pfn;
+					isolated_pages_obj[hyp_idx].order =
+								buddy_order;
+					hyp_idx += 1;
+				}
+				pfn = pfn + (1 << buddy_order);
+				continue;
+			}
+
+			buddy_page = get_buddy_page(page);
+			if (buddy_page && page_private(buddy_page) >=
+			    FREE_PAGE_HINTING_MIN_ORDER) {
+				int buddy_order = page_private(buddy_page);
+
+				ret = __isolate_free_page(buddy_page,
+							  buddy_order);
+				if (ret) {
+					unsigned long buddy_pfn =
+						page_to_pfn(buddy_page);
+
+					isolated_pages_obj[hyp_idx].pfn =
+								buddy_pfn;
+					isolated_pages_obj[hyp_idx].order =
+								buddy_order;
+					hyp_idx += 1;
+				}
+				pfn = page_to_pfn(buddy_page) +
+					(1 << buddy_order);
+				continue;
+			}
+			pfn++;
+		}
+		hinting_obj->free_page_arr[idx] = 0;
+		idx++;
+		if (idx == free_pages_idx)
+			spin_unlock_irqrestore(&zone_cur->lock, flags);
+	}
 
 	hinting_obj->free_pages_idx = 0;
 	put_cpu_var(hinting_obj);
+
+	if (hyp_idx > 0)
+		guest_free_page_report(isolated_pages_obj, hyp_idx);
+	else
+		kfree(isolated_pages_obj);
+		/* return some logical error here*/
 }
 
 int if_exist(struct page *page)
-- 
2.17.2

