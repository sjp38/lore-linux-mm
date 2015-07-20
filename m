Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 120839003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:33 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so19399911wic.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:32 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id w2si11996802wiy.40.2015.07.20.01.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id A4B1198BE1
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:22 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a seqlock when cpusets are disabled
Date: Mon, 20 Jul 2015 09:00:13 +0100
Message-Id: <1437379219-9160-5-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

There is a seqcounter that protects spurious allocation fails when a task
is changing the allowed nodes in a cpuset. There is no need to check the
seqcounter until a cpuset exists.

Signed-off-by: Mel Gorman <mgorman@sujse.de>
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
