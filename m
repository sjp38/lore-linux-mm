Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94964C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46FB920850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="RBw3GZAN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46FB920850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86C06B0276; Fri, 12 Apr 2019 11:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0DCD6B0278; Fri, 12 Apr 2019 11:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B0DA6B0279; Fri, 12 Apr 2019 11:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 762D26B0276
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:27:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p26so9017237qtq.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:27:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=gI3I5rEECfD9XFm6XVGRhJch/xlr1B+27KW5PF8K648=;
        b=T+s7124BaQ7GhhSiuFvv9iqc7wuzjwKUyzt1Iw9eK+YiF/mAO7AGkXOAkyDT6fsT0I
         NTBhD8Wl7zs6wEo4y7n8ZUCshYfO4EJzVoTkZ1K59rHtDTmE4Mvl9HadA0QVGVmlQ4kp
         KxUCwO7KfiomEGfskf7+bZNt/YYPSsL7J2OIzmu3w4l4zZYDVmWiFwdo26wMdj+AxerP
         jaK4ZmP7C883eGsKOgiSiggx9BZ64/0qz5WCRmhLig/W8IrbC5FvtIU3VelPtVs0ARz8
         btWzdTLVrgbyGFywR5LfzW1J5kK+duptG0hYQYk7ZXgYFi6aBS/7iIASEgLk1iYORSPo
         SeUg==
X-Gm-Message-State: APjAAAWdjFIbjXehZbh89jzGNuRNA7bAi6ApwVaErdrT+GuS5raWMzOn
	dZsBgS7iAYu3L8QkaUtPaEgqO1bDo6y49i08Bcx4HUkG4ukw9u5iYGhjvwNqGoh3f9XhSVSBgTG
	0xRZI7eRKSq2GXE0sFFiezBo1evChL5Hg+MQuTDGCuVdTY1u2Zs3NFPre96lHjmp2AA==
X-Received: by 2002:a0c:b8aa:: with SMTP id y42mr46528388qvf.66.1555082844172;
        Fri, 12 Apr 2019 08:27:24 -0700 (PDT)
X-Received: by 2002:a0c:b8aa:: with SMTP id y42mr46527821qvf.66.1555082837219;
        Fri, 12 Apr 2019 08:27:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082837; cv=none;
        d=google.com; s=arc-20160816;
        b=pTWbvd5bkg1Dp8XsjRAT96P9JwqoZSSsuU/TGYMGmUtdZXtMsMhsALj159f7nqm0oa
         pFhInyH44jSSawncaki+XA70FQ4zYfAzNKl4QI8vRC6Ljm8mYY0FZ/iZIBDBTe5LSYam
         898pVtlQ/YX9MhyIcz9kyvlFJOQ3ozxaeTsv3n7h/9o+xLKK3p1Di8cPPdCjYWTim/0q
         e0wFAd+BilXC3YwArAo5aJWIIKIQvqIKwHNAiVCMf2PbviTD6vW0C9X/DJg43f3SsLzL
         KR5qjInhvXB0Rhmb/QKefN7D9FcPGPMdvMfqmHCQ6Nkq790mY/ZWKwy4Sh7dWur/y2Fr
         sBZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=gI3I5rEECfD9XFm6XVGRhJch/xlr1B+27KW5PF8K648=;
        b=OxR/S6fc/S199RN3JYbYxq/adVkyqV6issfZePeLzgWSxg+zSrY/IWhDeqL0oj5rFu
         qQzqnVNu5J6+ZO0rQBOx4Lro8T0//3R864GmvbGk1WS+b97BPL34NpDYCtIc0NReSI7p
         Pexy4OS1prr+8dyDDDfa9YtbJ0e7W3deBgUYU6mjbHDtn0jJ/hp+RevoJEac1tC6vHjn
         RRcf9UN3yEEiabDcge0ou/NXiEO4kO3EVe1bxQlMQCbXhSi/uYmf+xRWxdDLyoMDTOcX
         W83mng3k4wmxFr0QZLWKZemNJ0mqNZPqSBWYxAfTekHkwgY2DwOGH+5mYt2PVl/hu//d
         tMWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RBw3GZAN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c192sor24896764qkb.34.2019.04.12.08.27.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:27:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RBw3GZAN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=gI3I5rEECfD9XFm6XVGRhJch/xlr1B+27KW5PF8K648=;
        b=RBw3GZANAFK2064CxPJDNog+YUbG2CdCJvBkdKUoI8h/xm0q63ys0aAnny4/JHxQEE
         duVyfObj/RBIcxxIHYoCwnpXLasr5pXRamJ2jCKcQn1uqGxo2opC87N2QkqgQTyeDG5Y
         bONeu3fRjPGMyrTEVZlTErpmGFKduMpLfRPml+Og3jy5dOcyi527u/UbMN/BLeSUgzxA
         MNGv1+eS8I2/pwgj8KqFYUufIObJBs9v6via956zF0k++O43ZvHgXHQGJI5WibmZ+0kD
         4w/lGSsbbsOlfxc/5fSDhkKqkQ9ZRXagMm9clIM0ZQ8DZ+tjO3mpD9vFmrZXd0nx7xTo
         2XMQ==
X-Google-Smtp-Source: APXvYqxU/FJM7ihb4hHUYSMmynCQXmOGtBn1vGcf2c2lY3S/Vkjt5tA3VUzbAW+IhrHDV8BN9jYTTg==
X-Received: by 2002:a37:6087:: with SMTP id u129mr45337840qkb.300.1555082836866;
        Fri, 12 Apr 2019 08:27:16 -0700 (PDT)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s17sm27104517qtc.15.2019.04.12.08.27.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 08:27:16 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/hotplug: treat CMA pages as unmovable
Date: Fri, 12 Apr 2019 11:26:59 -0400
Message-Id: <20190412152659.3916-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

has_unmovable_pages() is used by allocating CMA and gigantic pages as
well as the memory hotplug. The later doesn't know how to offline CMA
pool properly now, but if an unused (free) CMA page is encountered, then
has_unmovable_pages() happily considers it as a free memory and
propagates this up the call chain. Memory offlining code then frees the
page without a proper CMA tear down which leads to an accounting issues.
Moreover if the same memory range is onlined again then the memory never
gets back to the CMA pool.

State after memory offline:
 # grep cma /proc/vmstat
 nr_free_cma 205824

 # cat /sys/kernel/debug/cma/cma-kvm_cma/count
 209920

Also, kmemleak still think those memory address are reserved but have
already been used by the buddy allocator after onlining.

Offlined Pages 4096
kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree
(overlaps existing)
Call Trace:
[c00000003dc2faf0] [c000000000884b2c] dump_stack+0xb0/0xf4 (unreliable)
[c00000003dc2fb30] [c000000000424fb4] create_object+0x344/0x380
[c00000003dc2fbf0] [c0000000003d178c] __kmalloc_node+0x3ec/0x860
[c00000003dc2fc90] [c000000000319078] kvmalloc_node+0x58/0x110
[c00000003dc2fcd0] [c000000000484d9c] seq_read+0x41c/0x620
[c00000003dc2fd60] [c0000000004472bc] __vfs_read+0x3c/0x70
[c00000003dc2fd80] [c0000000004473ac] vfs_read+0xbc/0x1a0
[c00000003dc2fdd0] [c00000000044783c] ksys_read+0x7c/0x140
[c00000003dc2fe20] [c00000000000b108] system_call+0x5c/0x70
kmemleak: Kernel memory leak detector disabled
kmemleak: Object 0xc000201cc8000000 (size 13757317120):
kmemleak:   comm "swapper/0", pid 0, jiffies 4294937297
kmemleak:   min_count = -1
kmemleak:   count = 0
kmemleak:   flags = 0x5
kmemleak:   checksum = 0
kmemleak:   backtrace:
     cma_declare_contiguous+0x2a4/0x3b0
     kvm_cma_reserve+0x11c/0x134
     setup_arch+0x300/0x3f8
     start_kernel+0x9c/0x6e8
     start_here_common+0x1c/0x4b0
kmemleak: Automatic memory scanning thread ended

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: Borrow some commit log texts from Michal.
    Call dump_page() in the error path per Michal.

 mm/page_alloc.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..a9d2b0236167 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8005,7 +8005,10 @@ void *__init alloc_large_system_hash(const char *tablename,
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 int migratetype, int flags)
 {
-	unsigned long pfn, iter, found;
+	unsigned long found;
+	unsigned long iter = 0;
+	unsigned long pfn = page_to_pfn(page);
+	char reason[] = "unmovable page";
 
 	/*
 	 * TODO we could make this much more efficient by not checking every
@@ -8015,17 +8018,20 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 * can still lead to having bootmem allocations in zone_movable.
 	 */
 
-	/*
-	 * CMA allocations (alloc_contig_range) really need to mark isolate
-	 * CMA pageblocks even when they are not movable in fact so consider
-	 * them movable here.
-	 */
-	if (is_migrate_cma(migratetype) &&
-			is_migrate_cma(get_pageblock_migratetype(page)))
-		return false;
+	if (is_migrate_cma(get_pageblock_migratetype(page))) {
+		/*
+		 * CMA allocations (alloc_contig_range) really need to mark
+		 * isolate CMA pageblocks even when they are not movable in fact
+		 * so consider them movable here.
+		 */
+		if (is_migrate_cma(migratetype))
+			return false;
+
+		strscpy(reason, "CMA page", 9);
+		goto unmovable;
+	}
 
-	pfn = page_to_pfn(page);
-	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
+	for (found = 0; iter < pageblock_nr_pages; iter++) {
 		unsigned long check = pfn + iter;
 
 		if (!pfn_valid_within(check))
@@ -8105,7 +8111,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
 	if (flags & REPORT_FAILURE)
-		dump_page(pfn_to_page(pfn+iter), "unmovable page");
+		dump_page(pfn_to_page(pfn+iter), reason);
 	return true;
 }
 
-- 
2.20.1 (Apple Git-117)

