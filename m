Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6888E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:03:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so3349587edt.23
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:14 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id x67si3305ede.100.2018.12.14.15.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:03:12 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 09AAE987AC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:03:12 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/14] mm, compaction: Skip pageblocks with reserved pages
Date: Fri, 14 Dec 2018 23:03:01 +0000
Message-Id: <20181214230310.572-6-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Reserved pages are set at boot time, tend to be clustered and almost
never become unreserved. When isolating pages for migrating, skip
the entire pageblock is one PageReserved page is encountered on the
grounds that it is highly probable the entire pageblock is reserved.

The impact depends on the machine and timing but both thpscale and
thpfioscale when using MADV_HUGEPAGE show a reduction of scanning and
fault latency on a 1-socket machine. The 2-socket results were too
noisy to draw any meaningful conclusion but it's safe to assume less
scanning is useful.

1-socket thpfioscale
                                   4.20.0-rc6             4.20.0-rc6
                               mmotm-20181210        noreserved-v1r4
Amean     fault-base-1     1481.32 (   0.00%)     1443.63 (   2.54%)
Amean     fault-huge-1     1118.17 (   0.00%)      981.30 *  12.24%*
Amean     fault-both-1     1176.43 (   0.00%)     1052.64 *  10.52%*

Compaction migrate scanned     3860713     3294284
Compaction free scanned      613786341   433423502
Kcompactd migrate scanned       408711      291915
Kcompactd free scanned       242509759   217164988

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 3afa4e9188b6..8134dba47584 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -827,6 +827,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 					goto isolate_success;
 			}
 
+			/*
+			 * A reserved page is never freed and tend to be
+			 * clustered in the same pageblocks. Skip the block.
+			 */
+			if (PageReserved(page))
+				low_pfn = end_pfn;
+
 			goto isolate_fail;
 		}
 
-- 
2.16.4
