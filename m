Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 12A716B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 20:41:12 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so11448557wib.2
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 17:41:12 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id br7si14872160wib.16.2014.07.03.17.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 17:41:11 -0700 (PDT)
Date: Thu, 3 Jul 2014 20:41:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm: memcontrol: rewrite uncharge API: problems
Message-ID: <20140704004104.GG1369@cmpxchg.org>
References: <alpine.LSU.2.11.1406301558090.4572@eggly.anvils>
 <20140701174612.GC1369@cmpxchg.org>
 <20140702212004.GF1369@cmpxchg.org>
 <alpine.LSU.2.11.1407021518120.8299@eggly.anvils>
 <alpine.LSU.2.11.1407031219500.1370@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407031219500.1370@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 03, 2014 at 12:54:36PM -0700, Hugh Dickins wrote:
> On Wed, 2 Jul 2014, Hugh Dickins wrote:
> > On Wed, 2 Jul 2014, Johannes Weiner wrote:
> > > 
> > > Could you give the following patch a spin?  I put it in the mmots
> > > stack on top of mm-memcontrol-rewrite-charge-api-fix-shmem_unuse-fix.
> > 
> > I'm just with the laptop until this evening.  I slapped it on top of
> > my 3.16-rc2-mm1 plus fixes (but obviously minus my memcg_batch one
> > - which incidentally continues to run without crashing on the G5),
> > and it quickly gave me this lockdep splat, which doesn't look very
> > different from the one before.
> > 
> > I see there's now an -rc3-mm1, I'll try it out on that in half an
> > hour... but unless I send word otherwise, assume that's the same.
> 
> Yes, I get that lockdep report each time on -rc3-mm1 + your patch.

There are two instances where I missed to make &rtpz->lock IRQ-safe:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91b621846e10..bbaa3f4cf4db 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3919,7 +3919,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						    gfp_mask, &nr_scanned);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
-		spin_lock(&mctz->lock);
+		spin_lock_irq(&mctz->lock);
 
 		/*
 		 * If we failed to reclaim anything from this memory cgroup
@@ -3959,7 +3959,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		 */
 		/* If excess == 0, no tree ops */
 		__mem_cgroup_insert_exceeded(mz, mctz, excess);
-		spin_unlock(&mctz->lock);
+		spin_unlock_irq(&mctz->lock);
 		css_put(&mz->memcg->css);
 		loop++;
 		/*

That should make it complete - but the IRQ toggling costs are fairly
high so I'm rewriting the batching code to use the page lists that
most uncharges have anyway, and then batch the no-IRQ sections.

> I also twice got a flurry of res_counter.c:28 underflow warnings.
> Hmm, 62 of them each time (I was checking for a number near 512,
> which would suggest a THP/4k confusion, but no).  The majority
> of them coming from mem_cgroup_reparent_charges.

I haven't seen these yet.  But the location makes sense: if there are
any imbalances they'll be noticed during a group's final uncharges.

> But the laptop stayed up fine (for two hours before I had to stop
> it), and the G5 has run fine with that load for 16 hours now, no
> problems with release_pages, and not even a res_counter.c:28 (but
> I don't use lockdep on it).

Great!

> The x86 workstation ran fine for 4.5 hours, then hit some deadlock
> which I doubt had any connection to your changes: looked more like
> a jbd2 transaction was failing to complete (which, with me trying
> ext4 on loop on tmpfs, might be more my problem than anyone else's).
> 
> Oh, but nearly forgot, I did an earlier run on the laptop last night,
> which crashed within minutes on
> 
> VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> mm/memcontrol.c:6680!
> page had count 1 mapcount 0 mapping anon index 0x196
> flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> handle_mm_fault < __do_page_fault

Haven't seen that one yet, either.  The only way I can see this happen
is when the same page gets selected for migration twice in a row.
Maybe a race with putback, where it gets added to the LRU but isolated
by compaction before putback drops the refcount - will verify that.

Thanks for your reports!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
