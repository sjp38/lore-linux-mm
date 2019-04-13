Return-Path: <SRS0=SBXn=SP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DE75C10F0E
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 00:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0977218AF
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 00:26:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ih6tS4Qz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0977218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 536C56B0007; Fri, 12 Apr 2019 20:26:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6FF6B000C; Fri, 12 Apr 2019 20:26:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D5F26B000D; Fri, 12 Apr 2019 20:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0666B0007
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 20:26:48 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d131so9458952qkc.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 17:26:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=CSFjJsFUTQXAojtWlBr+PRir5Kz3Bk6fv+k8CiRRdW4=;
        b=DuFoxhAXyCPjE+4UwQ8lAjLGd/qET/NiBVAKfM9gMik1FPTnNi4w7PwSd8KSE6kAT+
         B1Kb0GfWeb0IpZl/GaKDZCRdCkHrQzq7fQiGCDySlT8ROhb2EyUaMqTO8h/LbqLRfMLG
         mjqKu/os0/XUOakHqgHbzJDL7wLn+BneuowppHYicYCFxe6fIZa/BR4KguOqJtt0kuI3
         ClJrU41Qjv9pJmDTBj7bh3OKR9phFvp2omIHrqGNlRiJOppYgxQgDl3xd0vqMUq8Qo6K
         kmR7eElX9xccTI6r45zqLk1q8Olwx59TrEFtDNR/xjipnLWuWj0fbGmTAeRuOGW7SZtF
         zaoQ==
X-Gm-Message-State: APjAAAUZ84aUPmMs/hvR8RHH8Zeh8JEol5iEmvbPTvZMC80pVLnc3upx
	Hln9XQNMzjI8v4U95dgSwWIiOOw8XPXks75IauOZ3zNDvVOj0AeCE4QKlG14v70i+En163v5Qpd
	N2k1RSGZtVb89aTIu+ZJL1CWnE2NWFkiw6ITgRvewUA7VkVN621a7R8j+UowQjTvzlg==
X-Received: by 2002:a05:620a:1529:: with SMTP id n9mr48440227qkk.190.1555115207780;
        Fri, 12 Apr 2019 17:26:47 -0700 (PDT)
X-Received: by 2002:a05:620a:1529:: with SMTP id n9mr48440139qkk.190.1555115206015;
        Fri, 12 Apr 2019 17:26:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555115206; cv=none;
        d=google.com; s=arc-20160816;
        b=wDgIfbfMhe6x6BPskplcRi5vslxNQaNwloPjG3eDD2AZdqaDNV33RHjLreuqOdqbzS
         bEhyz449FMcMNZ2iwbrbpbmizQmo7kjzAIq5bgz02+fTg0+cPJ9ecFfhv63Z0o2ZqsM+
         v3Yq0YtqB7q/IE6cAkZtU5uuNGFKvF2oazXn5Kr6rsYA1v7llMS2KC9Dtkt+Tx9bPFMl
         c2iAvdthQMWnKco5Q5efm6mmmdPD2w1AtMgxxxftHpf1j5dP8UGQSp8DCHF4oiwZZa58
         3XdkhibfreSx607mmegjrMqI4Vqfu70uut5jYXhYe4ZFrK+cd4WOIJNRoPDM9F8EopDe
         p2UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=CSFjJsFUTQXAojtWlBr+PRir5Kz3Bk6fv+k8CiRRdW4=;
        b=jsWbxGZ2TTBiO3zpe9jvCEse+41NHXfa73kgGb815MPvo8TDPnhx5gOQaoC6aB84gp
         CIcb/pkiwq/5e+mfv134N0cIZJYMQKZL85s5hqXr3fgLXs6BSwBBa8kGphcYPxynvWJ9
         foaOtHNheqpr8pM00QuMllO0gtIw0zus5/psokLTBHn0UMep1BLwnKZRRYQgAJNSftzV
         ZNeMCbN0zFz9t7og5yoiRhK3Zg1bgFlL7DpcJGw8lSN73dhlph6DVo9EnPjW3ah23EJf
         8GZNE4TForJsljcYjgewSFiUJFwkaX+acjFviPsKwbAJG5bJ6UW4q7uoZcr9rtSUe8I9
         oP+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ih6tS4Qz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p124sor25694423qkf.128.2019.04.12.17.26.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 17:26:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ih6tS4Qz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CSFjJsFUTQXAojtWlBr+PRir5Kz3Bk6fv+k8CiRRdW4=;
        b=ih6tS4QzKXyaONffNAgr+SyL6VEz2Iu7QhIJnFJsAkXbruFA2HJPo8LKqnwz3kW84B
         Da70Oci5Vv0aeZACKzejccC5WDtRQe7MQ1L8zzGLVgMXAlydA5oo07zBz4xVP1yejF8T
         q5h9G+PVnP/gMpVyCWIBje+D+0gOpmUkkmmw1YgStTXcUzFcSe0wloQYZqGF7RY+iQaN
         VDE3WTf73yuFIuftmV6An2olEgebqne+81hpA3N6jhgqyMa6TiPcM2KIRAVSge7RcaIk
         Kan2QZ7fG59BsDDJhMEl0YPbEFuPUoapBQGMvYUD84KLo9tImcCxHA6rVaYPdaMZHb3c
         MYBw==
X-Google-Smtp-Source: APXvYqwPZwh8zvhFunO8zwgzNke6KTJJu3obJ4HUfOUzJdqeNH4luDBANX0MaLA119r4qyrCgVbybg==
X-Received: by 2002:a37:4c85:: with SMTP id z127mr45628611qka.180.1555115205666;
        Fri, 12 Apr 2019 17:26:45 -0700 (PDT)
Received: from ovpn-124-191.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id x184sm15122554qke.35.2019.04.12.17.26.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 17:26:44 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v3] mm/hotplug: treat CMA pages as unmovable
Date: Fri, 12 Apr 2019 20:26:23 -0400
Message-Id: <20190413002623.8967-1-cai@lca.pw>
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

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v3: Use a string pointer instead of an array per Michal.
v2: Borrow some commit log texts.
    Call dump_page() in the error path.

 mm/page_alloc.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..40029b29fb88 100644
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
+	const char *reason = "unmovable page";
 
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
+		reason = "CMA page";
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
+		dump_page(pfn_to_page(pfn + iter), reason);
 	return true;
 }
 
-- 
2.20.1 (Apple Git-117)

