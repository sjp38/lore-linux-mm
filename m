Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD157C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C3F62133D
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="dxODNsdP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C3F62133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB7266B0008; Fri, 17 May 2019 17:54:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C41F16B000A; Fri, 17 May 2019 17:54:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABB456B000C; Fri, 17 May 2019 17:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84B1C6B0008
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:54:47 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id w34so7775869qtc.16
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:54:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=succA8z45ZOsiesf04L+hXIrQdIQDKYpeRjeM5YnMrqWUZOvLN8mriKOa1kjEDaeGl
         gPrXpKd0nx9HM7Nm7eb87Zm0qks6Q/BdGOKDwdtG5lJriA8rEILO7vDNjYsxQ4MbkXDL
         civl7TBzbHZXwfvqaTJpc4rpBZssR2QeCz5v81fymbx9FfEnyWu67burKk483B9I7Q7K
         d3y0MtRk5OjXfPZSCg4qpqLQO0aD5Ff5BYTZ15HwXYMF6/7I6VdwoEKudXqUDOW34ts/
         wAbcWC/AOR0NYlJuQwhhk8nik9VuklscX16pHznvo7RIw9HUyE0wQtEL+LM2JKbseCB4
         2uUA==
X-Gm-Message-State: APjAAAUvd76O3k4h2G+X3CLxMzSceieCMiQwY72v/oiGpw7Lwltib3Rw
	RyAb5GpaNF/LiN8wcmKnWUO3jvBiB2rriMoZ/faGhfDwHIIXOywb//VTQrf1QNF2rtDq3DZH2aA
	ZrJyia6GqVhpqLOiseT13kuXbyF+xJzl2tUZK5p6G6oiyXeI/pyFi2yDcTlS0Av9P3A==
X-Received: by 2002:ac8:3894:: with SMTP id f20mr49876074qtc.84.1558130087304;
        Fri, 17 May 2019 14:54:47 -0700 (PDT)
X-Received: by 2002:ac8:3894:: with SMTP id f20mr49876037qtc.84.1558130086533;
        Fri, 17 May 2019 14:54:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558130086; cv=none;
        d=google.com; s=arc-20160816;
        b=XGtVsA1sEf3RvGdSEwh1wjUZPBYiw6l3plzrgj9oqrXZi2ZdYMZP3SN42x1PxA1MxL
         4CbVnQVrgPmBCcIoQw6FtL/HbwmsK7JEA+RI8W2w9w80KYpnDMbF9Fc2MbrCfsTIyQvN
         QY6sg2vxyXTcs9T/eu+zTT6EHB4T4C/gLNJjpEfgoYxRz5DkCAtXB5QO5ez9VEggNJdC
         48l/0XumfKnfRJT/W/Ew6bkiLOyLMELQMoPuos1Qnz8/uPR1y+bNahe1NWlYC6PK+fIg
         PJZIsEdElzpvyiFfAYqFk2bBl/IbqTEzCJutoyXjmokpH38cdbdV698uqxnvk4oYH6qi
         yncg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=DrOgQCcStcD62chUVodbDkWd24zdBGwjVV8KPRD1+x+oDMya9jx+0w2yf+JUyFbO6N
         q/cy3LGv4C/Ct/fhdhaDCCHTvHg4EpK/YvGJdKRXKoERN7Xt13A2gg3w4rrZ7+P3QBJQ
         degP+xa3iiT2PT8ksCm5IdaMmnALi03TtGA1uUApCoxmbTB0SnCbaTnbI5HMmeJm3u69
         CYAx4+9BSK84fGFHipJjHOJeAjdemYv+R53/Wu9RbV1RRxora6s2wewrqtDUTzFkIfnF
         SsnA1DMp01d/le9OicryIxSq1SRrWBllH3AQ8WIBooe0v05RGr6HtaoJMf/DlQi05l0T
         Oeog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=dxODNsdP;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor12278284qta.70.2019.05.17.14.54.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 14:54:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=dxODNsdP;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=dxODNsdP4xdmGLZgD3wGpBVlOvBLAVbSmuov53M2mG0sFDyfGFIGchYc5sW1e4tdjh
         E4c/jto60Apec/FyJ74ps0C/lZTwCHSVCGEu/P9hjQyCnKCnrzUieZ4VeCLSkNoimqU6
         vTLoXPIvlC8WqNcEBLsvkQh9YYqP+L4H5r2GbwuKQ+kEujoYI57NpN8mOTCWgmfsr7Aw
         Spg565JQb5vi1JEv/tGDOgJGc//CmfQNLmu7NjApk78ZskurVXGDnNCuawRCwtqnE6X6
         JljgK2qNEAxVFEPGagOdIZlQ2j6+4SDQF/UVFwdv64lQUFlavVTkaDTXSW2ZYOAZXFsD
         rTLg==
X-Google-Smtp-Source: APXvYqwFk9kJSaOoaMhXOv97FFwjvOjt9oKxB+WBIkvvLLcYVDlAeyLAX4m1Cd2gwueE6vntUoBbxw==
X-Received: by 2002:ac8:3696:: with SMTP id a22mr50806933qtc.296.1558130086264;
        Fri, 17 May 2019 14:54:46 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n36sm6599813qtk.9.2019.05.17.14.54.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:54:45 -0700 (PDT)
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
Subject: [v6 3/3] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Fri, 17 May 2019 17:54:38 -0400
Message-Id: <20190517215438.6487-4-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190517215438.6487-1-pasha.tatashin@soleen.com>
References: <20190517215438.6487-1-pasha.tatashin@soleen.com>
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

echo offline > /sys/devices/system/memory/memoryN/state
...
echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind

Note: if unbind is done without offlining memory beforehand, it won't be
possible to do dax0.0 hotremove, and dax's memory is going to be part of
System RAM until reboot.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 drivers/dax/dax-private.h |  2 ++
 drivers/dax/kmem.c        | 41 +++++++++++++++++++++++++++++++++++----
 2 files changed, 39 insertions(+), 4 deletions(-)

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
index 4c0131857133..3d0a7e702c94 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -71,21 +71,54 @@ int dev_dax_kmem_probe(struct device *dev)
 		kfree(new_res);
 		return rc;
 	}
+	dev_dax->dax_kmem_res = new_res;
 
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct resource *res = dev_dax->dax_kmem_res;
+	resource_size_t kmem_start = res->start;
+	resource_size_t kmem_size = resource_size(res);
+	int rc;
+
+	/*
+	 * We have one shot for removing memory, if some memory blocks were not
+	 * offline prior to calling this function remove_memory() will fail, and
+	 * there is no way to hotremove this memory until reboot because device
+	 * unbind will succeed even if we return failure.
+	 */
+	rc = remove_memory(dev_dax->target_node, kmem_start, kmem_size);
+	if (rc) {
+		dev_err(dev,
+			"DAX region %pR cannot be hotremoved until the next reboot\n",
+			res);
+		return rc;
+	}
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

