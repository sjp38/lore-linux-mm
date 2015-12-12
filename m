Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 085F76B0038
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 11:19:08 -0500 (EST)
Received: by pfd5 with SMTP id 5so20294218pfd.2
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 08:19:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yi10si4638115pab.15.2015.12.12.08.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 08:19:07 -0800 (PST)
Date: Sat, 12 Dec 2015 19:18:56 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 6/7] mm: free swap cache aggressively if memcg swap is
 full
Message-ID: <20151212161856.GA28521@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <2c7ac3a5c2a2fb9b1c5136d8409652ed7ecc260f.1449742561.git.vdavydov@virtuozzo.com>
 <20151211193358.GE3773@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151211193358.GE3773@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 11, 2015 at 02:33:58PM -0500, Johannes Weiner wrote:
> On Thu, Dec 10, 2015 at 02:39:19PM +0300, Vladimir Davydov wrote:
> > Swap cache pages are freed aggressively if swap is nearly full (>50%
> > currently), because otherwise we are likely to stop scanning anonymous
> > when we near the swap limit even if there is plenty of freeable swap
> > cache pages. We should follow the same trend in case of memory cgroup,
> > which has its own swap limit.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> One note:
> 
> > @@ -5839,6 +5839,29 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
> >  	return nr_swap_pages;
> >  }
> >  
> > +bool mem_cgroup_swap_full(struct page *page)
> > +{
> > +	struct mem_cgroup *memcg;
> > +
> > +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > +
> > +	if (vm_swap_full())
> > +		return true;
> > +	if (!do_swap_account || !PageSwapCache(page))
> > +		return false;
> 
> The callers establish PageSwapCache() under the page lock, which makes
> sense since they only inquire about the swap state when deciding what
> to do with a swapcache page at hand. So this check seems unnecessary.

Yeah, you're right, we don't need it here. Will remove it in v2.

Besides, I think I should have inserted cgroup_subsys_on_dflt check in
this function so that it wouldn't check memcg->swap limit in case the
legacy hierarchy is used. Will do.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
