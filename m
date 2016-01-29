Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AA7866B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:30:34 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so77663389wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:30:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w76si9589637wmw.53.2016.01.29.09.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:30:33 -0800 (PST)
Date: Fri, 29 Jan 2016 12:30:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm: workingset: per-cgroup cache thrash detection
Message-ID: <20160129173017.GB8845@cmpxchg.org>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-6-git-send-email-hannes@cmpxchg.org>
 <20160127145827.GE9623@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160127145827.GE9623@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jan 27, 2016 at 05:58:27PM +0300, Vladimir Davydov wrote:
> On Tue, Jan 26, 2016 at 04:00:06PM -0500, Johannes Weiner wrote:
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index b14a2bb33514..1cf3065c143b 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -317,6 +317,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
> >  
> >  /* linux/mm/vmscan.c */
> >  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> > +extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
> 
> Better declare it in mm/internal.h? And is there any point in renaming
> it?

mm/internal.h kinda sucks. However, it was only in swap.h because it
started as an inline function. I now moved it to mmzone.h where struct
lruvec is defined and the other lruvec functions are declared/defined.

As for the rename, get_lru_size() is not a great name for a wider
scope. So I followed the spirit of lruvec_init() and lruvec_zone().

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 953f0f984392..864e237f32d9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -202,11 +207,20 @@ static void unpack_shadow(void *shadow, struct zone **zonep,
> >   */
> >  void *workingset_eviction(struct address_space *mapping, struct page *page)
> >  {
> > +	struct mem_cgroup *memcg = page_memcg(page);
> >  	struct zone *zone = page_zone(page);
> > +	int memcgid = mem_cgroup_id(memcg);
> 
> This will crash in case memcg is disabled via boot param.

Thanks for catching that. I added a mem_cgroup_disabled() check to
mem_cgroup_id() since it's now a public interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
