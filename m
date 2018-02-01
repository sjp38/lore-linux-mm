Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37BAF6B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 06:37:25 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id l17so4565892otf.12
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 03:37:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e127si1067158oib.192.2018.02.01.03.37.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Feb 2018 03:37:23 -0800 (PST)
Subject: Re: [4.15-rc9] fs_reclaim lockdep trace
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <7771dd55-2655-d3a9-80ee-24c9ada7dbbe@I-love.SAKURA.ne.jp>
	<8f1c776d-b791-e0b9-1e5c-62b03dcd1d74@I-love.SAKURA.ne.jp>
	<20180129102746.GQ2269@hirez.programming.kicks-ass.net>
	<201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
	<20180129135547.GR2269@hirez.programming.kicks-ass.net>
In-Reply-To: <20180129135547.GR2269@hirez.programming.kicks-ass.net>
Message-Id: <201802012036.FEE78102.HOMFFOtJVFOSQL@I-love.SAKURA.ne.jp>
Date: Thu, 1 Feb 2018 20:36:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: torvalds@linux-foundation.org, davej@codemonkey.org.uk, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, mhocko@kernel.org, linux-btrfs@vger.kernel.org

Peter Zijlstra wrote:
> On Mon, Jan 29, 2018 at 08:47:20PM +0900, Tetsuo Handa wrote:
> > Peter Zijlstra wrote:
> > > On Sun, Jan 28, 2018 at 02:55:28PM +0900, Tetsuo Handa wrote:
> > > > This warning seems to be caused by commit d92a8cfcb37ecd13
> > > > ("locking/lockdep: Rework FS_RECLAIM annotation") which moved the
> > > > location of
> > > > 
> > > >   /* this guy won't enter reclaim */
> > > >   if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
> > > >           return false;
> > > > 
> > > > check added by commit cf40bd16fdad42c0 ("lockdep: annotate reclaim context
> > > > (__GFP_NOFS)").
> > > 
> > > I'm not entirly sure I get what you mean here. How did I move it? It was
> > > part of lockdep_trace_alloc(), if __GFP_NOMEMALLOC was set, it would not
> > > mark the lock as held.
> > 
> > d92a8cfcb37ecd13 replaced lockdep_set_current_reclaim_state() with
> > fs_reclaim_acquire(), and removed current->lockdep_recursion handling.
> > 
> > ----------
> > # git show d92a8cfcb37ecd13 | grep recursion
> > -# define INIT_LOCKDEP                          .lockdep_recursion = 0, .lockdep_reclaim_gfp = 0,
> > +# define INIT_LOCKDEP                          .lockdep_recursion = 0,
> >         unsigned int                    lockdep_recursion;
> > -       if (unlikely(current->lockdep_recursion))
> > -       current->lockdep_recursion = 1;
> > -       current->lockdep_recursion = 0;
> > -        * context checking code. This tests GFP_FS recursion (a lock taken
> > ----------
> 
> That should not matter at all. The only case that would matter for is if
> lockdep itself would ever call into lockdep again. Not something that
> happens here.
> 
> > > The new code has it in fs_reclaim_acquire/release to the same effect, if
> > > __GFP_NOMEMALLOC, we'll not acquire/release the lock.
> > 
> > Excuse me, but I can't catch.
> > We currently acquire/release __fs_reclaim_map if __GFP_NOMEMALLOC.
> 
> Right, got the case inverted, same difference though. Before we'd do
> mark_held_lock(), now we do acquire/release under the same conditions.
> 
> > > > Since __kmalloc_reserve() from __alloc_skb() adds
> > > > __GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask, __need_fs_reclaim() is
> > > > failing to return false despite PF_MEMALLOC context (and resulted in
> > > > lockdep warning).
> > > 
> > > But that's correct right, __GFP_NOMEMALLOC should negate PF_MEMALLOC.
> > > That's what the name says.
> > 
> > __GFP_NOMEMALLOC negates PF_MEMALLOC regarding what watermark that allocation
> > request should use.
> 
> Right.
> 
> > But at the same time, PF_MEMALLOC negates __GFP_DIRECT_RECLAIM.
> 
> Ah indeed.
> 
> > Then, how can fs_reclaim contribute to deadlock?
> 
> Not sure it can. But if we're going to allow this, it needs to come with
> a clear description on why. Not a few clues to a puzzle.
> 

Let's decode Dave's report.

----------
stack backtrace:
CPU: 3 PID: 24800 Comm: sshd Not tainted 4.15.0-rc9-backup-debug+ #1
Call Trace:
 dump_stack+0xbc/0x13f
 __lock_acquire+0xa09/0x2040
 lock_acquire+0x12e/0x350
 fs_reclaim_acquire.part.102+0x29/0x30
 kmem_cache_alloc+0x3d/0x2c0
 alloc_extent_state+0xa7/0x410
 __clear_extent_bit+0x3ea/0x570
 try_release_extent_mapping+0x21a/0x260
 __btrfs_releasepage+0xb0/0x1c0
 btrfs_releasepage+0x161/0x170
 try_to_release_page+0x162/0x1c0
 shrink_page_list+0x1d5a/0x2fb0
 shrink_inactive_list+0x451/0x940
 shrink_node_memcg.constprop.88+0x4c9/0x5e0
 shrink_node+0x12d/0x260
 try_to_free_pages+0x418/0xaf0
 __alloc_pages_slowpath+0x976/0x1790
 __alloc_pages_nodemask+0x52c/0x5c0
 new_slab+0x374/0x3f0
 ___slab_alloc.constprop.81+0x47e/0x5a0
 __slab_alloc.constprop.80+0x32/0x60
 __kmalloc_track_caller+0x267/0x310
 __kmalloc_reserve.isra.40+0x29/0x80
 __alloc_skb+0xee/0x390
 sk_stream_alloc_skb+0xb8/0x340
----------

struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp, bool force_schedule) {
  skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp) = { // gfp == GFP_KERNEL
    static inline struct sk_buff *alloc_skb_fclone(unsigned int size, gfp_t priority) { // priority == GFP_KERNEL
      return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE) = {
        data = kmalloc_reserve(size, gfp_mask, node, &pfmemalloc) = { // gfp_mask == GFP_KERNEL
          obj = kmalloc_node_track_caller(size, flags | __GFP_NOMEMALLOC | __GFP_NOWARN, node) = { // flags == GFP_KERNEL
            __kmalloc_node_track_caller(size, GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN, node) = {
              void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags, int node, unsigned long caller) { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                ret = slab_alloc_node(s, gfpflags, node, caller) = { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                  static __always_inline void *slab_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node, unsigned long addr) { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                    s = slab_pre_alloc_hook(s, gfpflags) = { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                      static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags) { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                        fs_reclaim_acquire(flags) = { // flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                          void fs_reclaim_acquire(gfp_t gfp_mask) { // gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                            if (__need_fs_reclaim(gfp_mask)) // true due to gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC
                              lock_map_acquire(&__fs_reclaim_map); // acquires __fs_reclaim_map
                          }
                        }
                      }
                      fs_reclaim_release(flags); // releases __fs_reclaim_map
                    }
                    object = __slab_alloc(s, gfpflags, node, addr, c) = { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                      p = ___slab_alloc(s, gfpflags, node, addr, c) = { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                        freelist = new_slab_objects(s, gfpflags, node, &c) = {
                          page = new_slab(s, flags, node) = { // flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                            return allocate_slab(s, flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node) = {
                              page = alloc_slab_page(s, alloc_gfp, node, oo) = { // alloc_gfp == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                page = alloc_pages(flags, order) { // flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                  return alloc_pages_current(gfp_mask, order) = { //gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                    page = __alloc_pages_nodemask(gfp, order, policy_node(gfp, pol, numa_node_id()), policy_nodemask(gfp, pol)) = { // gfp == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                      page = __alloc_pages_slowpath(alloc_mask, order, &ac) = { // alloc_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                        page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac, &did_some_progress) = { // gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                          *did_some_progress = __perform_reclaim(gfp_mask, order, ac) = { // gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                            noreclaim_flag = memalloc_noreclaim_save(); // Sets PF_MEMALLOC
                                            fs_reclaim_acquire(flags) = { // flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                              void fs_reclaim_acquire(gfp_t gfp_mask) { // gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                if (__need_fs_reclaim(gfp_mask)) // true due to gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC
                                                  lock_map_acquire(&__fs_reclaim_map); // acquires __fs_reclaim_map
                                              }
                                            }
                                            progress = try_to_free_pages(ac->zonelist, order, gfp_mask, ac->nodemask) = {
                                              nr_reclaimed = do_try_to_free_pages(zonelist, &sc) = {
                                                shrink_zones(zonelist, sc) = {
                                                  shrink_node(zone->zone_pgdat, sc) = {
                                                    shrink_node_memcg(pgdat, memcg, sc, &lru_pages) = {
                                                      nr_reclaimed += shrink_list(lru, nr_to_scan, lruvec, memcg, sc) = {
                                                        return shrink_inactive_list(nr_to_scan, lruvec, sc, lru) = {
                                                          nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, 0, &stat, false) = {
                                                            if (!try_to_release_page(page, sc->gfp_mask))
                                                              goto activate_locked = {
                                                                return mapping->a_ops->releasepage(page, gfp_mask) = {
                                                                  static int btrfs_releasepage(struct page *page, gfp_t gfp_flags) { // gfp_flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                    return __btrfs_releasepage(page, gfp_flags) = {
                                                                      ret = try_release_extent_mapping(map, tree, page, gfp_flags) = {
                                                                        return try_release_extent_state(map, tree, page, mask) = { // mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                          ret = clear_extent_bit(tree, start, end, ~(EXTENT_LOCKED | EXTENT_NODATASUM), 0, 0, NULL, mask) = {
                                                                            return __clear_extent_bit(tree, start, end, bits, wake, delete, cached, mask, NULL) = {
                                                                              prealloc = alloc_extent_state(mask) = {
                                                                                state = kmem_cache_alloc(extent_state_cache, mask) = {
                                                                                  void *ret = slab_alloc(s, gfpflags, _RET_IP_) = { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                                    return slab_alloc_node(s, gfpflags, NUMA_NO_NODE, addr) = {
                                                                                      s = slab_pre_alloc_hook(s, gfpflags) = {
                                                                                        static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags) { // gfpflags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                                          fs_reclaim_acquire(flags) = { // flags == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                                            void fs_reclaim_acquire(gfp_t gfp_mask) { // gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC | __GFP_NOWARN
                                                                                              if (__need_fs_reclaim(gfp_mask)) // true due to gfp_mask == GFP_KERNEL | __GFP_NOMEMALLOC despite PF_MEMALLOC
                                                                                                lock_map_acquire(&__fs_reclaim_map); // acquires __fs_reclaim_map nestedly and lockdep complains
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                        fs_reclaim_release(flags); // releases __fs_reclaim_map
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                     }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

That is, all reclaim code is simply propagating __GFP_NOMEMALLOC added by kmalloc_reserve(), and
despite memory allocation from try_to_free_pages() path won't do direct reclaim due to PF_MEMALLOC,
fs_reclaim_acquire() from slab_pre_alloc_hook() from try_to_free_pages() path is failing to find that
this allocation will not do direct reclaim due to PF_MEMALLOC (due to

	/* this guy won't enter reclaim */
	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
		return false;

check in __need_fs_reclaim()).

After all, nested GFP_FS allocations cannot occur (whatever GFP flags are passed)
because such allocation will not do direct reclaim due to PF_MEMALLOC.

> Now, even if its not strictly a deadlock, there is something to be said
> for flagging GFP_FS allocs that lead to nested GFP_FS allocs, do we ever
> want to allow that?

Since PF_MEMALLOC negates __GFP_DIRECT_RECLAIM, propagating unmodified GFP flags
(like above) is safe as long as dependency is within current thread.

So, how to fix this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
