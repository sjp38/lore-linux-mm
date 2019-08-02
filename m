Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E85BC0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CABB42067D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:39:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="yP4dJsbY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CABB42067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE9926B000A; Fri,  2 Aug 2019 18:39:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4C2D6B000C; Fri,  2 Aug 2019 18:39:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9EDE6B000D; Fri,  2 Aug 2019 18:39:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B51F6B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:39:50 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t124so66094193qkh.3
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:39:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bV9RblgfAM24Mn0li+d85If1LPYzvCMLasoX7V2aE1c=;
        b=U3wM2bbz4wtSzKD4s+YlSWQyQu5xTFRaXvjp+ev7DrNtoikqVFdBgxk0MkghvIKdeQ
         aWXCY+4vZj2gJh42ZSJExVPtjz7mBtL5GSHsRNWkcrZ3vFzffvYmdE7AouzCC4kNDjnC
         LIEuxobsbI4uu1An/SGf21OJd1PUq0E1jjPIsxQvRhJGOA5k0iAiACSqjd5xKhwz7uPr
         TMFbfEoRKynkuZ6GPccES8yxIZAYZ/75Cdu6Z+TQkpGDwdZSPAqPiAIc1Lsx6csSHWTO
         6jKtUHJvsYhU7bmwv+nFL2wqarsaz0mWCRsYBHFvUlniicz4PFh2p9cysrakjqf9Ssw7
         xXxQ==
X-Gm-Message-State: APjAAAUsUwxVKMBrMSFupboCEGG/fJ+vPCELGHqigzF7iyiDFcTG5acN
	Cq9ns4sLAxnYO08HwkphUNQLdmhru0sA1jM8GcnuyuJSEieNKi0j3cVLTL7AAdRdkDZ6wNgPWfP
	0Pzc4m37sISglIp0DNYwva+G6AXQs5EBtP+dqzuFSWjjrwrUb4moXUwk1O2DGYyBdqg==
X-Received: by 2002:a0c:eec2:: with SMTP id h2mr97545137qvs.189.1564785590268;
        Fri, 02 Aug 2019 15:39:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlSgERNP+WwVdzcpE5adnC+0NoRVPNXgctct+6M+GGz8VF9b5xZscybtwdnb5dzXYnTMnQ
X-Received: by 2002:a0c:eec2:: with SMTP id h2mr97545102qvs.189.1564785589450;
        Fri, 02 Aug 2019 15:39:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564785589; cv=none;
        d=google.com; s=arc-20160816;
        b=dgkjxLzqIfmHqG1bT5MU0HGJ2uOT/IfkyWPLyY4pKe4A5FmXZ876ixXqSvEK+bwXuw
         dsybwW8b98yMhthvHP5B7Bs7j7+4/Ocst6znJ7UVbGZRHwxjQoeZcFxrwJTSKQUZVC8t
         diNVosiSH1xYkxlxPJUBLom1B2JwSjvP8jhb774VITD61Q/pA/tIEif2gHv+UCXqdMmU
         OB+u2GXWVNxRJyBJwymCMCQJuQ8KLYzCU27vQm4nsbMFEok6qKvpe/Xu4B++mjhKViLA
         JcUXLi22Ai8okPwmurFZkp2uumbNzM1Ml4bDq+s6pDhugmIfsqi6YExylT7GFeMwFmAe
         utZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bV9RblgfAM24Mn0li+d85If1LPYzvCMLasoX7V2aE1c=;
        b=JTfJ8gkIXHl6id4lF6W4KdcHcoSZvWrbtKGoGGsdAbPl8RhVxRb438npvzJWSX7Apm
         gd92b3jhqqzLll1rxHikdyCbHEZ9MaMtZqHn7NY/R6tUAKg3wiNyEhwxSCpiaEsMdXcs
         e/neo7ccJ/1L3ZXWrFz7Tx4FCcgk52/as0wBYW1piZVGCxptdUtGSMy38C45nwHoqBY5
         I9zMB2JUhjnQCJhnK+elkjeLhpGS+CRkVZdpU+epgUp+rG491oc1+dLjxUDONo/byYjb
         BrYO3scSyYrDJF8Q4xalyf2eP51znv1EXXEqOMNRw+Ah6+C1HGzx6u4FAeRb3lr9hHyw
         pGFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=yP4dJsbY;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f10si35060906qvh.21.2019.08.02.15.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 15:39:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=yP4dJsbY;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72Mcu0W121794;
	Fri, 2 Aug 2019 22:39:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=bV9RblgfAM24Mn0li+d85If1LPYzvCMLasoX7V2aE1c=;
 b=yP4dJsbYBlUwSok1WTUI9oIxojgTnrQ7C4XQYodVyQ241/kkw9otYXURcaHo38DqUklv
 aQv7PjTYVDpsZqqzzPl0MvimyWdII9jhXRe+MIhPYgRkMgTywylPhTKmWMfeft1Zv8FJ
 IbTc6XQNBc+U69lGlcPOxrVIQsF6O2e11F/1dJLls+i1qfDBJTnNTc3WlaXhDeAx4hdN
 4bocK1iADGpnQdz4Zf9Tnl9TUV8n3gaXIXvk4BWxHMOtBWeHOnJTXlH93Q1K45dGLJLj
 TNAmBKPLGVVVmsiY15rTd/NERzp7ehIjTIS/7J43w0aV3o/A5UUA1CEiylXdOE/Wc5pX dw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u0e1ucye0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:44 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72MbjuZ019447;
	Fri, 2 Aug 2019 22:39:44 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u49hunsrq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:43 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x72MdfuH006631;
	Fri, 2 Aug 2019 22:39:41 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 15:39:41 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] hugetlbfs: don't retry when pool page allocations start to fail
Date: Fri,  2 Aug 2019 15:39:30 -0700
Message-Id: <20190802223930.30971-4-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190802223930.30971-1-mike.kravetz@oracle.com>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020238
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020238
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
the pages will be interleaved between all nodes of the system.  If
nodes are not equal, it is quite possible for one node to fill up
before the others.  When this happens, the code still attempts to
allocate pages from the full node.  This results in calls to direct
reclaim and compaction which slow things down considerably.

When allocating pool pages, note the state of the previous allocation
for each node.  If previous allocation failed, do not use the
aggressive retry algorithm on successive attempts.  The allocation
will still succeed if there is memory available, but it will not try
as hard to free up memory.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 86 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 76 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..c707207e208f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1405,12 +1405,25 @@ pgoff_t __basepage_index(struct page *page)
 }
 
 static struct page *alloc_buddy_huge_page(struct hstate *h,
-		gfp_t gfp_mask, int nid, nodemask_t *nmask)
+		gfp_t gfp_mask, int nid, nodemask_t *nmask,
+		nodemask_t *node_alloc_noretry)
 {
 	int order = huge_page_order(h);
 	struct page *page;
+	bool alloc_try_hard = true;
 
-	gfp_mask |= __GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
+	/*
+	 * By default we always try hard to allocate the page with
+	 * __GFP_RETRY_MAYFAIL flag.  However, if we are allocating pages in
+	 * a loop (to adjust global huge page counts) and previous allocation
+	 * failed, do not continue to try hard on the same node.  Use the
+	 * node_alloc_noretry bitmap to manage this state information.
+	 */
+	if (node_alloc_noretry && node_isset(nid, *node_alloc_noretry))
+		alloc_try_hard = false;
+	gfp_mask |= __GFP_COMP|__GFP_NOWARN;
+	if (alloc_try_hard)
+		gfp_mask |= __GFP_RETRY_MAYFAIL;
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
 	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
@@ -1419,6 +1432,22 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 	else
 		__count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
 
+	/*
+	 * If we did not specify __GFP_RETRY_MAYFAIL, but still got a page this
+	 * indicates an overall state change.  Clear bit so that we resume
+	 * normal 'try hard' allocations.
+	 */
+	if (node_alloc_noretry && page && !alloc_try_hard)
+		node_clear(nid, *node_alloc_noretry);
+
+	/*
+	 * If we tried hard to get a page but failed, set bit so that
+	 * subsequent attempts will not try as hard until there is an
+	 * overall state change.
+	 */
+	if (node_alloc_noretry && !page && alloc_try_hard)
+		node_set(nid, *node_alloc_noretry);
+
 	return page;
 }
 
@@ -1427,7 +1456,8 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
  * should use this function to get new hugetlb pages
  */
 static struct page *alloc_fresh_huge_page(struct hstate *h,
-		gfp_t gfp_mask, int nid, nodemask_t *nmask)
+		gfp_t gfp_mask, int nid, nodemask_t *nmask,
+		nodemask_t *node_alloc_noretry)
 {
 	struct page *page;
 
@@ -1435,7 +1465,7 @@ static struct page *alloc_fresh_huge_page(struct hstate *h,
 		page = alloc_gigantic_page(h, gfp_mask, nid, nmask);
 	else
 		page = alloc_buddy_huge_page(h, gfp_mask,
-				nid, nmask);
+				nid, nmask, node_alloc_noretry);
 	if (!page)
 		return NULL;
 
@@ -1450,14 +1480,16 @@ static struct page *alloc_fresh_huge_page(struct hstate *h,
  * Allocates a fresh page to the hugetlb allocator pool in the node interleaved
  * manner.
  */
-static int alloc_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
+static int alloc_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
+				nodemask_t *node_alloc_noretry)
 {
 	struct page *page;
 	int nr_nodes, node;
 	gfp_t gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 
 	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
-		page = alloc_fresh_huge_page(h, gfp_mask, node, nodes_allowed);
+		page = alloc_fresh_huge_page(h, gfp_mask, node, nodes_allowed,
+						node_alloc_noretry);
 		if (page)
 			break;
 	}
@@ -1601,7 +1633,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		goto out_unlock;
 	spin_unlock(&hugetlb_lock);
 
-	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask, NULL);
 	if (!page)
 		return NULL;
 
@@ -1637,7 +1669,7 @@ struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask, NULL);
 	if (!page)
 		return NULL;
 
@@ -2207,13 +2239,31 @@ static void __init gather_bootmem_prealloc(void)
 static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
+	nodemask_t *node_alloc_noretry;
+
+	if (!hstate_is_gigantic(h)) {
+		/*
+		 * bit mask controlling how hard we retry per-node
+		 * allocations.
+		 */
+		node_alloc_noretry = kmalloc(sizeof(*node_alloc_noretry),
+						GFP_KERNEL | __GFP_NORETRY);
+	} else {
+		/* allocations done at boot time */
+		node_alloc_noretry = NULL;
+	}
+
+	/* bit mask controlling how hard we retry per-node allocations */
+	if (node_alloc_noretry)
+		nodes_clear(*node_alloc_noretry);
 
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (hstate_is_gigantic(h)) {
 			if (!alloc_bootmem_huge_page(h))
 				break;
 		} else if (!alloc_pool_huge_page(h,
-					 &node_states[N_MEMORY]))
+					 &node_states[N_MEMORY],
+					 node_alloc_noretry))
 			break;
 		cond_resched();
 	}
@@ -2225,6 +2275,8 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 			h->max_huge_pages, buf, i);
 		h->max_huge_pages = i;
 	}
+
+	kfree(node_alloc_noretry);
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -2323,6 +2375,14 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
+	NODEMASK_ALLOC(nodemask_t, node_alloc_noretry,
+						GFP_KERNEL | __GFP_NORETRY);
+
+	/* bit mask controlling how hard we retry per-node allocations */
+	if (node_alloc_noretry)
+		nodes_clear(*node_alloc_noretry);
+	else
+		return -ENOMEM;
 
 	spin_lock(&hugetlb_lock);
 
@@ -2356,6 +2416,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
 		if (count > persistent_huge_pages(h)) {
 			spin_unlock(&hugetlb_lock);
+			if (node_alloc_noretry)
+				NODEMASK_FREE(node_alloc_noretry);
 			return -EINVAL;
 		}
 		/* Fall through to decrease pool */
@@ -2388,7 +2450,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
-		ret = alloc_pool_huge_page(h, nodes_allowed);
+		ret = alloc_pool_huge_page(h, nodes_allowed,
+						node_alloc_noretry);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -2429,6 +2492,9 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	h->max_huge_pages = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
 
+	if (node_alloc_noretry)
+		NODEMASK_FREE(node_alloc_noretry);
+
 	return 0;
 }
 
-- 
2.20.1

