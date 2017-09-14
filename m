Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29F036B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 20:31:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so2533071pff.7
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 17:31:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m10sor7290856pln.105.2017.09.13.17.31.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 17:31:20 -0700 (PDT)
Date: Thu, 14 Sep 2017 09:31:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 04/20] mm: VMA sequence count
Message-ID: <20170914003116.GA599@jagdpanzerIV.localdomain>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1504894024-2750-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170913115354.GA7756@jagdpanzerIV.localdomain>
 <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi,

On (09/13/17 18:56), Laurent Dufour wrote:
> Hi Sergey,
> 
> On 13/09/2017 13:53, Sergey Senozhatsky wrote:
> > Hi,
> > 
> > On (09/08/17 20:06), Laurent Dufour wrote:
[..]
> > ok, so what I got on my box is:
> > 
> > vm_munmap()  -> down_write_killable(&mm->mmap_sem)
> >  do_munmap()
> >   __split_vma()
> >    __vma_adjust()  -> write_seqcount_begin(&vma->vm_sequence)
> >                    -> write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING)
> > 
> > so this gives 3 dependencies  ->mmap_sem   ->   ->vm_seq
> >                               ->vm_seq     ->   ->vm_seq/1
> >                               ->mmap_sem   ->   ->vm_seq/1
> > 
> > 
> > SyS_mremap() -> down_write_killable(&current->mm->mmap_sem)
> >  move_vma()   -> write_seqcount_begin(&vma->vm_sequence)
> >               -> write_seqcount_begin_nested(&new_vma->vm_sequence, SINGLE_DEPTH_NESTING);
> >   move_page_tables()
> >    __pte_alloc()
> >     pte_alloc_one()
> >      __alloc_pages_nodemask()
> >       fs_reclaim_acquire()
> > 
> > 
> > I think here we have prepare_alloc_pages() call, that does
> > 
> >         -> fs_reclaim_acquire(gfp_mask)
> >         -> fs_reclaim_release(gfp_mask)
> > 
> > so that adds one more dependency  ->mmap_sem   ->   ->vm_seq    ->   fs_reclaim
> >                                   ->mmap_sem   ->   ->vm_seq/1  ->   fs_reclaim
> > 
> > 
> > now, under memory pressure we hit the slow path and perform direct
> > reclaim. direct reclaim is done under fs_reclaim lock, so we end up
> > with the following call chain
> > 
> > __alloc_pages_nodemask()
> >  __alloc_pages_slowpath()
> >   __perform_reclaim()       ->   fs_reclaim_acquire(gfp_mask);
> >    try_to_free_pages()
> >     shrink_node()
> >      shrink_active_list()
> >       rmap_walk_file()      ->   i_mmap_lock_read(mapping);
> > 
> > 
> > and this break the existing dependency. since we now take the leaf lock
> > (fs_reclaim) first and the the root lock (->mmap_sem).
> 
> Thanks for looking at this.
> I'm sorry, I should have miss something.

no prob :)


> My understanding is that there are 2 chains of locks:
>  1. from __vma_adjust() mmap_sem -> i_mmap_rwsem -> vm_seq
>  2. from move_vmap() mmap_sem -> vm_seq -> fs_reclaim
>  2. from __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem

yes, as far as lockdep warning suggests.

> So the solution would be to have in __vma_adjust()
>  mmap_sem -> vm_seq -> i_mmap_rwsem
> 
> But this will raised the following dependency from  unmap_mapping_range()
> unmap_mapping_range() 		-> i_mmap_rwsem
>  unmap_mapping_range_tree()
>   unmap_mapping_range_vma()
>    zap_page_range_single()
>     unmap_single_vma()
>      unmap_page_range()	 	-> vm_seq
> 
> And there is no way to get rid of it easily as in unmap_mapping_range()
> there is no VMA identified yet.
> 
> That's being said I can't see any clear way to get lock dependency cleaned
> here.
> Furthermore, this is not clear to me how a deadlock could happen as vm_seq
> is a sequence lock, and there is no way to get blocked here.

as far as I understand,
   seq locks can deadlock, technically. not on the write() side, but on
the read() side:

read_seqcount_begin()
 raw_read_seqcount_begin()
   __read_seqcount_begin()

and __read_seqcount_begin() spins for ever

   __read_seqcount_begin()
   {
    repeat:
     ret = READ_ONCE(s->sequence);
     if (unlikely(ret & 1)) {
         cpu_relax();
         goto repeat;
     }
     return ret;
   }


so if there are two CPUs, one doing write_seqcount() and the other one
doing read_seqcount() then what can happen is something like this

	CPU0					CPU1

						fs_reclaim_acquire()
	write_seqcount_begin()
	fs_reclaim_acquire()			read_seqcount_begin()
	write_seqcount_end()

CPU0 can't write_seqcount_end() because of fs_reclaim_acquire() from
CPU1, CPU1 can't read_seqcount_begin() because CPU0 did write_seqcount_begin()
and now waits for fs_reclaim_acquire(). makes sense?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
