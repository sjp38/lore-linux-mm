Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC8876B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 05:40:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so4599471pff.6
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 02:40:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i129sor6418015pgd.342.2017.09.14.02.40.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 02:40:49 -0700 (PDT)
Date: Thu, 14 Sep 2017 18:40:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 04/20] mm: VMA sequence count
Message-ID: <20170914094043.GJ599@jagdpanzerIV.localdomain>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1504894024-2750-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170913115354.GA7756@jagdpanzerIV.localdomain>
 <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
 <20170914003116.GA599@jagdpanzerIV.localdomain>
 <441ff1c6-72a7-5d96-02c8-063578affb62@linux.vnet.ibm.com>
 <20170914081358.GG599@jagdpanzerIV.localdomain>
 <26fa0b71-4053-5af7-baa0-e5fff9babf41@linux.vnet.ibm.com>
 <20170914091101.GH599@jagdpanzerIV.localdomain>
 <9605ce43-0f61-48d7-88e2-88220b773494@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9605ce43-0f61-48d7-88e2-88220b773494@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On (09/14/17 11:15), Laurent Dufour wrote:
> On 14/09/2017 11:11, Sergey Senozhatsky wrote:
> > On (09/14/17 10:58), Laurent Dufour wrote:
> > [..]
> >> That's right, but here this is the  sequence counter mm->mm_seq, not the
> >> vm_seq one.
> > 
> > d'oh... you are right.
> 
> So I'm doubting about the probability of a deadlock here, but I don't like
> to see lockdep complaining. Is there an easy way to make it happy ?


 /*
  * well... answering your question - it seems raw versions of seqcount
  * functions don't call lockdep's lock_acquire/lock_release...
  *
  * but I have never told you that. never.
  */


lockdep, perhaps, can be wrong sometimes, and may be it's one of those
cases. may be not... I'm not a MM guy myself.

below is a lockdep splat I got yesterday. that's v3 of SPF patch set.


[ 2763.365898] ======================================================
[ 2763.365899] WARNING: possible circular locking dependency detected
[ 2763.365902] 4.13.0-next-20170913-dbg-00039-ge3c06ea4b028-dirty #1837 Not tainted
[ 2763.365903] ------------------------------------------------------
[ 2763.365905] khugepaged/42 is trying to acquire lock:
[ 2763.365906]  (&mapping->i_mmap_rwsem){++++}, at: [<ffffffff811181cc>] rmap_walk_file+0x5a/0x142
[ 2763.365913] 
               but task is already holding lock:
[ 2763.365915]  (fs_reclaim){+.+.}, at: [<ffffffff810e99dc>] fs_reclaim_acquire+0x12/0x35
[ 2763.365920] 
               which lock already depends on the new lock.

[ 2763.365922] 
               the existing dependency chain (in reverse order) is:
[ 2763.365924] 
               -> #3 (fs_reclaim){+.+.}:
[ 2763.365930]        lock_acquire+0x176/0x19e
[ 2763.365932]        fs_reclaim_acquire+0x32/0x35
[ 2763.365934]        __alloc_pages_nodemask+0x6d/0x1f9
[ 2763.365937]        pte_alloc_one+0x17/0x62
[ 2763.365940]        __pte_alloc+0x1f/0x83
[ 2763.365943]        move_page_tables+0x2c3/0x5a2
[ 2763.365944]        move_vma.isra.25+0xff/0x29f
[ 2763.365946]        SyS_mremap+0x41b/0x49e
[ 2763.365949]        entry_SYSCALL_64_fastpath+0x18/0xad
[ 2763.365951] 
               -> #2 (&vma->vm_sequence/1){+.+.}:
[ 2763.365955]        lock_acquire+0x176/0x19e
[ 2763.365958]        write_seqcount_begin_nested+0x1b/0x1d
[ 2763.365959]        __vma_adjust+0x1c4/0x5f1
[ 2763.365961]        __split_vma+0x12c/0x181
[ 2763.365963]        do_munmap+0x128/0x2af
[ 2763.365965]        vm_munmap+0x5a/0x73
[ 2763.365968]        elf_map+0xb1/0xce
[ 2763.365970]        load_elf_binary+0x91e/0x137a
[ 2763.365973]        search_binary_handler+0x70/0x1f3
[ 2763.365974]        do_execveat_common+0x45e/0x68e
[ 2763.365978]        call_usermodehelper_exec_async+0xf7/0x11f
[ 2763.365980]        ret_from_fork+0x27/0x40
[ 2763.365981] 
               -> #1 (&vma->vm_sequence){+.+.}:
[ 2763.365985]        lock_acquire+0x176/0x19e
[ 2763.365987]        write_seqcount_begin_nested+0x1b/0x1d
[ 2763.365989]        __vma_adjust+0x1a9/0x5f1
[ 2763.365991]        __split_vma+0x12c/0x181
[ 2763.365993]        do_munmap+0x128/0x2af
[ 2763.365994]        vm_munmap+0x5a/0x73
[ 2763.365996]        elf_map+0xb1/0xce
[ 2763.365998]        load_elf_binary+0x91e/0x137a
[ 2763.365999]        search_binary_handler+0x70/0x1f3
[ 2763.366001]        do_execveat_common+0x45e/0x68e
[ 2763.366003]        call_usermodehelper_exec_async+0xf7/0x11f
[ 2763.366005]        ret_from_fork+0x27/0x40
[ 2763.366006] 
               -> #0 (&mapping->i_mmap_rwsem){++++}:
[ 2763.366010]        __lock_acquire+0xa72/0xca0
[ 2763.366012]        lock_acquire+0x176/0x19e
[ 2763.366015]        down_read+0x3b/0x55
[ 2763.366017]        rmap_walk_file+0x5a/0x142
[ 2763.366018]        page_referenced+0xfc/0x134
[ 2763.366022]        shrink_active_list+0x1ac/0x37d
[ 2763.366024]        shrink_node_memcg.constprop.72+0x3ca/0x567
[ 2763.366026]        shrink_node+0x3f/0x14c
[ 2763.366028]        try_to_free_pages+0x288/0x47a
[ 2763.366030]        __alloc_pages_slowpath+0x3a7/0xa49
[ 2763.366032]        __alloc_pages_nodemask+0xf1/0x1f9
[ 2763.366035]        khugepaged+0xc8/0x167c
[ 2763.366037]        kthread+0x133/0x13b
[ 2763.366039]        ret_from_fork+0x27/0x40
[ 2763.366040] 
               other info that might help us debug this:

[ 2763.366042] Chain exists of:
                 &mapping->i_mmap_rwsem --> &vma->vm_sequence/1 --> fs_reclaim

[ 2763.366048]  Possible unsafe locking scenario:

[ 2763.366049]        CPU0                    CPU1
[ 2763.366050]        ----                    ----
[ 2763.366051]   lock(fs_reclaim);
[ 2763.366054]                                lock(&vma->vm_sequence/1);
[ 2763.366056]                                lock(fs_reclaim);
[ 2763.366058]   lock(&mapping->i_mmap_rwsem);
[ 2763.366061] 
                *** DEADLOCK ***

[ 2763.366063] 1 lock held by khugepaged/42:
[ 2763.366064]  #0:  (fs_reclaim){+.+.}, at: [<ffffffff810e99dc>] fs_reclaim_acquire+0x12/0x35
[ 2763.366068] 
               stack backtrace:
[ 2763.366071] CPU: 2 PID: 42 Comm: khugepaged Not tainted 4.13.0-next-20170913-dbg-00039-ge3c06ea4b028-dirty #1837
[ 2763.366073] Call Trace:
[ 2763.366077]  dump_stack+0x67/0x8e
[ 2763.366080]  print_circular_bug+0x2a1/0x2af
[ 2763.366083]  ? graph_unlock+0x69/0x69
[ 2763.366085]  check_prev_add+0x76/0x20d
[ 2763.366087]  ? graph_unlock+0x69/0x69
[ 2763.366090]  __lock_acquire+0xa72/0xca0
[ 2763.366093]  ? __save_stack_trace+0xa3/0xbf
[ 2763.366096]  lock_acquire+0x176/0x19e
[ 2763.366098]  ? rmap_walk_file+0x5a/0x142
[ 2763.366100]  down_read+0x3b/0x55
[ 2763.366102]  ? rmap_walk_file+0x5a/0x142
[ 2763.366103]  rmap_walk_file+0x5a/0x142
[ 2763.366106]  page_referenced+0xfc/0x134
[ 2763.366108]  ? page_vma_mapped_walk_done.isra.17+0xb/0xb
[ 2763.366109]  ? page_get_anon_vma+0x6d/0x6d
[ 2763.366112]  shrink_active_list+0x1ac/0x37d
[ 2763.366115]  shrink_node_memcg.constprop.72+0x3ca/0x567
[ 2763.366118]  ? ___might_sleep+0xd5/0x234
[ 2763.366121]  shrink_node+0x3f/0x14c
[ 2763.366123]  try_to_free_pages+0x288/0x47a
[ 2763.366126]  __alloc_pages_slowpath+0x3a7/0xa49
[ 2763.366128]  ? ___might_sleep+0xd5/0x234
[ 2763.366131]  __alloc_pages_nodemask+0xf1/0x1f9
[ 2763.366133]  khugepaged+0xc8/0x167c
[ 2763.366138]  ? remove_wait_queue+0x47/0x47
[ 2763.366140]  ? collapse_shmem.isra.45+0x828/0x828
[ 2763.366142]  kthread+0x133/0x13b
[ 2763.366145]  ? __list_del_entry+0x1d/0x1d
[ 2763.366147]  ret_from_fork+0x27/0x40

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
