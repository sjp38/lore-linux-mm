Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7E0E6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 09:27:30 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j1-v6so10054459pll.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 06:27:30 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g7-v6si32527510plb.426.2018.11.05.06.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 06:27:29 -0800 (PST)
Date: Mon, 5 Nov 2018 22:27:27 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2] mm: use kvzalloc for swap_info_struct allocation
Message-ID: <20181105142727.GB6203@intel.com>
References: <20181105061016.GA4502@intel.com>
 <fc23172d-3c75-21e2-d551-8b1808cbe593@virtuozzo.com>
 <20181105141156.GB10132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105141156.GB10132@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vasily Averin <vvs@virtuozzo.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org

On Mon, Nov 05, 2018 at 03:11:56PM +0100, Michal Hocko wrote:
> On Mon 05-11-18 14:17:01, Vasily Averin wrote:
> > commit a2468cc9bfdf ("swap: choose swap device according to numa node")
> > changed 'avail_lists' field of 'struct swap_info_struct' to an array.
> > In popular linux distros it increased size of swap_info_struct up to
> > 40 Kbytes and now swap_info_struct allocation requires order-4 page.
> > Switch to kvzmalloc allows to avoid unexpected allocation failures.
> 
> While this fixes the most visible issue is this a good long term
> solution? Aren't we wasting memory without a good reason? IIRC our limit

That's right, we need a better way of handling this in the long term.

> for swap files/devices is much smaller than potential NUMA nodes numbers
> so we can safely expect that would be only few numa affine nodes. I am
> not really familiar with the rework which has added numa node awareness
> but I wouls assueme that we should either go with one global table with
> a linked list of possible swap_info structure per numa node or use a
> sparse array.

There is a per-numa-node plist of available swap devices, so every swap
device needs an entry on those per-numa-node plist.

I think we can convert avail_lists from array to pointer and use vzalloc
to allocate the needed memory. MAX_NUMANODES can be used for a simple
implementation, or use the precise online node number but then we will
need to handle node online/offline events.

sparse array sounds promising, I'll take a look, thanks for the pointer.

> That being said I am not really objecting to this patch as it is simple
> and backportable to older (stable kernels).
>  
> I would even dare to add
> Fixes: a2468cc9bfdf ("swap: choose swap device according to numa node")
> 
> because not being able to add a swap space on a fragmented system looks
> like a regression to me.

Agree, especially it used to work.

Regards,
Aaron

> > Acked-by: Aaron Lu <aaron.lu@intel.com>
> > Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/swapfile.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 644f746e167a..8688ae65ef58 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -2813,7 +2813,7 @@ static struct swap_info_struct *alloc_swap_info(void)
> >  	unsigned int type;
> >  	int i;
> >  
> > -	p = kzalloc(sizeof(*p), GFP_KERNEL);
> > +	p = kvzalloc(sizeof(*p), GFP_KERNEL);
> >  	if (!p)
> >  		return ERR_PTR(-ENOMEM);
> >  
> > @@ -2824,7 +2824,7 @@ static struct swap_info_struct *alloc_swap_info(void)
> >  	}
> >  	if (type >= MAX_SWAPFILES) {
> >  		spin_unlock(&swap_lock);
> > -		kfree(p);
> > +		kvfree(p);
> >  		return ERR_PTR(-EPERM);
> >  	}
> >  	if (type >= nr_swapfiles) {
> > @@ -2838,7 +2838,7 @@ static struct swap_info_struct *alloc_swap_info(void)
> >  		smp_wmb();
> >  		nr_swapfiles++;
> >  	} else {
> > -		kfree(p);
> > +		kvfree(p);
> >  		p = swap_info[type];
> >  		/*
> >  		 * Do not memset this entry: a racing procfs swap_next()
> > -- 
> > 2.17.1
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
