Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA1846B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 03:47:37 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id he10so28074747wjc.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:47:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si2713475wmn.101.2016.12.06.00.47.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Dec 2016 00:47:36 -0800 (PST)
Date: Tue, 6 Dec 2016 09:47:35 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
Message-ID: <20161206084734.GC18664@dhcp22.suse.cz>
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
 <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
 <20161202091933.GD6830@dhcp22.suse.cz>
 <20161202065417.GB358195@stepanov.centos7>
 <20161205052325.GA30758@dhcp22.suse.cz>
 <20161202220913.GA536156@stepanov.centos7>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202220913.GA536156@stepanov.centos7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anatoly Stepanov <astepanov@cloudlinux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com

On Sat 03-12-16 01:09:13, Anatoly Stepanov wrote:
> On Mon, Dec 05, 2016 at 06:23:26AM +0100, Michal Hocko wrote:
> > On Fri 02-12-16 09:54:17, Anatoly Stepanov wrote:
> > > Alex, Vlasimil, Michal, thanks for your responses!
> > > 
> > > On Fri, Dec 02, 2016 at 10:19:33AM +0100, Michal Hocko wrote:
> > > > Thanks for CCing me Vlastimil
> > > > 
> > > > On Fri 02-12-16 09:44:23, Vlastimil Babka wrote:
> > > > > On 12/01/2016 02:16 AM, Anatoly Stepanov wrote:
> > > > > > As memcg array size can be up to:
> > > > > > sizeof(struct memcg_cache_array) + kmemcg_id * sizeof(void *);
> > > > > > 
> > > > > > where kmemcg_id can be up to MEMCG_CACHES_MAX_SIZE.
> > > > > > 
> > > > > > When a memcg instance count is large enough it can lead
> > > > > > to high order allocations up to order 7.
> > > > 
> > > > This is definitely not nice and worth fixing! I am just wondering
> > > > whether this is something you have encountered in the real life. Having
> > > > thousands of memcgs sounds quite crazy^Wscary to me. I am not at all
> > > > sure we are prepared for that and some controllers would have real
> > > > issues with it AFAIR.
> > > 
> > > In our company we use custom-made lightweight container technology, the thing is
> > > we can have up to several thousands of them on a server.
> > > So those high-order allocations were observed on a real production workload.
> > 
> > OK, this is interesting. Definitely worth mentioning in the changelog!
> > 
> > [...]
> > > > 	/*
> > > > 	 * Do not invoke OOM killer for larger requests as we can fall
> > > > 	 * back to the vmalloc
> > > > 	 */
> > > > 	if (size > PAGE_SIZE)
> > > > 		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> > > 
> > > I think we should check against PAGE_ALLOC_COSTLY_ORDER anyway, as
> > > there's no big need to allocate large contiguous chunks here, at the
> > > same time someone in the kernel might really need them.
> > 
> > PAGE_ALLOC_COSTLY_ORDER is and should remain the page allocator internal
> > implementation detail and shouldn't spread out much outside. GFP_NORETRY
> > will already make sure we do not push hard here.
> 
> May be i didn't put my thoughts well, so let's discuss in more detail:
> 
> 1. Yes, we don't try that hard to allocate high-order blocks with
> __GFP_NORETRY, but we still can do compaction and direct reclaim,
> which can be heavy for large chunk.  In the worst case we can even
> fail to find the chunk, after all reclaim/compaction steps were made.

Yes this is correct. But I am not sure what you are trying to tell
by that. Highorder requests are a bit of a problem. That's why
__GFP_NORETRY is implicit here. It also guarantees that we won't hit
the OOM killer because we do have a reasonable fallback. I do not see a
point to play with COSTLY_ORDER though. The page allocator knows how to
handle those and we are trying hard that those requests are not too
disruptive. Or am I still missing your point?

> 2. The second point is, even if we got the desired chunk quickly, we
> end up wasting large contiguous chunks, which might be needed for CMA
> or some h/w driver (DMA for inst.), when they can't use non-contiguous
> chunks.

On the other hand vmalloc is not free either.

> BTW, in the kernel there are few examples like alloc_fdmem() for inst., which
> use that "costly order" idea of the fallback.

I am not familiar with this code much so it is hard for me to comment.
Anyway I am not entirely sure the code is still valid. We do not do
excessive reclaim nor compaction for costly orders. THey are mostly an
optimistic try without __GFP_REPEAT these days. So the assumption which
it was based on back in 2011 might be no longer true.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
