Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 978F76B0071
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:48:44 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2236319dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:48:43 -0700 (PDT)
Date: Wed, 27 Jun 2012 12:48:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 02/11] memcg: Reclaim when more than one page needed.
In-Reply-To: <4FEADA55.4060409@parallels.com>
Message-ID: <alpine.DEB.2.00.1206271246380.22162@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-3-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252106430.26640@chino.kir.corp.google.com> <4FEADA55.4060409@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Suleiman Souhlal <suleiman@google.com>

On Wed, 27 Jun 2012, Glauber Costa wrote:

> > @@ -2206,7 +2214,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup
> > *memcg, gfp_t gfp_mask,
> > >  	 * unlikely to succeed so close to the limit, and we fall back
> > >  	 * to regular pages anyway in case of failure.
> > >  	 */
> > > -	if (nr_pages == 1 && ret)
> > > +	if (nr_pages <= NR_PAGES_TO_RETRY && ret)
> > >  		return CHARGE_RETRY;
> 
> Changed to costly order.
> 

1 << PAGE_ALLOC_COSTLY_ORDER was the suggestion.

> One more thing. The original version of this patch included
> a cond_resched() here, that was also removed. From my re-reading
> of the code in page_alloc.c and vmscan.c now, I tend to think
> this is indeed not needed, since any cond_resched()s that might
> be needed to ensure the safety of the code will be properly
> inserted by the reclaim code itself, so there is no need for us
> to include any when we signal that a retry is needed.
> 

For __GFP_WAIT, that sounds like a safe guarantee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
