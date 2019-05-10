Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CB65C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:21:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE9A8217D7
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:21:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9A8217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41E626B0006; Fri, 10 May 2019 14:21:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CE6E6B0007; Fri, 10 May 2019 14:21:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BE016B0008; Fri, 10 May 2019 14:21:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D295C6B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 14:21:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e21so5119994edr.18
        for <linux-mm@kvack.org>; Fri, 10 May 2019 11:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=AaEhReZUIYMF2KXtQYFD2SxDoHKodT8/p5g1LMd7orw=;
        b=kED2qQMJgj/UNZLm1tGfi4OxwmJqMUPijV/+nguMH5nowwoYWlZhvJgaxnFv2u8WLe
         ndaCyKxajEoK3n3vSNC9QxsTwKHdFUTReCy2lBW1bLz8gUTv9Fx2MaEXBC7SmcP5Micm
         a5KvwRTSqCjmKm7Rh2Lr8la/eWffB0zvY9nl1YAjUaJ0Rf2yE1h6AK4CPCHy7QTqRCbW
         GyaXJneVVr4vYlgas7Uxpe+Gu9Z8F5nnZ1Uk1Byrt48Vo7aOYJLuaAhGjtOtVUDFeSFi
         MmpFEphpL619KacP2hVjEdV0UrVmVFURjgv5wY4E1ZGXcRjhtFMKFhpEOOxku/JNS2wD
         bg7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVOIl7b2iQc+U7pYR2dJOjSls/l9TkrSiUZO0LQDftr+Yp0u+4i
	MzaCxKOzq6LpLGl8ovegx5EiPGJVEcuG11u4EuGM0dB6A4bmewo4O1zvNajQeD1WZrbJIs2f1fW
	FZC939fnNSNgqJYyV1tBBwF27pHTfqNsY4qOcCbiSUt+pE3AssqzdRUgfJOp0rjxgWQ==
X-Received: by 2002:a50:8682:: with SMTP id r2mr12360206eda.106.1557512488361;
        Fri, 10 May 2019 11:21:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJZlSWNFmRnhuZXKjTdx61/czywaaYTAB5IEPCcsy+DOED/v5yr+BOczYozJanJ7wnNqA7
X-Received: by 2002:a50:8682:: with SMTP id r2mr12360034eda.106.1557512486803;
        Fri, 10 May 2019 11:21:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557512486; cv=none;
        d=google.com; s=arc-20160816;
        b=JOCV9a/tSxfaeZNP7l6xaKsiygiVOKXvH9FcsXw/CGG4cJAJDFDg1b2YZ9OdBBKVL7
         wsLE25xUpMUEN5b97pj6yESXzYXhGIBNj879PB7FuGj3ZTfnQGQL5PpPfK/oS/nNc1fo
         hu+bvB9UQTYJ1gee6DdfQ4khsDfjM2fZNfKg2KUfUexyYQLslMtIDRDus1fQnRj3Q0UT
         XvRmOgmGu2CUAfvvjWlJzt8DlgVM4NL/ZCxGT83ENwjJTVFaEuZGmdJyI4nQVJw7due0
         xRjDLR40bRSNeqgQ9FQ8H1fhHMwTZqiKnMyLdcVnw2eX+YzSWz5rNthzU1kbOjK1z5iB
         Hpxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=AaEhReZUIYMF2KXtQYFD2SxDoHKodT8/p5g1LMd7orw=;
        b=Q2NMKKGfFYImDjSRTSiv7rzwoTFVwBwm0tSPtrmq3FdQlgHZaXos7GeC/nqbMELHoh
         oTyDttXvTUlEIb0xl3ixQL17Vkijy1fX3NuHkMRNv2oVQ4Xd+puCvP46J5fxnF9cl9X9
         z7Bm/Patg6cckgrMrxx1ZoJtcbDqIgz8M+0YEJyfs4C97txowKduG3qQQ8zJeTlhtQW4
         tIM38yqgoU3YQA9aCG0KrTb1iZtrTH2BT3qK9IDIXCl/YdzUAUdF6ZWUF0aG3AgPUelr
         UUdrbHX2P97h6inYfjK7XZfjw5k3My9Otnz/3GhPOEZxYRg56xY8zTbJPtXdEVpwi1YH
         RJPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id z5si3525111ejn.282.2019.05.10.11.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 11:21:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) client-ip=81.17.249.39;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.39 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 6FE9B98821
	for <linux-mm@kvack.org>; Fri, 10 May 2019 18:21:26 +0000 (UTC)
Received: (qmail 4850 invoked from network); 10 May 2019 18:21:26 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 10 May 2019 18:21:26 -0000
Date: Fri, 10 May 2019 19:21:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Qian Cai <cai@lca.pw>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm/compaction.c: correct zone boundary handling when
 isolating pages from a pageblock
Message-ID: <20190510182124.GI18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot reported the following error from a tree with a head commit of
baf76f0c58ae ("slip: make slhc_free() silently accept an error pointer")

  BUG: unable to handle kernel paging request at ffffea0003348000
  #PF error: [normal kernel read fault]
  PGD 12c3f9067 P4D 12c3f9067 PUD 12c3f8067 PMD 0
  Oops: 0000 [#1] PREEMPT SMP KASAN
  CPU: 1 PID: 28916 Comm: syz-executor.2 Not tainted 5.1.0-rc6+ #89
  Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
  RIP: 0010:constant_test_bit arch/x86/include/asm/bitops.h:314 [inline]
  RIP: 0010:PageCompound include/linux/page-flags.h:186 [inline]
  RIP: 0010:isolate_freepages_block+0x1c0/0xd40 mm/compaction.c:579
  Code: 01 d8 ff 4d 85 ed 0f 84 ef 07 00 00 e8 29 00 d8 ff 4c 89 e0 83 85 38 ff
  ff ff 01 48 c1 e8 03 42 80 3c 38 00 0f 85 31 0a 00 00 <4d> 8b 2c 24 31 ff 49
  c1 ed 10 41 83 e5 01 44 89 ee e8 3a 01 d8 ff
  RSP: 0018:ffff88802b31eab8 EFLAGS: 00010246
  RAX: 1ffffd4000669000 RBX: 00000000000cd200 RCX: ffffc9000a235000
  RDX: 000000000001ca5e RSI: ffffffff81988cc7 RDI: 0000000000000001
  RBP: ffff88802b31ebd8 R08: ffff88805af700c0 R09: 0000000000000000
  R10: 0000000000000000 R11: 0000000000000000 R12: ffffea0003348000
  R13: 0000000000000000 R14: ffff88802b31f030 R15: dffffc0000000000
  FS:  00007f61648dc700(0000) GS:ffff8880ae900000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: ffffea0003348000 CR3: 0000000037c64000 CR4: 00000000001426e0
  Call Trace:
   fast_isolate_around mm/compaction.c:1243 [inline]
   fast_isolate_freepages mm/compaction.c:1418 [inline]
   isolate_freepages mm/compaction.c:1438 [inline]
   compaction_alloc+0x1aee/0x22e0 mm/compaction.c:1550

There is no reproducer and it is difficult to hit -- 1 crash every
few days. The issue is very similar to the fix in commit 6b0868c820ff
("mm/compaction.c: correct zone boundary handling when resetting
pageblock skip hints"). When isolating free pages around a target
pageblock, the boundary handling is off by one and can stray into the next
pageblock. Triggering the syzbot error requires that the end of pageblock
is section or zone aligned, and that the next section is unpopulated.

A more subtle consequence of the bug is that pageblocks were being
improperly used as migration targets which potentially hurts fragmentation
avoidance in the long-term one page at a time.

A debugging patch revealed that it's definitely possible to stray outside
of a pageblock which is not intended. While syzbot cannot be used to
verify this patch, it was confirmed that the debugging warning no longer
triggers with this patch applied. It has also been confirmed that the
THP allocation stress tests are not degraded by this patch.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reported-by: syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com
Fixes: e332f741a8dd ("mm, compaction: be selective about what pageblocks to clear skip hints")
Cc: stable@vger.kernel.org # v5.1+
---
 mm/compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3319e0872d01..444029da4e9d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1228,7 +1228,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 
 	/* Pageblock boundaries */
 	start_pfn = pageblock_start_pfn(pfn);
-	end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
+	end_pfn = min(pageblock_end_pfn(pfn), zone_end_pfn(cc->zone)) - 1;
 
 	/* Scan before */
 	if (start_pfn != pfn) {
@@ -1239,7 +1239,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 
 	/* Scan after */
 	start_pfn = pfn + nr_isolated;
-	if (start_pfn != end_pfn)
+	if (start_pfn < end_pfn)
 		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, 1, false);
 
 	/* Skip this pageblock in the future as it's full or nearly full */

