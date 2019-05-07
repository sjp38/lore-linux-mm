Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 799AFC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BF8F206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BF8F206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E227C6B000C; Tue,  7 May 2019 14:38:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD2C66B000D; Tue,  7 May 2019 14:38:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEB216B000E; Tue,  7 May 2019 14:38:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAD046B000C
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u15so18997826qkj.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1AHud2ZD6tXhbo4XTIHImH/7A+j/bT1tgyCj7c12ovw=;
        b=m3bGGHkDfTM21NLFIWPfw3DPKATS6zsru0rFElOQqsh/29nAGggvdvVN5FD2BMEJZK
         S3tVXspAo4s7Rh5gQk25ALJD9mS7+jGKaJT7VA7BqfpcSOrW66GUmYYXuMGC1fozqHka
         dtOSxWHEOY9GDL3rfUkOD+DiGTgDlZbQoTODyM9NKEHa3MELuWN9lDW5cuvOdI7MNxHh
         rMHBn7RfElTF/zYvkUg/fHVf78OmThP6GZdZmi+NOAJv6MfmpeIdsXrM1FR9901ksxlM
         H6nq9xQ7DMPverkv113qWbvpqEU7V1fNaHwkUolos7QSHI7p695oSY/K4asBm6ioeTXp
         fv3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWDzPWWho9kP+raQlsw7GofN7zIMGE+HqDnpJM4a4lgMU2g9/fm
	52nAyqwp/TZdaQEfCp0XKud2efGfkLnOS+BoSYJbY5qyDs7ArUgTZN2X2iREX6S1KtxkK6AsPUE
	1gYV8M3ap3d1hPYppeEtZ91zH/BkUZrysmBedgkepQ8N7aUln86Xv1X/OhKTY/IrRvw==
X-Received: by 2002:a0c:8c49:: with SMTP id o9mr9577788qvb.7.1557254329417;
        Tue, 07 May 2019 11:38:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymmhjzYW4EyFggWUmTqENRibDfu57yYXuqBpxZcuZWOjmsQovCK/t7HBOAovonkdfRhYGH
X-Received: by 2002:a0c:8c49:: with SMTP id o9mr9577716qvb.7.1557254328286;
        Tue, 07 May 2019 11:38:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254328; cv=none;
        d=google.com; s=arc-20160816;
        b=finC03hudmC/3JKCW2hGCxtFYB32fRLAcveZCRyLRHq4637OmnjIzVKZQxGihuplU3
         BjnLVQhi30n8R+k86gl8/q6nFfGOFQIUd7vu0wBHYyxz2PJVksyS3hQVhKiQ7B8visAS
         OWy17il0eGo0qrBipM6zzVWyMJAUwBFWppMkj8G7Q4Rr9MIjWC68uVi1dKIen7+xnu12
         vDlFrBmbqitWnTqJsMK0HefytUUHXEFIIt6qpvbOXsIz32KDTqERqJItHJWHf1qONFnG
         4p6ypbq51UV1UtQGPxDMWbQ5Nraxa3ZXSJI6veCshurPAtLUm81uFVw8smJ2Pl371pNU
         IEEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1AHud2ZD6tXhbo4XTIHImH/7A+j/bT1tgyCj7c12ovw=;
        b=o3g63udwJgN8LMf6m0kSiyfTf3ooivJSX3pndSXZcVE77zUp01uiaL2ctYFdJmHcj3
         N/Eci2veDiAqkOPqXiWOBnmQByyUjVj22HKYlJz9DB0ubiMP4dQHACmCjZ2a5sGNZdPJ
         fnJyXMqPb4q1Dq2O/u2DsY4EHY18bDi1c144C+RE0kNX/onKLcYoGiYfn1stQwSqTeiM
         +NV86O7RzZvQ/xJlXvQ6vjaKhI6ZJfFrKrtG/a4ZPS0PMPniKU/cC+Qi8kDkl5oBb23x
         Z2NTDcWe2mhQGSUwcu3qFrEDbBh9IM5Mrw4OwzRDJmqfv6cXEwP9HgTJVviW669RVPBx
         dohQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u185si2978109qkb.135.2019.05.07.11.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6315F3082E72;
	Tue,  7 May 2019 18:38:47 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 172023DA5;
	Tue,  7 May 2019 18:38:41 +0000 (UTC)
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
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Date: Tue,  7 May 2019 20:38:01 +0200
Message-Id: <20190507183804.5512-6-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 07 May 2019 18:38:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer needed, the callers of arch_add_memory() can handle this
manually.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 8 --------
 mm/memory_hotplug.c            | 9 +++------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2d4de313926d..2f1f87e13baa 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
 extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
 			   unsigned long nr_pages, struct vmem_altmap *altmap);
 
-/*
- * Do we want sysfs memblock files created. This will allow userspace to online
- * and offline memory explicitly. Lack of this bit means that the caller has to
- * call move_pfn_range_to_zone to finish the initialization.
- */
-
-#define MHP_MEMBLOCK_API               (1<<0)
-
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		       struct mhp_restrictions *restrictions);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e1637c8a0723..107f72952347 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		struct vmem_altmap *altmap, bool want_memblock)
+				   struct vmem_altmap *altmap)
 {
 	int ret;
 
@@ -293,8 +293,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				restrictions->flags & MHP_MEMBLOCK_API);
+		err = __add_section(nid, section_nr_to_pfn(i), altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1066,9 +1065,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  */
 int __ref add_memory_resource(int nid, struct resource *res)
 {
-	struct mhp_restrictions restrictions = {
-		.flags = MHP_MEMBLOCK_API,
-	};
+	struct mhp_restrictions restrictions = {};
 	u64 start, size;
 	bool new_node = false;
 	int ret;
-- 
2.20.1

