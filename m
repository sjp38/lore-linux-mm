Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76038C73C66
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 308142073D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="CgnZ01od"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 308142073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FC668E0064; Tue,  9 Jul 2019 21:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AF9E8E0032; Tue,  9 Jul 2019 21:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A2A8E0064; Tue,  9 Jul 2019 21:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E443C8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:16:55 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q26so794666qtr.3
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:16:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=CVTJCjL61cT1sLEtn2w9JvdFUT6cQxdBQbzitEZ8G3w=;
        b=TuME682oXRJ/7v7UXnSDNb0yeTKfMj1sitggQMjvXpNHdEk4Cegrh3caqUQq/DQHr3
         wJmwIPkPsurG68sGyJNP/2ENxSNuQ75NXhYp2yusRf9sayWWqhrRZLE9YYmaZefZsB0p
         6iXSY2dZ+EYYvRt1UKMjuy2WZoHNrxv8TzbYCBOc0vjyQSr1Ar0YKzWlsh9ElRQKB2Gy
         IaRgNlqzazzQ2hAIs7kQlWkQ4FbPxXQwd9riC/KjGEQGd/1a1AmlCVblApgbLh5PChJF
         04ylkqrLdgiEU/Ae5N1PW6S7R4IPE8wyNR3mdSa3alpt2eI7wRpbSGEkTcCH3tC1t0i1
         mZgw==
X-Gm-Message-State: APjAAAUdR8SZmRz73QVSA3gXdjNICXh2CtMdFJXqzgVZGkdBnH4/Pfc0
	tjk5vhVN2sKu/1EUaf50NyAQvjQBZAyZmLUTRGyNUD8Qkddag2vyiw8yzO8Bx/GE4TEaKo+mCNP
	KRvxaWMJdfrGPCTqAwi0vZ2VEhB4i29xI2MgTUjuVmS+e2+YNARNTtGxGkyInm7QhwQ==
X-Received: by 2002:a0c:b4ae:: with SMTP id c46mr22510515qve.230.1562721415695;
        Tue, 09 Jul 2019 18:16:55 -0700 (PDT)
X-Received: by 2002:a0c:b4ae:: with SMTP id c46mr22510454qve.230.1562721414585;
        Tue, 09 Jul 2019 18:16:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721414; cv=none;
        d=google.com; s=arc-20160816;
        b=bk7t6ofeZzBHBJA8qeRz9xXmbl3xGvqFKj0tCoq0DPei6wscCgY9QCWpq+hWARm5LS
         sPO6BTMUjfKskgotumDttUEMEfUcnP5AKHw4GNAlJKB78QQ0ZNyXMSk+wrEGh3A7Twx8
         3l1NJJ7H8cYNpwjqrXldKjMOsNhZDjole2J4H9t7DEIRNvEhAGO4QiQIMBR75F9JL431
         tyvEVx32amJf5hlzNY7bPeyCmyBH4jySpIkD7nmXmrm53DljC3lhaf3WzWITRFpEihJj
         y0CMIwjJ7LPnV5Q0aYkvPZLB/XdD1GsFCHSCfJNpzAwbL+INtnL1KW0j30VfjRuYCCHy
         4/1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=CVTJCjL61cT1sLEtn2w9JvdFUT6cQxdBQbzitEZ8G3w=;
        b=SXEP2txCGBooORCecJ+gwhRrGiqtnKPaXLuNZcJ4t78oYbJO64wIbL+7R4Z5LTD5tB
         MGqmnMJJxc1GS/XCk/wXLjYDmMcsGVfvvnHpfO5wbNHhlzTVDMHyk1ptNS/th/0JfZ5x
         kcWJ93NUv/uvVwuvf3i2EigVimEFh4HH7dnXIfgHKv2/DFaJnQviRFIdT6FD43oLivUz
         ZUdqijzzWMwJJy75jDeo/LGa2NLJIKmlHw9WbwT4BqdpKsfqrnOvI7IDpYXVpTbKX20y
         GJPlcdGo25kfASqaVCceQMkCHxWA6Sqrlebl4FTqXuFBlsHp3Lk47Ao4nfEjZtwR9q+Z
         Fm4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=CgnZ01od;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c27sor242686qkk.192.2019.07.09.18.16.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 18:16:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=CgnZ01od;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CVTJCjL61cT1sLEtn2w9JvdFUT6cQxdBQbzitEZ8G3w=;
        b=CgnZ01od2X5o9ZxnU3YxLA5iP6DGIirNV+yqbmaGGd37pbDw+kMM0vJ0slJQWHOgGz
         89n/NsZaNntd/HsoETEEEWONOoRpUvU+swsq3e0sogqmdn7o3c+6pgPWb0uMVxE0WqLg
         +7f3548VjFl28RcqVuZy3NVuR0FeaZeD2MTcqLaGipojj6pr7WHfHlZaKZDd6uR230L0
         JT4sctjsx1qzKG+wB2YuOCU2TWArwX6x/FgTtjBrPZrz5jK0b+CWmWzZQlS4c5VoVZtr
         JemrX7sEW8IBBYGZikmfiz6eQN+ryIQdDAWkxCVDBjzH3tTwnd+byUmpjy4XiunxSWhU
         BXQQ==
X-Google-Smtp-Source: APXvYqys9rzeaiHpJCQSMGWFJQogIT5Nl/kLTQmCtVzEY7YWfkQtFYUrb2NcrUN7cHm0A3qL/HJzCg==
X-Received: by 2002:a05:620a:1661:: with SMTP id d1mr21322876qko.192.1562721414251;
        Tue, 09 Jul 2019 18:16:54 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u7sm260057qta.82.2019.07.09.18.16.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Jul 2019 18:16:53 -0700 (PDT)
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
Subject: [v7 3/3] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Tue,  9 Jul 2019 21:16:47 -0400
Message-Id: <20190710011647.10944-4-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190710011647.10944-1-pasha.tatashin@soleen.com>
References: <20190710011647.10944-1-pasha.tatashin@soleen.com>
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
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax-private.h |  2 ++
 drivers/dax/kmem.c        | 41 +++++++++++++++++++++++++++++++++++----
 2 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index b4177aafbbd1..9ee659ed5566 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -45,6 +45,7 @@ struct dax_region {
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
  * @ref: pgmap reference count (driver owned)
  * @cmp: @ref final put completion (driver owned)
+ * @dax_mem_res: physical address range of hotadded DAX memory
  */
 struct dev_dax {
 	struct dax_region *region;
@@ -54,6 +55,7 @@ struct dev_dax {
 	struct dev_pagemap pgmap;
 	struct percpu_ref ref;
 	struct completion cmp;
+	struct resource *dax_kmem_res;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index 4c0131857133..c52a8e5f2345 100644
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
+			"region %pR cannot be hotremoved, error (%d)\n",
+			res, rc);
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
2.22.0

