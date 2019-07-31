Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B3CFC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7DCF206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7DCF206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243028E0032; Wed, 31 Jul 2019 11:48:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F4E28E000D; Wed, 31 Jul 2019 11:48:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020478E0032; Wed, 31 Jul 2019 11:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9DA58E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so42650449edc.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aHAqICo5eTRSGwfWWKL3szs2vb6l+yyj2bXZq8YQTqI=;
        b=IeqnessWtHpuHXBTlmDN9LYbmTVEKYuj7gItXvXhu8TLqJkkf9zOEvgtLjv8N3prcz
         DqWuITaPtxODa/qYkPMyPzZiPqvkwU052l4AXqKKKIiAtgvRC7sdG+rBvGiI3PsImifR
         L1N+6Pj6wuwqIPiINNaz423WU2toCFkqaEDICWvBLtzya4vn23HIOq98Q8afmjlPdkii
         6xWXui8F79poKKcg0x69MdUro/nC5oRLi+LGQZPlLYMXqgHiZnk5gKpEWt3eHkbyEweW
         YVDaKTO3m23l5ycZws/dteBpXYwTHxqB3JnOBrjSkVuyNNk7QwZj9vhxs2W0o/g0iivM
         UW2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWZokNoKL0tmWeT3ggwXSgl9l8gTSXiuyJF6Q5OwPpqPzrdcf+Z
	mxBCZNLxI+cjYUlWwTjWfzkrLwYNjNMLCgNjSh5mVLKd7YoTFUONpLcOuvj8mYuCukHC5Hhfnos
	cWlg0ZwUzE3vgQA81iYT96THSK7IGthywz2CHnenUjR5GPAwEizhKHLnArK0kYU//hw==
X-Received: by 2002:a50:84e2:: with SMTP id 89mr108671522edq.218.1564588085264;
        Wed, 31 Jul 2019 08:48:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybHL2oLV3jgHdWsZhjkn6g+XhSDjgkQCY1Cl5Gc2ZzbnwMifFffVGPhvs1rv2opvggJWlY
X-Received: by 2002:a50:84e2:: with SMTP id 89mr108671456edq.218.1564588084419;
        Wed, 31 Jul 2019 08:48:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588084; cv=none;
        d=google.com; s=arc-20160816;
        b=rZmNn3MPHocL5ACb72qw6Gvz24SljYwKV/lMHrUBwSNfMhcbbhG8tV7wnL26cGdqo5
         lO8nnCcKTkkCceBSKivv/9zttnDFz94JBNW0335hjbyguPgHz6yUxJY1XB7zKK8ALy+7
         SVPxJdVFE3odPtwvK/DUcOnBA1jEeHQ3kBynQyBsFICGi79vzyNsRBvR02xsLhDgo9gi
         qpLyE0UiOjL3SIeT1jlmJLJTr2rfNv0G0TIDidsYKd6QupN71mj1/UHuoufkWsOrdg3+
         SVoIDcmpyb0ZreONS+18VZBdEsUjNL2cKx6NZ79qC9pvkHugLs8W26zLa126B+vwC32c
         IOrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=aHAqICo5eTRSGwfWWKL3szs2vb6l+yyj2bXZq8YQTqI=;
        b=EYqh9D+dI20ezVVZKy6Oav0a42kjpHlCMEMr0yW/ApzJuaWR3JwfJ/3ZUMiKPL9F2Z
         wEtQFAZpSA3/HXGk9fY1xOhgeHYq/o8Dzb9OdCU+obXVlGWAdskPQ965PTJ2sGxviFY/
         C0vTTCV5kMbmkhxURZ38PP2XRQnkJ2pmImc1lKj/UWzOuCQqUA5kdNTiGKPGfSRhV+KP
         9CH6IGRIkBnGX4ZmjcQEPr8wusTPpRDJKqFt4ZAmVKZFBzg3ZuskIKfl1RvZchEsacF/
         ZzPhmAenWY6WlLRkHxj64qT3JXWirVqt+650V3MnEEXjvYJYebru8rGZ0XAh7WsCqUtv
         Homw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w37si20716103eda.288.2019.07.31.08.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01F74AFE4;
	Wed, 31 Jul 2019 15:48:04 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	linux-mm@kvack.org,
	Rob Herring <robh+dt@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	will@kernel.org,
	linux-kernel@vger.kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org
Subject: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA addressable memory size
Date: Wed, 31 Jul 2019 17:47:46 +0200
Message-Id: <20190731154752.16557-4-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190731154752.16557-1-nsaenzjulienne@suse.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some SoCs might have multiple interconnects each with their own DMA
addressing limitations. This function parses the 'dma-ranges' on each of
them and tries to guess the maximum SoC wide DMA addressable memory
size.

This is specially useful for arch code in order to properly setup CMA
and memory zones.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 drivers/of/fdt.c       | 72 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_fdt.h |  2 ++
 2 files changed, 74 insertions(+)

diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 9cdf14b9aaab..f2444c61a136 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -953,6 +953,78 @@ int __init early_init_dt_scan_chosen_stdout(void)
 }
 #endif
 
+/**
+ * early_init_dt_dma_zone_size - Look at all 'dma-ranges' and provide the
+ * maximum common dmable memory size.
+ *
+ * Some devices might have multiple interconnects each with their own DMA
+ * addressing limitations. For example the Raspberry Pi 4 has the following:
+ *
+ * soc {
+ *	dma-ranges = <0xc0000000  0x0 0x00000000  0x3c000000>;
+ *	[...]
+ * }
+ *
+ * v3dbus {
+ *	dma-ranges = <0x00000000  0x0 0x00000000  0x3c000000>;
+ *	[...]
+ * }
+ *
+ * scb {
+ *	dma-ranges = <0x0 0x00000000  0x0 0x00000000  0xfc000000>;
+ *	[...]
+ * }
+ *
+ * Here the area addressable by all devices is [0x00000000-0x3bffffff]. Hence
+ * the function will write in 'data' a size of 0x3c000000.
+ *
+ * Note that the implementation assumes all interconnects have the same physical
+ * memory view and that the mapping always start at the beginning of RAM.
+ */
+int __init early_init_dt_dma_zone_size(unsigned long node, const char *uname,
+				       int depth, void *data)
+{
+	const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
+	u64 phys_addr, dma_addr, size;
+	u64 *dma_zone_size = data;
+	int dma_addr_cells;
+	const __be32 *reg;
+	const void *prop;
+	int len;
+
+	if (depth == 0)
+		*dma_zone_size = 0;
+
+	/*
+	 * We avoid pci host controllers as they have their own way of using
+	 * 'dma-ranges'.
+	 */
+	if (type && !strcmp(type, "pci"))
+		return 0;
+
+	reg = of_get_flat_dt_prop(node, "dma-ranges", &len);
+	if (!reg)
+		return 0;
+
+	prop = of_get_flat_dt_prop(node, "#address-cells", NULL);
+	if (prop)
+		dma_addr_cells = be32_to_cpup(prop);
+	else
+		dma_addr_cells = 1; /* arm64's default addr_cell size */
+
+	if (len < (dma_addr_cells + dt_root_addr_cells + dt_root_size_cells))
+		return 0;
+
+	dma_addr = dt_mem_next_cell(dma_addr_cells, &reg);
+	phys_addr = dt_mem_next_cell(dt_root_addr_cells, &reg);
+	size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+	if (!*dma_zone_size || *dma_zone_size > size)
+		*dma_zone_size = size;
+
+	return 0;
+}
+
 /**
  * early_init_dt_scan_root - fetch the top level address and size cells
  */
diff --git a/include/linux/of_fdt.h b/include/linux/of_fdt.h
index acf820e88952..2ad36b7bd4fa 100644
--- a/include/linux/of_fdt.h
+++ b/include/linux/of_fdt.h
@@ -72,6 +72,8 @@ extern int early_init_dt_reserve_memory_arch(phys_addr_t base, phys_addr_t size,
 					     bool no_map);
 extern u64 dt_mem_next_cell(int s, const __be32 **cellp);
 
+extern int early_init_dt_dma_zone_size(unsigned long node, const char *uname,
+				       int depth, void *data);
 /* Early flat tree scan hooks */
 extern int early_init_dt_scan_root(unsigned long node, const char *uname,
 				   int depth, void *data);
-- 
2.22.0

