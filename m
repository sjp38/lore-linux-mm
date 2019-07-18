Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B4E0C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDC852173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:57:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDC852173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F3E86B000D; Thu, 18 Jul 2019 04:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A3AF6B000E; Thu, 18 Jul 2019 04:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 694118E0001; Thu, 18 Jul 2019 04:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2B66B000D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:57:15 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w11so13325192wrl.7
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=gGxLkd4TPYq76mJCOWjwlhFe1AXpVgtBhjvq0ka/1fA=;
        b=DmB12ZLmJYW3KHDE90hEpq3n/mBrK2t4lY3KSeNC8wpPC6sYgeUV6N6chWsyFoLKnX
         TnxxEJ5y/qABwzNV0vERoSb5ZqKn8uEyTIm67le2OAbnUhTRPjaB9HFAcm9UeKy8NJEw
         KHvN+s5t83MXXLac5Sm1EiSxNU6Ozo97tDhwyDlJqGYM4C0h48J81qzvu04b5zUjvheV
         SqGdH1MlNQdQUHAi/cKk5bboEhSeOAWbidBpgnRiNH0j3Is15VGLf/MZqQpR+9uYE2o8
         vVNVx5A2rKGLdp/Mw8qpR7GV/zZUVd/ZeIBzVIAVTaZt0OZF5gWm6B2RvEVEmLy2p24S
         7pNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.11 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW5RYcYygHGKD4sGy1ZgpMHrC79ATQbBZ5SBRhsAAnJdQIKZdFL
	MzswR3ZnTWJhpq8QwMHF7sO61B/7qZiWVB5PFceLWCyJPVFXutuw7mvbMC9x0RS/pqPNXbNcsqM
	SNgoWfxks+Q63SVVXO4VSH1ilE0ZF1wAxBBzGx0G+wdafyo4ACVDb8CMVwhkykIsXGA==
X-Received: by 2002:a1c:7a02:: with SMTP id v2mr41006311wmc.159.1563440234648;
        Thu, 18 Jul 2019 01:57:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHD7PBRw5lUOomDsNnODY/Tyii9XGpSEcYZnPCbWvD7P2GB1sUenH0N6I2iHP29E/PzV10
X-Received: by 2002:a1c:7a02:: with SMTP id v2mr41006102wmc.159.1563440232326;
        Thu, 18 Jul 2019 01:57:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563440232; cv=none;
        d=google.com; s=arc-20160816;
        b=pPyREFKoKPFBWLBKY2drErE+zU4OC3q3LKr2pf/AcJyzpwdS/8X/clir79NDTwy2mW
         w/HcBOAOCl6aguqSyMthWtu6J1UE7TTsQwcCkQUso/swTgYbDMMqVqOXS1dr1wFptaeM
         aeivHeDI5AoUQmZXCrIHHl/pYHkjptNUF5rsBGJ5rsykM64piMShP3A55oZaz1FEbIq4
         agwUxm1Kq/vXe66WxOVs/e8TfEpsWMCoD9q/aMV197SzB+BYwz0j5H9s3adI9ChFIElz
         Nkad8/eErk5VlimgbLO2gSbXsu7M4SBnlLgYnqtvJV2mwqaC1yM0lXpxcYG+p2XxHKbR
         Rz5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=gGxLkd4TPYq76mJCOWjwlhFe1AXpVgtBhjvq0ka/1fA=;
        b=FfYTvqOqYnOaxZqXpgocG1KSKpgGixGaM/W3Y2kVWJuEx4VVuZKn9E373iNLFfa9FM
         ZD2S3dSvnEg5i2oXrWhkU5uPS1C5sW0GOA2J6Tc1/WTLJutm0eV/JBR7aRCf6UK2l1Qu
         I2VQ2bhfKJ0DeV4/lzHSrS98kwOtAIjxbpUkZ8Rx6OpOd/b7CretpV3G2Jz/CRgPkK16
         +yNCL62AjJTsREuz9oK4ZDL4Nt3eQ2E36iHQ6iEmLmJYKwiXTpEf4MHTzJPbEDiaftxb
         VtfyrohlVbs/o2chGoz6OpecJs+wlhMSKz5OJ4EGh/DWRG0tUit27nhWYBFQCmIeiKNm
         yT1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.11 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp28.blacknight.com (outbound-smtp28.blacknight.com. [81.17.249.11])
        by mx.google.com with ESMTPS id h5si22498528wrv.299.2019.07.18.01.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 01:57:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.11 as permitted sender) client-ip=81.17.249.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.11 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp28.blacknight.com (Postfix) with ESMTPS id 0FA47D04FD
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:57:11 +0100 (IST)
Received: (qmail 15222 invoked from network); 18 Jul 2019 08:57:10 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Jul 2019 08:57:10 -0000
Date: Thu, 18 Jul 2019 09:57:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: howaboutsynergy@protonmail.com, Vlastimil Babka <vbabka@suse.cz>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] mm: compaction: Avoid 100% CPU usage during compaction when
 a task is killed
Message-ID: <20190718085708.GE24383@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"howaboutsynergy" reported via kernel buzilla number 204165 that
compact_zone_order was consuming 100% CPU during a stress test for
prolonged periods of time. Specifically the following command, which
should exit in 10 seconds, was taking an excessive time to finish while
the CPU was pegged at 100%.

  stress -m 220 --vm-bytes 1000000000 --timeout 10

Tracing indicated a pattern as follows

          stress-3923  [007]   519.106208: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106212: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106216: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106219: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106223: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106227: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106231: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106235: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106238: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0
          stress-3923  [007]   519.106242: mm_compaction_isolate_migratepages: range=(0x70bb80 ~ 0x70bb80) nr_scanned=0 nr_taken=0

Note that compaction is entered in rapid succession while scanning and
isolating nothing. The problem is that when a task that is compacting
receives a fatal signal, it retries indefinitely instead of exiting while
making no progress as a fatal signal is pending.

It's not easy to trigger this condition although enabling zswap helps on
the basis that the timing is altered. A very small window has to be hit
for the problem to occur (signal delivered while compacting and isolating
a PFN for migration that is not aligned to SWAP_CLUSTER_MAX).

This was reproduced locally -- 16G single socket system, 8G swap, 30% zswap
configured, vm-bytes 22000000000 using Colin Kings stress-ng implementation
from github running in a loop until the problem hits). Tracing recorded the
problem occurring almost 200K times in a short window. With this patch, the
problem hit 4 times but the task existed normally instead of consuming CPU.

This problem has existed for some time but it was made worse by
cf66f0700c8f ("mm, compaction: do not consider a need to reschedule as
contention"). Before that commit, if the same condition was hit then
locks would be quickly contended and compaction would exit that way.

I haven't included a Reported-and-tested-by as the reporters real name
is unknown but this was caught and repaired due to their testing and
tracing.  If they want a tag added then hopefully they'll say so before
this gets merged.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=204165
Fixes: cf66f0700c8f ("mm, compaction: do not consider a need to reschedule as contention")
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
CC: stable@vger.kernel.org # v5.1+
---
 mm/compaction.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..952dc2fb24e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -842,13 +842,15 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Periodically drop the lock (if held) regardless of its
-		 * contention, to give chance to IRQs. Abort async compaction
-		 * if contended.
+		 * contention, to give chance to IRQs. Abort completely if
+		 * a fatal signal is pending.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
 		    && compact_unlock_should_abort(&pgdat->lru_lock,
-					    flags, &locked, cc))
-			break;
+					    flags, &locked, cc)) {
+			low_pfn = 0;
+			goto fatal_pending;
+		}
 
 		if (!pfn_valid_within(low_pfn))
 			goto isolate_fail;
@@ -1060,6 +1062,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
+fatal_pending:
 	cc->total_migrate_scanned += nr_scanned;
 	if (nr_isolated)
 		count_compact_events(COMPACTISOLATED, nr_isolated);

