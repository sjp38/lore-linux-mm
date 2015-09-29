Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 478DA6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 18:43:50 -0400 (EDT)
Received: by qkap81 with SMTP id p81so10189634qka.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 15:43:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h70si23506282qkh.122.2015.09.29.15.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 15:43:49 -0700 (PDT)
Date: Tue, 29 Sep 2015 15:43:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] mm: uncharge kmem pages from generic free_page path
Message-Id: <20150929154347.c22bc340458d534d5cdb096c@linux-foundation.org>
In-Reply-To: <bd8dc6295b2984a55233904fe6e85ff3b32052d7.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
	<bd8dc6295b2984a55233904fe6e85ff3b32052d7.1443262808.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 26 Sep 2015 13:45:53 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> Currently, to charge a page to kmemcg one should use alloc_kmem_pages
> helper. When the page is not needed anymore it must be freed with
> free_kmem_pages helper, which will uncharge the page before freeing it.
> Such a design is acceptable for thread info pages and kmalloc large
> allocations, which are currently the only users of alloc_kmem_pages, but
> it gets extremely inconvenient if one wants to make use of batched free
> (e.g. to charge page tables - see release_pages) or page reference
> counter (pipe buffers - see anon_pipe_buf_release).
> 
> To overcome this limitation, this patch moves kmemcg uncharge code to
> the generic free path and zaps free_kmem_pages helper. To distinguish
> kmem pages from other page types, it makes alloc_kmem_pages initialize
> page->_mapcount to a special value and introduces a new PageKmem helper,
> which returns true if it sees this value.

As far as I can tell, this new use of page._mapcount is OK, but...

- The documentation for _mapcount needs to be updated (mm_types.h)

- Don't believe the documentation!  Because someone else may have
  done what you tried to do.  Please manually audit mm/ for _mapcount
  uses.

- One such use is "For recording whether a page is in the buddy
  system, we set ->_mapcount PAGE_BUDDY_MAPCOUNT_VALUE".  Please update
  the comment for this while you're in there.  (Including description
  of the state's lifetime).

- And please update _mapcount docs for PageBalloon()

- Why is the code accessing ->_mapcount directly?  afaict page_mapcount()
  and friends will work OK?

- The patch adds overhead to all kernels, even non-kmemcg and
  non-memcg kernels.  Bad.  Fixable?

- PAGE_BUDDY_MAPCOUNT_VALUE, PAGE_BALLOON_MAPCOUNT_VALUE and
  PAGE_KMEM_MAPCOUNT_VALUE should all be put next to each other so
  readers can see all the possible values and so we don't get
  duplicates, etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
