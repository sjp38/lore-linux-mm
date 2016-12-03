Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72E1A6B0253
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:40:54 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id bk3so85385114wjc.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:40:54 -0800 (PST)
Received: from mail-wj0-x230.google.com (mail-wj0-x230.google.com. [2a00:1450:400c:c01::230])
        by mx.google.com with ESMTPS id n70si8857923wmd.139.2016.12.07.07.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 07:40:53 -0800 (PST)
Received: by mail-wj0-x230.google.com with SMTP id v7so364543689wjy.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:40:52 -0800 (PST)
Date: Sat, 3 Dec 2016 18:55:22 +0300
From: Anatoly Stepanov <astepanov@cloudlinux.com>
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
Message-ID: <20161203155522.GA648490@stepanov.centos7>
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
 <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
 <20161202091933.GD6830@dhcp22.suse.cz>
 <20161202065417.GB358195@stepanov.centos7>
 <20161205052325.GA30758@dhcp22.suse.cz>
 <20161202220913.GA536156@stepanov.centos7>
 <20161206084734.GC18664@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161206084734.GC18664@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com

On Tue, Dec 06, 2016 at 09:47:35AM +0100, Michal Hocko wrote:
> On Sat 03-12-16 01:09:13, Anatoly Stepanov wrote:
> > On Mon, Dec 05, 2016 at 06:23:26AM +0100, Michal Hocko wrote:
> > > On Fri 02-12-16 09:54:17, Anatoly Stepanov wrote:
> > > > Alex, Vlasimil, Michal, thanks for your responses!
> > > > 
> > > > On Fri, Dec 02, 2016 at 10:19:33AM +0100, Michal Hocko wrote:
> > > > > Thanks for CCing me Vlastimil
> > > > > 
> > > > > On Fri 02-12-16 09:44:23, Vlastimil Babka wrote:
> > > > > > On 12/01/2016 02:16 AM, Anatoly Stepanov wrote:
> > > > > > > As memcg array size can be up to:
> > > > > > > sizeof(struct memcg_cache_array) + kmemcg_id * sizeof(void *);
> > > > > > > 
> > > > > > > where kmemcg_id can be up to MEMCG_CACHES_MAX_SIZE.
> > > > > > > 
> > > > > > > When a memcg instance count is large enough it can lead
> > > > > > > to high order allocations up to order 7.
> > > > > 
> > > > > This is definitely not nice and worth fixing! I am just wondering
> > > > > whether this is something you have encountered in the real life. Having
> > > > > thousands of memcgs sounds quite crazy^Wscary to me. I am not at all
> > > > > sure we are prepared for that and some controllers would have real
> > > > > issues with it AFAIR.
> > > > 
> > > > In our company we use custom-made lightweight container technology, the thing is
> > > > we can have up to several thousands of them on a server.
> > > > So those high-order allocations were observed on a real production workload.
> > > 
> > > OK, this is interesting. Definitely worth mentioning in the changelog!
> > > 
> > > [...]
> > > > > 	/*
> > > > > 	 * Do not invoke OOM killer for larger requests as we can fall
> > > > > 	 * back to the vmalloc
> > > > > 	 */
> > > > > 	if (size > PAGE_SIZE)
> > > > > 		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> > > > 
> > > > I think we should check against PAGE_ALLOC_COSTLY_ORDER anyway, as
> > > > there's no big need to allocate large contiguous chunks here, at the
> > > > same time someone in the kernel might really need them.
> > > 
> > > PAGE_ALLOC_COSTLY_ORDER is and should remain the page allocator internal
> > > implementation detail and shouldn't spread out much outside. GFP_NORETRY
> > > will already make sure we do not push hard here.
> > 
> > May be i didn't put my thoughts well, so let's discuss in more detail:
> > 
> > 1. Yes, we don't try that hard to allocate high-order blocks with
> > __GFP_NORETRY, but we still can do compaction and direct reclaim,
> > which can be heavy for large chunk.  In the worst case we can even
> > fail to find the chunk, after all reclaim/compaction steps were made.
> 
> Yes this is correct. But I am not sure what you are trying to tell
> by that. Highorder requests are a bit of a problem. That's why
> __GFP_NORETRY is implicit here. It also guarantees that we won't hit
> the OOM killer because we do have a reasonable fallback. I do not see a
> point to play with COSTLY_ORDER though. The page allocator knows how to
> handle those and we are trying hard that those requests are not too
> disruptive. Or am I still missing your point?

My point is, while we're trying to get a pretty big contig. chunk (let's say of COSTLY_SIZE),
the reclaim can induce a lot of disk I/O which can be crucial
for overall system performance, at the same time we don't need that contig. chunk.

So, for COSTLY_SIZE chunks, vmalloc should perform better, as it's obviosly more likely
to find order-0 blocks w/o reclaim.

The bottom line is for COSTLY_SIZE chunks it's more likely to end up with the reclaim (=>disk I/O).
Which means for those chunks it's better to allocate them via vmalloc():

(Pseudo-code)
if (size < COSTLY) {
	ret = kmalloc(size);
	if (ret)
		return ret;
}

return vmalloc(size);

Right now i cannot see any significant overhead inside vmalloc() that can be an issue in this case.
Please tell if you know such a thing, it would be really interesting. 

> 
> > 2. The second point is, even if we got the desired chunk quickly, we
> > end up wasting large contiguous chunks, which might be needed for CMA
> > or some h/w driver (DMA for inst.), when they can't use non-contiguous
> > chunks.
> 
> On the other hand vmalloc is not free either.

Of course, but as i explained my thoughts above, i think kmalloc() seems to be worse
for large contig. chunks.

> 
> > BTW, in the kernel there are few examples like alloc_fdmem() for inst., which
> > use that "costly order" idea of the fallback.
> 
> I am not familiar with this code much so it is hard for me to comment.
> Anyway I am not entirely sure the code is still valid. We do not do
> excessive reclaim nor compaction for costly orders. THey are mostly an
> optimistic try without __GFP_REPEAT these days. So the assumption which
> it was based on back in 2011 might be no longer true.

Just to tell you one more case i oberved in real life scenario.
Once we encountered a problem on production server when a tons of forking from different apps
caused a lot of direct reclaim, and we fixed it by even more limiting usage of kmalloc().
PAGE_ALLOC_COSTLY_ORDER size was too big for us, after that production server started feeling better.
So, this limitation of kmalloc really makes much sense sometimes, and we need to take this into account.


> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
