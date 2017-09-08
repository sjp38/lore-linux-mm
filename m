Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12F8A6B0332
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 05:24:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d6so1962905wrd.7
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 02:24:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t76si1053401wme.39.2017.09.08.02.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 02:24:29 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v889NrUi131698
	for <linux-mm@kvack.org>; Fri, 8 Sep 2017 05:24:27 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cuq0r4vsh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Sep 2017 05:24:27 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 8 Sep 2017 10:24:25 +0100
Subject: Re: [PATCH v2 00/20] Speculative page faults
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170821022629.GA541@jagdpanzerIV.localdomain>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 8 Sep 2017 11:24:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170821022629.GA541@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <6302a906-221d-c977-4aea-67202eb3d96d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 21/08/2017 04:26, Sergey Senozhatsky wrote:
> Hello,
> 
> On (08/18/17 00:04), Laurent Dufour wrote:
>> This is a port on kernel 4.13 of the work done by Peter Zijlstra to
>> handle page fault without holding the mm semaphore [1].
>>
>> The idea is to try to handle user space page faults without holding the
>> mmap_sem. This should allow better concurrency for massively threaded
>> process since the page fault handler will not wait for other threads memory
>> layout change to be done, assuming that this change is done in another part
>> of the process's memory space. This type page fault is named speculative
>> page fault. If the speculative page fault fails because of a concurrency is
>> detected or because underlying PMD or PTE tables are not yet allocating, it
>> is failing its processing and a classic page fault is then tried.
>>
>> The speculative page fault (SPF) has to look for the VMA matching the fault
>> address without holding the mmap_sem, so the VMA list is now managed using
>> SRCU allowing lockless walking. The only impact would be the deferred file
>> derefencing in the case of a file mapping, since the file pointer is
>> released once the SRCU cleaning is done.  This patch relies on the change
>> done recently by Paul McKenney in SRCU which now runs a callback per CPU
>> instead of per SRCU structure [1].
>>
>> The VMA's attributes checked during the speculative page fault processing
>> have to be protected against parallel changes. This is done by using a per
>> VMA sequence lock. This sequence lock allows the speculative page fault
>> handler to fast check for parallel changes in progress and to abort the
>> speculative page fault in that case.
>>
>> Once the VMA is found, the speculative page fault handler would check for
>> the VMA's attributes to verify that the page fault has to be handled
>> correctly or not. Thus the VMA is protected through a sequence lock which
>> allows fast detection of concurrent VMA changes. If such a change is
>> detected, the speculative page fault is aborted and a *classic* page fault
>> is tried.  VMA sequence locks are added when VMA attributes which are
>> checked during the page fault are modified.
>>
>> When the PTE is fetched, the VMA is checked to see if it has been changed,
>> so once the page table is locked, the VMA is valid, so any other changes
>> leading to touching this PTE will need to lock the page table, so no
>> parallel change is possible at this time.
> 
> [ 2311.315400] ======================================================
> [ 2311.315401] WARNING: possible circular locking dependency detected
> [ 2311.315403] 4.13.0-rc5-next-20170817-dbg-00039-gaf11d7500492-dirty #1743 Not tainted
> [ 2311.315404] ------------------------------------------------------
> [ 2311.315406] khugepaged/43 is trying to acquire lock:
> [ 2311.315407]  (&mapping->i_mmap_rwsem){++++}, at: [<ffffffff8111b339>] rmap_walk_file+0x5a/0x147
> [ 2311.315415] 
>                but task is already holding lock:
> [ 2311.315416]  (fs_reclaim){+.+.}, at: [<ffffffff810ebd80>] fs_reclaim_acquire+0x12/0x35
> [ 2311.315420] 
>                which lock already depends on the new lock.
> 
> [ 2311.315422] 
>                the existing dependency chain (in reverse order) is:
> [ 2311.315423] 
>                -> #3 (fs_reclaim){+.+.}:
> [ 2311.315427]        fs_reclaim_acquire+0x32/0x35
> [ 2311.315429]        __alloc_pages_nodemask+0x8d/0x217
> [ 2311.315432]        pte_alloc_one+0x13/0x5e
> [ 2311.315434]        __pte_alloc+0x1f/0x83
> [ 2311.315436]        move_page_tables+0x2c9/0x5ac
> [ 2311.315438]        move_vma.isra.25+0xff/0x2a2
> [ 2311.315439]        SyS_mremap+0x41b/0x49e
> [ 2311.315442]        entry_SYSCALL_64_fastpath+0x18/0xad
> [ 2311.315443] 
>                -> #2 (&vma->vm_sequence/1){+.+.}:
> [ 2311.315449]        write_seqcount_begin_nested+0x1b/0x1d
> [ 2311.315451]        __vma_adjust+0x1b7/0x5d6
> [ 2311.315453]        __split_vma+0x142/0x1a3
> [ 2311.315454]        do_munmap+0x128/0x2af
> [ 2311.315455]        vm_munmap+0x5a/0x73
> [ 2311.315458]        elf_map+0xb1/0xce
> [ 2311.315459]        load_elf_binary+0x8e0/0x1348
> [ 2311.315462]        search_binary_handler+0x70/0x1f3
> [ 2311.315464]        load_script+0x1a6/0x1b5
> [ 2311.315466]        search_binary_handler+0x70/0x1f3
> [ 2311.315468]        do_execveat_common+0x461/0x691
> [ 2311.315471]        kernel_init+0x5a/0xf0
> [ 2311.315472]        ret_from_fork+0x27/0x40
> [ 2311.315473] 
>                -> #1 (&vma->vm_sequence){+.+.}:
> [ 2311.315478]        write_seqcount_begin_nested+0x1b/0x1d
> [ 2311.315480]        __vma_adjust+0x19c/0x5d6
> [ 2311.315481]        __split_vma+0x142/0x1a3
> [ 2311.315482]        do_munmap+0x128/0x2af
> [ 2311.315484]        vm_munmap+0x5a/0x73
> [ 2311.315485]        elf_map+0xb1/0xce
> [ 2311.315487]        load_elf_binary+0x8e0/0x1348
> [ 2311.315489]        search_binary_handler+0x70/0x1f3
> [ 2311.315490]        load_script+0x1a6/0x1b5
> [ 2311.315492]        search_binary_handler+0x70/0x1f3
> [ 2311.315494]        do_execveat_common+0x461/0x691
> [ 2311.315496]        kernel_init+0x5a/0xf0
> [ 2311.315497]        ret_from_fork+0x27/0x40
> [ 2311.315498] 
>                -> #0 (&mapping->i_mmap_rwsem){++++}:
> [ 2311.315503]        lock_acquire+0x176/0x19e
> [ 2311.315505]        down_read+0x3b/0x55
> [ 2311.315507]        rmap_walk_file+0x5a/0x147
> [ 2311.315508]        page_referenced+0x11c/0x134
> [ 2311.315511]        shrink_page_list+0x36b/0xb80
> [ 2311.315512]        shrink_inactive_list+0x1d9/0x437
> [ 2311.315514]        shrink_node_memcg.constprop.71+0x3e7/0x571
> [ 2311.315515]        shrink_node+0x3f/0x149
> [ 2311.315517]        try_to_free_pages+0x270/0x45f
> [ 2311.315518]        __alloc_pages_slowpath+0x34a/0xaa2
> [ 2311.315520]        __alloc_pages_nodemask+0x111/0x217
> [ 2311.315523]        khugepaged_alloc_page+0x17/0x45
> [ 2311.315524]        khugepaged+0xa29/0x16b5
> [ 2311.315527]        kthread+0xfb/0x103
> [ 2311.315529]        ret_from_fork+0x27/0x40
> [ 2311.315530] 
>                other info that might help us debug this:
> 
> [ 2311.315531] Chain exists of:
>                  &mapping->i_mmap_rwsem --> &vma->vm_sequence/1 --> fs_reclaim

Hi Sergey,

I can't see where such a chain could happen.

I tried to recreate it on top of the latest mm tree, to latest stack output
but I can't get it.
How did you raised this one ?

Thanks,
Laurent.


> 
> [ 2311.315537]  Possible unsafe locking scenario:
> 
> [ 2311.315538]        CPU0                    CPU1
> [ 2311.315539]        ----                    ----
> [ 2311.315540]   lock(fs_reclaim);
> [ 2311.315542]                                lock(&vma->vm_sequence/1);
> [ 2311.315545]                                lock(fs_reclaim);
> [ 2311.315547]   lock(&mapping->i_mmap_rwsem);
> [ 2311.315549] 
>                 *** DEADLOCK ***
> 
> [ 2311.315551] 1 lock held by khugepaged/43:
> [ 2311.315552]  #0:  (fs_reclaim){+.+.}, at: [<ffffffff810ebd80>] fs_reclaim_acquire+0x12/0x35
> [ 2311.315556] 
>                stack backtrace:
> [ 2311.315559] CPU: 0 PID: 43 Comm: khugepaged Not tainted 4.13.0-rc5-next-20170817-dbg-00039-gaf11d7500492-dirty #1743
> [ 2311.315560] Call Trace:
> [ 2311.315564]  dump_stack+0x67/0x8e
> [ 2311.315568]  print_circular_bug.isra.39+0x1c7/0x1d4
> [ 2311.315570]  __lock_acquire+0xb1a/0xe06
> [ 2311.315572]  ? graph_unlock+0x69/0x69
> [ 2311.315575]  lock_acquire+0x176/0x19e
> [ 2311.315577]  ? rmap_walk_file+0x5a/0x147
> [ 2311.315579]  down_read+0x3b/0x55
> [ 2311.315581]  ? rmap_walk_file+0x5a/0x147
> [ 2311.315583]  rmap_walk_file+0x5a/0x147
> [ 2311.315585]  page_referenced+0x11c/0x134
> [ 2311.315587]  ? page_vma_mapped_walk_done.isra.15+0xb/0xb
> [ 2311.315589]  ? page_get_anon_vma+0x6d/0x6d
> [ 2311.315591]  shrink_page_list+0x36b/0xb80
> [ 2311.315593]  ? _raw_spin_unlock_irq+0x29/0x46
> [ 2311.315595]  shrink_inactive_list+0x1d9/0x437
> [ 2311.315597]  shrink_node_memcg.constprop.71+0x3e7/0x571
> [ 2311.315600]  shrink_node+0x3f/0x149
> [ 2311.315602]  try_to_free_pages+0x270/0x45f
> [ 2311.315604]  __alloc_pages_slowpath+0x34a/0xaa2
> [ 2311.315608]  ? ___might_sleep+0xd5/0x234
> [ 2311.315609]  __alloc_pages_nodemask+0x111/0x217
> [ 2311.315612]  khugepaged_alloc_page+0x17/0x45
> [ 2311.315613]  khugepaged+0xa29/0x16b5
> [ 2311.315616]  ? remove_wait_queue+0x47/0x47
> [ 2311.315618]  ? collapse_shmem.isra.43+0x882/0x882
> [ 2311.315620]  kthread+0xfb/0x103
> [ 2311.315622]  ? __list_del_entry+0x1d/0x1d
> [ 2311.315624]  ret_from_fork+0x27/0x40
> 
> 	-ss
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
