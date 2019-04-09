Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7E13C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8569120883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8569120883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 268B06B0007; Tue,  9 Apr 2019 06:02:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 211146B000D; Tue,  9 Apr 2019 06:02:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 091E56B0010; Tue,  9 Apr 2019 06:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCF976B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:02:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s70so14081076qka.1
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:02:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=74ERUBoHJPrSHJLqNHZrJXdfWEaat/pYAfyl8SvmS20=;
        b=KVHWxYIpUFEQYjqISyy6wdkYh8lALbYlghxhV6038VEzLKlB13HhD3NR+/0I3MmqS5
         bXO5PPkQantmy/twkL2koRUu+kZ8RQbKET84+ealK3nImoEokXvvRsmP4AVdMfxPVdnl
         +HtMXq29dMDzuvgKCcjU9EqrSz68mPWZz4YktM8dUKS8h6f3X9utKCf3xbOhEDK3nRrN
         Xbry/crCSfKLymEmwRCnIo03cngaHSCsjRjblId5PbYXC7mYlhxGJvFfthZN7kmQuhmn
         uMJm9Q26rLDLKNu6858K/E+Y0dQ81583cEJKGiBQF779VnCQ7yXGoLsa9qDlqyMaLgwb
         VKBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUaxTerhhyoTet1vzvmR5qnnPhERHxpJRSjqhYS8Lj7P7n3KM14
	LdWJx1r984x6TzORjO0MimrJl3cMcd1GKZ1h/9UkqLf2wq6fzZ6bqnil7hy7OCGakGULF8acCJ4
	tDa+3ILkv6TS/cYQwzW33o5ElWqacWnWLZ/tt73OtjV1NbGXJFmHImGcvIJOszl2rgA==
X-Received: by 2002:a37:7381:: with SMTP id o123mr26048453qkc.96.1554804125658;
        Tue, 09 Apr 2019 03:02:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSgt8T2z3qmK8qXWjxc0JSp4NEOKNJdynYL1jO/FfzAz/J4/+6nAt5ZZoibivFe4C/TaHy
X-Received: by 2002:a37:7381:: with SMTP id o123mr26048374qkc.96.1554804124488;
        Tue, 09 Apr 2019 03:02:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554804124; cv=none;
        d=google.com; s=arc-20160816;
        b=eHo3eWOawb0lp/mcyGw+apcGp9FWBfkqcvO9/ertx1Qokb/ea46t+V4b6Hf7ATB4Nt
         HCTxWcdLGy6Dxc8txPJfD751i+dsz7bRsOGuubBa002Adeitm7ll5ZKXwFYGaqLSBpad
         igsc4ucvYbQ6wMXC0On3hQJRNhzrda6U54m6dppoANNBLKkG3Rd2o+n2vzxEPNPhKJFC
         mJH6JUoZLzkR1z/oBBS4m/sEfDQzxpn7UMmR0cQz9hqleSTRKE32B7Xzo8u4Wso4ytOE
         qZUW6yuGjF9uj7np/7kCxiX3vemKW8JdN6iceaoT+aMZCMd+8+a40e6eTrG0IdhpdOT7
         X5TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=74ERUBoHJPrSHJLqNHZrJXdfWEaat/pYAfyl8SvmS20=;
        b=Bokh8C8/8svrmhp/2bnbJrrpvZ+s3phZmYNoTaz6yPlbpv/ixMa4idSnXmAoMofwAq
         yTTuZkeOOXKjcjyPgwBMTsIEswy5s3BkNCSsqbnBZ6Q4zk8k3zUBSe30GEvHjXXHIc/r
         HmmoaLKm4zO+Mu7oGP+lHs6Gwsh4FQ8o74KT3S8cI3Vvhkx4YsweSeCr9QuRBCnXljC2
         uXw3yI9JxpbIHJO72qjX/BsURrD1zQvnfpfKEuaoOeHvpA0GLQoHcr2CpTeauIUELkB8
         /NrepMlNcPenbF2ZE+XdLBvn0kFjNcmB1qx+KjWU9zUEQ1xeIpQAA7+yGl2rWSmbTOia
         pneg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u17si624711qka.140.2019.04.09.03.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:02:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 98722307D860;
	Tue,  9 Apr 2019 10:02:03 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5767F5D721;
	Tue,  9 Apr 2019 10:02:00 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after arch_remove_memory()
Date: Tue,  9 Apr 2019 12:01:45 +0200
Message-Id: <20190409100148.24703-2-david@redhat.com>
In-Reply-To: <20190409100148.24703-1-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 09 Apr 2019 10:02:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__add_pages() doesn't add the memory resource, so __remove_pages()
shouldn't remove it. Let's factor it out. Especially as it is a special
case for memory used as system memory, added via add_memory() and
friends.

We now remove the resource after removing the sections instead of doing
it the other way around. I don't think this change is problematic.

add_memory()
	register memory resource
	arch_add_memory()

remove_memory
	arch_remove_memory()
	release memory resource

While at it, explain why we ignore errors and that it only happeny if
we remove memory in a different granularity as we added it.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4970ff658055..696ed7ee5e28 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -562,20 +562,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	if (is_dev_zone(zone)) {
 		if (altmap)
 			map_offset = vmem_altmap_offset(altmap);
-	} else {
-		resource_size_t start, size;
-
-		start = phys_start_pfn << PAGE_SHIFT;
-		size = nr_pages * PAGE_SIZE;
-
-		ret = release_mem_region_adjustable(&iomem_resource, start,
-					size);
-		if (ret) {
-			resource_size_t endres = start + size - 1;
-
-			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
-					&start, &endres, ret);
-		}
 	}
 
 	clear_zone_contiguous(zone);
@@ -1820,6 +1806,25 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
+static void __release_memory_resource(u64 start, u64 size)
+{
+	int ret;
+
+	/*
+	 * When removing memory in the same granularity as it was added,
+	 * this function never fails. It might only fail if resources
+	 * have to be adjusted or split. We'll ignore the error, as
+	 * removing of memory cannot fail.
+	 */
+	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+			&start, &endres, ret);
+	}
+}
+
 /**
  * remove_memory
  * @nid: the node ID
@@ -1854,6 +1859,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_remove(start, size);
 
 	arch_remove_memory(nid, start, size, NULL);
+	__release_memory_resource(start, size);
 
 	try_offline_node(nid);
 
-- 
2.17.2

