Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40EC58E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 05:43:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so152368edb.5
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 02:43:22 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v27si3113570edm.111.2019.01.07.02.43.20
        for <linux-mm@kvack.org>;
        Mon, 07 Jan 2019 02:43:20 -0800 (PST)
Date: Mon, 7 Jan 2019 10:43:14 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: survive in a low-memory situation
Message-ID: <20190107104314.uugftsqcjsi5j6g2@mbp>
References: <20190102165931.GB6584@arrakis.emea.arm.com>
 <20190102180619.12392-1-cai@lca.pw>
 <20190103093201.GB31793@dhcp22.suse.cz>
 <9197d86b-a684-c7f4-245b-63c890f1104f@lca.pw>
 <20190103170735.GV31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103170735.GV31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 03, 2019 at 06:07:35PM +0100, Michal Hocko wrote:
> > > On Wed 02-01-19 13:06:19, Qian Cai wrote:
> > > [...]
> > >> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> > >> index f9d9dc250428..9e1aa3b7df75 100644
> > >> --- a/mm/kmemleak.c
> > >> +++ b/mm/kmemleak.c
> > >> @@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> > >>  	struct rb_node **link, *rb_parent;
> > >>  
> > >>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> > >> +#ifdef CONFIG_PREEMPT_COUNT
> > >> +	if (!object) {
> > >> +		/* last-ditch effort in a low-memory situation */
> > >> +		if (irqs_disabled() || is_idle_task(current) || in_atomic())
> > >> +			gfp = GFP_ATOMIC;
> > >> +		else
> > >> +			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> > >> +		object = kmem_cache_alloc(object_cache, gfp);
> > >> +	}
> > >> +#endif
[...]
> I will not object to this workaround but I strongly believe that
> kmemleak should rethink the metadata allocation strategy to be really
> robust.

This would be nice indeed and it was discussed last year. I just haven't
got around to trying anything yet:

https://marc.info/?l=linux-mm&m=152812489819532

-- 
Catalin
