Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9E16B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 09:51:18 -0400 (EDT)
Received: by iow1 with SMTP id 1so125117092iow.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:51:18 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c3si16512808ioe.17.2015.10.16.06.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 06:51:17 -0700 (PDT)
Date: Fri, 16 Oct 2015 16:51:06 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151016135106.GJ11309@esperanza>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
 <20151016131726.GA602@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20151016131726.GA602@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 16, 2015 at 04:17:26PM +0300, Kirill A. Shutemov wrote:
> On Mon, Oct 05, 2015 at 01:21:43AM +0300, Vladimir Davydov wrote:
> > Before the previous patch, __mem_cgroup_from_kmem had to handle two
> > types of kmem - slab pages and pages allocated with alloc_kmem_pages -
> > differently, because slab pages did not store information about owner
> > memcg in the page struct. Now we can unify it. Since after it, this
> > function becomes tiny we can fold it into mem_cgroup_from_kmem.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > ---
> >  include/linux/memcontrol.h |  7 ++++---
> >  mm/memcontrol.c            | 18 ------------------
> >  2 files changed, 4 insertions(+), 21 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 8a9b7a798f14..0e2e039609d1 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -769,8 +769,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
> >  struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
> >  void __memcg_kmem_put_cache(struct kmem_cache *cachep);
> >  
> > -struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr);
> > -
> >  static inline bool __memcg_kmem_bypass(gfp_t gfp)
> >  {
> >  	if (!memcg_kmem_enabled())
> > @@ -832,9 +830,12 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
> >  
> >  static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
> >  {
> > +	struct page *page;
> > +
> >  	if (!memcg_kmem_enabled())
> >  		return NULL;
> > -	return __mem_cgroup_from_kmem(ptr);
> > +	page = virt_to_head_page(ptr);
> > +	return page->mem_cgroup;
> >  }
> 
> virt_to_head_page() is defined in <linux/mm.h> but you don't include it,
> and the commit breaks build for me (on v4.3-rc5-mmotm-2015-10-15-15-20).
> 
>   CC      arch/x86/kernel/asm-offsets.s
> In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
>                  from /home/kas/linux/mm/include/linux/suspend.h:4,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/memcontrol.h: In function a?~mem_cgroup_from_kmema?T:
> /home/kas/linux/mm/include/linux/memcontrol.h:841:9: error: implicit declaration of function a?~virt_to_head_pagea?T [-Werror=implicit-function-declaration]
>   page = virt_to_head_page(ptr);
>          ^
> /home/kas/linux/mm/include/linux/memcontrol.h:841:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
>   page = virt_to_head_page(ptr);
>        ^
> In file included from /home/kas/linux/mm/include/linux/suspend.h:8:0,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/mm.h: At top level:
> /home/kas/linux/mm/include/linux/mm.h:452:28: error: conflicting types for a?~virt_to_head_pagea?T
>  static inline struct page *virt_to_head_page(const void *x)
>                             ^
> In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
>                  from /home/kas/linux/mm/include/linux/suspend.h:4,
>                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:12:
> /home/kas/linux/mm/include/linux/memcontrol.h:841:9: note: previous implicit declaration of a?~virt_to_head_pagea?T was here
>   page = virt_to_head_page(ptr);
>          ^
> cc1: some warnings being treated as errors

Oops, in my config I have CONFIG_CGROUP_WRITEBACK enabled, which results
in including mm.h to memcontrol.h indirectly:

 linux/memcontrol.h
  linux/writeback.h
   linux/bio.h
    linux/highmem.h
     linux/mm.h

That's why I didn't notice this. Sorry about that.

> 
> The patch below fixes it for me (and for allmodconfig on x86-64), but I'm not
> sure if it have any side effects on other configurations.

It should work OK with any config, otherwise CONFIG_CGROUP_WRITEBACK
would be broken too.

Andrew, could you please merge the fix by Kirill into
memcg-simplify-and-inline-__mem_cgroup_from_kmem.patch

Thanks,
Vladimir

> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 47677acb4516..e8e52e502c20 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -26,6 +26,7 @@
>  #include <linux/page_counter.h>
>  #include <linux/vmpressure.h>
>  #include <linux/eventfd.h>
> +#include <linux/mm.h>
>  #include <linux/mmzone.h>
>  #include <linux/writeback.h>
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
