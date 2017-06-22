Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73D086B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:49:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u62so5299666lfg.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:49:34 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id y15si963343ljd.249.2017.06.22.10.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 10:49:32 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f28so3706646lfi.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:49:31 -0700 (PDT)
Date: Thu, 22 Jun 2017 20:49:29 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] fs/dcache.c: fix spin lockup issue on nlru->lock
Message-ID: <20170622174929.GB3273@esperanza>
References: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
 <1498027155-4456-1-git-send-email-stummala@codeaurora.org>
 <20170621163134.GA3273@esperanza>
 <8d82c32d-6cbb-c39d-2f0e-0af23925b3c1@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d82c32d-6cbb-c39d-2f0e-0af23925b3c1@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Jun 22, 2017 at 10:01:39PM +0530, Sahitya Tummala wrote:
> 
> 
> On 6/21/2017 10:01 PM, Vladimir Davydov wrote:
> >
> >>index cddf397..c8ca150 100644
> >>--- a/fs/dcache.c
> >>+++ b/fs/dcache.c
> >>@@ -1133,10 +1133,11 @@ void shrink_dcache_sb(struct super_block *sb)
> >>  		LIST_HEAD(dispose);
> >>  		freed = list_lru_walk(&sb->s_dentry_lru,
> >>-			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
> >>+			dentry_lru_isolate_shrink, &dispose, 1024);
> >>  		this_cpu_sub(nr_dentry_unused, freed);
> >>  		shrink_dentry_list(&dispose);
> >>+		cond_resched();
> >>  	} while (freed > 0);
> >In an extreme case, a single invocation of list_lru_walk() can skip all
> >1024 dentries, in which case 'freed' will be 0 forcing us to break the
> >loop prematurely. I think we should loop until there's at least one
> >dentry left on the LRU, i.e.
> >
> >	while (list_lru_count(&sb->s_dentry_lru) > 0)
> >
> >However, even that wouldn't be quite correct, because list_lru_count()
> >iterates over all memory cgroups to sum list_lru_one->nr_items, which
> >can race with memcg offlining code migrating dentries off a dead cgroup
> >(see memcg_drain_all_list_lrus()). So it looks like to make this check
> >race-free, we need to account the number of entries on the LRU not only
> >per memcg, but also per node, i.e. add list_lru_node->nr_items.
> >Fortunately, list_lru entries can't be migrated between NUMA nodes.
> It looks like list_lru_count() is iterating per node before iterating over
> all memory
> cgroups as below -
> 
> unsigned long list_lru_count_node(struct list_lru *lru, int nid)
> {
>         long count = 0;
>         int memcg_idx;
> 
>         count += __list_lru_count_one(lru, nid, -1);
>         if (list_lru_memcg_aware(lru)) {
>                 for_each_memcg_cache_index(memcg_idx)
>                         count += __list_lru_count_one(lru, nid, memcg_idx);
>         }
>         return count;
> }
> 
> The first call to __list_lru_count_one() is iterating all the items per node
> i.e, nlru->lru->nr_items.

lru->node[nid].lru.nr_items returned by __list_lru_count_one(lru, nid, -1)
only counts items accounted to the root cgroup, not the total number of
entries on the node.

> Is my understanding correct? If not, could you please clarify on how to get
> the lru items per node?

What I mean is iterating over list_lru_node->memcg_lrus to count the
number of entries on the node is racy. For example, suppose you have
three cgroups with the following values of list_lru_one->nr_items:

  0   0   10

While list_lru_count_node() is at #1, cgroup #2 is offlined and its
list_lru_one is drained, i.e. its entries are migrated to the parent
cgroup, which happens to be #0, i.e. we see the following picture:

 10   0   0

     ^^^
  memcg_ids points here in list_lru_count_node() 

Then the count returned by list_lru_count_node() will be 0, although
there are still 10 entries on the list.

To avoid this race, we could keep list_lru_node->lock locked while
walking over list_lru_node->memcg_lrus, but that's too heavy. I'd prefer
adding list_lru_node->nr_count which would be equal to the total number
of list_lru entries on the node, i.e. sum of list_lru_node->lru.nr_lrus
and list_lru_node->memcg_lrus->lru[]->nr_items.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
