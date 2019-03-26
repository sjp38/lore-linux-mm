Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 765A3C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 272CC20857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 272CC20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAB106B0005; Tue, 26 Mar 2019 05:02:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5A426B000A; Tue, 26 Mar 2019 05:02:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4AE16B000C; Tue, 26 Mar 2019 05:02:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 927586B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:02:50 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y64so11044261qka.3
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:02:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=UgSKYmd1Jzx4h5TGK0shnAQGDXzcbCAb2UOZJVJE79I=;
        b=dCWWxQEf1cGa0oO6Kk7UEKECYPqD2f9VZS0YDY/uM1Wk9dc66MRUlJSNrMBHNAg2AX
         +BI6q8gkb0ZH7hYR5IEtFCirN8LXTcG+QwXDJZ4RvGPDnzqDAk5MpaY6iFlNO+GfIkFv
         7WCaGKQ0mfd1qA2ZbapAEdfEXvnOJT0VXVAuVzRW+B6JtfhupwWnXU74fvwY21xKwScm
         V5xU6Yr7jFK57EUkD01Yhnylpy2WJvabXSZVPxprEpC0jTjll32B9qUWyqK4xkPgLA6F
         +NTAs8rn2n+JGI1yHDmip/S2kDtRc7XBfvwwZPTyamM1wfPIO1Y5vAJFAlPC45QvY6uz
         N10g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsT/cIUESDOjXQGEjkPNfapufV6Ritwq8aEL5sCZkmyGThwa4L
	Fl/ECtE88LfF5cd0wh1yN40egx3PbaI0l781uhS7ACSnDCFHSKVR6uPc6Rayfmlw3j4jAhVfvTU
	bHoVFO23dQ2pzBYU930nFC39OLjX2w5Klr7h+OFDQriwjypfIbvoie2U375lHuCz2Tg==
X-Received: by 2002:a0c:d196:: with SMTP id e22mr23295155qvh.181.1553590970401;
        Tue, 26 Mar 2019 02:02:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo1qWuKDFC+OblLoCOLv2050lV1WCzD0XrrlBLDFHk9aQg+Gp9FNiIMNSeWNoZHEF5NIyB
X-Received: by 2002:a0c:d196:: with SMTP id e22mr23295115qvh.181.1553590969843;
        Tue, 26 Mar 2019 02:02:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590969; cv=none;
        d=google.com; s=arc-20160816;
        b=M2FJc15ffWa/MPyCL/3CIP2XoERygeuI5CiTJYxCxgPu5rC7/Pjed782DVIjkcJhnd
         goNeCYbehcweFe8utZIj/ihFehIKq7ckG/Ed7O+60JBddXEVyqOK8FHLleV35QqpWyKJ
         Nrs/xIOo/0+oCsLO/mnCq4XIjfLyQdLS1jL6lFkIIJp4Rp6+ZQzsTWh8CaMOdOZUi1LG
         BcjF2h8jlvGXENciWxbGHN1GdgNIMhLlg0/PAjo4XQpiogdqT6SgvazPkW8rrUGiJnMS
         WpKiZlGirX9QBWL1vZnADkGnnYfPPP5zQ4XlnqJcs/Vw64/SCyiShb84sVw56fkJix0/
         aNxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=UgSKYmd1Jzx4h5TGK0shnAQGDXzcbCAb2UOZJVJE79I=;
        b=Ta6ODK9x7REVWvphanhTk4AgJIe7hXtSMM5Nir34Ccvs/jHEUMTsV/H/BaBwrZqCTK
         BRn4dXz8WetDZL4Br3sFp4rxwbvLHr/KXqn47UD3ecsEpwXpt2Es+zNCPLnekSBPJ0Mc
         mNTt0MQT1W+w+EEG3niMqtMAilUapafYj91609cwaDSUvgks0auGq0l2FMlc9XGeB5IX
         1V7tbUbAnN1NcO3XUUN2e8q4SvthqUvve/uWy89AcGsOKu+BdvW+T7nb/1Apym2i1+jw
         77zzV5dXveGfYtdKdqMDVYhJXBToEQEonE4BYEUgmTsj7hau4Ed7+NMWMTek75nSmUCU
         5nNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i12si2541845qtr.73.2019.03.26.02.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:02:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C0B9C89C31;
	Tue, 26 Mar 2019 09:02:48 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 46BBC8387A;
	Tue, 26 Mar 2019 09:02:43 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	osalvador@suse.de,
	willy@infradead.org,
	william.kucharski@oracle.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 3/4] mm/sparse: Rename function related to section memmap allocation/free
Date: Tue, 26 Mar 2019 17:02:26 +0800
Message-Id: <20190326090227.3059-4-bhe@redhat.com>
In-Reply-To: <20190326090227.3059-1-bhe@redhat.com>
References: <20190326090227.3059-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 26 Mar 2019 09:02:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are used to allocate/free section memmap, have nothing
to do with kmalloc/free during the handling. Rename them to remove
the confusion.

Signed-off-by: Baoquan He <bhe@redhat.com>
Acked-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/sparse.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index f4f34d69131e..68a89d133fa7 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -590,13 +590,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap,
+static void __free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
@@ -614,7 +614,7 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(void)
+static struct page *__alloc_section_memmap(void)
 {
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
@@ -635,13 +635,13 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
-	return __kmalloc_section_memmap();
+	return __alloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap,
+static void __free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	if (is_vmalloc_addr(memmap))
@@ -722,7 +722,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	usemap = __kmalloc_section_usemap();
 	if (!usemap)
 		return -ENOMEM;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = alloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap) {
 		kfree(usemap);
 		return  -ENOMEM;
@@ -786,7 +786,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			__free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.17.2

