Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7359C6B0265
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 03:36:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u14so5526887lfd.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 00:36:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ty2si30807694wjb.223.2016.09.07.00.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 00:36:47 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u877WmkC120983
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 03:36:45 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25a3m66xpw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Sep 2016 03:36:45 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Wed, 7 Sep 2016 08:36:44 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0D13F1B0804B
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 08:38:28 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u877agEk6553872
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 07:36:42 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u877afET002352
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 01:36:42 -0600
Subject: [PATCH] mm, page_alloc: warn about empty nodemask
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Wed, 07 Sep 2016 08:41:26 +0800
In-Reply-To: <3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz>
References: <1473044391.4250.19.camel@TP420>
	 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
	 <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
	 <3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <1473208886.12692.2.camel@TP420>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Warn about allocating with an empty nodemask, it would be easier to
understand than oom messages. The check is added in the slow path.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
--- 
mm/page_alloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c6..d624ff3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3448,6 +3448,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
+	if (ac->nodemask && nodes_empty(*ac->nodemask)) {
+		pr_warn("nodemask is empty\n");
+		gfp_mask &= ~__GFP_NOWARN;
+		goto nopage;
+	}
+
 	/*
 	 * For costly allocations, try direct compaction first, as it's likely
 	 * that we have enough base pages and don't need to reclaim. Don't try


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
