Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFB7DC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E2022190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LyqW3tnX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E2022190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 530BC8E000C; Wed, 24 Jul 2019 13:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E0778E0005; Wed, 24 Jul 2019 13:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D1138E000C; Wed, 24 Jul 2019 13:50:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 100448E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:50:35 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t5so42063909qtd.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pckymHbnRHu+rafvqysstMGQoahE6dDQ06s/gXDYrBc=;
        b=bwRoKiPtkkRrg2xcx9ltLEHQwox5bGj+oK+OUtJopu4RO+22H2JBNM61MQ8aaYO3bp
         QcUjzgD7KLkRijYriHEITcxK8elLHULEzwJb9hn4nBnh7UaEhNcLSvu/Oh4H0cX2HVJg
         jRB10d5TkvfYVYLaabDNWGOLkMmOO8N/HCX0po/VjEb7mM2UFdoJg2YKnhA2lSGuUjnw
         NYDB3uuJg3lZ9jXB2/1fsMhyL6JuBfGZxnspzVrw+hutggqnpX+WjUsQSSg0/zlmiqKY
         ZcD8VUII1KEUkK7GI4tkseswyMCAqF+2Lb22/eEkuib7AqL3/cRq2zpffcWAGVJCoT+j
         OtAA==
X-Gm-Message-State: APjAAAV72s3eo8OwluDsmqYsYELyxV841LJsRCBFqEGgnSn51NMpYzdV
	M8QNUjx0wj9bVnHpECzTwtdZBNmV1lzhQXDfERsbOvAE9NBE7xFJppPPAxQco8+7nDdQWtZUZpt
	eccAKD/f9MUt09SqhGbTE4Lt1Cn0fX7Nr4g/BoQlvyft+J+4fXuQ6XQi8QHL6CRkwnA==
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr60418559qvc.172.1563990634783;
        Wed, 24 Jul 2019 10:50:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxF1uWMTzZQ6DNuhGzgShF7FgF4YzzVroocsMRo4K0003nfbDvkkN8qzbCKlGm9uHpHZ0Yt
X-Received: by 2002:a0c:ae31:: with SMTP id y46mr60418507qvc.172.1563990633925;
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563990633; cv=none;
        d=google.com; s=arc-20160816;
        b=bIe2uifrsFL/lYHhNOJPZGNuGvchwm1+pbnGdZz2Hv7o7FHM01Nt5quzzShRMNBmvB
         mCU4vEmpnHht2vIanVoQohIJtZnIrzEesNF0qtc5LEIXHr1SwF+rzHrdkQJx6PPOC0vV
         wdOKHP05S+ium4+2BUYX9QQB5n/+Ai+wgZI7WTRq/Iwhlb8CdNodMTOIAHwOmfQIrDDD
         zcPfUUf+lcorLDqM2ATLFn4aC9bO6p/R6LDVeFFkid3xBH93cGFkx/lColPFv7o+VAr3
         mOnN+bayKH2iQ3PK0G09RjTDRCQUhxPDEAkoYro3ctPy60+BqmVYeXlhrsDQ+U6mOZXP
         8EnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pckymHbnRHu+rafvqysstMGQoahE6dDQ06s/gXDYrBc=;
        b=oivxPdI3P97zAHt/hyVYkwX44KrNWj4HFZjs5OXce3mVOOfIATzPTEV3jyKXd8cogb
         y5JWFhHThOR5cmol3TxCvtPG6HdoTTMpA7atwBvPeQQRecpjTa1Wb5OiP311UtGaoefR
         pU6ceI8CU925KwVuAywClMeI2I7giRuySfjBhTI/ttLqpqmDYQCpjjGbJXn4WY/td+5G
         pIS2uQMvwbPX8IGMvLaul3au692W59dm27UVqV+SNV+op0Qw3fO8nG0u/6tmNDUehu7b
         c4LVQsHhtXXh2i/6l8AV3OxmCQ9iXn10FLN+X4hIIFczd2140v0JTIsm0nyfZEfnd2tc
         urVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LyqW3tnX;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n49si31566888qtf.49.2019.07.24.10.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:50:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LyqW3tnX;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHdv8A050046;
	Wed, 24 Jul 2019 17:50:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=pckymHbnRHu+rafvqysstMGQoahE6dDQ06s/gXDYrBc=;
 b=LyqW3tnXiUeCTD+OMYyOSyntNW7Oow0QdHShbM20ewy7LYaVgE4PMeTNIpvjuyZ15caD
 hPxkaqYeG04m9CEi7QtXOE5KpwMEv4M3Jq7b0c+JP5RWhNaVUcOrt5c8IODDciMT5psW
 gDxMsdLQZQDCn/mAv1Dsb/eV4uZDzv98dvxlp62wO4nuoIFfnV7/5XG7ks35LsH4QQrA
 2sBjEQbze+uv+5o0AsuixJHizx7SwmJGo+qLG+u7O9XgyNAdeeAsGkNpQGXozlmUxzdp
 +8sSckHg0Bgz0jkpb9AZg3/wkBffjkmvIVtoq0E9DjdQpxA9fQwfx18xpdb+pX1ZeTTF QA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2tx61by0ur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:30 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHcAF9185415;
	Wed, 24 Jul 2019 17:50:29 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2tx60y960j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:29 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6OHoTE7022375;
	Wed, 24 Jul 2019 17:50:29 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 10:50:29 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/3] hugetlbfs: don't retry when pool page allocations start to fail
Date: Wed, 24 Jul 2019 10:50:14 -0700
Message-Id: <20190724175014.9935-4-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724175014.9935-1-mike.kravetz@oracle.com>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240191
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240191
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
 mm/hugetlb.c | 87 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 77 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..f3c50344a9b4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1405,12 +1405,27 @@ pgoff_t __basepage_index(struct page *page)
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
+	else
+		gfp_mask |= __GFP_NORETRY;
 	if (nid == NUMA_NO_NODE)
 		nid = numa_mem_id();
 	page = __alloc_pages_nodemask(gfp_mask, order, nid, nmask);
@@ -1419,6 +1434,22 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
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
 
@@ -1427,7 +1458,8 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
  * should use this function to get new hugetlb pages
  */
 static struct page *alloc_fresh_huge_page(struct hstate *h,
-		gfp_t gfp_mask, int nid, nodemask_t *nmask)
+		gfp_t gfp_mask, int nid, nodemask_t *nmask,
+		nodemask_t *node_alloc_noretry)
 {
 	struct page *page;
 
@@ -1435,7 +1467,7 @@ static struct page *alloc_fresh_huge_page(struct hstate *h,
 		page = alloc_gigantic_page(h, gfp_mask, nid, nmask);
 	else
 		page = alloc_buddy_huge_page(h, gfp_mask,
-				nid, nmask);
+				nid, nmask, node_alloc_noretry);
 	if (!page)
 		return NULL;
 
@@ -1450,14 +1482,16 @@ static struct page *alloc_fresh_huge_page(struct hstate *h,
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
@@ -1601,7 +1635,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		goto out_unlock;
 	spin_unlock(&hugetlb_lock);
 
-	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask, NULL);
 	if (!page)
 		return NULL;
 
@@ -1637,7 +1671,7 @@ struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
+	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask, NULL);
 	if (!page)
 		return NULL;
 
@@ -2207,13 +2241,31 @@ static void __init gather_bootmem_prealloc(void)
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
@@ -2225,6 +2277,9 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 			h->max_huge_pages, buf, i);
 		h->max_huge_pages = i;
 	}
+
+	if (node_alloc_noretry)
+		kfree(node_alloc_noretry);
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -2323,6 +2378,12 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
+	NODEMASK_ALLOC(nodemask_t, node_alloc_noretry,
+						GFP_KERNEL | __GFP_NORETRY);
+
+	/* bit mask controlling how hard we retry per-node allocations */
+	if (node_alloc_noretry)
+		nodes_clear(*node_alloc_noretry);
 
 	spin_lock(&hugetlb_lock);
 
@@ -2356,6 +2417,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
 		if (count > persistent_huge_pages(h)) {
 			spin_unlock(&hugetlb_lock);
+			if (node_alloc_noretry)
+				NODEMASK_FREE(node_alloc_noretry);
 			return -EINVAL;
 		}
 		/* Fall through to decrease pool */
@@ -2388,7 +2451,8 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
-		ret = alloc_pool_huge_page(h, nodes_allowed);
+		ret = alloc_pool_huge_page(h, nodes_allowed,
+						node_alloc_noretry);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -2429,6 +2493,9 @@ static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
 	h->max_huge_pages = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
 
+	if (node_alloc_noretry)
+		NODEMASK_FREE(node_alloc_noretry);
+
 	return 0;
 }
 
-- 
2.20.1

