Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF166B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 00:23:30 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so58989037wjc.0
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 21:23:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id za10si13640333wjc.98.2016.12.04.21.23.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Dec 2016 21:23:29 -0800 (PST)
Date: Mon, 5 Dec 2016 06:23:26 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
Message-ID: <20161205052325.GA30758@dhcp22.suse.cz>
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
 <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
 <20161202091933.GD6830@dhcp22.suse.cz>
 <20161202065417.GB358195@stepanov.centos7>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202065417.GB358195@stepanov.centos7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anatoly Stepanov <astepanov@cloudlinux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com

On Fri 02-12-16 09:54:17, Anatoly Stepanov wrote:
> Alex, Vlasimil, Michal, thanks for your responses!
> 
> On Fri, Dec 02, 2016 at 10:19:33AM +0100, Michal Hocko wrote:
> > Thanks for CCing me Vlastimil
> > 
> > On Fri 02-12-16 09:44:23, Vlastimil Babka wrote:
> > > On 12/01/2016 02:16 AM, Anatoly Stepanov wrote:
> > > > As memcg array size can be up to:
> > > > sizeof(struct memcg_cache_array) + kmemcg_id * sizeof(void *);
> > > > 
> > > > where kmemcg_id can be up to MEMCG_CACHES_MAX_SIZE.
> > > > 
> > > > When a memcg instance count is large enough it can lead
> > > > to high order allocations up to order 7.
> > 
> > This is definitely not nice and worth fixing! I am just wondering
> > whether this is something you have encountered in the real life. Having
> > thousands of memcgs sounds quite crazy^Wscary to me. I am not at all
> > sure we are prepared for that and some controllers would have real
> > issues with it AFAIR.
> 
> In our company we use custom-made lightweight container technology, the thing is
> we can have up to several thousands of them on a server.
> So those high-order allocations were observed on a real production workload.

OK, this is interesting. Definitely worth mentioning in the changelog!

[...]
> > 	/*
> > 	 * Do not invoke OOM killer for larger requests as we can fall
> > 	 * back to the vmalloc
> > 	 */
> > 	if (size > PAGE_SIZE)
> > 		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> 
> I think we should check against PAGE_ALLOC_COSTLY_ORDER anyway, as
> there's no big need to allocate large contiguous chunks here, at the
> same time someone in the kernel might really need them.

PAGE_ALLOC_COSTLY_ORDER is and should remain the page allocator internal
implementation detail and shouldn't spread out much outside. GFP_NORETRY
will already make sure we do not push hard here.

> 
> > 
> > 	ret = kzalloc(size, gfp_mask);
> > 	if (ret)
> > 		return ret;
> > 	return vzalloc(size);
> > 
> 
> > I also do not like memcg_alloc helper name. It suggests we are
> > allocating a memcg while it is used for cache arrays and slab LRUS.
> > Anyway this pattern is quite widespread in the kernel so I would simply
> > suggest adding kvmalloc function instead.
> 
> Agreed, it would be nice to have a generic call.
> I would suggest an impl. like this:
> 
> void *kvmalloc(size_t size)

gfp_t gfp_mask should be a parameter as this should be a generic helper.

> {
> 	gfp_t gfp_mask = GFP_KERNEL;


> 	void *ret;
> 
>  	if (size > PAGE_SIZE)
>  		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> 
> 
> 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> 		ret = kzalloc(size, gfp_mask);
> 		if (ret)
> 			return ret;
> 	}

No, please just do as suggested above. Tweak the gfp_mask for higher
order requests and do kmalloc first with vmalloc as a  fallback.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
