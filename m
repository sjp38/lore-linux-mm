Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E9F0C04AAF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:39:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 541FA2087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:39:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 541FA2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B145E6B0010; Tue,  7 May 2019 14:38:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC73F6B0266; Tue,  7 May 2019 14:38:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F29D6B0269; Tue,  7 May 2019 14:38:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF066B0010
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l20so17286358qtq.21
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BEy7q9rHfwt3l5FIt7jpUEGaL3ViTPH7RwPgQioEzsM=;
        b=otpoQRtUswxjSVD3bicPC8izmn1b0k/T6MKPibuGWbWf4uuwIrgzPAI5CWhGifP4WR
         6SKdyUV7WU3ZEk0Tep44t812FE2rPwAjIHWu/5T0KK9KEpBE9nHt08gJPM+en0Ogsm2h
         a/WUXWP3D6+UVKDZNCUKIFdJ2psRK1kvzGU8Jmc5DlJ8D+X1frv9SDtwRtH0+Omnrb/J
         x1pk+3wcrjPGAWKjv7qsGukfZn+Hqj8OtvIiZAhQLAr99guvfKqR3MGhCgogfTQ9qVK/
         1PYjNobRYEio8mxriQSsFkoElyWOxY2csAlvy65QiwuR9We9kJ7uxEKHNeVpKmqD0QF4
         b/mA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+cCRcO5OwyLovSvnttOeWA8FJf7AoXl8jesIMsEAVIZ/B7XOT
	2fc3DUaVpMv8/G+QdR28PYxoxFOnW0qP18ibURTu1e2C68RoaRgB7eeVJMFODlPIzNCr4m6hfGg
	7tPjZF1b4h8FJ7HM6rCSlOlx1jHqH/xn0TtNB82RbGGJbaeB7pq2VfofkqzsBr7arqA==
X-Received: by 2002:ac8:e0f:: with SMTP id a15mr28674208qti.360.1557254339228;
        Tue, 07 May 2019 11:38:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn9Pv1krEOut7XGzFgXvjR7AZzNsDNjvZSqfrc4f8zLIJKKyJ/je9Kazn/JOgqMK9vnFSG
X-Received: by 2002:ac8:e0f:: with SMTP id a15mr28674158qti.360.1557254338573;
        Tue, 07 May 2019 11:38:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254338; cv=none;
        d=google.com; s=arc-20160816;
        b=PBloashZraBX8xHTkp/G/mAv+f5JJpsGlofcqxLTUigCk+FsM4559HGBxhw93cH+Xl
         JhW/eIRR2fdXzwEn4OK47AqJwarSf0FD5ML15Twn3aHsPjDUVfUjOR43FsBxjfsRiu+X
         esOjtWKYMmOjqdKzLwTsiSLqDOuwcYBnK01TYmdGIMxmcaYAKLp1ooGytdVdJwV8fDTn
         R7YMRBIWdFIeaQUa1IJYAfPKhOore6V2EjUKgIsJMVur1pWWlrY3jmKoGpP+yIapM9Qk
         Zrzc7OO6fD9L07n+DHfvQ8NncAfwz6arF/WwwCYxby5NmlV2QZXnqpyBIsrS2bVcrWlT
         l1oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BEy7q9rHfwt3l5FIt7jpUEGaL3ViTPH7RwPgQioEzsM=;
        b=OQOd+3mtpFqs6wa+NLbq4raES0iIfCIv0UGSQ7xWfQ8UVPihC3xu3VP/EoB7X3b8tr
         IGwC5v8J7vctALYCpmOTu7A7Mwnq9K8BDCjfbbY3tJggo/2egtvj9/WcvreFOd1V0/SP
         h02uLCRcjQeuyYxoMbAXePpsx1Twa+dotYLYCLSyCzsEm5LZlm6OF6sloeASq2SMA5wW
         F5Vbz+DEKA0ycIqEvlQUpSKLfaxwUM/RScLN3oQ46b40IKt0BKQcLV7QarLd4STGAoy1
         KyTb6EXI/IVCPwdnxR6XAB9CrBC9QTmbX/Lln9cpHw4Tj0C2B1IenvIU4iocXuFsLkjw
         LSYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r58si1211338qtr.405.2019.05.07.11.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF6BDC05FBCB;
	Tue,  7 May 2019 18:38:57 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E0C683DA5;
	Tue,  7 May 2019 18:38:55 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 8/8] mm/memory_hotplug: Remove "zone" parameter from sparse_remove_one_section
Date: Tue,  7 May 2019 20:38:04 +0200
Message-Id: <20190507183804.5512-9-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 07 May 2019 18:38:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Unused, and memory unplug path should never care about zones. This is
the job of memory offlining. ZONE_DEVICE might require special care -
the caller of arch_remove_memory() should handle this.

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
index 527fe4f9c620..e0340c8f6df4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -523,7 +523,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
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

