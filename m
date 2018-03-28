Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C932F6B0011
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:02:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n7so1228299wrb.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:02:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si2885525wrh.30.2018.03.28.07.02.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 07:02:49 -0700 (PDT)
Date: Wed, 28 Mar 2018 16:02:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: optimize find_min_pfn_for_node() by
 geting the minimal pfn directly
Message-ID: <20180328140247.GP9275@dhcp22.suse.cz>
References: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
 <20180328034752.96146-1-richard.weiyang@gmail.com>
 <20180328115853.GI9275@dhcp22.suse.cz>
 <20180328133456.GB543@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328133456.GB543@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed 28-03-18 21:34:56, Wei Yang wrote:
> On Wed, Mar 28, 2018 at 01:58:53PM +0200, Michal Hocko wrote:
> >On Wed 28-03-18 11:47:52, Wei Yang wrote:
> >[...]
[...]
> >> @@ -6365,14 +6365,16 @@ unsigned long __init node_map_pfn_alignment(void)
> >>  /* Find the lowest pfn for a node */
> >>  static unsigned long __init find_min_pfn_for_node(int nid)
> >>  {
> >> -	unsigned long min_pfn = ULONG_MAX;
> >> -	unsigned long start_pfn;
> >> -	int i;
> >> +	unsigned long min_pfn;
> >> +	int i = -1;
> >>  
> >> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
> >> -		min_pfn = min(min_pfn, start_pfn);
> >> +	/*
> >> +	 * The first pfn on nid node is the minimal one, as the pfn's are
> >> +	 * stored in ascending order.
> >> +	 */
> >> +	first_mem_pfn(i, nid, &min_pfn);
> >>  
> >> -	if (min_pfn == ULONG_MAX) {
> >> +	if (i == -1) {
> >>  		pr_warn("Could not find start_pfn for node %d\n", nid);
> >>  		return 0;
> >>  	}
> >
> >I would just open code it. Other than that I strongly suspect this will
> >not have any measurable impact becauser we usually only have handfull of
> >memory ranges but why not. Just make the new implementation less ugly
> >than it is cuurrently - e.g. opencode first_mem_pfn and you can add
> 
> Open code here means use __next_mem_pfn_range() directly instead of using
> first_mem_pfn()?

Yes with the comment explaining how we rely on sorted ranges the way you
did.
-- 
Michal Hocko
SUSE Labs
