Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9D296B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 18:11:36 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x186-v6so16066547qkb.0
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 15:11:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s8-v6si1353317qta.56.2018.06.18.15.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 15:11:31 -0700 (PDT)
Date: Mon, 18 Jun 2018 18:11:26 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180615130925.GI24039@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com>
References: <1528790608-19557-1-git-send-email-jing.xia@unisoc.com> <20180612212007.GA22717@redhat.com> <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com> <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com>
 <20180614073153.GB9371@dhcp22.suse.cz> <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com> <20180615073201.GB24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com> <20180615130925.GI24039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Fri, 15 Jun 2018, Michal Hocko wrote:

> On Fri 15-06-18 08:47:52, Mikulas Patocka wrote:
> > 
> > 
> > On Fri, 15 Jun 2018, Michal Hocko wrote:
> > 
> > > On Fri 15-06-18 07:35:07, Mikulas Patocka wrote:
> > > > 
> > > > Because mempool uses it. Mempool uses allocations with "GFP_NOIO | 
> > > > __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN". An so dm-bufio uses 
> > > > these flags too. dm-bufio is just a big mempool.
> > > 
> > > This doesn't answer my question though. Somebody else is doing it is not
> > > an explanation. Prior to your 41c73a49df31 there was no GFP_NOIO
> > > allocation AFAICS. So why do you really need it now? Why cannot you
> > 
> > dm-bufio always used "GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | 
> > __GFP_NOWARN" since the kernel 3.2 when it was introduced.
> > 
> > In the kernel 4.10, dm-bufio was changed so that it does GFP_NOWAIT 
> > allocation, then drops the lock and does GFP_NOIO with the dropped lock 
> > (because someone was likely experiencing the same issue that is reported 
> > in this thread) - there are two commits that change it - 9ea61cac0 and 
> > 41c73a49df31.
> 
> OK, I see. Is there any fundamental reason why this path has to do one
> round of GFP_IO or it can keep NOWAIT, drop the lock, sleep and retry
> again?

If the process is woken up, there was some buffer added to the freelist, 
or refcount of some buffer was dropped to 0. In this case, we don't want 
to drop the lock and use GFP_NOIO, because the freed buffer may disappear 
when we drop the lock.

> [...]
> > > is the same class of problem, honestly, I dunno. And I've already said
> > > that stalling __GFP_NORETRY might be a good way around that but that
> > > needs much more consideration and existing users examination. I am not
> > > aware anybody has done that. Doing changes like that based on a single
> > > user is certainly risky.
> > 
> > Why don't you set any rules how these flags should be used?
> 
> It is really hard to change rules during the game. You basically have to
> examine all existing users and that is well beyond my time scope. I've
> tried that where it was possible. E.g. __GFP_REPEAT and turned it into a
> well defined semantic. __GFP_NORETRY is a bigger beast.
> 
> Anyway, I believe that it would be much safer to look at the problem
> from a highlevel perspective. You seem to be focused on __GFP_NORETRY
> little bit too much IMHO. We are not throttling callers which explicitly
> do not want to or cannot - see current_may_throttle. Is it possible that
> both your md and mempool allocators can either (ab)use PF_LESS_THROTTLE
> or use other means? E.g. do you have backing_dev_info at that time?
> -- 
> Michal Hocko
> SUSE Labs

I grepped the kernel for __GFP_NORETRY and triaged them. I found 16 cases 
without a fallback - those are bugs that make various functions randomly 
return -ENOMEM.

Most of the callers provide callback.

There is another strange flag - __GFP_RETRY_MAYFAIL - it provides two 
different functions - if the allocation is larger than 
PAGE_ALLOC_COSTLY_ORDER, it retries the allocation as if it were smaller. 
If the allocations is smaller than PAGE_ALLOC_COSTLY_ORDER, 
__GFP_RETRY_MAYFAIL will avoid the oom killer (larger order allocations 
don't trigger the oom killer at all).

So, perhaps __GFP_RETRY_MAYFAIL could be used instead of __GFP_NORETRY in 
the cases where the caller wants to avoid trigerring the oom killer (the 
problem is that __GFP_NORETRY causes random failure even in no-oom 
situations but __GFP_RETRY_MAYFAIL doesn't).


So my suggestion is - fix these obvious bugs when someone allocates memory 
with __GFP_NORETRY without any fallback - and then, __GFP_NORETRY could be 
just changed to return NULL instead of sleeping.




arch/arm/mm/dma-mapping.c - fallback to a smaller size without __GFP_NORETRY

arch/mips/mm/dma-default.c - says that it uses __GFP_NORETRY to avoid the 
oom killer, provides no fallback - it seems to be a BUG

arch/sparc/mm/tsb.c - fallback to a smaller size without __GFP_NORETRY

arch/x86/include/asm/floppy.h - __GFP_NORETRY doesn't seem to serve any 
purpose, it may cause random failures during initialization, can be 
removed - BUG

arch/powerpc/mm/mmu_context_iommu.c - uses it just during moving pages, 
there's no problem with failure

arch/powerpc/platforms/pseries/cmm.c - a vm balloon driver, no problem 
with failure

block/bio.c - falls back to mempool

block/blk-mq.c - errorneous use of __GFP_NORETRY during initialization, it 
falls back to a smaller size, but doesn't drop the __GFP_NORETRY flag 
(BUG)

drivers/gpu/drm/i915/i915_gem.c - it starts with __GFP_NORETRY and on 
failure, it ORs it with __GFP_RETRY_MAYFAIL (which of these conflicting 
flags wins?)

drivers/gpu/drm/i915/i915_gem_gtt.c - __GFP_NORETRY is used during 
initialization (BUG), it shouldn't be used

drivers/gpu/drm/i915/i915_gem_execbuffer.c - fallback to a smaller size without __GFP_NORETRY

drivers/gpu/drm/i915/i915_gem_internal.c - fallback to a smaller size without __GFP_NORETRY
size

drivers/gpu/drm/i915/i915_gem_userptr.c - seems to provide fallback

drivers/gpu/drm/i915/i915_gpu_error.c - fallback to a smaller size without __GFP_NORETRY

drivers/gpu/drm/etnaviv/etnaviv_dump.c - coredump on error path, no 
problem if it fails

drivers/gpu/drm/ttm/ttm_page_alloc.c - uses __GFP_NORETRY for transparent 
hugepages, no problem with failure

drivers/gpu/drm/ttm/ttm_page_alloc_dma.c - uses __GFP_NORETRY for 
transparent hugepages, no problem with failure

drivers/gpu/drm/msm/msm_gem_submit.c - uses __GFP_NORETRY to process ioctl 
and lacks a fallback - it is a BUG - __GFP_NORETRY should be dropped

drivers/hv/hv_balloon.c - a vm balloon driver, no problem with failure

drivers/crypto/chelsio/chtls/chtls_io.c - fallback to a smaller size without __GFP_NORETRY

drivers/xen/balloon.c - a vm balloon driver, no problem with failure

drivers/mtd/mtdcore.c - fallback to a smaller size without __GFP_NORETRY

drivers/md/dm-verity-target.c - skips prefetch on failure, no problem

drivers/md/dm-writecache.c - falls back to a smaller i/os on failure

drivers/md/dm-bufio.c - reserves some buffers on creation and falls back 
to them

drivers/md/dm-integrity.c - falls back to sector-by-sector verification

drivers/md/dm-kcopyd.c - falls back to reserved pages

drivers/md/dm-crypt.c - falls back to mempool

drivers/iommu/dma-iommu.c - fallback to a smaller size without __GFP_NORETRY

drivers/mmc/core/mmc_test.c - fallback to a smaller size, but doesn't drop 
__GFP_NORETRY - BUG

drivers/staging/android/ion/ion_system_heap.c - fallback to a smaller size without __GFP_NORETRY

fs/cachefiles/ - uses __GFP_NORETRY extensively - since this is just a 
cache, so failure supposedly shouldn't be problem - but it's hard to 
verify the whole driver that it handles failures properly

fs/xfs/xfs_buf.c - uses __GFP_NORETRY only on readahead

fs/fscache/cookie.c - no fallback, but if it fails, the caller will just 
invalidate the cache entry - no problem

fs/fscache/page.c - like above - failure will just inhibit caching

fs/nfs/write.c - fails only if allowed by the arugment never_fail

include/linux/kexec.h - no fallback - it seems to be a BUG

include/linux/pagemap.h - uses __GFP_NORETRY only on readahead

kernel/bpf/syscall.c - it says it need __GFP_NORETRY to avoid oom killer - 
provides no fallback, so it seems to be BUG

kernel/events/ring_buffer.c - falls back to a smaller size, but doesn't drop 
__GFP_NORETRY - BUG

kernel/groups.c - falls back to vmalloc (should it use kvmalloc?)

kernel/trace/ring_buffer.c - no fallback - BUG

kernel/trace/trace.c - no fallback - BUG

kernel/power/swap.c - falls back, but there is useless WARN_ON_ONCE(1) on 
the fallback path

lib/debugobjects.c - turns off debugging on alloaction failure

lib/rhashtable.c - uses __GFP_NORETRY only with GFP_ATOMIC - __GFP_NORETRY 
is useless

mm/hugetlb.c - no problem if hugepage allocation fails

mm/mempool.c - falls back to mempool

mm/kmemleak.c - disables kmemleak on allocation failure

mm/page_alloc.c/__page_frag_cache_refill - fallback to a smaller size without __GFP_NORETRY

mm/zswap.c/zswap_pool_create - used during pool creation - probably a BUG
mm/zswap.c/zswap_frontswap_store - used when compressing a page - probably 
ok to fail

mm/memcontrol.c - I don't know if it is a bug

mm/shmem.c - used during hugepage allocation - ok to fail

mm/slub.c - fallback to a smaller size without __GFP_NORETRY

mm/util.c - fallback to vmalloc

net/packet/af_packet.c - fallback without __GFP_NORETRY

net/xdp/xsk_queue.c - no fallback - BUG

net/core/skbuff.c - fallback to a smaller size without __GFP_NORETRY

net/core/sock.c - fallback to a smaller size without __GFP_NORETRY

net/netlink/af_netlink.c - it's ok to fail when decreasing the size of skb

net/smc/smc_core.c - falls back to a smaller size, but doesn't drop 
__GFP_NORETRY - BUG

net/netfilter/x_tables.c - __GFP_NORETRY is used to avoid the oom killer
- provides no fallback - it seems to be a BUG

security/integrity/ima/ima_crypto.c - fallback to a smaller size without __GFP_NORETRY

sound/core/memalloc.c - __GFP_NORETRY is used to avoid the oom killer
- provides no fallback - it seems to be a BUG

Mikulas
