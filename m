Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A653EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E4D62146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E4D62146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7BC96B0003; Wed, 20 Mar 2019 03:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2BBE6B0006; Wed, 20 Mar 2019 03:53:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C41F16B0007; Wed, 20 Mar 2019 03:53:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 97F4D6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:53:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e1so1515891qth.23
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:53:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=NHYm78XeumLt8ir9csQDBL74SYZAX+2NrnzQ7Es7qeA=;
        b=I2VDQnYyKsDMZSaSDZZFrtUX6Qbh+sJtsFcrJwrlwvxn7PXE06/2VHtn0apKWNj+fg
         fPmOo14ySUUyPnlHjHXszQXeNGRrEkAcwZWkAMtjmw/zIuyDXKpVDSnvxS8HqbQ/1JHc
         AcQ4LsRqa/Vy+thNgv3D4KOF53zr7m6mV9hEHEGe8J3uJLM5havuP2jqpX5zc2zmWruT
         GpIwB5VbFqz/cdmu0/WpGFFUnk97sZGQPjdDWhpW1DfKElN93iYSl6+xKoIwSfLlMoGc
         xUo38JCqEeAHCIHcRIwWez0vjmYCgnNeBApDFlGe9JcUKt+DTBihDle9G/B8+SOQfSXV
         qrww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVzLx8UxSKU2aUSmeZV4+2XOaaME4sv9WV8OpbKOIMqZaeGpogy
	eoOlFlvpDxIf0s4P9M4OohAmJFRUuxen8NsrL+FiyY/wLRmsXo14mf9+t0tVR6AAx9LQSDQdzYf
	CJReGCQ5LgLfypZyFK5FMKiZCCu5VQWsroBJU8kzFm2QHm7ZVCmzCfnW1DCUQwDDP3Q==
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr5375261qvc.37.1553068396356;
        Wed, 20 Mar 2019 00:53:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlkZHgT2blP/fujF5UaxUZp9DRlgJkrdmVCCbSLOxmz1iTrLk7Top7rD3SfrBFDpLvFlZM
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr5375233qvc.37.1553068395734;
        Wed, 20 Mar 2019 00:53:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068395; cv=none;
        d=google.com; s=arc-20160816;
        b=VQ9hON2X9GQ5AZFD60+T9wHA2BeyaWPSlIBq4tjECfsAxvxGs58rxcsC7ezlJXQKZv
         D6+GxEVjxoFIjCTEuJ1InqYnGqb0BqggEEcarFAMykn1gAv2JloFATNiLIvv1fVNB1r/
         618VldhMLBfpBVTnbHS8kjN7p+RjW7KdJRf/D36F0BA01Gw5egse0Hkz70p5CJYZBbOD
         WS2Ee0+MYgB/THLHiR/nNV0UQLkqpaj32m/njROd+2JSTwtdM6AUwh6iRWQrIoHq9ZmL
         IxkX9FcZ5T5u4QaG4gO5QmJm+le7nxe3flh1clRZS/DyuHU3pKs2BSfMksoGmtK4ved9
         8i3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=NHYm78XeumLt8ir9csQDBL74SYZAX+2NrnzQ7Es7qeA=;
        b=iVdHXcbdKvKhKLi1yHm2wZenH/ppf9jSgjIqgyjYhZ4BDT415UR4N+aul5OeRKedgM
         zVWS5kuLrvi51t0Ksj+K+lnvN7Yoa277zy6zfHDVkXsnHYZwhckyjdt0ECXnTFW/fpGe
         Up7G95nTpzJW5q/LpHnTNKZZDHO2BBNznFw/aBeeBejOYWEcD2zWbgXJPizRZyCHYPbG
         1cw/qLzlT2nHoqpx4m26ZYJv0qorHwbGgxsHNcAhXtOZTkdck/2AQjOoRsYhQesjTcsz
         GtU5xvu2gI8pDyph76SR1XIJLyCLAWMS/CHuDfBBCbVC1vtxflONH0dtihgFQ/lRCSDZ
         e1yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l37si751249qte.317.2019.03.20.00.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:53:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F075031688EB;
	Wed, 20 Mar 2019 07:53:14 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6DBF85D9C4;
	Wed, 20 Mar 2019 07:53:05 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	osalvador@suse.de,
	mhocko@suse.com,
	rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com,
	linux-mm@kvack.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH] mm/sparse: Rename function related to section memmap allocation/free
Date: Wed, 20 Mar 2019 15:53:01 +0800
Message-Id: <20190320075301.13994-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 20 Mar 2019 07:53:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are used allocate/free section memmap, have nothing
to do with kmalloc/free during the handling. Rename them to remove
the confusion.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 054b99f74181..374206212d01 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -579,13 +579,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
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
@@ -603,7 +603,7 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(void)
+static struct page *__alloc_section_memmap(void)
 {
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
@@ -624,13 +624,13 @@ static struct page *__kmalloc_section_memmap(void)
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
@@ -701,7 +701,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	usemap = __kmalloc_section_usemap();
 	if (!usemap)
 		return -ENOMEM;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = alloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap) {
 		kfree(usemap);
 		return -ENOMEM;
@@ -726,7 +726,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 out:
 	if (ret < 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
+		__free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -777,7 +777,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			__free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.17.2

