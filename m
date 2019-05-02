Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DB5DC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8CD6204FD
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:43:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="PyyTBVSC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8CD6204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9B86B0007; Thu,  2 May 2019 14:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85C4C6B0008; Thu,  2 May 2019 14:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7258E6B000A; Thu,  2 May 2019 14:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 477A46B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:43:46 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k6so3298852qkf.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:43:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=F53mVZg38ORKpzG6u8tAANwm3nwFDbLr58RDkqAxcF0=;
        b=nrHo7r4t8lUrj4v4uCAYlN+1uBIOEeG/o8UQMF1zpPhTrdhJtct+C/pm8mfeyNakxD
         8MNqWqPXD6SKJW/pMSEdBCudyDgDZxP6d5buUXPhGJdrgivPAIM4SDnB0JZiFeuCxeXo
         fkXKbV/mMuSlZVyfXX2RxsmnShVflHsRRSZw/ijnLzECq37DONVZVRTGnr8Itu8l3Dzp
         6Tn1rXh2EuRTxqMFrV8p9QHVbX9bZCMlIxZS+lVs9RLiQkbPTr5sXp2VcVtpTBfwHbQ6
         7MgRJFj4zFusgMuIi2vwcwHYXalCS06Q13sii/9Pqd+Kt8+IwSsKejy5NV2eAXKOGYxC
         5CQA==
X-Gm-Message-State: APjAAAWs+6Zlz2Ynd9tKhD46FAE2GXs/vh3Jg3YgHDNvGeOC0brGCTuo
	YklB+tgg8v+Z8rO0Pf72T92hMSFRvKtUi2EfVPmZDm58HFW87cM4pimJitKIPtNWdfhVAkNP9YW
	P/dV+sjR0yCD40+255ym7rub17SFTD2Pqiw27ZYA9U3OoGUUgR545aHrCNfAzjQapFw==
X-Received: by 2002:ac8:1a10:: with SMTP id v16mr4568973qtj.32.1556822626014;
        Thu, 02 May 2019 11:43:46 -0700 (PDT)
X-Received: by 2002:ac8:1a10:: with SMTP id v16mr4568895qtj.32.1556822624741;
        Thu, 02 May 2019 11:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556822624; cv=none;
        d=google.com; s=arc-20160816;
        b=B0R+9GLxAbTT/AKCSh2sZQQKeiP6+S61KS+1KdZUY6ueI7GYa5aNlsuvTTfU4s3fyu
         E5UZe3kL9FHDBOICA/7ojHg/DwOIYpfJTIE1HGf8G5fAPog5rh+3+/wfcRfq3pVYq+Sr
         8YzKJ6ZPdLD1lvp7EZcJOPPlQIjzvfBzrDFH5xOiu8W0GJcVOeVrTpxdJewYJmT8sgZh
         Fak0sgcr0lPjh2z9vI6kxNVgcfCdy5UsMt1TO/ZmghUYdVrJ0aBTSYk1hy+gaAWv7i62
         5EUizY5I+v/yypnrdFfV6Nkd4ybtOR/flZ1FJyukojlbmduQYXxMBqGJPkLjZlFHdXkg
         u6bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=F53mVZg38ORKpzG6u8tAANwm3nwFDbLr58RDkqAxcF0=;
        b=SOJZ+tyirHrT/voHJcSorxzfEGs4GDYD9bwhsEtRPegYFOD+VAPeqlVF6e8TjSKEVK
         Z78E+yqD1HPHH5O6nLpwMLodkZoFS2jpLD7bAi19IpZ5fT54npRQdVrCXgaP49DK+KnE
         Rcwt5um3NyDnoXPbPKy7oICsls4xrQMnjAR/oy2m1ufV5ApwTMwyvstuoWdwCLEEKTu2
         KA++i6LKNiE6GI73OQvcNHSQmFfccptmjatltLS0Zj/j2K/EM04M3cj8shNfh5OZtl6Q
         d2jBUtaSal0L1+0Bv91fT341grmh5Kcpnyypvt4fqL9lwlEpd5pu8FMgE8oTbs+qozJa
         IhaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=PyyTBVSC;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t15sor4307363qvm.16.2019.05.02.11.43.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 11:43:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=PyyTBVSC;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F53mVZg38ORKpzG6u8tAANwm3nwFDbLr58RDkqAxcF0=;
        b=PyyTBVSCQ3AA7QeDsVoZcXkNxvscJ/Eubktvsu0ShHb2SYfsJHqxOAtwRUBbYO2Nhl
         vOyL7FoxPWAyfDeiPb+hBBEFYObZRK/QIpYfdZhTrCaCHDjO24HV9jTO15x+L8rv9QBD
         FGnVGHj9tbIiUsXWeJjjrrMlZKDIBMvMzIgCR5xCvL/6KohNIGgJhsSNG/fSj6XXKJqT
         t0Rv+SI6yWGseZZCK/dRe7U5S+GoFTC+StqtJ4naZC5rDJosDhBbXDxFxov1A40jPfHC
         dJqV3/+l/NnjkDFyD/8uj631iQSWrBko8wkUxRTAMyMUieMl4saojWrtndVA7LpmG4gv
         Ufgw==
X-Google-Smtp-Source: APXvYqyfwEAWWnvwijtzClV/lCkQK+L47PTgTei/5edOoaHHMny11XeQ+5u/49ncXcht4fFFuYhkew==
X-Received: by 2002:a0c:a94b:: with SMTP id z11mr4530210qva.166.1556822624458;
        Thu, 02 May 2019 11:43:44 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 8sm25355751qtr.32.2019.05.02.11.43.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 11:43:43 -0700 (PDT)
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
Subject: [v5 2/3] mm/hotplug: make remove_memory() interface useable
Date: Thu,  2 May 2019 14:43:36 -0400
Message-Id: <20190502184337.20538-3-pasha.tatashin@soleen.com>
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
---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 61 ++++++++++++++++++++++------------
 2 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8ade08c50d26..5438a2d92560 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -304,7 +304,7 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
-extern void remove_memory(int nid, u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern void __remove_memory(int nid, u64 start, u64 size);
 
 #else
@@ -321,7 +321,11 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return -EINVAL;
 }
 
-static inline void remove_memory(int nid, u64 start, u64 size) {}
+static inline bool remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+}
+
 static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8c454e82d4f6..a826aededa1a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1778,9 +1778,10 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
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
@@ -1843,19 +1844,9 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
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
 
@@ -1863,13 +1854,13 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
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
@@ -1879,14 +1870,42 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
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
 {
+
+	/*
+	 * trigger BUG() is some memory is not offlined prior to calling this
+	 * function
+	 */
+	if (try_remove_memory(nid, start, size))
+		BUG();
+}
+
+/* Remove memory if every memory block is offline, otherwise return false */
+int remove_memory(int nid, u64 start, u64 size)
+{
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

