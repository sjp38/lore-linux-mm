Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0912BC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 23:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B65121881
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 23:54:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="eWNkXNsh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B65121881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF556B0006; Wed,  3 Jul 2019 19:54:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AE168E0003; Wed,  3 Jul 2019 19:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 176F78E0001; Wed,  3 Jul 2019 19:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3B466B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 19:54:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so2196761pld.15
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 16:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lRFxzELYfMVCyxwAkaClIeFK5uwSzrQldTtm4JqVY7g=;
        b=YAkTdCnrC9VZZjQFg1WFUYUmS4U3PPiBgOkLHMDZNzmLyhqTEMChKTZqebYbJAAvKy
         4HWxTYky6u88GZysOaJm/iFiKzW6APhQo5Drq6JaoLCs1Z2Vur4iBRFZlOqZwZ8qF0W+
         PuK4e05AK5q4dDYh8UyzAG8hoJVyJniLI/lQrJ4vuqHwAz2nZhIlbd3XGCavXB8Ha/gA
         zJ6G8zuswn1bcSPa6doYNF2+x3ZrGw+tbKd5VyQda5BFYZcdbeqQRTVRY7xuwL9JDojW
         Z8yiHYV04iZAO+LN7nE51QXLm1iHajixOPr8ygAbfpiddyfvpWtm+JS671RsLztzgP/l
         Arhw==
X-Gm-Message-State: APjAAAVFLI9l9uV3lPi6aPY55qQWOPCGA1OCzY7WhNYzqEsXFP0pOFF0
	ldgaO8xiBnJMcBNI0rNpu2ophYJtzSpDS+xeiVtEGfv2iUa+8f3ra5UYpSEYO6ISb6jXKUOAuLV
	haV8Gb1UGk7hJQpJlrhs4o3xBKm+8OHRjKJOMXPVO3LIZgIpZCuO5pGssaVhpZoPjIA==
X-Received: by 2002:a63:c20e:: with SMTP id b14mr15555960pgd.96.1562198090187;
        Wed, 03 Jul 2019 16:54:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwu3ooM9io6jUqmAM5LbWqEH99WFpCX7XVBguewm894rK3iVa7ctLUqhiCIDMCY8BZderQ0
X-Received: by 2002:a63:c20e:: with SMTP id b14mr15555906pgd.96.1562198088996;
        Wed, 03 Jul 2019 16:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562198088; cv=none;
        d=google.com; s=arc-20160816;
        b=ZQlhKvAN6CrCgWLNxnf0ntUuPw5ORLMmdWA04tqMkUbM89VIqnTJWl2089DvE3aTKt
         J2A0+CASqUlTa8ySSpdOLZfSUuvkBMHe8q/Lk0/sobt8cxsFJogiLf6xGyGAHL+5aa4H
         OnYvIpvdvVXaZO50ky3JmA9wbgq9iQOyiMcSPogDnlFYUTOD3exOORWuy4bggbbRzGGf
         fZUAuXlCHiALHO2pynfQ/xD097G2ikmVe3x25cGGCcipoJoOIVlxJ78PZ6mw6Iq/UpIp
         6sH97Zw8YzAInr+MAozvtab5PZSz38WODNjHWrFJtFvI+FIOu4kGl63wKByxubMXh6hY
         7u7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lRFxzELYfMVCyxwAkaClIeFK5uwSzrQldTtm4JqVY7g=;
        b=s18mMhr0NNhsl4gnfg/Jx/WsBCxnJYQ7xFplbHwK7oW1m6C2BNa2t8X9EZcn7fjGzD
         6Vn7M9EiV0BIXH+vqkaKjPxsKPndev5chBSh5wLgB2fBrqMbCGUkDU1tJrvHWIiv4+cU
         Aw4zd87+vKKaDM7IDorhRB5N5bjOxUUJR99wqCAzJfKV2RNeyWXiu1zCbV1cn4PEWOQJ
         qfSa1vjh1NF9BrDctwRS5YveHLVGosJUm9NAzejX25YL/kNWe08WlPzg5nLG8Bq8L1bC
         81QXv0xSf4UPSyAOSJo/GVq+tErk4/bfU8+b99ot9JtYO12NVAvshxHoBopGm9wo20aj
         rr3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eWNkXNsh;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v189si3507708pgd.289.2019.07.03.16.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 16:54:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=eWNkXNsh;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x63NsRwx168343;
	Wed, 3 Jul 2019 23:54:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=lRFxzELYfMVCyxwAkaClIeFK5uwSzrQldTtm4JqVY7g=;
 b=eWNkXNshfk6swcQNcJuHS2WHidHmc5993aQlROjTbPVUzXt2+UIXobRAA4njbi1/DsoR
 HFdWgylr6tqR6z1SHFtyuf6Ht2nfVhdBeUWS99P722NnudoxGzXsB10okYW2V50Ivo8M
 lL6x3Eln9hPkXVUcILhQnFjImK1njhHuzdOQEieJvr4nQXAXeJtc+xFW89pE/ozErLtp
 B1MWJm0KszzrLsjwkwrtaqKjyE8ZakG0Eehde3foKrzt0Ng85dZKbaH8CHqbai1Pjwr/
 F9Xby8kwLr6eEOUKYvQ4MMpgf4QcB+PVnjqXpoZCC9iYYnHGRpy7KuacZhXx0/iHhWvU aw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2te61ec089-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Jul 2019 23:54:45 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x63NqQNX147728;
	Wed, 3 Jul 2019 23:54:45 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2tebkv518u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Jul 2019 23:54:45 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x63NsbPA005307;
	Wed, 3 Jul 2019 23:54:37 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Jul 2019 16:54:36 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
 <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
 <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
 <20190701085920.GB2812@suse.de>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <20190703094325.GB2737@techsingularity.net>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <571d5557-2153-59ea-334b-8636cc1a49c9@oracle.com>
Date: Wed, 3 Jul 2019 16:54:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703094325.GB2737@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9307 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907030294
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9307 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907030294
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 2:43 AM, Mel Gorman wrote:
> Indeed. I'm getting knocked offline shortly so I didn't give this the
> time it deserves but it appears that part of this problem is
> hugetlb-specific when one node is full and can enter into this continual
> loop due to __GFP_RETRY_MAYFAIL requiring both nr_reclaimed and
> nr_scanned to be zero.

Yes, I am not aware of any other large order allocations consistently made
with __GFP_RETRY_MAYFAIL.  But, I did not look too closely.  Michal believes
that hugetlb pages allocations should use __GFP_RETRY_MAYFAIL.

> Have you considered one of the following as an option?
> 
> 1. Always use the on-stack nodes_allowed in __nr_hugepages_store_common
>    and copy nodes_states if necessary. Add a bool parameter to
>    alloc_pool_huge_page that is true when called from set_max_huge_pages.
>    If an allocation from alloc_fresh_huge_page, clear the failing node
>    from the mask so it's not retried, bail if the mask is empty. The
>    consequences are that round-robin allocation of huge pages will be
>    different if a node failed to allocate for transient reasons.

That seems to be a more aggressive form of 3 below.

> 2. Alter the condition in should_continue_reclaim for
>    __GFP_RETRY_MAYFAIL to consider if nr_scanned < SWAP_CLUSTER_MAX.
>    Either raise priority (will interfere with kswapd though) or
>    bail entirely.  Consequences may be that other __GFP_RETRY_MAYFAIL
>    allocations do not want this behaviour. There are a lot of users.

Due to high number of users, I am avoiding such a change.  It would be
hard to validate that such a change does not impact other users.

> 3. Move where __GFP_RETRY_MAYFAIL is set in a gfp_mask in mm/hugetlb.c.
>    Strip the flag if an allocation fails on a node. Consequences are
>    that setting the required number of huge pages is more likely to
>    return without all the huge pages set.

We are actually using a form of this in our distro kernel.  It works quite
well on the older (4.11 based) distro kernel.  My plan was to push this
upstream.  However, when I tested this on recent upstream kernels, I
encountered long stalls associated with the first __GFP_RETRY_MAYFAIL
allocation failure.  That is what prompted me to ask this queastion/start
this thread.  The distro kernel would see stalls taking tens of seconds,
upstream would see stalls of several minutes.  Much has changed since 4.11,
so I was trying to figure out what might be causing this change in behavior.

BTW, here is the patch I was testing.  It actually has additional code to
switch between __GFP_RETRY_MAYFAIL and __GFP_NORETRY and back to hopefully
take into account transient conditions.

From 528c52397301f02acb614c610bd65f0f9a107481 Mon Sep 17 00:00:00 2001
From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Wed, 3 Jul 2019 13:36:24 -0700
Subject: [PATCH] hugetlbfs: don't retry when pool page allocations start to
 fail

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

