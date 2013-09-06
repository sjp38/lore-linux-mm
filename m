Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B236B6B0032
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 14:01:25 -0400 (EDT)
Date: Fri, 06 Sep 2013 14:01:05 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378490465-7uvqrj27-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130906160423.GT2975@sgi.com>
References: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1378416466-30913-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130906160423.GT2975@sgi.com>
Subject: Re: [PATCH 2/2] thp: support split page table lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Hi Alex,

On Fri, Sep 06, 2013 at 11:04:23AM -0500, Alex Thorlton wrote:
> On Thu, Sep 05, 2013 at 05:27:46PM -0400, Naoya Horiguchi wrote:
> > Thp related code also uses per process mm->page_table_lock now.
> > So making it fine-grained can provide better performance.
> > 
> > This patch makes thp support split page table lock by using page->ptl
> > of the pages storing "pmd_trans_huge" pmds.
> > 
> > Some functions like pmd_trans_huge_lock() and page_check_address_pmd()
> > are expected by their caller to pass back the pointer of ptl, so this
> > patch adds to those functions new arguments for that. Rather than that,
> > this patch gives only straightforward replacement.
> > 
> > ChangeLog v3:
> >  - fixed argument of huge_pmd_lockptr() in copy_huge_pmd()
> >  - added missing declaration of ptl in do_huge_pmd_anonymous_page()
> 
> I've applied these and tested them using the same tests program that I
> used when I was working on the same issue, and I'm running into some
> bugs.  Here's a stack trace:

Thank you for helping testing. This bug is new to me.

> general protection fault: 0000 [#1] SMP 
> Modules linked in:
> CPU: 268 PID: 32381 Comm: memscale Not tainted
> 3.11.0-medusa-03121-g757f8ca #184
> Hardware name: SGI UV2000/ROMLEY, BIOS SGI UV 2000/3000 series BIOS
> 01/15/2013
> task: ffff880fbdd82180 ti: ffff880fc0c5a000 task.ti: ffff880fc0c5a000
> RIP: 0010:[<ffffffff810e3eef>]  [<ffffffff810e3eef>]
> pgtable_trans_huge_withdraw+0x38/0x60
> RSP: 0018:ffff880fc0c5bc88  EFLAGS: 00010297
> RAX: ffffea17cebe8838 RBX: 00000015309bd000 RCX: ffffea01f623b028
> RDX: dead000000100100 RSI: ffff8dcf77d84c30 RDI: ffff880fbda67580
> RBP: ffff880fc0c5bc88 R08: 0000000000000013 R09: 0000000000014da0
> R10: ffff880fc0c5bc88 R11: ffff888f7efda000 R12: ffff8dcf77d84c30
> R13: ffff880fc0c5bdf8 R14: 800005cf401ff067 R15: ffff8b4de5fabff8
> FS:  0000000000000000(0000) GS:ffff880fffd80000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007ffff768b0b8 CR3: 0000000001a0b000 CR4: 00000000000407e0
> Stack:
>  ffff880fc0c5bcc8 ffffffff810f7643 ffff880fc0c5bcc8 ffffffff810d8297
>  ffffea1456237510 00007fc7b0e00000 0000000000000000 00007fc7b0c00000
>  ffff880fc0c5bda8 ffffffff810d85ba ffff880fc0c5bd48 ffff880fc0c5bd68
> Call Trace:
>  [<ffffffff810f7643>] zap_huge_pmd+0x4c/0x101
>  [<ffffffff810d8297>] ? tlb_flush_mmu+0x58/0x75
>  [<ffffffff810d85ba>] unmap_single_vma+0x306/0x7d6
>  [<ffffffff810d8ad9>] unmap_vmas+0x4f/0x82
>  [<ffffffff810dab5e>] exit_mmap+0x8b/0x113
>  [<ffffffff810a9743>] ? __delayacct_add_tsk+0x170/0x182
>  [<ffffffff8103c609>] mmput+0x3e/0xc4
>  [<ffffffff8104088c>] do_exit+0x380/0x907
>  [<ffffffff810fb89c>] ? vfs_write+0x149/0x1a3
>  [<ffffffff81040e85>] do_group_exit+0x72/0x9b
>  [<ffffffff81040ec0>] SyS_exit_group+0x12/0x16
>  [<ffffffff814f52d2>] system_call_fastpath+0x16/0x1b
> Code: 51 20 48 8d 41 20 48 39 c2 75 0d 48 c7 87 28 03 00 00 00 00 00 00
> eb 36 48 8d 42 e0 48 89 87 28 03 00 00 48 8b 51 20 48 8b 41 28 <48> 89
> 42 08 48 89 10 48 ba 00 01 10 00 00 00 ad de 48 b8 00 02 
> RIP  [<ffffffff810e3eef>] pgtable_trans_huge_withdraw+0x38/0x60
>  RSP <ffff880fc0c5bc88>
> ---[ end trace e5413b388b6ea448 ]---
> Fixing recursive fault but reboot is needed!
> general protection fault: 0000 [#2] SMP 
> Modules linked in:
> CPU: 268 PID: 1722 Comm: kworker/268:1 Tainted: G      D
> 3.11.0-medusa-03121-g757f8ca #184
> Hardware name: SGI UV2000/ROMLEY, BIOS SGI UV 2000/3000 series BIOS
> 01/15/2013
> Workqueue: events vmstat_update
> task: ffff880fc1a74280 ti: ffff880fc1a76000 task.ti: ffff880fc1a76000
> RIP: 0010:[<ffffffff810bcdcb>]  [<ffffffff810bcdcb>]
> free_pcppages_bulk+0x97/0x329
> RSP: 0018:ffff880fc1a77c98  EFLAGS: 00010082
> RAX: ffff880fffd94d68 RBX: dead0000002001e0 RCX: ffff880fffd94d50
> RDX: ffff880fffd94d68 RSI: 000000000000001f RDI: ffff888f7efdac68
> RBP: ffff880fc1a77cf8 R08: 0000000000000400 R09: ffffffff81a8bf00
> R10: ffff884f7efdac00 R11: ffffffff81009bae R12: dead000000200200
> R13: ffff888f7efdac00 R14: 000000000000001f R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff880fffd80000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007ffff768b0b8 CR3: 0000000001a0b000 CR4: 00000000000407e0
> Stack:
>  ffff880fc1a77ce8 ffff880fffd94d68 0000000000000010 ffff880fffd94d50
>  0000001ff9276a68 ffff880fffd94d60 0000000000000000 000000000000001f
>  ffff880fffd94d50 0000000000000292 ffff880fc1a77d38 ffff880fffd95d05
> Call Trace:
>  [<ffffffff810bd149>] drain_zone_pages+0x33/0x42
>  [<ffffffff810cd5a6>] refresh_cpu_vm_stats+0xcc/0x11e
>  [<ffffffff810cd609>] vmstat_update+0x11/0x43
>  [<ffffffff8105350f>] process_one_work+0x260/0x389
>  [<ffffffff8105381a>] worker_thread+0x1e2/0x332
>  [<ffffffff81053638>] ? process_one_work+0x389/0x389
>  [<ffffffff810579df>] kthread+0xb3/0xbd
>  [<ffffffff81053638>] ? process_one_work+0x389/0x389
>  [<ffffffff8105792c>] ? kthread_freezable_should_stop+0x5b/0x5b
>  [<ffffffff814f522c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8105792c>] ? kthread_freezable_should_stop+0x5b/0x5b
> Code: 48 89 55 c8 48 39 14 08 74 ce 41 83 fe 03 44 0f 44 75 c4 48 83 c2
> 08 48 89 45 b0 48 89 55 a8 48 8b 45 a8 4c 8b 20 49 8d 5c 24 e0 <48> 8b
> 53 20 48 8b 43 28 48 89 42 08 48 89 10 48 ba 00 01 10 00 
> RIP  [<ffffffff810bcdcb>] free_pcppages_bulk+0x97/0x329
>  RSP <ffff880fc1a77c98>
> ---[ end trace e5413b388b6ea449 ]---
> BUG: unable to handle kernel paging request at ffffffffffffffd8
> IP: [<ffffffff8105742c>] kthread_data+0xb/0x11
> PGD 1a0c067 PUD 1a0e067 PMD 0 
> Oops: 0000 [#3] SMP 
> Modules linked in:
> CPU: 268 PID: 1722 Comm: kworker/268:1 Tainted: G      D
> 3.11.0-medusa-03121-g757f8ca #184
> Hardware name: SGI UV2000/ROMLEY, BIOS SGI UV 2000/3000 series BIOS
> 01/15/2013
> task: ffff880fc1a74280 ti: ffff880fc1a76000 task.ti: ffff880fc1a76000
> RIP: 0010:[<ffffffff8105742c>]  [<ffffffff8105742c>]
> kthread_data+0xb/0x11
> RSP: 0018:ffff880fc1a77948  EFLAGS: 00010092
> RAX: 0000000000000000 RBX: 000000000000010c RCX: 0000000000000000
> RDX: 000000000000000f RSI: 000000000000010c RDI: ffff880fc1a74280
> RBP: ffff880fc1a77948 R08: 00000000000442c8 R09: 0000000000000000
> R10: dead000000200200 R11: ffff880fc1a742e8 R12: ffff880fc1a74868
> R13: ffff880fffd91cc0 R14: ffff880ff9b7a040 R15: 000000000000010c
> FS:  0000000000000000(0000) GS:ffff880fffd80000(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000028 CR3: 0000000001a0b000 CR4: 00000000000407e0
> Stack:
>  ffff880fc1a77968 ffffffff8105151f ffff880fc1a77968 ffff880fc1a74280
>  ffff880fc1a77ab8 ffffffff814f2e98 ffff880fc1a76010 0000000000004000
>  ffff880fc1a74280 0000000000011cc0 ffff880fc1a77fd8 ffff880fc1a77fd8
> Call Trace:
>  [<ffffffff8105151f>] wq_worker_sleeping+0x10/0x82
>  [<ffffffff814f2e98>] __schedule+0x1b7/0x8f7
>  [<ffffffff8135d4bd>] ? mix_pool_bytes+0x4a/0x56
>  [<ffffffff810a5d05>] ? call_rcu_sched+0x16/0x18
>  [<ffffffff8103f708>] ? release_task+0x3a7/0x3bf
>  [<ffffffff814f36b5>] schedule+0x61/0x63
>  [<ffffffff81040e0f>] do_exit+0x903/0x907
>  [<ffffffff8100529a>] oops_end+0xb9/0xc1
>  [<ffffffff81005393>] die+0x55/0x5e
>  [<ffffffff8100341a>] do_general_protection+0x93/0x139
>  [<ffffffff814f4d82>] general_protection+0x22/0x30
>  [<ffffffff81009bae>] ? default_idle+0x6/0x8
>  [<ffffffff810bcdcb>] ? free_pcppages_bulk+0x97/0x329
>  [<ffffffff810bcd5d>] ? free_pcppages_bulk+0x29/0x329
>  [<ffffffff810bd149>] drain_zone_pages+0x33/0x42
>  [<ffffffff810cd5a6>] refresh_cpu_vm_stats+0xcc/0x11e
>  [<ffffffff810cd609>] vmstat_update+0x11/0x43
>  [<ffffffff8105350f>] process_one_work+0x260/0x389
>  [<ffffffff8105381a>] worker_thread+0x1e2/0x332
>  [<ffffffff81053638>] ? process_one_work+0x389/0x389
>  [<ffffffff810579df>] kthread+0xb3/0xbd
>  [<ffffffff81053638>] ? process_one_work+0x389/0x389
>  [<ffffffff8105792c>] ? kthread_freezable_should_stop+0x5b/0x5b
>  [<ffffffff814f522c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8105792c>] ? kthread_freezable_should_stop+0x5b/0x5b
> Code: 65 48 8b 04 25 40 b7 00 00 48 8b 80 90 05 00 00 48 89 e5 48 8b 40
> c8 c9 48 c1 e8 02 83 e0 01 c3 48 8b 87 90 05 00 00 55 48 89 e5 <48> 8b
> 40 d8 c9 c3 48 3b 3d 67 ca c2 00 55 48 89 e5 75 09 0f bf 
> RIP  [<ffffffff8105742c>] kthread_data+0xb/0x11
>  RSP <ffff880fc1a77948>
> CR2: ffffffffffffffd8
> ---[ end trace e5413b388b6ea44a ]---
> Fixing recursive fault but reboot is needed!
> 
> I'm testing on a 528 core machine, with ~2TB of memory, THP on.  The
> test case works like this:
> 
> - Spawn 512 threads using pthread_create, pin each thread to a separate
>   cpu
> - Each thread allocates 512mb, local to its cpu
> - Threads are sent a "go" signal, all threads begin touching the first
>   byte of each 4k chunk of their 512mb simultaneously
> 
> I'm working on debugging the issue now, but I thought I'd get this out
> to everyone in case they might have some input.  I'll try and get my
> test program cleaned up and posted somewhere today so that others can
> try it out as well.

Thanks. Please let me know when it's available. I'll look at it.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
