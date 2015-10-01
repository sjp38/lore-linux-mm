Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6C09C82F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 14:52:25 -0400 (EDT)
Received: by labzv5 with SMTP id zv5so80644603lab.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 11:52:24 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id qg5si3613817lbb.18.2015.10.01.11.52.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 11:52:23 -0700 (PDT)
Date: Thu, 1 Oct 2015 21:52:09 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/5] mm: uncharge kmem pages from generic free_page path
Message-ID: <20151001185209.GJ2302@esperanza>
References: <bd8dc6295b2984a55233904fe6e85ff3b32052d7.1443262808.git.vdavydov@parallels.com>
 <xr93twqbk7nt.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <xr93twqbk7nt.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 30, 2015 at 12:51:18PM -0700, Greg Thelen wrote:
> 
> Vladimir Davydov wrote:
...
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index 416509e26d6d..a190719c2f46 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -594,6 +594,28 @@ static inline void __ClearPageBalloon(struct page *page)
> >  }
> >  
> >  /*
> > + * PageKmem() returns true if the page was allocated with alloc_kmem_pages().
> > + */
> > +#define PAGE_KMEM_MAPCOUNT_VALUE (-512)
> > +
> > +static inline int PageKmem(struct page *page)
> > +{
> > +	return atomic_read(&page->_mapcount) == PAGE_KMEM_MAPCOUNT_VALUE;
> > +}
> > +
> > +static inline void __SetPageKmem(struct page *page)
> > +{
> > +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> > +	atomic_set(&page->_mapcount, PAGE_KMEM_MAPCOUNT_VALUE);
> > +}
> 
> What do you think about several special mapcount values for various
> types of kmem?
> 
> It's helps user and administrators break down memory usage.
> 
> A nice equation is:
>   memory.usage_in_bytes = memory.stat[file + anon + unevictable + kmem]
> 
> Next, it's helpful to be able to breakdown kmem into:
>   kmem = stack + pgtable + slab + ...
> 
> On one hand (and the kernel I use internally) we can use separate per
> memcg counters for each kmem type.  Then reconstitute memory.kmem as
> needed by adding them together.  But using keeping a single kernel kmem
> counter is workable if there is a way to breakdown the memory charge to
> a container (e.g. by walking /proc/kpageflags-ish or per memcg
> memory.kpageflags-ish file).

I don't think that storing information about kmem type on the page
struct just to report it via /proc/kpageflags is a good idea, because
the number of unused bits left on the page struct is limited so we'd
better (ab)use them carefully, only when it's really difficult to get
along w/o them.

OTOH I do agree that some extra info showing what "kmem" is actually
used for could be helpful. To accumulate this info we can always use
per-cpu counters, which are pretty cheap and won't degrade performance,
and then report it via memory.stat. Furthermore, it will be more
convenient for administrators to read this info in human-readable format
than parsing /proc/kpageflags, which in addition takes long on systems
with a lot of RAM.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
