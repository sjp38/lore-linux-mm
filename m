Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C31F060021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 20:55:57 -0500 (EST)
Message-ID: <4B15C902.4020008@redhat.com>
Date: Tue, 01 Dec 2009 20:55:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
References: <20091125133752.2683c3e4@bree.surriel.com> <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 11/30/2009 05:00 PM, Larry Woodman wrote:
> While running workloads that do lots of forking processes, exiting
> processes and page reclamation(AIM 7) on large systems very high system
> time(100%) and lots of lock contention was observed.
>
>
>
> CPU5:
> [<ffffffff814afb48>] ? _spin_lock+0x27/0x48
>   [<ffffffff81101deb>] ? anon_vma_link+0x2a/0x5a
>   [<ffffffff8105d3d8>] ? dup_mm+0x242/0x40c
>   [<ffffffff8105e0a9>] ? copy_process+0xab1/0x12be
>   [<ffffffff8105ea07>] ? do_fork+0x151/0x330
>   [<ffffffff81058407>] ? default_wake_function+0x0/0x36
>   [<ffffffff814b0243>] ? _spin_lock_irqsave+0x2f/0x68
>   [<ffffffff810121d3>] ? stub_clone+0x13/0x20
> [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b
>
> CPU4:
> [<ffffffff814afb4a>] ? _spin_lock+0x29/0x48
>   [<ffffffff81103062>] ? anon_vma_unlink+0x2a/0x84
>   [<ffffffff810fbab7>] ? free_pgtables+0x3c/0xe1
>   [<ffffffff810fd8b1>] ? exit_mmap+0xc5/0x110
>   [<ffffffff8105ce4c>] ? mmput+0x55/0xd9
>   [<ffffffff81061afd>] ? exit_mm+0x109/0x129
>   [<ffffffff81063846>] ? do_exit+0x1d7/0x712
>   [<ffffffff814b0243>] ? _spin_lock_irqsave+0x2f/0x68
>   [<ffffffff81063e07>] ? do_group_exit+0x86/0xb2
>   [<ffffffff81063e55>] ? sys_exit_group+0x22/0x3e
> [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b
>
> CPU0:
> [<ffffffff814afb4a>] ? _spin_lock+0x29/0x48
> [<ffffffff81101ad1>] ? page_check_address+0x9e/0x16f
>   [<ffffffff81101cb8>] ? page_referenced_one+0x53/0x10b
>   [<ffffffff81102f5a>] ? page_referenced+0xcd/0x167
>   [<ffffffff810eb32d>] ? shrink_active_list+0x1ed/0x2a3
>   [<ffffffff810ebde9>] ? shrink_zone+0xa06/0xa38
>   [<ffffffff8108440a>] ? getnstimeofday+0x64/0xce
>   [<ffffffff810ecaf9>] ? do_try_to_free_pages+0x1e5/0x362
>   [<ffffffff810ecd9f>] ? try_to_free_pages+0x7a/0x94
>   [<ffffffff810ea66f>] ? isolate_pages_global+0x0/0x242
>   [<ffffffff810e57b9>] ? __alloc_pages_nodemask+0x397/0x572
>   [<ffffffff810e3c1e>] ? __get_free_pages+0x19/0x6e
>   [<ffffffff8105d6c9>] ? copy_process+0xd1/0x12be
>   [<ffffffff81204eb2>] ? avc_has_perm+0x5c/0x84
>   [<ffffffff81130db8>] ? user_path_at+0x65/0xa3
>   [<ffffffff8105ea07>] ? do_fork+0x151/0x330
>   [<ffffffff810b7935>] ? check_for_new_grace_period+0x78/0xab
>   [<ffffffff810121d3>] ? stub_clone+0x13/0x20
> [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b
>
>
> ------------------------------------------------------------------------------
>     PerfTop:     864 irqs/sec  kernel:99.7% [100000 cycles],  (all, 8
> CPUs)
> ------------------------------------------------------------------------------
>
>               samples    pcnt         RIP          kernel function
>    ______     _______   _____   ________________   _______________
>
>               3235.00 - 75.1% - ffffffff814afb21 : _spin_lock
>                670.00 - 15.6% - ffffffff81101a33 : page_check_address
>                165.00 -  3.8% - ffffffffa01cbc39 : rpc_sleep_on  [sunrpc]
>                 40.00 -  0.9% - ffffffff81102113 : try_to_unmap_one
>                 29.00 -  0.7% - ffffffff81101c65 : page_referenced_one
>                 27.00 -  0.6% - ffffffff81101964 : vma_address
>                  8.00 -  0.2% - ffffffff8125a5a0 : clear_page_c
>                  6.00 -  0.1% - ffffffff8125a5f0 : copy_page_c
>                  6.00 -  0.1% - ffffffff811023ca : try_to_unmap_anon
>                  5.00 -  0.1% - ffffffff810fb014 : copy_page_range
>                  5.00 -  0.1% - ffffffff810e4d18 : get_page_from_freelist
>
>
>
> The cause was determined to be the unconditional call to
> page_referenced() for every mapped page encountered in
> shrink_active_list().  page_referenced() takes the anon_vma->lock and
> calls page_referenced_one() for each vma.  page_referenced_one() then
> calls page_check_address() which takes the pte_lockptr spinlock.   If
> several CPUs are doing this at the same time there is a lot of
> pte_lockptr spinlock contention with the anon_vma->lock held.  This
> causes contention on the anon_vma->lock, stalling in the fo and very
> high system time.
>
> Before the splitLRU patch shrink_active_list() would only call
> page_referenced() when reclaim_mapped got set.  reclaim_mapped only got
> set when the priority worked its way from 12 all the way to 7. This
> prevented page_referenced() from being called from shrink_active_list()
> until the system was really struggling to reclaim memory.
>
> On way to prevent this is to change page_check_address() to execute a
> spin_trylock(ptl) when it was called by shrink_active_list() and simply
> fail if it could not get the pte_lockptr spinlock.  This will make
> shrink_active_list() consider the page not referenced and allow the
> anon_vma->lock to be dropped much quicker.
>
> The attached patch does just that, thoughts???
>    
My first thought is that you haven't read the code
you are trying to patch.

The purpose of calling page_referenced on anonymous
pages from shrink_active_list is to CLEAR the referenced
bit, not to test it!

Not clearing the referenced bit will break page replacement,
because pages that were not recently referenced will appear
to be, causing them to get another round on the active list,
which in turn could increase the list movement...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
