Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F07476B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:20:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v104so22571749wrb.6
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:20:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o81si9820657wrb.203.2017.06.12.05.20.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 05:20:37 -0700 (PDT)
Date: Mon, 12 Jun 2017 14:20:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 4/4] hugetlb: add support for preferred node to
 alloc_huge_page_nodemask
Message-ID: <20170612122035.GL7476@dhcp22.suse.cz>
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-5-mhocko@kernel.org>
 <a41926b2-1e49-d6a6-f92e-5ebf2fa101e3@suse.cz>
 <20170612090656.GD7476@dhcp22.suse.cz>
 <cb18b8ad-af25-b269-3808-5a7452ee2d60@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb18b8ad-af25-b269-3808-5a7452ee2d60@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 12-06-17 13:53:51, Vlastimil Babka wrote:
> On 06/12/2017 11:06 AM, Michal Hocko wrote:
[...]
> > -/* Movability of hugepages depends on migration support. */
> > -static inline gfp_t htlb_alloc_mask(struct hstate *h)
> > +static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> >  {
> > -	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
> > -		return GFP_HIGHUSER_MOVABLE;
> > -	else
> > -		return GFP_HIGHUSER;
> > +	if (nid != NUMA_NO_NODE)
> > +		return dequeue_huge_page_node_exact(h, nid);
> > +
> > +	return dequeue_huge_page_nodemask(h, nid, NULL);
> 
> This with nid == NUMA_NO_NODE will break at node_zonelist(nid,
> gfp_mask); in dequeue_huge_page_nodemask(). I guess just use the local
> node as preferred.

You are right. Anyway I have a patch to remove this helper altogether.

> > -retry_cpuset:
> > -	cpuset_mems_cookie = read_mems_allowed_begin();
> > -	gfp_mask = htlb_alloc_mask(h);
> > -	nid = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
> > -	zonelist = node_zonelist(nid, gfp_mask);
> > -
> > -	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > -						MAX_NR_ZONES - 1, nodemask) {
> > -		if (cpuset_zone_allowed(zone, gfp_mask)) {
> > -			page = dequeue_huge_page_node(h, zone_to_nid(zone));
> > -			if (page) {
> > -				if (avoid_reserve)
> > -					break;
> > -				if (!vma_has_reserves(vma, chg))
> > -					break;
> > -
> > -				SetPagePrivate(page);
> > -				h->resv_huge_pages--;
> > -				break;
> > -			}
> > -		}
> > +	nid = huge_node(vma, address, htlb_alloc_mask(h), &mpol, &nodemask);
> > +	page = dequeue_huge_page_nodemask(h, nid, nodemask);
> > +	if (page && !(avoid_reserve || (!vma_has_reserves(vma, chg)))) {
> 
> Ugh that's hard to parse.
> What about: if (page && !avoid_reserve && vma_has_reserves(...)) ?

Yeah, I have just translated the two breaks into a single condition
without scratching my head to much. If you think that this face of De Morgan
is nicer I can use it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
