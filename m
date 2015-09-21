Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 18F016B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:52:50 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so108889394wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:52:49 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j6si30170717wjf.167.2015.09.21.03.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:52:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id DD95F2F804D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:52:43 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 03/10] mm, page_alloc: Remove unnecessary taking of a seqlock when cpusets are disabled
Date: Mon, 21 Sep 2015 11:52:35 +0100
Message-Id: <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There is a seqcounter that protects against spurious allocation failures
when a task is changing the allowed nodes in a cpuset. There is no need
to check the seqcounter until a cpuset exists.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/cpuset.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 1b357997cac5..6eb27cb480b7 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -104,6 +104,9 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
  */
 static inline unsigned int read_mems_allowed_begin(void)
 {
+	if (!cpusets_enabled())
+		return 0;
+
 	return read_seqcount_begin(&current->mems_allowed_seq);
 }
 
@@ -115,6 +118,9 @@ static inline unsigned int read_mems_allowed_begin(void)
  */
 static inline bool read_mems_allowed_retry(unsigned int seq)
 {
+	if (!cpusets_enabled())
+		return false;
+
 	return read_seqcount_retry(&current->mems_allowed_seq, seq);
 }
 
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
