Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB746B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:23:12 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so101313853wic.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:23:11 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id ft15si11385341wic.122.2015.10.14.06.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 06:23:04 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so130072800wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:23:03 -0700 (PDT)
Date: Wed, 14 Oct 2015 15:22:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151014132248.GH28333@dhcp22.suse.cz>
References: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
 <20151013133225.GA31034@dhcp22.suse.cz>
 <201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Wed 14-10-15 01:19:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I can see two options here. Either we teach zone_reclaimable to be less
> > fragile or remove zone_reclaimable from shrink_zones altogether. Both of
> > them are risky because we have a long history of changes in this areas
> > which made other subtle behavior changes but I guess that the first
> > option should be less fragile. What about the following patch? I am not
> > happy about it because the condition is rather rough and a deeper
> > inspection is really needed to check all the call sites but it should be
> > good for testing.
> 
> While zone_reclaimable() for Node 0 DMA32 became false by your patch,
> zone_reclaimable() for Node 0 DMA kept returning true, and as a result
> overall result (i.e. zones_reclaimable) remained true.

Ahh, right you are. ZONE_DMA might have 0 or close to 0 pages on
LRUs while it is still protected from allocations which are not
targeted for this zone. My patch clearly haven't considered that. The
fix for that would be quite straightforward. We have to consider
lowmem_reserve of the zone wrt. the allocation/reclaim gfp target
zone. But this is getting more and more ugly (see the patch below just
for testing/demonstration purposes).

The OOM report is really interesting:

> [   69.039152] Node 0 DMA32 free:74224kB min:44652kB low:55812kB high:66976kB active_anon:1334792kB inactive_anon:8240kB active_file:48364kB inactive_file:230752kB unevictable:0kB isolated(anon):92kB isolated(file):0kB present:2080640kB managed:1774264kB mlocked:0kB dirty:9328kB writeback:199060kB mapped:38140kB shmem:8472kB slab_reclaimable:17840kB slab_unreclaimable:16292kB kernel_stack:3840kB pagetables:7864kB unstable:0kB bounce:0kB free_pcp:784kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no

so your whole file LRUs are either dirty or under writeback and
reclaimable pages are below min wmark. This alone is quite suspicious.
Why hasn't balance_dirty_pages throttled writers and allowed them to
make the whole LRU dirty? What is your dirty{_background}_{ratio,bytes}
configuration on that system.

Also why throttle_vm_writeout haven't slown the reclaim down?

Anyway this is exactly the case where zone_reclaimable helps us to
prevent OOM because we are looping over the remaining LRU pages without
making progress... This just shows how subtle all this is :/

I have to think about this much more..
---
