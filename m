Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD9C8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:07:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so33824409edf.17
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:07:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k22si3202731edd.408.2019.01.03.09.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:07:38 -0800 (PST)
Date: Thu, 3 Jan 2019 18:07:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] kmemleak: survive in a low-memory situation
Message-ID: <20190103170735.GV31793@dhcp22.suse.cz>
References: <20190102165931.GB6584@arrakis.emea.arm.com>
 <20190102180619.12392-1-cai@lca.pw>
 <20190103093201.GB31793@dhcp22.suse.cz>
 <9197d86b-a684-c7f4-245b-63c890f1104f@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9197d86b-a684-c7f4-245b-63c890f1104f@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 11:51:57, Qian Cai wrote:
> On 1/3/19 4:32 AM, Michal Hocko wrote:
> > On Wed 02-01-19 13:06:19, Qian Cai wrote:
> > [...]
> >> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> >> index f9d9dc250428..9e1aa3b7df75 100644
> >> --- a/mm/kmemleak.c
> >> +++ b/mm/kmemleak.c
> >> @@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> >>  	struct rb_node **link, *rb_parent;
> >>  
> >>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> >> +#ifdef CONFIG_PREEMPT_COUNT
> >> +	if (!object) {
> >> +		/* last-ditch effort in a low-memory situation */
> >> +		if (irqs_disabled() || is_idle_task(current) || in_atomic())
> >> +			gfp = GFP_ATOMIC;
> >> +		else
> >> +			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> >> +		object = kmem_cache_alloc(object_cache, gfp);
> >> +	}
> >> +#endif
> > 
> > I do not get it. How can this possibly help when gfp_kmemleak_mask()
> > adds __GFP_NOFAIL modifier to the given gfp mask? Or is this not the
> > case anymore in some tree?
> 
> Well, __GFP_NOFAIL can still fail easily without __GFP_DIRECT_RECLAIM in a
> low-memory situation.

OK, I guess I understand now. So the issue is that a (general) atomic
allocation will provide its gfp mask down to kmemleak and you are
trying/hoping that if the allocation is no from an atomic context then
you can fortify it by using a sleepable allocation for the kmemleak
metadata or giving it access to memory reserves for atomic allocations.

I think this is still fragile because most atomic allocations are for a
good reason. As I've said earlier the current implementation which
abuses __GFP_NOFAIL is fra from great and we have discussed some
alternatives. Not sure whan came out of it.

I will not object to this workaround but I strongly believe that
kmemleak should rethink the metadata allocation strategy to be really
robust.
-- 
Michal Hocko
SUSE Labs
