Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3C73C82F5F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 06:45:43 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so22022881wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:45:42 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id dx9si9821249wib.80.2015.08.12.03.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 03:45:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id D5CD599008
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:45:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a seqlock when cpusets are disabled
Date: Wed, 12 Aug 2015 11:45:29 +0100
Message-Id: <1439376335-17895-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There is a seqcounter that protects against spurious allocation failures
when a task is changing the allowed nodes in a cpuset. There is no need
to check the seqcounter until a cpuset exists.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
