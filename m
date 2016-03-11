Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id E44B06B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:45:49 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id z8so11170983ige.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:45:49 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id l9si13981823pfb.158.2016.03.11.05.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 05:45:49 -0800 (PST)
Date: Fri, 11 Mar 2016 16:45:34 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311134533.GN1946@esperanza>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
 <20160311123900.GM1946@esperanza>
 <20160311125104.GM27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311125104.GM27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2016 at 01:51:05PM +0100, Michal Hocko wrote:
> On Fri 11-03-16 15:39:00, Vladimir Davydov wrote:
> > On Fri, Mar 11, 2016 at 12:54:50PM +0100, Michal Hocko wrote:
> > > On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> > > > These fields are used for dumping info about allocation that triggered
> > > > OOM. For cgroup this information doesn't make much sense, because OOM
> > > > killer is always invoked from page fault handler.
> > > 
> > > The oom killer is indeed invoked in a different context but why printing
> > > the original mask and order doesn't make any sense? Doesn't it help to
> > > see that the reclaim has failed because of GFP_NOFS?
> > 
> > I don't see how this can be helpful. How would you use it?
> 
> If we start seeing GFP_NOFS triggered OOMs we might be enforced to
> rethink our current strategy to ignore this charge context for OOM.

IMO the fact that a lot of OOMs are triggered by GFP_NOFS allocations
can't be a good enough reason to reconsider OOM strategy. We need to
know what kind of allocation fails anyway, and the current OOM dump
gives us no clue about that.

Besides, what if OOM was triggered by GFP_NOFS by pure chance, i.e. it
would have been triggered by GFP_KERNEL if it had happened at that time?
IMO it's just confusing.

>  
> > Wouldn't it be better to print err msg in try_charge anyway?
> 
> Wouldn't that lead to excessive amount of logged messages?

We could ratelimit these messages. Slab charge failures are already
reported to dmesg (see ___slab_alloc -> slab_out_of_memory) and nobody's
complained so far. Are there any non-slab GFP_NOFS allocations charged
to memcg?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
