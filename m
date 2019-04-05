Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48332C10F00
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03B8921738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:51:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03B8921738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 448236B026C; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F4226B026D; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BADE6B0270; Fri,  5 Apr 2019 09:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C02AC6B026C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:51:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s27so3278945eda.16
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:51:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=01tDvYmxF/9KT991KCuHbvIVLzPFrrD4a7OhNA6ejgo=;
        b=pk77Mv3+KbljNAZNG8kjsxEqZSROUmBvE1rtPIcQJQJ5krNuRqWDjVNpWla3XcI1B2
         MsupLhyGqgk+o7rPaid2wQDXrERfMrSxYKIElHl/Y1ivdl4vWxm36uemA4vvJD5IWACe
         iHsW1m8GOGhe3c9c8TwS/zdn5pNV50f41CbE4NrZVgCD4MXBD3IV75O+javKIuU4yh3k
         MVV9/7o02GRcnf92ZGzTsU2R4Xk9X4uTS6V3LF9kLEZjVseHnaqnoPiFe4nTq6rKqUBV
         o4uoKW0PhiMpIcdZoHeJKjWEVB2uXBh/56RudwIM65EF0v7RjWUY1bsRs2cC0BFZJRiP
         CSww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXUGXslEnGa/U0P8KuJZ69wDNexkB1EJyDGc+Z9jy8gVBnPSPY0
	FAjNPRtiwEFpy7CiVzS8r3UsslsGjFwWuZHvaPzyNZC1+gqqj7goxCDDXp4dLu45jzo+5e/nTZe
	jQ8vLiofc7l6CZIELe6eWVeSxkWwChWEmGbMJvm6LShxNgc+q6ZRQ3yEkzj5kpJtzRg==
X-Received: by 2002:aa7:c803:: with SMTP id a3mr8311226edt.39.1554472283244;
        Fri, 05 Apr 2019 06:51:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLNGKvpIjqFQcaBQ1K0R6L7ao7ZcIT0DLD7AAMNKznT2cXvDdL8JPm3vywR/Ho35jpft/w
X-Received: by 2002:aa7:c803:: with SMTP id a3mr8311141edt.39.1554472282015;
        Fri, 05 Apr 2019 06:51:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554472282; cv=none;
        d=google.com; s=arc-20160816;
        b=atjZ9ji3gre4tOYKGH5Qiwa6bUGNywvkKuUpvTEnj/CLR1f40+qNYFb2WcSvMg2qvL
         m4KmbFCRQeAiczLAbsqe1UUvTY+TBVFzcWmtWWAuoQKthcOb/k2oBHgDAqX+L6ZKRw+5
         YrWQc2gprtG2n8SIz+zuMSTryuhj2MXIX85Fp0SEvK7/qzhBfUHQvMKBMvtjWqasgV+Q
         HVrJ67G1VGdSY1oOJuWLpfWlf8bii+qmKTPc6b5ZeRUkzyZezuhBNgxOcSr2EpArO4Fe
         4eO+xfS5d0qUqWA8WbFKzuYrNqkVZO+sONLdPaG9P4T0qMj008A08Fok60eQoA8S6ADM
         EM+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=01tDvYmxF/9KT991KCuHbvIVLzPFrrD4a7OhNA6ejgo=;
        b=ntp4WHLs5ByCfc9oeJtm+cvTpKW0Z9qYqueFYvvwZEsrCdKyEMVbZFrJJciy0o035F
         /Y4kJ0p6hLwkw1Rda2WsSqLuN9HIteU3pLpoHRQPkC/qQUZs/7jRlDwsQ+6LSdJ7JQfV
         F5jjCv5VNonBoar2kgnjAcQ/ce5agm70dRInj8BijM/lIUAS9hmh5EmEVdhOtqffbw0U
         SFwTvYiSJpnTckKEECQ/3PbrramSQByqmbrrwQb8g+Anmx0+75/bQONNakqD39HQycRr
         h5hUycZWxHIVxN9URUq/wNskTsMtWt9tTZ49m9JjEFtiv0HJPYognkJ5FycLErC/SGm0
         t2PA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id x38si1405063edm.253.2019.04.05.06.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 06:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) client-ip=81.17.249.192;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id 727D3B8B7F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 14:51:21 +0100 (IST)
Received: (qmail 28399 invoked from network); 5 Apr 2019 13:51:21 -0000
Received: from unknown (HELO stampy.163woodhaven.lan) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPA; 5 Apr 2019 13:51:21 -0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Linus Torvalds <torvalds@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/2] mm/compaction.c: correct zone boundary handling when resetting pageblock skip hints
Date: Fri,  5 Apr 2019 14:51:19 +0100
Message-Id: <20190405135120.27532-2-mgorman@techsingularity.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190405135120.27532-1-mgorman@techsingularity.net>
References: <20190405135120.27532-1-mgorman@techsingularity.net>
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

He bisected it down to e332f741a8dd ("mm, compaction: be selective about
what pageblocks to clear skip hints").  The problem is that the patch in
question was sloppy with respect to the handling of zone boundaries.  In
some instances, it was possible for PFNs outside of a zone to be examined
and if those were not properly initialised or poisoned then it would
trigger the VM_BUG_ON.  This patch corrects the zone boundary issues when
resetting pageblock skip hints and Mikhail reported that the bug did not
trigger after 30 hours of testing.

Link: http://lkml.kernel.org/r/20190327085424.GL3189@techsingularity.net
Fixes: e332f741a8dd ("mm, compaction: be selective about what pageblocks to clear skip hints")
Reported-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Vlastimil Babka <vbabka@suse.cz>
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
-- 
2.16.4

