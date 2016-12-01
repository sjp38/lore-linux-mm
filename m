Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 147976B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 05:07:29 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o20so93019872lfg.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 02:07:29 -0800 (PST)
Received: from smtp39.i.mail.ru (smtp39.i.mail.ru. [94.100.177.99])
        by mx.google.com with ESMTPS id s11si33914641lja.80.2016.12.01.02.07.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 02:07:27 -0800 (PST)
Date: Thu, 1 Dec 2016 13:07:17 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [Bug 189181] New: BUG: unable to handle kernel NULL pointer
 dereference in mem_cgroup_node_nr_lru_pages
Message-ID: <20161201100717.GA13790@esperanza>
References: <bug-189181-27@https.bugzilla.kernel.org/>
 <20161129145654.c48bebbd684edcd6f64a03fe@linux-foundation.org>
 <20161130170040.GJ18432@dhcp22.suse.cz>
 <20161130181653.GA30558@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130181653.GA30558@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, marmarek@mimuw.edu.pl

On Wed, Nov 30, 2016 at 01:16:53PM -0500, Johannes Weiner wrote:
> Hi Michael,
> 
> On Wed, Nov 30, 2016 at 06:00:40PM +0100, Michal Hocko wrote:
> > > > [   15.665196] BUG: unable to handle kernel NULL pointer dereference at
> > > > 0000000000000400
> > > > [   15.665213] IP: [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
> > > > [   15.665225] PGD 0 
> > > > [   15.665230] Oops: 0000 [#1] SMP
> > > > [   15.665235] Modules linked in: fuse xt_nat xen_netback xt_REDIRECT
> > > > nf_nat_redirect ip6table_filter ip6_tables xt_conntrack ipt_MASQUERADE
> > > > nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_i
> > > > pv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack intel_rapl
> > > > x86_pkg_temp_thermal coretemp crct10dif_pclmul crc32_pclmul crc32c_intel
> > > > ghash_clmulni_intel pcspkr dummy_hcd udc_core u2mfn(O) 
> > > > xen_blkback xenfs xen_privcmd xen_blkfront
> > > > [   15.665285] CPU: 0 PID: 60 Comm: kswapd0 Tainted: G           O   
> > > > 4.8.10-12.pvops.qubes.x86_64 #1
> > > > [   15.665292] task: ffff880011863b00 task.stack: ffff880011868000
> > > > [   15.665297] RIP: e030:[<ffffffff8122d520>]  [<ffffffff8122d520>]
> > > > mem_cgroup_node_nr_lru_pages+0x20/0x40
> > > > [   15.665307] RSP: e02b:ffff88001186bc70  EFLAGS: 00010293
> > > > [   15.665311] RAX: 0000000000000000 RBX: ffff88001186bd20 RCX:
> > > > 0000000000000002
> > > > [   15.665317] RDX: 000000000000000c RSI: 0000000000000000 RDI:
> > > > 0000000000000000
> > 
> > I cannot generate a similar code to yours but the above suggests that we
> > are getting NULL memcg. This would suggest a global reclaim and
> > count_shadow_nodes misinterprets that because it does
> > 
> > 	if (memcg_kmem_enabled()) {
> > 		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
> > 						     LRU_ALL_FILE);
> > 	} else {
> > 		pages = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
> > 			node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
> > 	}
> > 
> > this might be a race with kmem enabling AFAICS. Anyaway I believe that
> > the above check needs to ne extended for the sc->memcg != NULL
> 
> Yep, my locally built code looks very different from the report, but
> it's clear that memcg is NULL. I didn't see the race you mention, but
> it makes sense to me: shrink_slab() is supposed to filter memcg-aware
> shrinkers based on whether we have a memcg or not, but it only does it
> when kmem accounting is enabled; if it's disabled, the shrinker should
> also use its non-memcg behavior. However, nothing prevents a memcg
> with kmem from onlining between the filter and the shrinker run.

Yeah, I think the issue can be easily reproduced by triggering the
reclaimer while running mkdir/rmdir on a memory cgroup directory in a
loop provided no other memory cgroup exists in the system.

> 
> > diff --git a/mm/workingset.c b/mm/workingset.c
> > index 617475f529f4..0f07522c5c0e 100644
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -348,7 +348,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
> >  	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
> >  	local_irq_enable();
> >  
> > -	if (memcg_kmem_enabled()) {
> > +	if (memcg_kmem_enabled() && sc->memcg) {
> >  		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
> >  						     LRU_ALL_FILE);
> >  	} else {
> 
> If we do that, I'd remove the racy memcg_kmem_enabled() check
> altogether and just check for whether we have a memcg or not.

Agree. BTW this is how the other memcg-aware shrinker, list_lru, works -
see list_lru_shrink_count -> memcg_cache_id.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
