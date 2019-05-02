Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5389EC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09907204FD
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Kz0i1rO4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09907204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4C46B0008; Thu,  2 May 2019 14:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54DC16B000A; Thu,  2 May 2019 14:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 418F86B000C; Thu,  2 May 2019 14:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0496B0008
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:43:48 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r132so3289681qke.8
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=O33Zl3X5/LIE/Jgf9f0gFRZS+Y+SVNG09T0WMnzjcjdhPNnn7RUHKqlW4ClsiqSeKc
         XhR08/tlBbU+oaJUqW0wPDw1FIv7CNUy1htQtmEYOL69OW963DNcnLMRjlfU73XVnF7Q
         S8yqRcwE4AaWPH5oz84PFnkr8I3TFWToX2NhPIFxbXqpByN0Hi7BeSKQn2nQsOSNoxBN
         yDgAK88jdYF+U4YSR6jb4CwP6n+PInn8CQc3HOhtrXO1XZySWbYZfzm8sQk1N/0AfAuZ
         OrboG/mjGwUPNs6DzjriQIIqMdOiqz4cKqN5/koTqgbHZ2ho6hgRggzst+ZsSgFO+sjl
         shAQ==
X-Gm-Message-State: APjAAAWt1GjDPU6sm8ZKSOB7cf7khMbalycMKtH/uAank/U36MYyGL29
	bNTx5k0621wK4f/ghAe9GJxyowMrgoNHSkogoy4s/DHS5hEUqwBKzvMYp3rbmbqgukz7SQJtn5b
	Peo7WGCR1nbWg18n7wnXVr/x3TebQ1BMLo2A8AxI+n5uxsDUDeCFM7rZrjn3ylw4ZWQ==
X-Received: by 2002:a37:5009:: with SMTP id e9mr4139761qkb.206.1556822627879;
        Thu, 02 May 2019 11:43:47 -0700 (PDT)
X-Received: by 2002:a37:5009:: with SMTP id e9mr4139680qkb.206.1556822626593;
        Thu, 02 May 2019 11:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556822626; cv=none;
        d=google.com; s=arc-20160816;
        b=Um/NGP2Y5edjwGIr3b0rj7U0kpGUQbLtlhnm01UWGrcxv4khUJpVBoiYOMdUOAVixv
         h7LY4B0ski3GZUo0FlMWuzqfoF0vALUr0vqkEJdEGYrV0vhO/vrRBoFeRKGKoufqgEA5
         eZFuoh5fJA6oeX+6ouuPFZJtTXzLXyzHm5byq2j0m2MjouWGPdvLv3J7PJR3SRW38SV7
         PkT2EwC1vbyt5/mkefgOsg6ojvAOd5bDwvIm3FESeTRwpSWtGJ5RsRKLWAuR7P1GlhW2
         7PiEIS+vpxLtsryEJM+fWx3LH8eltwHXPJM/0wV8wpyxeUKjK8e1b+HAqZfh66b0tgQw
         I4DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=ztHRI4b3jEElbnnmVqI2XmXhy59aoM/ioSOt4gCbWoPdW6Om3sY2QrQ/yFlsF4NBmS
         pOb3fl/69YeTz1Yd/deSqOueFxoserIduaFjwOAghwlG8jOBJE71KrJ4jAEdXiqDvVNf
         eT2aMvMRj1Usoe1wbW8k8WOIz+Pif7xJkwE90PF9L8A8e7aVgVugVIhtGrLEap5EzZPa
         sLZ30oZgrAMkBmF3yvUW2O1dOetJ/faGtZ+TVoEYS6OZaaUAF6ccz1VXOmPM4pET/WWP
         9wZskfrZDKUUCTVwsXu6lKgFgFjutoK14AJ1TjN4AXh9H1kGdMp3FZgeS2RDiveRJzaU
         fscQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Kz0i1rO4;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9sor26451813qkg.61.2019.05.02.11.43.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 11:43:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Kz0i1rO4;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8p3wsS4SMTLuQgzuXCRhTKHP61mCg8wFpFeHB9x4QIQ=;
        b=Kz0i1rO4XLenBHe0eXayRavWGw7pvnIFj5qwbjyLHk/JTkjzzMAusXSgeGztfw2jXT
         AzH2pV256L4jup5CB6VA42JG9lRPJYVWLrtDJCQDUK4EQXR2yj8Q80TY24L817JHSxmh
         spuIx6Z5shY9RIx1zMZAOkq55ZwXnBzneYb/OA0UTekFNXQmtBsUfMzl9t9YQELg8HsA
         BLChCaBKaoUuHkqkKNUfkT6HH30xNnSWRNZ6LbGEPBplAiDSCMZ4JS7ykdoiUMoi5e/r
         DseTc2Ralec84SLyABLLfoTQtUvda4DOocw5xSVDm+Kl2UHGf8zyXwN93fFAbcyycuLE
         MRaw==
X-Google-Smtp-Source: APXvYqwlR182BydaUd9wxvHRObZ5OHWhUVdD8TWzfsPIOWEf+7ldGKtgZ4Wt4Y7sgMqeTtP2DX+lSg==
X-Received: by 2002:a37:6087:: with SMTP id u129mr4356847qkb.300.1556822626323;
        Thu, 02 May 2019 11:43:46 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 8sm25355751qtr.32.2019.05.02.11.43.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 11:43:45 -0700 (PDT)
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
Subject: [v5 3/3] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Thu,  2 May 2019 14:43:37 -0400
Message-Id: <20190502184337.20538-4-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190502184337.20538-1-pasha.tatashin@soleen.com>
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
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

