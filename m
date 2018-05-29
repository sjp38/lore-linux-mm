Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E496A6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 13:56:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n9-v6so9613985wmh.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 10:56:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f1-v6si2429245edr.169.2018.05.29.10.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 10:56:03 -0700 (PDT)
Date: Tue, 29 May 2018 13:58:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
Message-ID: <20180529175806.GA28689@cmpxchg.org>
References: <20180524110011.1940-1-vbabka@suse.cz>
 <20180524153225.GA7329@cmpxchg.org>
 <fcdcf7be-afd1-9747-d97e-51cd071d3f5c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fcdcf7be-afd1-9747-d97e-51cd071d3f5c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On Mon, May 28, 2018 at 10:15:46AM +0200, Vlastimil Babka wrote:
> On 05/24/2018 05:32 PM, Johannes Weiner wrote:
> > On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
> >> - the vmstat/meminfo counter name is rather general and might suggest it also
> >>   includes reclaimable page caches, which it doesn't
> >>
> >> Suggestions welcome for all three points. For the last one, we might also keep
> >> the counter separate from nr_slab_reclaimable, not superset. I did a superset
> >> as IIRC somebody suggested that in the older threads or at LSF.
> > 
> > Yeah, the "reclaimable" name is too generic. How about KReclaimable?
> > 
> > The counter being a superset sounds good to me. We use this info for
> > both load balancing and manual debugging. For load balancing code it's
> > nice not having to worry about finding all the counters that hold
> > reclaimable memory depending on kernel version; it's always simply
> > user cache + user anon + kernel reclaimable. And for debugging, we can
> > always add more specific subset counters later on if we need them.
> 
> Hm, Christoph in his reply to patch 4/5 expressed a different opinion.
> It's true that updating two counters has extra overhead, especially if
> there are two separate critical sections:
> 
> mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
> mod_node_page_state(page_pgdat(page), NR_RECLAIMABLE, nr_pages);
> 
> The first disables irq for CONFIG_MEMCG or defers to
> mod_node_page_state() otherwise.
> mod_node_page_state() is different depending on CONFIG_SMP and
> CONFIG_HAVE_CMPXCHG_LOCAL.
> 
> I don't see an easy way to make this optimal? Different counter would be
> indeed simpler. /proc/vmstat would then print separate counters, but we
> could have both separate and summary counter in /proc/meminfo. Would
> that be enough?

Yeah, that works just as well.
