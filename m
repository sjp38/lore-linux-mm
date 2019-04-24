Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47270C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F29AC218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:26:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F29AC218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A03366B0266; Wed, 24 Apr 2019 06:26:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B0D46B0269; Wed, 24 Apr 2019 06:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A0AD6B026A; Wed, 24 Apr 2019 06:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3476B0266
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:26:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f89so17324278qtb.4
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=ecnOAbwG8mUZHjsAt43/D/e3fDkmBeuJWIE+p8a1cgc6ilflfIs7AlQx74KcP5faLx
         S8okv8N4o+SULCmKGCXDQg3v9/gb1M7ebtBKeHeiW17WwmlzdmFWrQhJc3LIg6AEwbwj
         gFu6QB/ROvRMMKZI4l/9kYxZ1xu0vKX2ixb2Wb4FeCI2SqHp4+zJ28nMRbZ68ofHdtxr
         GiCI4D+EwslmBFnl+0e5DLrMyqo6nFhYIZ05UVv2mF8Vik3jgCDgJl9Pw+KHF4n4vJuo
         TNOUlYIfdTScPEULy5bi8tg8SnR2eEde1L4ccM2QH+iu8hikJyggAYNPvRyXcTPLlQXo
         U89g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUxwUtYHy/ogiBGsXidh4nICbfui+fdprz8yghva4kWZqsJyNfC
	7XN7YNGSaGrkExGafA23QoIOCPz5cLwnucq5zMxN0XswShZ2akxZEuZa1M5qc1+2xDm0mXwXDhv
	bi7LJbBw/OxQESa5Y+Loto0kdbG/TBuZzPoKzGcS1L1Fvcz6Y/FK1ajCGYbaUSD7saA==
X-Received: by 2002:a05:620a:1389:: with SMTP id k9mr247822qki.192.1556101572186;
        Wed, 24 Apr 2019 03:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk5WwAih+n1AJV6CsLUWg8AyONoz1LNBD8jFNREmkQOGUTuQewEeCqrY8WmHpjWWdCnDQx
X-Received: by 2002:a05:620a:1389:: with SMTP id k9mr247784qki.192.1556101571520;
        Wed, 24 Apr 2019 03:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101571; cv=none;
        d=google.com; s=arc-20160816;
        b=SjnPR/FY4osUQ2GflBL+g5YJdTZXpca9mX+EZhVV7SHeb/X9Jj1sC+HGV1j0T4NQ+V
         2F6oR1Fs8/yYphsFNF6oQd6QoREil/mcc5HLyv+7ZiasxvzjmouSEBWLYVfdY+jAQ/MR
         LI/7t86tzahLXq6oNsHi0bW+BLeNTLIhiAFl9eL0hkQfJ2opIIssm9AayTgymgm1oaum
         sv3z6rJ8e7Izxs3pX/zCvkGVLTph154ShVZERBPt3QYUFCEFnMB6OJHY8vVrz/bdcsF6
         G7QDuVR9L8rd0fEzWAQuMmnY6MHPNCEJNExnwzBtSO0/HbQIk/Mvw5nUW9Jfn1BQfhQV
         8wnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jwqamueXeySfeFxINzjppTw9mQ9ehliTYQXoU7pLAas=;
        b=c0s2uMfS16Mp/RzJCyjDxhD7H1HMPTDiCXnfxEyTQ7Nx26eWfMYA4XyM1YOdGN2piZ
         P8hb1JprOZdPShggctYCeA1NZLK9ZJf9uE9ch+bxd8y4iIgPvKMCO6lCcRcAvcNsrdza
         J56KHgioBABCxCAPaTJPI42v6XYG3d1izQuqXk5XlJPQYNLBD+2SHLAdp8MeWfT+jpHL
         RzVAnZKwEl2xAfMHk97rgajWm+s3zTuHrACJZtTqhi8Ro3uC1Ygjm7d8bKEMCkXUtc7A
         Mjtxn5pvZHW1Cu+dgG4jT2hrhHPk7Bv1JhOc4Jk714i7GUgFM2ldx4EWGmtFCzIt2dax
         OxwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x26si6129187qto.160.2019.04.24.03.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9334940F46;
	Wed, 24 Apr 2019 10:26:10 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 79977600C4;
	Wed, 24 Apr 2019 10:26:07 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH v1 7/7] mm/memory_hotplug: Make unregister_memory_block_under_nodes() never fail
Date: Wed, 24 Apr 2019 12:25:11 +0200
Message-Id: <20190424102511.29318-8-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 24 Apr 2019 10:26:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We really don't want anything during memory hotunplug to fail.
We always pass a valid memory block device, that check can go. Avoid
allocating memory and eventually failing. As we are always called under
lock, we can use a static piece of memory. This avoids having to put
the structure onto the stack, having to guess about the stack size
of callers.

Patch inspired by a patch from Oscar Salvador.

In the future, there might be no need to iterate over nodes at all.
mem->nid should tell us exactly what to remove. Memory block devices
with mixed nodes (added during boot) should properly fenced off and never
removed.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c  | 18 +++++-------------
 include/linux/node.h |  5 ++---
 2 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 04fdfa99b8bc..9be88fd05147 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 
 /*
  * Unregister memory block device under all nodes that it spans.
+ * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
  */
-int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
+	static nodemask_t unlinked_nodes;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
-	if (!unlinked_nodes)
-		return -ENOMEM;
-	nodes_clear(*unlinked_nodes);
-
+	nodes_clear(unlinked_nodes);
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
@@ -827,15 +821,13 @@ int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 			continue;
 		if (!node_online(nid))
 			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
+		if (node_test_and_set(nid, unlinked_nodes))
 			continue;
 		sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
 			 kobject_name(&node_devices[nid]->dev.kobj));
 	}
-	NODEMASK_FREE(unlinked_nodes);
-	return 0;
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
diff --git a/include/linux/node.h b/include/linux/node.h
index 02a29e71b175..548c226966a2 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
+extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
 
 extern int register_memory_node_under_compute_node(unsigned int mem_nid,
 						   unsigned int cpu_nid,
@@ -175,9 +175,8 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
+static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
 {
-	return 0;
 }
 
 static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
-- 
2.20.1

