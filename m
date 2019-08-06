Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E23CC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:01:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E9B208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:01:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E9B208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60FE16B0273; Tue,  6 Aug 2019 05:01:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C04D6B0274; Tue,  6 Aug 2019 05:01:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AEC46B0275; Tue,  6 Aug 2019 05:01:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27C1D6B0273
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:01:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so78280677qtc.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:01:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=pfOaJ1FQbtHzmV6FQpHCd39orW+vuYvzkWOG68m6uew=;
        b=gXMrNlNGcrzqxNPCNOgYBKU1P/RgGCW9kRziZzE4b65nfu3DEIOgBjlrkmVDpXVinq
         HEGFM4Y7VQwhfDnLSsBdD2l/reSug3i/ww4Ws/g1w1MJCfqeOz7PufRK89uwf8ktQAfB
         4xU+thZTAqBNSY/On/EcD+vddtCeU+fy8boQ7SHojXw583dEYK5RPWZLoLOmX4tiQm/K
         NWkuYJLGM7s2qXcfaLIuw0tWBLWTyA7RP30QbEldI2Vn2r/uZ5fvTy9yaTIrLYebQnHS
         +seMpqb2jgvT26lKOpHFJBEJfEEImFRvBU/bc/e0uOOqDFjOLek18njeue793Ay5MuXp
         OPww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRI+VYYw8eSI2Kie/53az1qvx29nqH1r7ZF7rdI3bNa46mW86g
	qs1pSokL4dFFRfXeFSDYQE4hsMfV01FKU2OMpJfyNWgMe5A7QlLLxpO3P8a5jaovGAosAB0lQnA
	1eVVwT6lZOqFmV6jY/KibvGBoyTpjI7M+D9B2h791Ke5SPuwZkMRHVK35I+ycuZDdfw==
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr1927581qvj.236.1565082108929;
        Tue, 06 Aug 2019 02:01:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjfzOGZ/ISnd9aMXRKkDdIEkHdwkD2gg516AcyDwoeK0EZ7vAVxXsHPyOUHVi2SnPBRLYU
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr1927531qvj.236.1565082108236;
        Tue, 06 Aug 2019 02:01:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565082108; cv=none;
        d=google.com; s=arc-20160816;
        b=SSsdPVNq9hwZ+ZUbaMHDyxsd+I9kuNtSCvm8ryzETJewrKhUy10kBbg8PtDxyQb8pr
         VnO2ru3NgV++W51zFnNNhZB17fjBcYjSCnJKwb0vxMYCXrB4UBI0s8Nj8SD3S+DFEfmG
         RWocz8VemgCu/uv32LFbSdMsTpaaNXzorPnQmefo9U3XO8h64dRQe04GCmsFUWKQkZlg
         56yvhojYrC3dipUA0VjZjxM3ZcjHo6SjoWCaikGi/VMSFXC383Mj9mWjxnPeckgysJOi
         A4fn+jqNYVFMLfHIRpBOZNpQQFyBRrH19+bzKLfjXrUJPlMvvPLodydVxKqrRQfisoDj
         IwXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=pfOaJ1FQbtHzmV6FQpHCd39orW+vuYvzkWOG68m6uew=;
        b=1FJQVjuDWSUzTFFMN9aCEjcafu7mjuIsa4BpDPbTNeMF3pXDf5eitGxbfwuqcq1gTD
         BXBfv/kTghxVrcEgIlV4HAO7C69tccwlMNkjuh3Dyi7ndN30U1RzWunr7rdJ505gvCc7
         sJKsJmv7qsvSZC9zUvnREoECbnXwDyJz6N9KtXzCO40jCRoxyEKHsZO6bgi17/Lz60Sb
         Tu3p847Fycx2L4nC3W1u8wopyYPqHmwFIF/OLfQv8zNN1cnTbPhacu1nJJDcT8bVH0BO
         S0Jnro9hSAX6BHFr5WBmh90UUPSk1tU5PpkL4Vj2otca83xqZvGvtCuE+S49dLuBvgBZ
         Q4wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x12si30919228qta.126.2019.08.06.02.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:01:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5DEB13082B15;
	Tue,  6 Aug 2019 09:01:47 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-71.ams2.redhat.com [10.36.117.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 039DE1A269;
	Tue,  6 Aug 2019 09:01:42 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Michal Hocko <mhocko@suse.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v1] driver/base/memory.c: Validate memory block size early
Date: Tue,  6 Aug 2019 11:01:42 +0200
Message-Id: <20190806090142.22709-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 06 Aug 2019 09:01:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's validate the memory block size early, when initializing the
memory device infrastructure. Fail hard in case the value is not
suitable.

As nobody checks the return value of memory_dev_init(), turn it into a
void function and fail with a panic in all scenarios instead. Otherwise,
we'll crash later during boot when core/drivers expect that the memory
device infrastructure (including memory_block_size_bytes()) works as
expected.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 31 +++++++++----------------------
 include/linux/memory.h |  6 +++---
 2 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 790b3bcd63a6..6bea4f3f8040 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -100,21 +100,6 @@ unsigned long __weak memory_block_size_bytes(void)
 }
 EXPORT_SYMBOL_GPL(memory_block_size_bytes);
 
-static unsigned long get_memory_block_size(void)
-{
-	unsigned long block_sz;
-
-	block_sz = memory_block_size_bytes();
-
-	/* Validate blk_sz is a power of 2 and not less than section size */
-	if ((block_sz & (block_sz - 1)) || (block_sz < MIN_MEMORY_BLOCK_SIZE)) {
-		WARN_ON(1);
-		block_sz = MIN_MEMORY_BLOCK_SIZE;
-	}
-
-	return block_sz;
-}
-
 /*
  * Show the first physical section index (number) of this memory block.
  */
@@ -461,7 +446,7 @@ static DEVICE_ATTR_RO(removable);
 static ssize_t block_size_bytes_show(struct device *dev,
 				     struct device_attribute *attr, char *buf)
 {
-	return sprintf(buf, "%lx\n", get_memory_block_size());
+	return sprintf(buf, "%lx\n", memory_block_size_bytes());
 }
 
 static DEVICE_ATTR_RO(block_size_bytes);
@@ -811,19 +796,22 @@ static const struct attribute_group *memory_root_attr_groups[] = {
 /*
  * Initialize the sysfs support for memory devices...
  */
-int __init memory_dev_init(void)
+void __init memory_dev_init(void)
 {
 	int ret;
 	int err;
 	unsigned long block_sz, nr;
 
+	/* Validate the configured memory block size */
+	block_sz = memory_block_size_bytes();
+	if (!is_power_of_2(block_sz) || block_sz < MIN_MEMORY_BLOCK_SIZE)
+		panic("Memory block size not suitable: 0x%lx\n", block_sz);
+	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
+
 	ret = subsys_system_register(&memory_subsys, memory_root_attr_groups);
 	if (ret)
 		goto out;
 
-	block_sz = get_memory_block_size();
-	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
-
 	/*
 	 * Create entries for memory sections that were found
 	 * during boot and have been initialized
@@ -839,8 +827,7 @@ int __init memory_dev_init(void)
 
 out:
 	if (ret)
-		printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
-	return ret;
+		panic("%s() failed: %d\n", __func__, ret);
 }
 
 /**
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 704215d7258a..0ebb105eb261 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -79,9 +79,9 @@ struct mem_section;
 #define IPC_CALLBACK_PRI        10
 
 #ifndef CONFIG_MEMORY_HOTPLUG_SPARSE
-static inline int memory_dev_init(void)
+static inline void memory_dev_init(void)
 {
-	return 0;
+	return;
 }
 static inline int register_memory_notifier(struct notifier_block *nb)
 {
@@ -112,7 +112,7 @@ extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 int create_memory_block_devices(unsigned long start, unsigned long size);
 void remove_memory_block_devices(unsigned long start, unsigned long size);
-extern int memory_dev_init(void);
+extern void memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
 extern struct memory_block *find_memory_block(struct mem_section *);
-- 
2.21.0

