Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC984280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 22:02:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n75so68344182pfh.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:02:27 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id z62si9134899pgd.93.2017.05.19.19.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 19:02:26 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id m17so47160128pfg.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:02:26 -0700 (PDT)
Date: Fri, 19 May 2017 19:02:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
In-Reply-To: <591F9A09.6010707@huawei.com>
Message-ID: <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On Sat, 20 May 2017, Xishi Qiu wrote:
> On 2017/5/20 6:00, Hugh Dickins wrote:
> > 
> > You're ignoring the rcu_read_lock() on entry to page_lock_anon_vma_read(),
> > and the SLAB_DESTROY_BY_RCU (recently renamed SLAB_TYPESAFE_BY_RCU) nature
> > of the anon_vma_cachep kmem cache.  It is not safe to muck with anon_vma->
> > root in anon_vma_free(), others could still be looking at it.
> > 
> > Hugh
> > 
> 
> Hi Hugh,
> 
> Thanks for your reply.
> 
> SLAB_DESTROY_BY_RCU will let it call call_rcu() in free_slab(), but if the
> anon_vma *reuse* by someone again, access root_anon_vma is not safe, right?

That is safe, on reuse it is still a struct anon_vma; then the test for
!page_mapped(page) will show that it's no longer a reliable anon_vma for
this page, so page_lock_anon_vma_read() returns NULL.

But of course, if page->_mapcount has been corrupted or misaccounted,
it may think page_mapped(page) when actually page is not mapped,
and the anon_vma is not good for it.

> 
> e.g. if I clean the root pointer before free it, then access root_anon_vma
> in page_lock_anon_vma_read() is NULL pointer access, right?

Yes, cleaning root pointer before free may result in NULL pointer access.

Hugh

> 
> anon_vma_free()
> 	...
> 	anon_vma->root = NULL;
> 	kmem_cache_free(anon_vma_cachep, anon_vma);
> 	...
> 
> Thanks,
> Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
