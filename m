Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D256C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8F05206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="d/ejljcx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8F05206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C69156B0006; Thu, 25 Apr 2019 13:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFA616B0008; Thu, 25 Apr 2019 13:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ADE66B000A; Thu, 25 Apr 2019 13:54:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 770766B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:54:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u65so576285qkd.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:54:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Foh3LzSAlRhsG5v+CYaUdl7ltYSt8W1VE3b+4djK8OY=;
        b=De6Sr43GJTPzaE1/f/RTZVfERdIicQl41b9hS0QRQVPkbAjqpbRXbqUN3BTRmAMYnd
         Yf3rw++vs+u4MVc/hS6nLowIVyBo47eTH97Qjy/x2PLLL7fWV5Z0EHoz9IXseoI2InY2
         DS2ipAFioch+QUJTWCUHMznli10m6RENLuKKSRgAOHTwYFMBwCouQ+vg9eQ5pLIcqakN
         pFnxRPbzPEQKC54kfMBCNdS8kN9uGFcNJluJyzxzslMtzOLCZcIq3SHyPtEYutdsFpUk
         d4QjpUymcIUPK6LjZeX8BUXSCCcbIz7pqKNyPA781W9wLKhDW3XsHSyn76GGzyh26hq/
         LBdg==
X-Gm-Message-State: APjAAAV8v0wFqhwFl8B9/VZqWA+RJ49zxEKgRz9fp92atKnruNCOFxoA
	viOU5mTy29olRbYDr67zFE0qDSG/KSiSJ9tv6O2Xqvf3oYyEm0Wh81s7E5IU1NgCFn/YCbhNS3E
	s06II04h7fGoJ3ZeLn+fyhlCbJ+ZBRZP5BapxQsuvGlKl2PuPAe4WEo850rLfRhcUcg==
X-Received: by 2002:aed:20c3:: with SMTP id 61mr31117984qtb.356.1556214888202;
        Thu, 25 Apr 2019 10:54:48 -0700 (PDT)
X-Received: by 2002:aed:20c3:: with SMTP id 61mr31117898qtb.356.1556214886924;
        Thu, 25 Apr 2019 10:54:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556214886; cv=none;
        d=google.com; s=arc-20160816;
        b=daIhdeBtmuKSTUqfSiqt3wS8lP3OnJGT5XkzUAj0BmQifMNZkxoT0A6pZ+DUYi/+on
         7Rhrh4XayjCd3d84WMk8yb67SShOVMesep6ZOkfk/3cCrQkQCNWRgktdv6goiklWBHcA
         LlTV9znviz1Iemvt1QGImTMikSsae+eDfCZwzxxbckGBtVD+Lq+jNm0aM8EDNE3Yuhjp
         yvP+kvTAyoGSDwZVVUa8VWilEZV/Fa5Zcxc6MsA7ax/75cxK7v3UDyz6pM4aP4AdVYqr
         0iS6+4I8702ijK8bYWRf2TYFVMtaJl5SdV1oelUzCfqa0yRMOm04LFXyBEJ+4N/N+vRX
         sr2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=Foh3LzSAlRhsG5v+CYaUdl7ltYSt8W1VE3b+4djK8OY=;
        b=AxymZkpKrhuK5Oj2KETLZGikXO8wJR3Jq7wzU/+lAYtMFxcuOYabadO35tFd3Xip2N
         qfk6NPQGcUzajdvg59LK7CVOi8jjKIeLwQGcEwDfnKJGzGjaAgOWEzAmew39rzyu30aL
         Ra13hb/ICUXvOKj6C1EA3q7Wi+y37mus+egyt9vCfV+gBtf4182zMvy70+nztlk5Jrhz
         uy9JtMfyHzcPC+9LD3Vl+v53OlKn1c3Vy32lgC1vEulfUp61uJid0hK9Ie3b2eivCZ5N
         93MmmZPfcc1eRaS9WaE91gJH75rVyxa7AgrAk36zBi944P8qW3VYK2tQOgBAAJd/hCVl
         gaFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="d/ejljcx";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i58sor12881701qtc.13.2019.04.25.10.54.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 10:54:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="d/ejljcx";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Foh3LzSAlRhsG5v+CYaUdl7ltYSt8W1VE3b+4djK8OY=;
        b=d/ejljcxIHRrYf5z/BBKT9pKiES0qzALTZdEmXuYgGsfVcLAl0u1Ll92XApR3StG3d
         rTkhPDbx7AZgnWfh9lGA69LR3D/lSbGP3d4rqL0jooMehemCn9Be5F09xymRBxobcMPf
         FLvnWxNd5KY71W5pTRwtGXnIHlfeUR+860h4T3l4TXt0KyH9c90NRjDhNWugt7xGh+Ul
         fUL3hW5xk22tnrr5TtfJ+qE01n3R8gs/XGo4OzGSDSjb6LpBSWQPBqqJvkdyOvqUedVA
         6DVpCI1Ym7XiO49G2lfMLODxZCu4bSFl5yOhWwV2ekjlJPVk3VC8TZcVB4K42uZeCkci
         HOfQ==
X-Google-Smtp-Source: APXvYqznfWTOB1ABb7LzLPgV1YO+P+2Jyh8aJmNlX1CylGASgC4G/RUvtv9b9jhOo21gGaho9/PDIQ==
X-Received: by 2002:ac8:2843:: with SMTP id 3mr31737455qtr.327.1556214886603;
        Thu, 25 Apr 2019 10:54:46 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 7sm5950641qtx.20.2019.04.25.10.54.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 10:54:45 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v3 2/2] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Thu, 25 Apr 2019 13:54:40 -0400
Message-Id: <20190425175440.9354-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190425175440.9354-1-pasha.tatashin@soleen.com>
References: <20190425175440.9354-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is now allowed to use persistent memory like a regular RAM, but
currently there is no way to remove this memory until machine is
rebooted.

This work expands the functionality to also allows hotremoving
previously hotplugged persistent memory, and recover the device for use
for other purposes.

To hotremove persistent memory, the management software must first
offline all memory blocks of dax region, and than unbind it from
device-dax/kmem driver. So, operations should look like this:

echo offline > echo offline > /sys/devices/system/memory/memoryN/state
...
echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind

Note: if unbind is done without offlining memory beforehand, it won't be
possible to do dax0.0 hotremove, and dax's memory is going to be part of
System RAM until reboot.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 drivers/dax/dax-private.h |  2 +
 drivers/dax/kmem.c        | 94 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 92 insertions(+), 4 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index a45612148ca0..999aaf3a29b3 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -53,6 +53,7 @@ struct dax_region {
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
  * @ref: pgmap reference count (driver owned)
  * @cmp: @ref final put completion (driver owned)
+ * @dax_mem_res: physical address range of hotadded DAX memory
  */
 struct dev_dax {
 	struct dax_region *region;
@@ -62,6 +63,7 @@ struct dev_dax {
 	struct dev_pagemap pgmap;
 	struct percpu_ref ref;
 	struct completion cmp;
+	struct resource *dax_kmem_res;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index 4c0131857133..6f1640462df9 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -71,21 +71,107 @@ int dev_dax_kmem_probe(struct device *dev)
 		kfree(new_res);
 		return rc;
 	}
+	dev_dax->dax_kmem_res = new_res;
 
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * Check that device-dax's memory_blocks are offline. If a memory_block is not
+ * offline a warning is printed and an error is returned. dax hotremove can
+ * succeed only when every memory_block is offlined beforehand.
+ */
+static int
+check_memblock_offlined_cb(struct memory_block *mem, void *arg)
+{
+	struct device *mem_dev = &mem->dev;
+	bool is_offline;
+
+	device_lock(mem_dev);
+	is_offline = mem_dev->offline;
+	device_unlock(mem_dev);
+
+	if (!is_offline) {
+		struct device *dev = (struct device *)arg;
+		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
+		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
+		phys_addr_t spa = spfn << PAGE_SHIFT;
+		phys_addr_t epa = epfn << PAGE_SHIFT;
+
+		dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
+			 &spa, &epa);
+
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct resource *res = dev_dax->dax_kmem_res;
+	resource_size_t kmem_start;
+	resource_size_t kmem_size;
+	unsigned long start_pfn;
+	unsigned long end_pfn;
+	int rc;
+
+	/*
+	 * dax kmem resource does not exist, means memory was never hotplugged.
+	 * So, nothing to do here.
+	 */
+	if (!res)
+		return 0;
+
+	kmem_start = res->start;
+	kmem_size = resource_size(res);
+	start_pfn = kmem_start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
+
+	/*
+	 * Walk and check that every singe memory_block of dax region is
+	 * offline
+	 */
+	lock_device_hotplug();
+	rc = walk_memory_range(start_pfn, end_pfn, dev,
+			       check_memblock_offlined_cb);
+
+	/*
+	 * If admin has not offlined memory beforehand, we cannot hotremove dax.
+	 * Unfortunately, because unbind will still succeed there is no way for
+	 * user to hotremove dax after this.
+	 */
+	if (rc) {
+		unlock_device_hotplug();
+		return rc;
+	}
+
+	/* Hotremove memory, cannot fail because memory is already offlined */
+	__remove_memory(dev_dax->target_node, kmem_start, kmem_size);
+	unlock_device_hotplug();
+
+	/* Release and free dax resources */
+	release_resource(res);
+	kfree(res);
+	dev_dax->dax_kmem_res = NULL;
+
+	return 0;
+}
+#else
 static int dev_dax_kmem_remove(struct device *dev)
 {
 	/*
-	 * Purposely leak the request_mem_region() for the device-dax
-	 * range and return '0' to ->remove() attempts. The removal of
-	 * the device from the driver always succeeds, but the region
-	 * is permanently pinned as reserved by the unreleased
+	 * Without hotremove purposely leak the request_mem_region() for the
+	 * device-dax range and return '0' to ->remove() attempts. The removal
+	 * of the device from the driver always succeeds, but the region is
+	 * permanently pinned as reserved by the unreleased
 	 * request_mem_region().
 	 */
 	return 0;
 }
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 
 static struct dax_device_driver device_dax_kmem_driver = {
 	.drv = {
-- 
2.21.0

