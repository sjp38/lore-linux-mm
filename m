Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0876B0037
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 17:20:11 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so11936293wes.14
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:20:10 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id jp7si33295950wjc.62.2014.07.02.14.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 14:20:10 -0700 (PDT)
Date: Wed, 2 Jul 2014 17:20:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm: memcontrol: rewrite uncharge API: problems
Message-ID: <20140702212004.GF1369@cmpxchg.org>
References: <alpine.LSU.2.11.1406301558090.4572@eggly.anvils>
 <20140701174612.GC1369@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701174612.GC1369@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 01, 2014 at 01:46:12PM -0400, Johannes Weiner wrote:
> Hi Hugh,
> 
> On Mon, Jun 30, 2014 at 04:55:10PM -0700, Hugh Dickins wrote:
> > Hi Hannes,
> > 
> > Your rewrite of the memcg charge/uncharge API is bold and attractive,
> > but I'm having some problems with the way release_pages() now does
> > uncharging in I/O completion context.
> 
> Yes, I need to make the uncharge path IRQ-safe.  This looks doable.
> 
> > At the bottom see the lockdep message I get when I start shmem swapping.
> > Which I have not begun to attempt to decipher (over to you!), but I do
> > see release_pages() mentioned in there (also i915, hope it's irrelevant).
> 
> This seems to be about uncharge acquiring the IRQ-unsafe soft limit
> tree lock while the outer release_pages() holds the IRQ-safe lru_lock.
> A separate issue, AFAICS, that would also be fixed by IRQ-proofing the
> uncharge path.
> 
> > Which was already worrying me on the PowerPC G5, when moving tasks from
> > one memcg to another and removing the old, while swapping and swappingoff
> > (I haven't tried much else actually, maybe it's much easier to reproduce).
> > 
> > I get "unable to handle kernel paging at 0x180" oops in __raw_spinlock <
> > res_counter_uncharge_until < mem_cgroup_uncharge_end < release_pages <
> > free_pages_and_swap_cache < tlb_flush_mmu_free < tlb_finish_mmu <
> > unmap_region < do_munmap (or from exit_mmap < mmput < do_exit).
> > 
> > I do have CONFIG_MEMCG_SWAP=y, and I think 0x180 corresponds to the
> > memsw res_counter spinlock, if memcg is NULL.  I don't understand why
> > usually the PowerPC: I did see something like it once on this x86 laptop,
> > maybe having lockdep in on this slows things down enough not to hit that.
> > 
> > I've stopped those crashes with patch below: the memcg_batch uncharging
> > was never designed for use from interrupts.  But I bet it needs more work:
> > to disable interrupts, or do something clever with atomics, or... over to
> > you again.
> 
> I was convinced I had tested these changes with lockdep enabled, but
> it must have been at an earlier stage while developing the series.
> Otherwise, I should have gotten the same splat as you report.

Turns out this was because the soft limit was not set in my tests, and
without soft limit excess that spinlock is never acquired.  I could
reproduce it now.

> Thanks for the report, I hope to have something useful ASAP.

Could you give the following patch a spin?  I put it in the mmots
stack on top of mm-memcontrol-rewrite-charge-api-fix-shmem_unuse-fix.

Thanks!

---
