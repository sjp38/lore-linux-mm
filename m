Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 168AF6B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:13:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so23839496wme.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:13:56 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id f134si6390497wmg.96.2016.06.23.06.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 06:13:55 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id r201so49576040wme.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:13:54 -0700 (PDT)
Date: Thu, 23 Jun 2016 15:13:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 15/27] mm, page_alloc: Consider dirtyable memory in terms
 of nodes
Message-ID: <20160623131353.GJ30077@dhcp22.suse.cz>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-16-git-send-email-mgorman@techsingularity.net>
 <20160622141521.GC7527@dhcp22.suse.cz>
 <20160622142756.GH9208@dhcp22.suse.cz>
 <20160623125312.GW1868@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160623125312.GW1868@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 23-06-16 13:53:12, Mel Gorman wrote:
> On Wed, Jun 22, 2016 at 04:27:57PM +0200, Michal Hocko wrote:
> > > which can use it (e.g. vmalloc). I understand how this is both an
> > > inherent problem of 32b with a larger high:low ratio and why it is hard
> > > to at least pretend we can cope with it with node based approach but we
> > > should at least document it.
> > > 
> > > I workaround would be to enable highmem_dirtyable_memory which can lead
> > > to premature OOM killer for some workloads AFAIR.
> > [...]
> > > >  static unsigned long highmem_dirtyable_memory(unsigned long total)
> > > >  {
> > > >  #ifdef CONFIG_HIGHMEM
> > > > -	int node;
> > > >  	unsigned long x = 0;
> > > > -	int i;
> > > > -
> > > > -	for_each_node_state(node, N_HIGH_MEMORY) {
> > > > -		for (i = 0; i < MAX_NR_ZONES; i++) {
> > > > -			struct zone *z = &NODE_DATA(node)->node_zones[i];
> > > >  
> > > > -			if (is_highmem(z))
> > > > -				x += zone_dirtyable_memory(z);
> > > > -		}
> > > > -	}
> > 
> > Hmm, I have just noticed that we have NR_ZONE_LRU_ANON resp.
> > NR_ZONE_LRU_FILE so we can estimate the amount of highmem contribution
> > to the global counters by the following or similar:
> > 
> > 	for_each_node_state(node, N_HIGH_MEMORY) {
> > 		for (i = 0; i < MAX_NR_ZONES; i++) {
> > 			struct zone *z = &NODE_DATA(node)->node_zones[i];
> > 
> > 			if (!is_highmem(z))
> > 				continue;
> > 
> > 			x += zone_page_state(z, NR_FREE_PAGES) + zone_page_state(z, NR_ZONE_LRU_FILE) - high_wmark_pages(zone);
> > 		}
> > 
> > high wmark reduction would be to emulate the reserve. What do you think?
> 
> Agreed with minor modifications. Went with this
> 
>         for_each_node_state(node, N_HIGH_MEMORY) {
>                 for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
>                         struct zone *z;
> 
>                         if (!is_highmem_idx(z))
>                                 continue;
> 
>                         z = &NODE_DATA(node)->node_zones[i];
>                         x += zone_page_state(z, NR_FREE_PAGES) +
>                                 zone_page_state(z, NR_ZONE_LRU_FILE) -
>                                 high_wmark_pages(zone);

I guess you will still need an underflow protection. Because both free +
lru pages might be below high wmark.

			dirtyable += zone_page_state(z, NR_FREE_PAGES) +
					zone_page_state(z, NR_ZONE_LRU_FILE);
			if (dirtyable > high_wmark_pages(zone)
				dirtyable -= high_wmark_pages(zone);

			x += dirtyable;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
