Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D57ADC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A61FA20C01
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:16:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A61FA20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E59EC6B0008; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E02F56B000A; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D01426B000C; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63B376B0008
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:15:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20so13088313edr.15
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Ke5wH9Ag8u2fyYD2m3TWob2LGobe+h0dyRZV/UG23pM=;
        b=bg4zSuleZ0GBH6+cIFhUMqB8Y2uTK/OYMknJgNPqvwc0AorfQqeGQLKNXghIW0w8hQ
         HVgODhm8fs1E5aC6XotnkNf2R5nHcrJ2TL98lpwHTyPs1KwqBVqjtAuM2qfXILQ/nW7k
         jIkYiyvmuCCjMiD9Xxhgt2C2gz19tcta8F5g3Zlb9SFVrWkz3LBV4VMOxewoKPQP+6fC
         Yz47S5s6JknlZYgt9TTtneSnsPVeUJU7KmWEWqQ6bMnqBqoevMu4GSnXpRcp6VxUhj3F
         dfd/Ny9/VkAfzv65TNNcKSaisz1ovmXFEO+4puriKFLVkPetK76fZ75vfJt+hOLjyxgX
         Ofxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUCNMZqxu7hDaPJ4MmuDiYKTysyFbNArRjRTQgll59DoVcy9BHT
	Q9GJG9lCBy7UJR3NGl3usOpztwEdScWQk8aEWhgxBfuvtgCUbvtKqh5iDQj8f6Avf9xtvfBf/zB
	6JzXhZ5n8Rof0ex8Yr+auB419kIwPIfB+PRxw2juXA7G0lXjggffBZ9rXs6LN2TQu8Q==
X-Received: by 2002:aa7:d30b:: with SMTP id p11mr22391390edq.23.1563178558986;
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhzr1FMWyF06ZvEmUqjmLCJy0oooqopEpTruNsuuHgCTZ8+wG63GepEUNl+bvmoS14TJAm
X-Received: by 2002:aa7:d30b:: with SMTP id p11mr22391337edq.23.1563178558226;
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563178558; cv=none;
        d=google.com; s=arc-20160816;
        b=bt9EaJKKUHaDQKsZY24GaUvzQE/0tITatkiU/cbJnGk/NcATLEduplEIX0JSx03Q1j
         /RrFaFQ/LQDujV12fAfKX0SIFilyXACSV3rZZerSgLc5cH8+NwLsNGIEKbBhHPdLGwxb
         O5wL3MAxDmdq4PA0MVEIj6SCu4pDmJW6/yjgmBPZmlQrMUzJnZ//rM0DNLnlV6z5T4SO
         Jz4pffhS3P9I9mMK1MfCGuzNip7zHxOmWlrpduJ8IK+qWbPDPdBFmZQ3ySPWlM96ICBw
         E+5i5x1rmmaVXK8dSmjxoiRP4z7E6X+z/qrOL2bvNd0i5zlukY+oe7ooskkzPOgcpgql
         0XXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Ke5wH9Ag8u2fyYD2m3TWob2LGobe+h0dyRZV/UG23pM=;
        b=amLZtq0WVsPfOXPDdPqrD0uPkhEF/LYAwMjYK09Iqlt1ohAtCB46u9SjyR60ZGIL5a
         obQBz+whA4SqmXHl+kgO8YeEPXfnCn0i1H82haWPEYcOMj2+/bySew8nOr8PFy+/AVvW
         HuH4tLLxyl/E0FQ4faxXAjP7T14uAeDf1tWV4X1eXl2jnNq+tQ5rHn6NzSj6XnOBBDGI
         RVqjlZQWsRsi8Slhi9Dgy5zuJHVihZkBQ3SaePlVcm5PRiYbaWJsAzuvLE3wM2XIsb1t
         Rxrc4L4uXQ8GmG9imU3Cggxg8bz9U5uhLqWVAfTF3a1TYSXqeQQwGkp7G1YUFQHst/j3
         WzbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si8602044ejv.380.2019.07.15.01.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 01:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DB217AFDB;
	Mon, 15 Jul 2019 08:15:57 +0000 (UTC)
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
Subject: [PATCH 1/2] mm,sparse: Fix deactivate_section for early sections
Date: Mon, 15 Jul 2019 10:15:48 +0200
Message-Id: <20190715081549.32577-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190715081549.32577-1-osalvador@suse.de>
References: <20190715081549.32577-1-osalvador@suse.de>
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

