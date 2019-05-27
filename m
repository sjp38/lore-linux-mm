Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D3C2C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45EFD20883
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:13:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45EFD20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E39636B0280; Mon, 27 May 2019 07:13:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE9B46B0281; Mon, 27 May 2019 07:13:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB15B6B0282; Mon, 27 May 2019 07:13:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3EB36B0280
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:13:10 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id o16so2987556otp.17
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:13:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FcpQtkM7mXzSuK2MeOX2MTV1RrfG5BMJDhikRUdEp1k=;
        b=P56zM598yJe6nCsTjetcudAJSY5P2aOTfs35St5UOBpef6jDKRpyQAJscS0cLgEEK3
         o5C8hjQModPz64GFjUvaov66ivbc/Z5MPAqU6USfDjrtwJOid2oAaAo4VkP+pw+/bO0Q
         98jFRTuJtsYqTvUllvBJZf/YAiaHDxAqNEZ92YhIXw38V7PRIKV5ZmeT+kLhmzze0LwW
         yAgXZqHzZBpJpxA+iCXIxVMdXTNlxZIr8RGDyemsMRFBHIqyL9l9rM9IHyck1YPcwZLm
         DhjvmKYGxbWgKTaMin/SkHcuC62hPMLLDNt5u3bqmPhiLtth3moQmwYKpIUuSG2aIL30
         bXVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWrShZWUhw33Mka7kKEvjOhAZNaojybRI/JvuhKT3uTjrRlNPF4
	Qb2+3o10+7V3KeVlVkoS3zQCTSsaj+06jStjECuwUNH7wDrW4nduG+7aEKxTHdwJFdFeRA9jLTz
	B+Adi3WBL5ReruYW2+sG5przYhxBlh+IeFQ8wdl55IOLLjMP+tHG5XqG3KFjZ1x53bg==
X-Received: by 2002:a9d:7457:: with SMTP id p23mr349883otk.5.1558955590398;
        Mon, 27 May 2019 04:13:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIppsBxQFyEzbURdUtPa8v9VxzKvhChV0/yEkxkeYaoJqjcNN8BQfrC1gasLvsle+PCUok
X-Received: by 2002:a9d:7457:: with SMTP id p23mr349852otk.5.1558955589876;
        Mon, 27 May 2019 04:13:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955589; cv=none;
        d=google.com; s=arc-20160816;
        b=ahd4NkVTYefSWQnR5yok43WixF5ZcAL9iKqHC09XbSXPsLof7XqXaerQrjPJNc57ub
         M/9N7PTx4t7ir+iDe6eYIEc42lJJ2T0Hw91giBZbf6nz71BrQajUfNLLF7mTM7MiSYGA
         1j15SqoETFSfYq6EexzYP5BsjzMKA8dvK3AbT1UVCZosPr3FQnHwZhNqYexF+RQKBjug
         adOthz+luD6o5q/5Xfu27w1/yquuKRugFIUBEkdB0GeehJMTp/eM2Vt+72TxcrUFjcRc
         5ZmaaXjztupnCiRGth5VQu/g/KihlkroLWR3sT7eabILbqntALrnRtE4wf93FL1cAnlP
         TrJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=FcpQtkM7mXzSuK2MeOX2MTV1RrfG5BMJDhikRUdEp1k=;
        b=uSP9L38Zfm1NdET8qx06nbnMyUAt4kbfm1xjVWFh7yeZXzKN37ruhbSLCam2Tdeva1
         gemciI4HvME6XiCGeXQJNfiH71FP8DvpQQHVn3GEGVm0yC9coIIZZ2bjQKaajnw+yy3a
         pEdJsDRYcBB7BdhgtHRDsOwpdz/RwIGzebjyT+fvH4tesNjMve8PlD8/ozfbZd2ku3Z4
         5qDBePBIzUAGRPHNmOgxZcsXf8DsFuEh0Gd4lVpJTdjmaD3gqFMFVMsxAVxHwxasMN/z
         NOHqX3ijl3qIwK015LPOtprVaRSFtTQAwbO9wR++j5RGBlYoxnfPNtpRGJTEABnPXfOB
         TZgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u51si5903612otb.63.2019.05.27.04.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:13:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 32F0F30833BF;
	Mon, 27 May 2019 11:13:09 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A50CC19C7F;
	Mon, 27 May 2019 11:13:04 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v3 11/11] mm/memory_hotplug: Remove "zone" parameter from sparse_remove_one_section
Date: Mon, 27 May 2019 13:11:52 +0200
Message-Id: <20190527111152.16324-12-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 27 May 2019 11:13:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The parameter is unused, so let's drop it. Memory removal paths should
never care about zones. This is the job of memory offlining and will
require more refactorings.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 2 +-
 mm/memory_hotplug.c            | 2 +-
 mm/sparse.c                    | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2f1f87e13baa..1a4257c5f74c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -346,7 +346,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_one_section(int nid, unsigned long start_pfn,
 				  struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern void sparse_remove_one_section(struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 82136c5b4c5f..e48ec7b9dee2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -524,7 +524,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_one_section(ms, map_offset, altmap);
 }
 
 /**
diff --git a/mm/sparse.c b/mm/sparse.c
index d1d5e05f5b8d..1552c855d62a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -800,8 +800,8 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset, struct vmem_altmap *altmap)
+void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
+			       struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL;
-- 
2.20.1

