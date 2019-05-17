Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C6E5C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FCD72133D
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="OCk6/zZy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FCD72133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0B2A6B0006; Fri, 17 May 2019 17:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70206B0008; Fri, 17 May 2019 17:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898C26B000A; Fri, 17 May 2019 17:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 651026B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:54:46 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l20so7766849qtq.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=oZtfX1EsFJjeahXRqy4pGct5cturWJyiPbutyS49o0o=;
        b=W4OEKcobouoao6QpDqZCz26ukJ7pnXKgKJj4xLHXfQR3n7YLGpdx42xBpZAu5oXat8
         9EuthqsJjun/1b5jDdTLL49Ksw3HXR0gd92mydWpNsGM8f4Adj2lKsvaaFJ6wa296bNO
         XAxT3bFhvvHQ4WKaU3cMt1JuMw0W8lPmFuIRcU/dXC5gZ7v48JSsLaMF8avFO+gbt6em
         Nkjm6lP3/TcmRAxmm7Ko2KxgULObnj70cwXWrDRel5Rrt7v3V7acUoYBPC4fjT76QhRa
         WG9F+AYerH8bCU+STnggJUqEM7YKC9BscWuHktadU+1Q4ebpmiS/XAAHmPNN9pGBU0fC
         rFMg==
X-Gm-Message-State: APjAAAUzN2+NNsP0KPLIWTS28WOlN86xOE6yCSrr6kvX/1PhTlzIgh2o
	5Id7BjInrcJv5zp5vfrXrIGqIyuVFhUInv3ITsAS+tjMYUntwLhD8P5w0WBCXx8thLeDavN5doW
	5a8P8qjjJ4YLQBk3CY8iv5FSV50pm5GTaihTaPgiwvmfKJKaU3eSk2Po6rCycLLo/cg==
X-Received: by 2002:ac8:33aa:: with SMTP id c39mr49832502qtb.258.1558130085705;
        Fri, 17 May 2019 14:54:45 -0700 (PDT)
X-Received: by 2002:ac8:33aa:: with SMTP id c39mr49832467qtb.258.1558130084915;
        Fri, 17 May 2019 14:54:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558130084; cv=none;
        d=google.com; s=arc-20160816;
        b=lhj5Y36MT7s082cSjxfQ+FL4SiQ8fD+uG2ymbw/xLTJtCL7yY6DBLLYyIZA8fQ0C6D
         lByHlUeLsn3APRB+Nvksap8xu/heePBCDb30iBrjvW9WeCsTqDJqZUlxHPYi7ZUIDX9w
         SJYDYmhQPWgOEGUL2o2kOeL4sVYJW4APG+bvQntthpl6BTDfa+4nWe11kOOagrbN/Hq5
         y18IQwUXXyLjnAEsNM146Vz/7hT6TW8OLY0fepHW5VPOB248baTZFAbExyM/jCOeaAiW
         30ZgKv1iGQhUQkp1rh+Sueh+MoM1ITlDrZELOqNDnvRNRIYeIYEuUM9r1YwsWdkGBxqW
         Sh7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=oZtfX1EsFJjeahXRqy4pGct5cturWJyiPbutyS49o0o=;
        b=QkcQVaxIv1hyJ/b/c3js0w3uB0e0WLIlMxswBSrYgjD2bA4aHtD1Z9QALbGcFZraXL
         wuF++JFGpK6o37UF1BlbeVpB0/HZAtjYUKfMqzKfrusvH4ebwJKS5o2OQ2HhmRhN5vRk
         uA9hFpRcGDAtK4WkjlB4TQ5eKUULb1/41lM9muKa+v5bCLDSEvHuMthR/tXZHfATYTJw
         8r37x7c+ooCIdtFAqk+AzzYaB9mcD8JWfQYtoQ5vZJIEf3W35pRwcx96Dw4VQ1oQjoL7
         7Ft1LCibcjIvoZUX/kWwn1BYtXPMX3oDeBl0dqggILKycuA0fT4yWcyHG63qzOsqB1M9
         UxUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="OCk6/zZy";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i59sor7872101qva.50.2019.05.17.14.54.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 14:54:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="OCk6/zZy";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oZtfX1EsFJjeahXRqy4pGct5cturWJyiPbutyS49o0o=;
        b=OCk6/zZyF14XcPyyMATB4Ym+LlfbjeEqQItqmdENfhxAIL7cHoM94ugihG5R1YlUwP
         jyOovQljik1bZ9u1Q17gwNSzs//6T0sHHsn2nZn6oduYrc1RwPHPU82m9/ULK5W2vkrF
         4+ZOr0KMFsimF91CAv01CSFgbFsxosShzFArqF02FMtG9sDp0Orljcvp+xse0RqkWqKq
         K3kiIonSoJQg0yVwJ2g6tZMJKiovC3dzhCAAP42XaahkEEEEZ8Qb3VLkPAin2xpWGCFO
         1HB+ik713/SslbvcIJeCr1EhRo4dQwxqJXMBiS6l96Ce9QQeD79P47HlY+Bi+I+kUnbX
         KdxQ==
X-Google-Smtp-Source: APXvYqw1HhlmDQ1zjvj92mE60iFZ0AD+1AWuI0vYk2b6i/mKmMR7uORFYBtfk6du8rP1a68lCkbwRw==
X-Received: by 2002:a0c:9ac1:: with SMTP id k1mr47616206qvf.36.1558130084638;
        Fri, 17 May 2019 14:54:44 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n36sm6599813qtk.9.2019.05.17.14.54.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:54:43 -0700 (PDT)
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
Subject: [v6 2/3] mm/hotplug: make remove_memory() interface useable
Date: Fri, 17 May 2019 17:54:37 -0400
Message-Id: <20190517215438.6487-3-pasha.tatashin@soleen.com>
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

As of right now remove_memory() interface is inherently broken. It tries
to remove memory but panics if some memory is not offline. The problem
is that it is impossible to ensure that all memory blocks are offline as
this function also takes lock_device_hotplug that is required to
change memory state via sysfs.

So, between calling this function and offlining all memory blocks there
is always a window when lock_device_hotplug is released, and therefore,
there is always a chance for a panic during this window.

Make this interface to return an error if memory removal fails. This way
it is safe to call this function without panicking machine, and also
makes it symmetric to add_memory() which already returns an error.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 64 +++++++++++++++++++++++-----------
 2 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..988fde33cd7f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -324,7 +324,7 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
-extern void remove_memory(int nid, u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern void __remove_memory(int nid, u64 start, u64 size);
 
 #else
@@ -341,7 +341,11 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return -EINVAL;
 }
 
-static inline void remove_memory(int nid, u64 start, u64 size) {}
+static inline int remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+}
+
 static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 328878b6799d..ace2cc614da4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1735,9 +1735,10 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
 		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
-	}
 
-	return ret;
+		return -EBUSY;
+	}
+	return 0;
 }
 
 static int check_cpu_on_node(pg_data_t *pgdat)
@@ -1820,19 +1821,9 @@ static void __release_memory_resource(resource_size_t start,
 	}
 }
 
-/**
- * remove_memory
- * @nid: the node ID
- * @start: physical address of the region to remove
- * @size: size of the region to remove
- *
- * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
- * and online/offline operations before this call, as required by
- * try_offline_node().
- */
-void __ref __remove_memory(int nid, u64 start, u64 size)
+static int __ref try_remove_memory(int nid, u64 start, u64 size)
 {
-	int ret;
+	int rc = 0;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
@@ -1840,13 +1831,13 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
-	 * whether all memory blocks in question are offline and trigger a BUG()
+	 * whether all memory blocks in question are offline and return error
 	 * if this is not the case.
 	 */
-	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
-				check_memblock_offlined_cb);
-	if (ret)
-		BUG();
+	rc = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
+			       check_memblock_offlined_cb);
+	if (rc)
+		goto done;
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
@@ -1858,14 +1849,45 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	try_offline_node(nid);
 
+done:
 	mem_hotplug_done();
+	return rc;
 }
 
-void remove_memory(int nid, u64 start, u64 size)
+/**
+ * remove_memory
+ * @nid: the node ID
+ * @start: physical address of the region to remove
+ * @size: size of the region to remove
+ *
+ * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
+ * and online/offline operations before this call, as required by
+ * try_offline_node().
+ */
+void __remove_memory(int nid, u64 start, u64 size)
+{
+
+	/*
+	 * trigger BUG() is some memory is not offlined prior to calling this
+	 * function
+	 */
+	if (try_remove_memory(nid, start, size))
+		BUG();
+}
+
+/*
+ * Remove memory if every memory block is offline, otherwise return -EBUSY is
+ * some memory is not offline
+ */
+int remove_memory(int nid, u64 start, u64 size)
 {
+	int rc;
+
 	lock_device_hotplug();
-	__remove_memory(nid, start, size);
+	rc  = try_remove_memory(nid, start, size);
 	unlock_device_hotplug();
+
+	return rc;
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-- 
2.21.0

