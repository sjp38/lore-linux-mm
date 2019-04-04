Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD76C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A66220820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="Gfm1ydd0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Mu+YIkDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A66220820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 672BD6B026E; Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FADB6B026F; Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44D136B0270; Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24B9C6B026E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:33 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s26so921551qkm.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=fFiPOXcG+tagawAnsTiiPFqaNASH1sdzyZFszg1HWpM=;
        b=KHq/d4olYLeGWM9vMFGDTuvZojAcdf4w+lLx6yFJdNvS7EX6x4Zx9+OivyE7nsweSy
         PJxjUSDv7ERDs+Q5rBWlBOwyLthHM1j9Zj/WeaaSpIxtfjG1veEmW66FJJdBHtWKAQIl
         Zh1E6J5wH+X4geRhnp3GRua+Ba2PC2wZ0XhXYoqBiB7K80Xh+XIexYsPo3FxWbpSQ3l9
         HHb561tw+SB3CWTohTU/OY98eqoAYtRNwsbL6iFRUHb5JY+aizmQVSy02VA5kW69hWl3
         uNUipsn2rKj1j4jQj8LF0PReWfKS8hz2769NtGABfa9RCRBHk7sblb5PXrdBVEwMFW9N
         g6Kg==
X-Gm-Message-State: APjAAAXPeyzzp91zzSXNI1pp+53dsoSfp/KXkVSuhVrZk2j6DDiIhtBN
	O1BJjkFkuPtTs0hzGkmMgBsewkfFK/JELuXYjs/cuwiEGfoySASsgUukV4WNRqThHUJ3HD+5Pq5
	2ICQn7HrarwqjjbJ0kTYVr7dH35BlGZCmiGCCqm3fOMae7lizeQvPy+f0ekpnLI1f/w==
X-Received: by 2002:ae9:c210:: with SMTP id j16mr2862778qkg.218.1554343292912;
        Wed, 03 Apr 2019 19:01:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySdzkV03Sh5PGpBxpsamZOXDeTBiz5gxEE0hTTjSaQFzcziETfTp6cZsl0+p7u/0O7CYxJ
X-Received: by 2002:ae9:c210:: with SMTP id j16mr2862707qkg.218.1554343292120;
        Wed, 03 Apr 2019 19:01:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343292; cv=none;
        d=google.com; s=arc-20160816;
        b=b1oKRLoU4L8WKIA8eICmkCqY0KdTw8PS3mNoxBTiOcOKwUJB+HKKF+MpGvNAlGrFyl
         LctRnvqQnkbOtd6cLp5vqnyTHsH0WRznGSN80sqEMUGC/HVaME+vUTZgKPuZ3TA6Md6A
         bMooZ80wRPRynNfC1vgpYVbe3IN9HfkajcoetWcrKHOfiiP3j+44V1wUvc6ieS8rhDit
         jPHysQRIJBxLvP+FJCJj8Hn/s1djcQ5nsdXgUzX5bu6pxqye9jIu1YNV4umPcsW7r8IE
         fKg/sRoaVY5AGdz8vBV+jC3RN0OIo3O048TncimyZs7GASf3UP/WeOFTFx85qYJkuAUK
         3p+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=fFiPOXcG+tagawAnsTiiPFqaNASH1sdzyZFszg1HWpM=;
        b=g8KuspQTOq+HElsnPpyPa6d/LGg7JIS/a9v7EQCxUwqNaO4vKdBqJCG7taqgGRpsOK
         UuuD2f1dKCsIkXeE3lwEYhGUz9RDrgBJAs5tWvYzyDO3E16Ois2R9uVTe7jSkJGnBYKl
         q81qKwnJ+GYXIluWsuxdc8Rh8wWQKQVCH8c+ypaTyzMXGlCJWYYZjynxRjapNzqi4AQD
         h4UI8hVy/MZUqBjEDeYV0a8BJixhpH9mhuvnjguBkAjuz6DDomDHY9Rzbsv+UHF8LxRn
         06MmDD2MrgLcfII4V/+BRfTqErCMT/h+PHmbr6LeGLI0Aubr8GBd5IEUVS9JYo/cBOjn
         FF3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=Gfm1ydd0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Mu+YIkDB;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id p28si8406767qtj.306.2019.04.03.19.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=Gfm1ydd0;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Mu+YIkDB;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D651B226C0;
	Wed,  3 Apr 2019 22:01:31 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=fFiPOXcG+taga
	wAnsTiiPFqaNASH1sdzyZFszg1HWpM=; b=Gfm1ydd0rEKEmAh6YCF/WLq52HFoN
	uiTjw6U6R4ewtBPRLPopBIVKqrLS3oaxHPx2JysLOdHndECZQV3mzJToXrf0CfSZ
	8uNotHy9s7Lxwj6l+Ac1XYU1xPa8loNBctcDGy+HTTnaucve2eGtFfpTg87f2rmZ
	8KMWUCKSSN4soiPwjyIhc3FjbC5oOXSxmp1EWqwKgtq0rC4KvbNdUID83tLhT44/
	nXTrD5q0BzNuDKkd5HAqTpWFoyQpDimuLK98s2K1KwbyrmWH5H2XsP07lHuS3IDR
	IZeejK9F1vRWL3lJ2En4W6zO8nJnlXk61vcAorwgrQ4+KGaIycNgAgE+w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=fFiPOXcG+tagawAnsTiiPFqaNASH1sdzyZFszg1HWpM=; b=Mu+YIkDB
	Twp8/EFWuJX/uJEN9yZF70j/31sYOwPAsAyX0cV086LDxC6ULQiCS6w/31s24Qra
	cKaPx+dKXMOy1in6YoLMO7VgEkQG2Ljj3P8pi5nNg4V/iOxpIbNoFS2RjzNzBzDs
	agys7n9q4mqfUry4ncDiNQj90GMagvs+zgbtibF0PcjtYF4GG3VqN8a/BW0ooHnz
	knZ6mEI1qZb2+XJXDJ8XR+BzLML2I0+fGFNRkMj/J5Znh3NCpfl38W18WHCRpyko
	+W7YVyNYYZZk3IDP7TB4RZs6rn6pVi9gpy/tT6gPty5+hOMEZnBhmoz5l1VwGr+D
	A9q7qCTiuWVfFA==
X-ME-Sender: <xms:e2WlXMHcDLyxiSUMhxVDgajUDVDbEOBobLPxmj81zZJgfsxZyJVOOg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepje
X-ME-Proxy: <xmx:e2WlXIlsObTUPbnuEpWRrOJU1JilLD6y0fKsmgWXz3RB_pO8tfnGyQ>
    <xmx:e2WlXPnPDBm8LwXitp7HH7cl4YaWZN2pO2Iz2t9v4H9xT457slv8eA>
    <xmx:e2WlXJu-Oz9eAL-JubY7kfuDhhq6qaZzz3owRLdj4gXKOWH2j2A06Q>
    <xmx:e2WlXBvZkTc0rI8Q8YTbxV3s7l30b7KHxd8qNs-OOy5Xn5867MqEKA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1474710310;
	Wed,  3 Apr 2019 22:01:30 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 10/25] mm: migrate: copy_page_lists_mt() to copy a page list using multi-threads.
Date: Wed,  3 Apr 2019 19:00:31 -0700
Message-Id: <20190404020046.32741-11-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

This prepare the support for migrate_page_concur(), which migrates
multiple pages at the same time.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/copy_page.c | 123 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h  |   2 +
 2 files changed, 125 insertions(+)

diff --git a/mm/copy_page.c b/mm/copy_page.c
index 84f1c02..d2fd67e 100644
--- a/mm/copy_page.c
+++ b/mm/copy_page.c
@@ -126,6 +126,129 @@ int copy_page_multithread(struct page *to, struct page *from, int nr_pages)
 
 	return err;
 }
+
+int copy_page_lists_mt(struct page **to, struct page **from, int nr_items)
+{
+	int err = 0;
+	unsigned int total_mt_num = limit_mt_num;
+	int to_node = page_to_nid(*to);
+	int i;
+	struct copy_page_info *work_items[NR_CPUS] = {0};
+	const struct cpumask *per_node_cpumask = cpumask_of_node(to_node);
+	int cpu_id_list[NR_CPUS] = {0};
+	int cpu;
+	int max_items_per_thread;
+	int item_idx;
+
+	total_mt_num = min_t(unsigned int, total_mt_num,
+						 cpumask_weight(per_node_cpumask));
+
+
+	if (total_mt_num > num_online_cpus())
+		return -ENODEV;
+
+	/* Each threads get part of each page, if nr_items < totla_mt_num */
+	if (nr_items < total_mt_num)
+		max_items_per_thread = nr_items;
+	else
+		max_items_per_thread = (nr_items / total_mt_num) +
+				((nr_items % total_mt_num)?1:0);
+
+
+	for (cpu = 0; cpu < total_mt_num; ++cpu) {
+		work_items[cpu] = kzalloc(sizeof(struct copy_page_info) +
+					sizeof(struct copy_item)*max_items_per_thread, GFP_KERNEL);
+		if (!work_items[cpu]) {
+			err = -ENOMEM;
+			goto free_work_items;
+		}
+	}
+
+	i = 0;
+	for_each_cpu(cpu, per_node_cpumask) {
+		if (i >= total_mt_num)
+			break;
+		cpu_id_list[i] = cpu;
+		++i;
+	}
+
+	if (nr_items < total_mt_num) {
+		for (cpu = 0; cpu < total_mt_num; ++cpu) {
+			INIT_WORK((struct work_struct *)work_items[cpu],
+					  copy_page_work_queue_thread);
+			work_items[cpu]->num_items = max_items_per_thread;
+		}
+
+		for (item_idx = 0; item_idx < nr_items; ++item_idx) {
+			unsigned long chunk_size = PAGE_SIZE * hpage_nr_pages(from[item_idx]) / total_mt_num;
+			char *vfrom = kmap(from[item_idx]);
+			char *vto = kmap(to[item_idx]);
+			VM_BUG_ON(PAGE_SIZE * hpage_nr_pages(from[item_idx]) % total_mt_num);
+			BUG_ON(hpage_nr_pages(to[item_idx]) !=
+				   hpage_nr_pages(from[item_idx]));
+
+			for (cpu = 0; cpu < total_mt_num; ++cpu) {
+				work_items[cpu]->item_list[item_idx].to = vto + chunk_size * cpu;
+				work_items[cpu]->item_list[item_idx].from = vfrom + chunk_size * cpu;
+				work_items[cpu]->item_list[item_idx].chunk_size =
+					chunk_size;
+			}
+		}
+
+		for (cpu = 0; cpu < total_mt_num; ++cpu)
+			queue_work_on(cpu_id_list[cpu],
+						  system_highpri_wq,
+						  (struct work_struct *)work_items[cpu]);
+	} else {
+		item_idx = 0;
+		for (cpu = 0; cpu < total_mt_num; ++cpu) {
+			int num_xfer_per_thread = nr_items / total_mt_num;
+			int per_cpu_item_idx;
+
+			if (cpu < (nr_items % total_mt_num))
+				num_xfer_per_thread += 1;
+
+			INIT_WORK((struct work_struct *)work_items[cpu],
+					  copy_page_work_queue_thread);
+
+			work_items[cpu]->num_items = num_xfer_per_thread;
+			for (per_cpu_item_idx = 0; per_cpu_item_idx < work_items[cpu]->num_items;
+				 ++per_cpu_item_idx, ++item_idx) {
+				work_items[cpu]->item_list[per_cpu_item_idx].to = kmap(to[item_idx]);
+				work_items[cpu]->item_list[per_cpu_item_idx].from =
+					kmap(from[item_idx]);
+				work_items[cpu]->item_list[per_cpu_item_idx].chunk_size =
+					PAGE_SIZE * hpage_nr_pages(from[item_idx]);
+
+				BUG_ON(hpage_nr_pages(to[item_idx]) !=
+					   hpage_nr_pages(from[item_idx]));
+			}
+
+			queue_work_on(cpu_id_list[cpu],
+						  system_highpri_wq,
+						  (struct work_struct *)work_items[cpu]);
+		}
+		if (item_idx != nr_items)
+			pr_err("%s: only %d out of %d pages are transferred\n", __func__,
+				item_idx - 1, nr_items);
+	}
+
+	/* Wait until it finishes  */
+	for (i = 0; i < total_mt_num; ++i)
+		flush_work((struct work_struct *)work_items[i]);
+
+	for (i = 0; i < nr_items; ++i) {
+			kunmap(to[i]);
+			kunmap(from[i]);
+	}
+
+free_work_items:
+	for (cpu = 0; cpu < total_mt_num; ++cpu)
+		if (work_items[cpu])
+			kfree(work_items[cpu]);
+
+	return err;
+}
 /* ======================== DMA copy page ======================== */
 #include <linux/dmaengine.h>
 #include <linux/dma-mapping.h>
diff --git a/mm/internal.h b/mm/internal.h
index cb1a610..51f5e1b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -558,5 +558,7 @@ extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
 
 extern int copy_page_lists_dma_always(struct page **to,
 			struct page **from, int nr_pages);
+extern int copy_page_lists_mt(struct page **to,
+			struct page **from, int nr_pages);
 
 #endif	/* __MM_INTERNAL_H */
-- 
2.7.4

