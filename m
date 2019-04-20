Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EC72C282E3
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D26B320854
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="JPJzZ5OI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D26B320854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06DF6B0008; Sat, 20 Apr 2019 11:31:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8826B000A; Sat, 20 Apr 2019 11:31:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 980D56B000C; Sat, 20 Apr 2019 11:31:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8216B0008
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 11:31:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t67so1318568qkd.15
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 08:31:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Clj8uwwo5TlLh2AL+5SY6gvLnqtqKsZdzrxWwRvWBiM=;
        b=Nf6V9vRVMJNN9F0nvLuFCbuLHNVkkeV/Cqy4gs7kqi2e1wHeKuykABRcmjqINLgui7
         0xUzMkXAI2VQH0q8aVWABwQw8nPiC4MH2hOTokI0/U3mNJ2TBHayZo5iTReKaALFVrvs
         ZTJrHSkf9c9LTRd82m1KDoMWAyTsqxBOXpck+It5NSy7reTP/hS/iIMMYGrI4Wp2yArk
         ATbZXO8DCr4VDmtCxGk8X2N/IYdAyYsjJCoDBf6yLYYi4vp8qceYwSLoUksB6oV46keL
         lX0M5GmCHI3DxzF0Klv8VKRmQLbS2qf+r8O9bgoiI3klMGJxL1GrVBt6A/WyjBR3nFYZ
         dVSw==
X-Gm-Message-State: APjAAAV04fu4/zmLI8ObrNOsPU7FPjw1nCroA3f7FkLBTyq4AFoWB8PH
	3KaDioP4u5j1aE3ZDd/kQBVo+y3oqnLvhOXX7i1YJ0Epia4t/rr48B2q4yG62wH2h/LSVhHDYgp
	4xzWyLS+iHZDfi7e3fy/pZ8dJaSUkRfgYSlM2vmQHZeBTnaAwySuMN8s7jVJN9uh3qQ==
X-Received: by 2002:a37:a34a:: with SMTP id m71mr7843669qke.323.1555774316157;
        Sat, 20 Apr 2019 08:31:56 -0700 (PDT)
X-Received: by 2002:a37:a34a:: with SMTP id m71mr7843559qke.323.1555774314510;
        Sat, 20 Apr 2019 08:31:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555774314; cv=none;
        d=google.com; s=arc-20160816;
        b=e3ExgouKjizQGI440G4XV+lWkHMPWdaUN5y9bSLHm0ZYqEebTNx/aGpE5SPASeiyXX
         UlpK5wz4xipVGYMx7AM8Hzk9MHio7Fz0Axb3rhdIuirhZBTlGMx8RBlFQKT54ZfHu+Uf
         LUAegli+IHWyqrsOpEO6CymhWgvxPiSs9VBu2QVbifvWqNMLF7UmJXQyCJZC00WpdPY7
         OArj5SjclRMDLVteQ7md27MKCYHMMswq/oinOWZJ4heHb50mQwmtcfe802qtzgcxSX5l
         7d8u3oZ8Y5VH5l6PzVw1PTUXYli11/U+KOd/RFBoH5l8wGo8p+FDw6v8jlcZyfGfIhPB
         Lftg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=Clj8uwwo5TlLh2AL+5SY6gvLnqtqKsZdzrxWwRvWBiM=;
        b=ZWrNtO4G6XMYDyVghhRHSu5oYovBYo1L7xu7O+Z68U7r2rs4/Te5DawiYeRc36HoBe
         /S3LBCteq9alrVJB/hMPVPcvgoSL6LG7oY00mp8jBvOKH/VorKzGF0L60/mrxn34YLRU
         TBBHsTIPVcoJq4HzXqwQD3/NhfqIj7D5TwxihdNtTy19GNy/T/7dOaY7dZyklp22POt0
         hhdUZBcFKe8aqe5yykKLAwutdhZhDz2AM932esNTHSKKBSVQ2xRYZkbNm5BeOIyZivte
         M1Zk4sEwKHaoq3gETk1L/GDBfmZXKF5G5B8+WB32pJQgkmbJxCou5JjfYD3mT8iYG1Ww
         xArQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=JPJzZ5OI;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7sor11132257qtb.63.2019.04.20.08.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 08:31:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=JPJzZ5OI;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Clj8uwwo5TlLh2AL+5SY6gvLnqtqKsZdzrxWwRvWBiM=;
        b=JPJzZ5OIKsLYmvTIdkFML/dY72CPRTW2cT1SIq31qcyFxvWqMafajQMhQFxhcBOPTU
         8AzB3qNhiJmnFlWB5HqQAvz8AGpUtICShYYnF4DOHmWErHByfa3aiDWfCZMtV269BAAY
         ComE68zI6lRgCS/Xct0un5xrG/E06s0FxD8CFTL4yGNJmepVb515K1dMoVsrPJaC/SRz
         OBGvYtneZKjRG5lqWq6EnLUu26e6NOpYPYFIRZ72cX6MjO8E2aVpD1MQP7Cazw/2FkcL
         ZEnWbFIEIG7Vz5OYRaxd7zvnnT9Dd/Tp9eJ4w/B4eBR4YyTWf6PKF5d+M93wGVDSP0fQ
         R+4Q==
X-Google-Smtp-Source: APXvYqx+mhwHAne3YPmJNiH6uMUBiZOZZazvJRAODWFHnY5wdXYRB8uUqucch1+iEUrDBmqThGGBGQ==
X-Received: by 2002:ac8:7687:: with SMTP id g7mr1627560qtr.114.1555774314241;
        Sat, 20 Apr 2019 08:31:54 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n201sm3976523qka.10.2019.04.20.08.31.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 08:31:53 -0700 (PDT)
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
	jglisse@redhat.com
Subject: [v1 2/2] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Sat, 20 Apr 2019 11:31:48 -0400
Message-Id: <20190420153148.21548-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190420153148.21548-1-pasha.tatashin@soleen.com>
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
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

This work expands the functionality to also allow hot removing
previously hotplugged persistent memory, and recover the device for use
for other purposes.

To hotremove persistent memory, the management software must unbind it
from device-dax/kmem driver:

            echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 drivers/dax/dax-private.h |  2 +
 drivers/dax/kmem.c        | 77 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 75 insertions(+), 4 deletions(-)

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
index 4c0131857133..026c34f93df5 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -71,21 +71,90 @@ int dev_dax_kmem_probe(struct device *dev)
 		kfree(new_res);
 		return rc;
 	}
+	dev_dax->dax_kmem_res = new_res;
 
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * Offline device-dax's memory_blocks. If a memory_block cannot be offlined
+ * a warning is printed and an error is returned. dax hotremove can succeed
+ * only when every memory_block is offline.
+ */
+static int
+offline_memblock_cb(struct memory_block *mem, void *arg)
+{
+	struct device *dev = (struct device *)arg;
+	int rc = device_offline(&mem->dev);
+
+	if (rc < 0) {
+		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
+		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
+		phys_addr_t spa = spfn << PAGE_SHIFT;
+		phys_addr_t epa = epfn << PAGE_SHIFT;
+
+		dev_warn(dev, "could not offline memory block [%pa-%pa]\n",
+			 &spa, &epa);
+
+		return rc;
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
+	/* Walk and offline every singe memory_block of the dax region. */
+	lock_device_hotplug();
+	rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
+	unlock_device_hotplug();
+	if (rc)
+		return rc;
+
+	/* Hotremove memory, cannot fail because memory is already offlined */
+	remove_memory(dev_dax->target_node, kmem_start, kmem_size);
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

