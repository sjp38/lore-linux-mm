Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7533C6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:28:00 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so4154578wme.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:28:00 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id cv1si11560157wjb.126.2016.06.22.07.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 07:27:59 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id c82so1677004wme.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:27:58 -0700 (PDT)
Date: Wed, 22 Jun 2016 16:27:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 15/27] mm, page_alloc: Consider dirtyable memory in terms
 of nodes
Message-ID: <20160622142756.GH9208@dhcp22.suse.cz>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-16-git-send-email-mgorman@techsingularity.net>
 <20160622141521.GC7527@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622141521.GC7527@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 22-06-16 16:15:21, Michal Hocko wrote:
> On Tue 21-06-16 15:15:54, Mel Gorman wrote:
> > Historically dirty pages were spread among zones but now that LRUs are
> > per-node it is more appropriate to consider dirty pages in a node.
> 
> I think this should deserve a note that a behavior for 32b highmem
> systems will change and could lead to early write throttling and
> observable stalls as a result because highmem_dirtyable_memory will
> always return totalhigh_pages regardless of how much is free resp. on
> LRUs so we can overestimate it.
> 
> Highmem is usually used for LRU pages but there are other allocations
> which can use it (e.g. vmalloc). I understand how this is both an
> inherent problem of 32b with a larger high:low ratio and why it is hard
> to at least pretend we can cope with it with node based approach but we
> should at least document it.
> 
> I workaround would be to enable highmem_dirtyable_memory which can lead
> to premature OOM killer for some workloads AFAIR.
[...]
> >  static unsigned long highmem_dirtyable_memory(unsigned long total)
> >  {
> >  #ifdef CONFIG_HIGHMEM
> > -	int node;
> >  	unsigned long x = 0;
> > -	int i;
> > -
> > -	for_each_node_state(node, N_HIGH_MEMORY) {
> > -		for (i = 0; i < MAX_NR_ZONES; i++) {
> > -			struct zone *z = &NODE_DATA(node)->node_zones[i];
> >  
> > -			if (is_highmem(z))
> > -				x += zone_dirtyable_memory(z);
> > -		}
> > -	}

Hmm, I have just noticed that we have NR_ZONE_LRU_ANON resp.
NR_ZONE_LRU_FILE so we can estimate the amount of highmem contribution
to the global counters by the following or similar:

	for_each_node_state(node, N_HIGH_MEMORY) {
		for (i = 0; i < MAX_NR_ZONES; i++) {
			struct zone *z = &NODE_DATA(node)->node_zones[i];

			if (!is_highmem(z))
				continue;

			x += zone_page_state(z, NR_FREE_PAGES) + zone_page_state(z, NR_ZONE_LRU_FILE) - high_wmark_pages(zone);
		}

high wmark reduction would be to emulate the reserve. What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
