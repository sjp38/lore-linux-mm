Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6531FC0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C0DB2147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ffw9c4N5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C0DB2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D8AF6B0008; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 188956B0005; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED3306B000C; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD2756B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id h37so8129649uad.16
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NkfExKMcLKaKUZb76g5CsxS1F+1fcLfxs/msqSWpJyg=;
        b=TLtRu7MBdDyLcAIF2/qX1YqHyQsSwWApcnqmn4Dyd5AJtexgnokLHY/bMJGZQZUmyJ
         ft7YYEP5yBsndy3G5zvZ9i2wCx5sB29480PkWZC3OIan6fLKElKeJUj1FnJqfecO9xKz
         UVDwcQR3H5wxKU9JyjzBWo58l8x2rzMNb+2dC0kEZea0RdlXXv1E8kudA93UddJD8QUq
         v631fxJSOTyhXUzhPeg0RMVzXLA4fOQSDOn7PSvXE7olz9LAUBx3XdAsdKETxGc1qS15
         SExkSWPIvuhJwNwe9c/e+3/mBTpiBd/IhdvAWNgFRTD/BIIrHWsbbH6/RagA2uagluqI
         zhbA==
X-Gm-Message-State: APjAAAU86SXGq627fXgzACQ7+5ssvqn8XkipHhGQF0lg28FiLfzahbkk
	QlxI7csajwIwydAZE4LAraKjAX/QJyIBDoA2aY8HdObpp8wSKkPmjEWea4xcpGVdCrHX5BPQhTu
	b86bWk0GIZEQlLcwIvYryp/1DX1JljPZszxDBJTh4Wq8r85FeWaG7X4kCVkO723iU8g==
X-Received: by 2002:a67:a44b:: with SMTP id p11mr717109vsh.237.1565056091315;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYGCduO/ts8TXdo+Vh4BUEhUhA0bKtA0bbXfXaZJKaorBEwym0f/M3ryelS3Bgd7ZDkCz8
X-Received: by 2002:a67:a44b:: with SMTP id p11mr717093vsh.237.1565056090490;
        Mon, 05 Aug 2019 18:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056090; cv=none;
        d=google.com; s=arc-20160816;
        b=Q8DsJxX18GiIIUiPgceEDP9d/CSCCxVt41IdE6dFkfbtAkbe+eMB71iiK9gZnl1VIc
         qlt24OaXqBQCPvJ4hCH3hoyDcr3C1PGj8CYlsOZ0XFKdu2G2xbjnHQv7qcWkLS6ccRww
         aHXrlzk0QGG8DKFuhXZqddgtFGgPnfjb3KVK6/BTs8dRtiMn6v9CyY+Jmh3W9qh216p2
         gNbxehUBv7jdd6yLQD/hbAZeIwXx7839ycYxjvup+nH0wXXecATjTdE22rWBj7hytLpK
         MgME52bdgN2y7sRryS7B1XS/stWyubKUeXwiQOBaVrpG/y254zzNGomfGZpZRXBHF7An
         z7Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NkfExKMcLKaKUZb76g5CsxS1F+1fcLfxs/msqSWpJyg=;
        b=qbUkcCvcA6ojqaoJ6tyTA6/3TJu2yjI0aQODBns3dv9OCHdtQbsQ0QH3kH+HmDzPXT
         zh4GmJ7uItg8msw0A6T+biVPymNhm25Vgq9xoAmJGbnQOj77ioDWAS+jzrnXj5ckbEWc
         O0HYe4NmIr/naT/RSeXrvAoNPsU0DTc4P5pQYHYKdH9qM5U/D9BONFCp60jXepzIFQ6a
         GDB+51WdNkWRc7Y40c3XiQGSUESWX3CEvEUhGJet9mcpgvhSY2Hgrgr6VghSxdsd8USt
         XuDiJRJnE6cV2jYg797Spp9JI371KQTk15GmwTbX5Kucef1Gj1I2SJ9W63+h4mqn8WM/
         rjsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ffw9c4N5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h9si15656024vsk.245.2019.08.05.18.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ffw9c4N5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761i73Z151869;
	Tue, 6 Aug 2019 01:48:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=NkfExKMcLKaKUZb76g5CsxS1F+1fcLfxs/msqSWpJyg=;
 b=Ffw9c4N5uibqiguUP/+Kxijh2it7kC65bqaiLVF+uWAkM+cwU5wJ4EsIKqnXh6+wpYu2
 Kx8+9zR8F4/87DVsm2/Tt/M00ITVQct/1bVvATEnZh58tDT9gCtnBUwxDEEEhBv8mK9j
 LZWUgTr4agZ6G+Qgi7TywPysOh08PaowpFUPpv92PqocSw6ExE7oSQW9aTU4nkMT79uM
 8M/h2aAuOMu1CtGcUaRZW8C6j4MyXJj8fLDNFRceZXkF4B3VlPGUtRbCNpfMMrgDZTDi
 x2VP7NCKE/XPFSHQwFyWPL4ZnJPx83LojZBM1mXFf7EKftIYAWf6mQaILaFQdnDjNE3/ Ng== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u527pjm9n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:05 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761m4fm032603;
	Tue, 6 Aug 2019 01:48:04 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2u50ac9ax6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:04 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x761lxFd016089;
	Tue, 6 Aug 2019 01:47:59 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 18:47:59 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 4/4] hugetlbfs: don't retry when pool page allocations start to fail
Date: Mon,  5 Aug 2019 18:47:44 -0700
Message-Id: <20190806014744.15446-5-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806014744.15446-1-mike.kravetz@oracle.com>
References: <20190806014744.15446-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060020
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060019
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
v2 - Removed __GFP_NORETRY from bit mask allocations and added more
     comments.  OK to pass NULL to NODEMASK_FREE.

 mm/hugetlb.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 79 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..2be0b055958a 100644
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
 
@@ -2207,13 +2239,33 @@ static void __init gather_bootmem_prealloc(void)
 static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
+	nodemask_t *node_alloc_noretry;
+
+	if (!hstate_is_gigantic(h)) {
+		/*
+		 * Bit mask controlling how hard we retry per-node allocations.
+		 * Ignore errors as lower level routines can deal with
+		 * node_alloc_noretry == NULL.  If this kmalloc fails at boot
+		 * time, we are likely in bigger trouble.
+		 */
+		node_alloc_noretry = kmalloc(sizeof(*node_alloc_noretry),
+						GFP_KERNEL);
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
@@ -2225,6 +2277,8 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 			h->max_huge_pages, buf, i);
 		h->max_huge_pages = i;
 	}
+
+	kfree(node_alloc_noretry);
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -2323,6 +2377,17 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
+	NODEMASK_ALLOC(nodemask_t, node_alloc_noretry, GFP_KERNEL);
+
+	/*
+	 * Bit mask controlling how hard we retry per-node allocations.
+	 * If we can not allocate the bit mask, do not attempt to allocate
+	 * the requested huge pages.
+	 */
+	if (node_alloc_noretry)
+		nodes_clear(*node_alloc_noretry);
+	else
+		return -ENOMEM;
 
 	spin_lock(&hugetlb_lock);
 
@@ -2356,6 +2421,7 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
 		if (count > persistent_huge_pages(h)) {
 			spin_unlock(&hugetlb_lock);
+			NODEMASK_FREE(node_alloc_noretry);
 			return -EINVAL;
 		}
 		/* Fall through to decrease pool */
@@ -2388,7 +2454,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
-		ret = alloc_pool_huge_page(h, nodes_allowed);
+		ret = alloc_pool_huge_page(h, nodes_allowed,
+						node_alloc_noretry);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -2429,6 +2496,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	h->max_huge_pages = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
 
+	NODEMASK_FREE(node_alloc_noretry);
+
 	return 0;
 }
 
-- 
2.20.1

