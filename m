Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7B32B6B0279
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:47:04 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so109705713igb.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 09:47:04 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id s83si1363016ioi.2.2015.09.30.09.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 09:47:02 -0700 (PDT)
Date: Wed, 30 Sep 2015 19:46:51 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/5] mm: uncharge kmem pages from generic free_page path
Message-ID: <20150930164651.GA19988@esperanza>
References: <cover.1443262808.git.vdavydov@parallels.com>
 <bd8dc6295b2984a55233904fe6e85ff3b32052d7.1443262808.git.vdavydov@parallels.com>
 <20150929154347.c22bc340458d534d5cdb096c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150929154347.c22bc340458d534d5cdb096c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 29, 2015 at 03:43:47PM -0700, Andrew Morton wrote:
> On Sat, 26 Sep 2015 13:45:53 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Currently, to charge a page to kmemcg one should use alloc_kmem_pages
> > helper. When the page is not needed anymore it must be freed with
> > free_kmem_pages helper, which will uncharge the page before freeing it.
> > Such a design is acceptable for thread info pages and kmalloc large
> > allocations, which are currently the only users of alloc_kmem_pages, but
> > it gets extremely inconvenient if one wants to make use of batched free
> > (e.g. to charge page tables - see release_pages) or page reference
> > counter (pipe buffers - see anon_pipe_buf_release).
> > 
> > To overcome this limitation, this patch moves kmemcg uncharge code to
> > the generic free path and zaps free_kmem_pages helper. To distinguish
> > kmem pages from other page types, it makes alloc_kmem_pages initialize
> > page->_mapcount to a special value and introduces a new PageKmem helper,
> > which returns true if it sees this value.
> 
> As far as I can tell, this new use of page._mapcount is OK, but...
> 
> - The documentation for _mapcount needs to be updated (mm_types.h)
> 
> - Don't believe the documentation!  Because someone else may have
>   done what you tried to do.  Please manually audit mm/ for _mapcount
>   uses.

OK, I rechecked mm/. Here is the list of (ab)users of the
page->_mapcount field:

 - free pages in buddy (PAGE_BUDDY_MAPCOUNT_VALUE)
 - balloon pages (PAGE_BALLOON_MAPCOUNT_VALUE)
 - compound tail pages (use _mapcount for reference counting)

None of them needs PageKmem set by design. The _mapcount is also
overloaded by slab, but the latter doesn't need alloc_kmem_pages for
kmemcg accounting.

However, there is a (ab)user of _mapcount outside mm/. It's arch/x390,
which stores its private info in page table pages' _mapcount. AFAICS
this shouldn't result in any conflicts with the PageKmem helper
introduced by this patch set, because s390 doesn't use generic
tlb_remove_page, but it looks nasty anyway and at least needs a comment.
I'll look what we can do with that.

> 
> - One such use is "For recording whether a page is in the buddy
>   system, we set ->_mapcount PAGE_BUDDY_MAPCOUNT_VALUE".  Please update
>   the comment for this while you're in there.  (Including description
>   of the state's lifetime).
> 
> - And please update _mapcount docs for PageBalloon()
> 
> - Why is the code accessing ->_mapcount directly?  afaict page_mapcount()
>   and friends will work OK?

page_mapcount() lives in mm.h, which isn't included by page-flags.h.
Anyway, I don't think it's a good idea to use page_mapcount() helper
here, because the latter returns not the value of _mapcount, but the
actual count of page mappings (i.e. _mapcount+1), which is IMO confusing
if the page is never mapped and _mapcount is (ab)used for storing a
flag.

> 
> - The patch adds overhead to all kernels, even non-kmemcg and
>   non-memcg kernels.  Bad.  Fixable?

If kmemcg is not used, memcg_kmem_uncharge_pages is a no-op (thanks to
jump labels), so the overhead added is that of load + comparison + store
(i.e. if PageKmem(page) __ClearPageKmem(page)) at worst. For most cases
(!PageKmem) it's just a load + comparison. Taking into account the fact
that page->_mapcount is accessed in free_pages_check anyway, the
overhead should therefore be negligible IMO.

I can, of course, move all PageKmem stuff under CONFIG_MEMCG_KMEM, but
is that vague performance benefit worth obscuring the code?

> 
> - PAGE_BUDDY_MAPCOUNT_VALUE, PAGE_BALLOON_MAPCOUNT_VALUE and
>   PAGE_KMEM_MAPCOUNT_VALUE should all be put next to each other so
>   readers can see all the possible values and so we don't get
>   duplicates, etc.

Right, will do.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
