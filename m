Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A562EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 518422084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:34:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 518422084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFDD6B0275; Wed,  3 Apr 2019 15:33:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F5906B0276; Wed,  3 Apr 2019 15:33:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 520CC6B0277; Wed,  3 Apr 2019 15:33:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 274246B0275
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1so122829qte.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CyU3rZ/sOKVxQY6gKYSz5WatUbvmZB1DmVxc8WNP/dY=;
        b=h/Gz0jUeRf8pmU7XDdTNnJ0ONq6OHNgmJruTwxllJHRAzmG1caDyIcjz7JoGs/1PTR
         tG34VAW4WMvLwqSjZhbkQ6kX1BGRi+U7fCEzJ6TSwRXC+TXdSFXtjnbhJbUhCbcJAK16
         XEDI3cfNgx6TOC3ns7za6XJed6PV5IVjb9V/DfkkxEiUYxgvp1qgKPikie5qZG8LEB1U
         ugbIjQNTgT+lEUKbTSZzjIpU/EtIozjr4A3zmpGC8gUCEYV8YqFjeQ+DqcyRzV6F97+6
         OEl0o0cdwiRe0UmWyBR6Mpc1inpHVql6KoGb3+qnBUIrZa6j8lwkxaRn6CwKEcIaRxTl
         fkmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEUFOLWkNlQz8tQy+aYdMCTgtFF9dyFg0RFHvvSIpKoO04FLeP
	BFoHpqKFx4FvDlrwbcsoQOPNhRtfB0J2trZ7uxjWlJWfsmbllaJ0aMQouBfGg6knWxXmbqlmSzK
	o+2U+EYkUMKSCYrnrxiyQl9V7Z+6pXPA0ZFzjn2ReIZgVm8wyAxo8zSrgcEMujgfboQ==
X-Received: by 2002:a0c:969d:: with SMTP id a29mr1268460qvd.56.1554320024916;
        Wed, 03 Apr 2019 12:33:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM7+JKfr8cM5bgsBTxWXhwyX7QBmzg1aE1YAWH8zcrg2zZML78EG4hoXDLd9Tw5fxCUbpz
X-Received: by 2002:a0c:969d:: with SMTP id a29mr1268417qvd.56.1554320024196;
        Wed, 03 Apr 2019 12:33:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320024; cv=none;
        d=google.com; s=arc-20160816;
        b=lEmU5oyha892EqOJyAZPqeduccNURMNUIfYD/SJXRJOQJabM3+D3V1giOliz21x2h2
         ttSZtYuJQ4Fzb9++AIMpfXvKlmm6B1GsudORUZgtPqw+wUF4kRax/3f7xTqID60epWxg
         eTwpKT9b8PiWDIu5R+FYKXFns4kYoX/b6oaaJfUNPYeJZepTPQhS/jPMO0kL77BAC8/C
         x33kX1eTRY8e0qPaOewlvYTvtNv00/f853AIXgbpu7VnUU88nq2kvac6os0HXcLp3+Tv
         JY2SpyRKOD+l8MEl2kxJCMpySU9E35PZ1jU7Iavz29Ge6DnZuhuVJHBGh+LTssutxnCl
         bUMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CyU3rZ/sOKVxQY6gKYSz5WatUbvmZB1DmVxc8WNP/dY=;
        b=coCxQwP3qPtgmaw8KcwB2gH0zd3LI+iHQtZ1Ihj+JxT9QjhtiBw+EuHidU5VzHMuUW
         xZAMN+ZhIlZiI+JW2F/jtI954IotD0TR5shJwBz0l0i0o8NNDj3Eg1lqKvAnRGncD7x3
         8qXZ91Zy0jHRQimVdZoBf1LfVj1QeVsYh/kDB/DQyktTP/PxOa6VJo1aq04ClYcX2J4y
         t18AFbM3QIYRNLnouSXhW8WrLFlEM62SKYtBIfaUK1eCBB3Edj4sdO8mCiAQCAi2Ibbg
         pgLRrNh7jRAZBnuXUqh9gfvG2jtAsMbRkN7MAVEBbWxhrlQR/7Gl9m7CCC1QbmeYaWIA
         lWKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b54si5365637qte.184.2019.04.03.12.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 621B13092669;
	Wed,  3 Apr 2019 19:33:43 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4AC056012C;
	Wed,  3 Apr 2019 19:33:42 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3 11/12] mm/hmm: add an helper function that fault pages and map them to a device v3
Date: Wed,  3 Apr 2019 15:33:17 -0400
Message-Id: <20190403193318.16478-12-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 03 Apr 2019 19:33:43 +0000 (UTC)
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

Changes since v2:
    - Improved function comment for kernel documentation.
Changes since v1:
    - improved commit message

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/hmm.h |   9 +++
 mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 161 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index a79fcc6681f5..f81fe2c0f343 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -474,6 +474,15 @@ int hmm_range_register(struct hmm_range *range,
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
index 39bc77d7e6e3..82fded7273d8 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -30,6 +30,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memremap.h>
 #include <linux/jump_label.h>
+#include <linux/dma-mapping.h>
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
@@ -1173,6 +1174,157 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
 EXPORT_SYMBOL(hmm_range_fault);
+
+/**
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
+/**
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

