Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7E16F6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:30:34 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so19908232wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:30:34 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id c125si2985522wmf.81.2016.03.11.06.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 06:30:33 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id p65so19907718wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:30:33 -0800 (PST)
Date: Fri, 11 Mar 2016 15:30:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311143031.GS27701@dhcp22.suse.cz>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
 <20160311123900.GM1946@esperanza>
 <20160311125104.GM27701@dhcp22.suse.cz>
 <20160311134533.GN1946@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160311134533.GN1946@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-03-16 16:45:34, Vladimir Davydov wrote:
> On Fri, Mar 11, 2016 at 01:51:05PM +0100, Michal Hocko wrote:
> > On Fri 11-03-16 15:39:00, Vladimir Davydov wrote:
> > > On Fri, Mar 11, 2016 at 12:54:50PM +0100, Michal Hocko wrote:
> > > > On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> > > > > These fields are used for dumping info about allocation that triggered
> > > > > OOM. For cgroup this information doesn't make much sense, because OOM
> > > > > killer is always invoked from page fault handler.
> > > > 
> > > > The oom killer is indeed invoked in a different context but why printing
> > > > the original mask and order doesn't make any sense? Doesn't it help to
> > > > see that the reclaim has failed because of GFP_NOFS?
> > > 
> > > I don't see how this can be helpful. How would you use it?
> > 
> > If we start seeing GFP_NOFS triggered OOMs we might be enforced to
> > rethink our current strategy to ignore this charge context for OOM.
> 
> IMO the fact that a lot of OOMs are triggered by GFP_NOFS allocations
> can't be a good enough reason to reconsider OOM strategy.

What I meant was that the global OOM doesn't trigger OOM got !__GFP_FS
while we do in the memcg charge path.

> We need to
> know what kind of allocation fails anyway, and the current OOM dump
> gives us no clue about that.

We do print gfp_mask now so we know what was the charging context.

> Besides, what if OOM was triggered by GFP_NOFS by pure chance, i.e. it
> would have been triggered by GFP_KERNEL if it had happened at that time?

Not really. GFP_KERNEL would allow to invoke some shrinkers which are
GFP_NOFS incopatible.

> IMO it's just confusing.
> 
> >  
> > > Wouldn't it be better to print err msg in try_charge anyway?
> > 
> > Wouldn't that lead to excessive amount of logged messages?
> 
> We could ratelimit these messages. Slab charge failures are already
> reported to dmesg (see ___slab_alloc -> slab_out_of_memory) and nobody's
> complained so far. Are there any non-slab GFP_NOFS allocations charged
> to memcg?

I believe there might be some coming from FS via add_to_page_cache_lru.
Especially when their mapping gfp_mask clears __GFP_FS. I haven't
checked the code deeper but some of those might be called from the page
fault path and trigger memcg OOM. I would have to look closer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
