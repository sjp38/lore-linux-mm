Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 240DFC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8DBF20879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8DBF20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D29B66B026C; Mon, 25 Mar 2019 10:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB0E86B026D; Mon, 25 Mar 2019 10:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2FC76B026E; Mon, 25 Mar 2019 10:40:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 876686B026C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so10387375qtr.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MqKfHNfNBWpbmcGqXPdVGblL10NQAvDWexvXCgPT6fQ=;
        b=B9zpUdMJjsEWKSYWGcTp0hFyX3vd0C1dkrzjJOubx5bVmiKQt9eXaYJGL5iiurw14k
         959aeqLmJSR53T4B6iNV0y11PguizFxgI6A4hvvcNbIpCtwlBwJM8hzoypNLnUkZgpTn
         p94W5Em0UH5TP5YdYiaOGEXhwLKqK4QhZY4X98/390zVcseH6Dx+hzf2Mw6dUu24Tso1
         jSqMNUj/36BPZUKsMlgDLPsQwGDyawj/Ns2rcPwt8eZMCP2yJ+Sgi3aN3p2Zyfn8RA8c
         0Z/NvY3byKySe3EtOOma9NLgCPAODh0S2rFH85+hGuT45r9dOQhjz5U31thFwqIfCmR+
         PFNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLJeIV9Ljtuwh8Rm+siQ1Co9cObZyypLJPGLqcvkeG0yJ0N8Oz
	EE0Meec3KDp1EpRWh7lK68974FycE/KnLWvE/JJsGBlPO5FnvbQdhoqXIsX9OFyo1WzAiO4DR4c
	xtNUmridut975cZ5GHSX3mMHl+D0+7QAalP9LYKUpWtFFyHT1fqcJUcZPYNWeJKfnpA==
X-Received: by 2002:a05:620a:101b:: with SMTP id z27mr19164017qkj.160.1553524825309;
        Mon, 25 Mar 2019 07:40:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqq/OVtCGsbaF2MyCQPfejjs57HSqvfAt6orqMpwBGoqfUZ5lmGt/RfpHJ3afKM3nGC5VV
X-Received: by 2002:a05:620a:101b:: with SMTP id z27mr19163964qkj.160.1553524824574;
        Mon, 25 Mar 2019 07:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524824; cv=none;
        d=google.com; s=arc-20160816;
        b=jn3iYQDQGR1Z0xGJr3tyDD6Aqq3aX5iA/RNKFE4WU3cS+ERPUA5aNudxPc/wjgpt6d
         jIkWo2PzwfhO7+tn6N1cmxPmJ8pn3/yqAy6dh93sWv1TxztLgUC5twD+blczj/rV5qXu
         ZeC8aQPCcxiinNhXVJi46GipkICAWReduiEoc92J1dLIkOtdp8y2GWUw7YkKqg+V0EGj
         88gIcWr/2jI/LD1+N5bKI6jmOLkxK7LcRXPURqNAWYaHUqrrtT9cSYPnz3VcV+Nnk6Oo
         ZkA94HAB2s25yvso/agdLxI+iaU1/wML3w16stz3qJ0zViTf0IThZFZd6+cFLqnu70F/
         Ar8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MqKfHNfNBWpbmcGqXPdVGblL10NQAvDWexvXCgPT6fQ=;
        b=eQ+WlYjrO1nJuLjZOvuGCtSqcTLEN9iQVYnpFXuuk8OhQsNqsUUHHw/OUoK0p6DfmD
         P9RuPWwNv2mN5nlVRBAVMZ8U7F8tKSeU/d18QmX5ZHwiaqrmPxrMuMyeRt2kLYz7AYFz
         b/Hf1qGXFg5vyRT26sIfBl4IhK/Q8ug3ZTvhdPSUm8aYaulYb85jGcccOwDZ/Lsrs8mr
         io4H3E7H86H7lhZ8K6k1cA6A8yT3T2nMS/iKBK0UxD8xL35cm5p8Zqd0uNDyFfs+i+X1
         6qI51qSzj+P8/oRg2YdEfNYejHzlz5To0DbNOa/nmbwVkkb29E+dxmleiSqUmClaxZQ4
         ca3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 25si2754194qtq.283.2019.03.25.07.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B07DB2026E;
	Mon, 25 Mar 2019 14:40:23 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EBEBD1001DC8;
	Mon, 25 Mar 2019 14:40:22 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 11/11] mm/hmm: add an helper function that fault pages and map them to a device v2
Date: Mon, 25 Mar 2019 10:40:11 -0400
Message-Id: <20190325144011.10560-12-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 25 Mar 2019 14:40:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This is a all in one helper that fault pages in a range and map them to
a device so that every single device driver do not have to re-implement
this common pattern.

This is taken from ODP RDMA in preparation of ODP RDMA convertion. It
will be use by nouveau and other drivers.

Changes since v1:
    - improved commit message

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/hmm.h |   9 +++
 mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 161 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5f9deaeb9d77..7aadf18b29cb 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -568,6 +568,15 @@ int hmm_range_register(struct hmm_range *range,
 void hmm_range_unregister(struct hmm_range *range);
 long hmm_range_snapshot(struct hmm_range *range);
 long hmm_range_fault(struct hmm_range *range, bool block);
+long hmm_range_dma_map(struct hmm_range *range,
+		       struct device *device,
+		       dma_addr_t *daddrs,
+		       bool block);
+long hmm_range_dma_unmap(struct hmm_range *range,
+			 struct vm_area_struct *vma,
+			 struct device *device,
+			 dma_addr_t *daddrs,
+			 bool dirty);
 
 /*
  * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
diff --git a/mm/hmm.c b/mm/hmm.c
index ce33151c6832..fd143251b157 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -30,6 +30,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
 #include <linux/jump_label.h>
+#include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
@@ -1163,6 +1164,157 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
 EXPORT_SYMBOL(hmm_range_fault);
+
+/*
+ * hmm_range_dma_map() - hmm_range_fault() and dma map page all in one.
+ * @range: range being faulted
+ * @device: device against to dma map page to
+ * @daddrs: dma address of mapped pages
+ * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
+ * Returns: number of pages mapped on success, -EAGAIN if mmap_sem have been
+ *          drop and you need to try again, some other error value otherwise
+ *
+ * Note same usage pattern as hmm_range_fault().
+ */
+long hmm_range_dma_map(struct hmm_range *range,
+		       struct device *device,
+		       dma_addr_t *daddrs,
+		       bool block)
+{
+	unsigned long i, npages, mapped;
+	long ret;
+
+	ret = hmm_range_fault(range, block);
+	if (ret <= 0)
+		return ret ? ret : -EBUSY;
+
+	npages = (range->end - range->start) >> PAGE_SHIFT;
+	for (i = 0, mapped = 0; i < npages; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		/*
+		 * FIXME need to update DMA API to provide invalid DMA address
+		 * value instead of a function to test dma address value. This
+		 * would remove lot of dumb code duplicated accross many arch.
+		 *
+		 * For now setting it to 0 here is good enough as the pfns[]
+		 * value is what is use to check what is valid and what isn't.
+		 */
+		daddrs[i] = 0;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		/* Check if range is being invalidated */
+		if (!range->valid) {
+			ret = -EBUSY;
+			goto unmap;
+		}
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+			dir = DMA_BIDIRECTIONAL;
+
+		daddrs[i] = dma_map_page(device, page, 0, PAGE_SIZE, dir);
+		if (dma_mapping_error(device, daddrs[i])) {
+			ret = -EFAULT;
+			goto unmap;
+		}
+
+		mapped++;
+	}
+
+	return mapped;
+
+unmap:
+	for (npages = i, i = 0; (i < npages) && mapped; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		if (dma_mapping_error(device, daddrs[i]))
+			continue;
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+			dir = DMA_BIDIRECTIONAL;
+
+		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		mapped--;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(hmm_range_dma_map);
+
+/*
+ * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dma_map()
+ * @range: range being unmapped
+ * @vma: the vma against which the range (optional)
+ * @device: device against which dma map was done
+ * @daddrs: dma address of mapped pages
+ * @dirty: dirty page if it had the write flag set
+ * Returns: number of page unmapped on success, -EINVAL otherwise
+ *
+ * Note that caller MUST abide by mmu notifier or use HMM mirror and abide
+ * to the sync_cpu_device_pagetables() callback so that it is safe here to
+ * call set_page_dirty(). Caller must also take appropriate locks to avoid
+ * concurrent mmu notifier or sync_cpu_device_pagetables() to make progress.
+ */
+long hmm_range_dma_unmap(struct hmm_range *range,
+			 struct vm_area_struct *vma,
+			 struct device *device,
+			 dma_addr_t *daddrs,
+			 bool dirty)
+{
+	unsigned long i, npages;
+	long cpages = 0;
+
+	/* Sanity check. */
+	if (range->end <= range->start)
+		return -EINVAL;
+	if (!daddrs)
+		return -EINVAL;
+	if (!range->pfns)
+		return -EINVAL;
+
+	npages = (range->end - range->start) >> PAGE_SHIFT;
+	for (i = 0; i < npages; ++i) {
+		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		struct page *page;
+
+		page = hmm_pfn_to_page(range, range->pfns[i]);
+		if (page == NULL)
+			continue;
+
+		/* If it is read and write than map bi-directional. */
+		if (range->pfns[i] & range->values[HMM_PFN_WRITE]) {
+			dir = DMA_BIDIRECTIONAL;
+
+			/*
+			 * See comments in function description on why it is
+			 * safe here to call set_page_dirty()
+			 */
+			if (dirty)
+				set_page_dirty(page);
+		}
+
+		/* Unmap and clear pfns/dma address */
+		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
+		range->pfns[i] = range->values[HMM_PFN_NONE];
+		/* FIXME see comments in hmm_vma_dma_map() */
+		daddrs[i] = 0;
+		cpages++;
+	}
+
+	return cpages;
+}
+EXPORT_SYMBOL(hmm_range_dma_unmap);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
-- 
2.17.2

