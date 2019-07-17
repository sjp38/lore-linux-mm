Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A13A4C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7203A217D9
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 09:07:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7203A217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4D726B0003; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB1506B0008; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A88AD8E0001; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6F46B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 05:07:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so17623392edb.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 02:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Bti46f+Y06Sv2tAwUIdnw52o5JPz/p0dtD24RrvbZvE=;
        b=dnt7yg+RsjaYlwrO4qdARhrkVr/6F69KIi0+16v1wdPQZFXSwtR9tH/4E+qPjVHcar
         loUfEklHwPAu0shV/uTrPpDFfNgASWimB2YOLx0HxEbG4XnzhC/rSQI4V1x9FHSUcBi1
         WKKLeTD38kEmYke4/0qc0tN2aOKjr9JfAQ5NviaxuhqnCa8EUtaL7kTWsqRfz6R5Jziv
         6ql6U0bE+IeUiaaLwvVoR1YnRwlrwZ/Pqjqz+ygKzag+DMSum9Ud3rHBhxTRLk0aFU35
         8JqVKniCqwLkHadDL+A5aZXsSyL+gny3BSjpAuVrLXReF1i/umZGTzxm0zZ5kLm+qnIc
         hiZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU5K9Kg+jsS+/IijxlA9FXzJ8qQVssFH2HqEr4uG5MltiHIvfUm
	JnDUPU2IYgJXMK8vxZ+l0NyTSNAevkTt2nNaSsVJrgze6T4vu7P1IjfwSqKwCax0zAjWqYK1mNG
	VHhmz8L1FUUsPSf/7eamJNtHgSUDLIo6LnrnDox4zyziQvchConj5s/q3Diasmzq/MQ==
X-Received: by 2002:a50:aed6:: with SMTP id f22mr33956504edd.59.1563354450947;
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSDyzJAL+k9FCzp5ZKimUDNU3Y6Gw+fPzx6QkD9DwokBK5nw5G3KHu4scO0NW6NmiVnDJf
X-Received: by 2002:a50:aed6:: with SMTP id f22mr33956448edd.59.1563354450014;
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563354450; cv=none;
        d=google.com; s=arc-20160816;
        b=MNdqdVreh0ik7nayW9zTr2iDh3piXH9irk8jvpSI+Yaot8Kj9o/ufDpOzab9wQSO86
         fLLWV8x9drfKBcvHKOVrT9WKVPR+ttjFMtvFY6KifumwDoOWkdmmbJhwqp3oDiUGpiMc
         9hjNzbVzq68qD5vyzrTVQoydBtyxLeakHKB3SeVsqz5/mB2nJMp4S3Kquwg4HJZRdOYh
         m94IhmAcM8q4pXFCD+yOzMN1tUKjK7noEhw7CT/1iLMDXGeR/cR7fpidygC1mVymYNNC
         4ngVQorqq8HcbXwOycO6EWOYuPYRGE//2VZkLH7MVQrfpCcruDyNiSv/k7su2Dj3rOrF
         6g6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Bti46f+Y06Sv2tAwUIdnw52o5JPz/p0dtD24RrvbZvE=;
        b=QFp4xiqm1yI95IfcV5sM3K/xHCstjnKA3giMT+BEgOd7GYrM3y5i2N4zp+KWieBxQz
         70l/9l0106NKK4gIfuCsrtYKP59SNQi3M53A6/AgEk+Envj+hXYnQA7M+UsgJWluSTeX
         nEtgCv2fqSNuY8iOtRF463EZT9uL3W2j/hl8ohuVlcp+Yy3zZIrS65s+Vv4zQ//U7WHt
         kVJLK7yuEb9zO6ka5PPY51zJsGLPrHHx6sX/3zbUY+YUXpOBnwcTquHNxbZbM+t7pdr/
         Mv13JM9p8FeICISJEom/fAx2WTHNTiZXKgVAhNPtPdK+CZSeVpbWjkmvelTRXIfraT7i
         7Raw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m55si14317651edm.55.2019.07.17.02.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 02:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 62F82AF40;
	Wed, 17 Jul 2019 09:07:29 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	aneesh.kumar@linux.ibm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 1/2] mm,sparse: Fix deactivate_section for early sections
Date: Wed, 17 Jul 2019 11:07:24 +0200
Message-Id: <20190717090725.23618-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190717090725.23618-1-osalvador@suse.de>
References: <20190717090725.23618-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

deactivate_section checks whether a section is early or not
in order to either call free_map_bootmem() or depopulate_section_memmap().
Being the former for sections added at boot time, and the latter for
sections hotplugged.

The problem is that we zero section_mem_map, so the last early_section()
will always report false and the section will not be removed.

Fix this checking whether a section is early or not at function
entry.

Fixes: mmotm ("mm/sparsemem: Support sub-section hotplug")
Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Reviewed-by: Dan Williams <dan.j.wiliams@intel.com>
---
 mm/sparse.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 3267c4001c6d..1e224149aab6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -738,6 +738,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
 	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
 	struct mem_section *ms = __pfn_to_section(pfn);
+	bool section_is_early = early_section(ms);
 	struct page *memmap = NULL;
 	unsigned long *subsection_map = ms->usage
 		? &ms->usage->subsection_map[0] : NULL;
@@ -772,7 +773,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
 		unsigned long section_nr = pfn_to_section_nr(pfn);
 
-		if (!early_section(ms)) {
+		if (!section_is_early) {
 			kfree(ms->usage);
 			ms->usage = NULL;
 		}
@@ -780,7 +781,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
 		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
 	}
 
-	if (early_section(ms) && memmap)
+	if (section_is_early && memmap)
 		free_map_bootmem(memmap);
 	else
 		depopulate_section_memmap(pfn, nr_pages, altmap);
-- 
2.12.3

