Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 857AFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:54:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B1BB2082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:54:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B1BB2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B6B76B000E; Wed, 27 Mar 2019 04:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 997BE6B0010; Wed, 27 Mar 2019 04:54:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87E976B0266; Wed, 27 Mar 2019 04:54:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE256B000E
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:54:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x13so6356111edq.11
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:54:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=sFHhJFS6f9R+xTFvdKKMDkT4ynpmZ+1DnEeq8rftfuQ=;
        b=SPViYmElajmletZ6tAXPhP87SssXkDzl794H9Kcvi92WvcgjK3z3ywRhmmzYimcQw2
         DRpGzpE1LR8I+5x2EbF+LaqRUhJi8wd70dohLuJ/znjPXPyWeSCFyt0pMC+nzULUM/sv
         4o8L0Ca9FA48hC6c5W+h8NzhQvDM5WuiepIsIpbbsmUSpyKaF8wDX8kX3Xe7UGrM53F4
         ePtuU4FJ0JMPBkUVbbVnt24t6DumN0QJLyVEcKlFsXt/pSoq2UHy+eOy9Vb6T39cvBvR
         iYzeC60YY+cTar3T9ne3NUUwRh8hRktu7f0YULHvfvWFPkUj1Dqyuf9GwrB2TbBfPl9z
         uhvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXWyfV51S08ZHPFaQoZZw2spNK6bKEHRihgpWXgS9ueF6o8xiKX
	BHo6i/YSSNmytpMSFMvkcQ4QY1AkLWD9gxTGb/A8gHl4mRNWneMOJPuisJpsjZohyPcKV+s8kOk
	Xf5OhvTIBJhIaWlaOWMkFzActPJ/UZrrMtLltOJKdUA06G7U7FO3WGky2SQjdohlLfQ==
X-Received: by 2002:a17:906:cc9:: with SMTP id l9mr19476447ejh.53.1553676867678;
        Wed, 27 Mar 2019 01:54:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy24FJ1qxpXOXN0YlZME+BEBVJUofUd0B5o/dYS0e2kRxl/bifhwiMsjLx5RGh2H6jsl98l
X-Received: by 2002:a17:906:cc9:: with SMTP id l9mr19476401ejh.53.1553676866408;
        Wed, 27 Mar 2019 01:54:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676866; cv=none;
        d=google.com; s=arc-20160816;
        b=bMfvQxeCqAnCNtBQntWja4XFAc4y4yXFYeh+G4nVospswC/d8Hq4DF/g0Wf+TIGILe
         IzhLSLHiVgu+Q1Uh6BQknMZaUMKkZH5ptyXCzZwUkCcGr7KCYiFnOcKRF/PHEmwGHeOC
         Lai/S4oh60xA34C7J5Vzatl0YKikHz4RVcGAt/o5dZorDxLd2Ss6pxXr2Asi4aWmqef5
         3/J0h9gf/YhcGIQ1nD0g3cxRJe8+SoQYLMdUHX4yyZvpppHRHNE7r7NJjoP7VV2dQ/XM
         lV8ON0aUmlN13HWY7p0kSlV6ut2wwVtDiyMj/n9UdhgUwf7Vi28xMxxoSdabUguBmsMx
         EYGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=sFHhJFS6f9R+xTFvdKKMDkT4ynpmZ+1DnEeq8rftfuQ=;
        b=RhtCRR28FAZQVSGQgJfvfOUTFi8P0nOndz1fMZbzWCKTgNoSy+Lj1fxCXgYKmwqv3S
         jioiVHdtTiYgbv/oBn63Jc2JeDARzst0kKK0Eqnz9jRjvzkf0iXDSbZ4Sld1aud93G9e
         FSLqV4CJogSWFjkRKNll9UVT6GN+SfeVcxFFVKz+xAAn0w7ja2Mmn3H+a5A5hE06fcjd
         VLvEyIjkKYxUGOHwmSDn/vYNAitkBjjfKC+dQX57c2egB/xclyJUb+8mSUytAf+sMMOi
         dqYaudyGi0XfChIBYWd3U+pVisg7+IV0B+HDJWdcNMg/5q1NEBbynPSqZCXJWqmdXw3w
         nUHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id g14si4745274ejh.186.2019.03.27.01.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 01:54:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 14D12B87A3
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:54:26 +0000 (GMT)
Received: (qmail 16859 invoked from network); 27 Mar 2019 08:54:25 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 27 Mar 2019 08:54:25 -0000
Date: Wed, 27 Mar 2019 08:54:24 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz, linux-kernel@vger.kernel.org
Subject: [PATCH] Correct zone boundary handling when resetting pageblock skip
 hints
Message-ID: <20190327085424.GL3189@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mikhail Gavrilo reported the following bug being triggered in a Fedora
kernel based on 5.1-rc1 but it is relevant to a vanilla kernel.

 kernel: page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 kernel: ------------[ cut here ]------------
 kernel: kernel BUG at include/linux/mm.h:1021!
 kernel: invalid opcode: 0000 [#1] SMP NOPTI
 kernel: CPU: 6 PID: 116 Comm: kswapd0 Tainted: G         C        5.1.0-0.rc1.git1.3.fc31.x86_64 #1
 kernel: Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1201 12/07/2018
 kernel: RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
 kernel: Code: fe 06 e8 0f 8e fc ff 44 0f b6 4c 24 04 48 85 c0 0f 85 dc fe ff ff e9 68 fe ff ff 48 c7 c6 58 b7 2e 8c 4c 89 ff e8 0c 75 00 00 <0f> 0b 48 c7 c6 58 b7 2e 8c e8 fe 74 00 00 0f 0b 48 89 fa 41 b8 01
 kernel: RSP: 0018:ffff9e2d03f0fde8 EFLAGS: 00010246
 kernel: RAX: 0000000000000034 RBX: 000000000081f380 RCX: ffff8cffbddd6c20
 kernel: RDX: 0000000000000000 RSI: 0000000000000006 RDI: ffff8cffbddd6c20
 kernel: RBP: 0000000000000001 R08: 0000009898b94613 R09: 0000000000000000
 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000100000
 kernel: R13: 0000000000100000 R14: 0000000000000001 R15: ffffca7de07ce000
 kernel: FS:  0000000000000000(0000) GS:ffff8cffbdc00000(0000) knlGS:0000000000000000
 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 kernel: CR2: 00007fc1670e9000 CR3: 00000007f5276000 CR4: 00000000003406e0
 kernel: Call Trace:
 kernel:  __reset_isolation_suitable+0x62/0x120
 kernel:  reset_isolation_suitable+0x3b/0x40
 kernel:  kswapd+0x147/0x540
 kernel:  ? finish_wait+0x90/0x90
 kernel:  kthread+0x108/0x140
 kernel:  ? balance_pgdat+0x560/0x560
 kernel:  ? kthread_park+0x90/0x90
 kernel:  ret_from_fork+0x27/0x50

He bisected it down to commit e332f741a8dd ("mm, compaction: be selective
about what pageblocks to clear skip hints"). The problem is that the patch
in question was sloppy with respect to the handling of zone boundaries. In
some instances, it was possible for PFNs outside of a zone to be examined
and if those were not properly initialised or poisoned then it would
trigger the VM_BUG_ON. This patch corrects the zone boundary issues when
resetting pageblock skip hints and Mikhail reported that the bug did not
trigger after 30 hours of testing.

Fixes: e332f741a8dd ("mm, compaction: be selective about what pageblocks to clear skip hints")
Reported-and-tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..b4930bf93c8a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -242,6 +242,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 							bool check_target)
 {
 	struct page *page = pfn_to_online_page(pfn);
+	struct page *block_page;
 	struct page *end_page;
 	unsigned long block_pfn;
 
@@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
 		return false;
 
+	/* Ensure the start of the pageblock or zone is online and valid */
+	block_pfn = pageblock_start_pfn(pfn);
+	block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
+	if (block_page) {
+		page = block_page;
+		pfn = block_pfn;
+	}
+
+	/* Ensure the end of the pageblock or zone is online and valid */
+	block_pfn += pageblock_nr_pages;
+	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
+	end_page = pfn_to_online_page(block_pfn);
+	if (!end_page)
+		return false;
+
 	/*
 	 * Only clear the hint if a sample indicates there is either a
 	 * free page or an LRU page in the block. One or other condition
 	 * is necessary for the block to be a migration source/target.
 	 */
-	block_pfn = pageblock_start_pfn(pfn);
-	pfn = max(block_pfn, zone->zone_start_pfn);
-	page = pfn_to_page(pfn);
-	if (zone != page_zone(page))
-		return false;
-	pfn = block_pfn + pageblock_nr_pages;
-	pfn = min(pfn, zone_end_pfn(zone));
-	end_page = pfn_to_page(pfn);
-
 	do {
 		if (pfn_valid_within(pfn)) {
 			if (check_source && PageLRU(page)) {
@@ -309,7 +316,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 static void __reset_isolation_suitable(struct zone *zone)
 {
 	unsigned long migrate_pfn = zone->zone_start_pfn;
-	unsigned long free_pfn = zone_end_pfn(zone);
+	unsigned long free_pfn = zone_end_pfn(zone) - 1;
 	unsigned long reset_migrate = free_pfn;
 	unsigned long reset_free = migrate_pfn;
 	bool source_set = false;

