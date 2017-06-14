Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C677A6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:41:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s4so1622552wrc.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:41:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t77si492308wmd.114.2017.06.14.09.41.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:41:55 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:41:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170614164151.GA11240@dhcp22.suse.cz>
References: <20170613090039.14393-1-mhocko@kernel.org>
 <20170613090039.14393-3-mhocko@kernel.org>
 <1b208520-8d4b-9a58-7384-1a031b610e15@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1b208520-8d4b-9a58-7384-1a031b610e15@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 14-06-17 18:17:18, Vlastimil Babka wrote:
> On 06/13/2017 11:00 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > alloc_huge_page_nodemask tries to allocate from any numa node in the
> > allowed node mask starting from lower numa nodes. This might lead to
> > filling up those low NUMA nodes while others are not used. We can reduce
> > this risk by introducing a concept of the preferred node similar to what
> > we have in the regular page allocator. We will start allocating from the
> > preferred nid and then iterate over all allowed nodes in the zonelist
> > order until we try them all.
> > 
> > This is mimicking the page allocator logic except it operates on
> > per-node mempools. dequeue_huge_page_vma already does this so distill
> > the zonelist logic into a more generic dequeue_huge_page_nodemask
> > and use it in alloc_huge_page_nodemask.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I've reviewed the current version in git, where patch 3/4 is folded.
> 
> Noticed some things below, but after fixing:
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

[...]
> > +retry_cpuset:
> > +	cpuset_mems_cookie = read_mems_allowed_begin();
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
> > +		if (!cpuset_zone_allowed(zone, gfp_mask))
> > +			continue;
> > +		/*
> > +		 * no need to ask again on the same node. Pool is node rather than
> > +		 * zone aware
> > +		 */
> > +		if (zone_to_nid(zone) == node)
> > +			continue;
> > +		node = zone_to_nid(zone);
> >  
> > -	for_each_online_node(node) {
> >  		page = dequeue_huge_page_node_exact(h, node);
> >  		if (page)
> > -			return page;
> > +			break;
> 
> Either keep return page here...
> 
> >  	}
> > +	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> > +		goto retry_cpuset;
> > +
> >  	return NULL;
> 
> ... or return page here.

ups I went with the former.

[...]

> > -struct page *alloc_huge_page_nodemask(struct hstate *h, nodemask_t *nmask)
> > +
> > +struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
> > +		nodemask_t *nmask)
> >  {
> >  	struct page *page = NULL;
> > -	int node;
> >  
> >  	spin_lock(&hugetlb_lock);
> >  	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> > -		for_each_node_mask(node, *nmask) {
> > -			page = dequeue_huge_page_node_exact(h, node);
> > -			if (page)
> > -				break;
> > -		}
> > +		page = dequeue_huge_page_nodemask(h, preferred_nid, nmask);
> 
> 
> 
> > +		if (page)
> > +			goto unlock;
> >  	}
> > +unlock:
> 
> This doesn't seem needed?

This on top?
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9ac0ae725c5e..f9868e095afa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -902,7 +902,6 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 {
 	unsigned int cpuset_mems_cookie;
 	struct zonelist *zonelist;
-	struct page *page = NULL;
 	struct zone *zone;
 	struct zoneref *z;
 	int node = -1;
@@ -912,6 +911,8 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), nmask) {
+		struct page *page;
+
 		if (!cpuset_zone_allowed(zone, gfp_mask))
 			continue;
 		/*
@@ -924,9 +925,9 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 
 		page = dequeue_huge_page_node_exact(h, node);
 		if (page)
-			break;
+			return page;
 	}
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
+	if (unlikely(read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
 	return NULL;
@@ -1655,18 +1656,18 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 		nodemask_t *nmask)
 {
 	gfp_t gfp_mask = htlb_alloc_mask(h);
-	struct page *page = NULL;
 
 	spin_lock(&hugetlb_lock);
 	if (h->free_huge_pages - h->resv_huge_pages > 0) {
+		struct page *page;
+
 		page = dequeue_huge_page_nodemask(h, gfp_mask, preferred_nid, nmask);
-		if (page)
-			goto unlock;
+		if (page) {
+			spin_unlock(&hugetlb_lock);
+			return page;
+		}
 	}
-unlock:
 	spin_unlock(&hugetlb_lock);
-	if (page)
-		return page;
 
 	/* No reservations, try to overcommit */
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
