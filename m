Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 733AF6B1F5F
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:57:56 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so957905pla.2
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:57:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor17744771plf.73.2018.11.20.00.57.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 00:57:55 -0800 (PST)
Date: Tue, 20 Nov 2018 11:57:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LKP] dd2283f260 [ 97.263072]
 WARNING:at_kernel/locking/lockdep.c:#lock_downgrade
Message-ID: <20181120085749.lj7dzk52633oq42s@kshutemo-mobl1>
References: <20181115055443.GF18977@shao2-debian>
 <d9371abc-60f6-ce37-529f-d097464a1412@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9371abc-60f6-ce37-529f-d097464a1412@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kernel test robot <rong.a.chen@intel.com>, Waiman Long <longman@redhat.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Nov 16, 2018 at 08:56:04AM -0800, Yang Shi wrote:
> 
> > a8dda165ec  vfree: add debug might_sleep()
> > dd2283f260  mm: mmap: zap pages with read mmap_sem in munmap
> > 5929a1f0ff  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
> > 0bc80e3cb0  Add linux-next specific files for 20181114
> > +-----------------------------------------------------+------------+------------+------------+---------------+
> > |                                                     | a8dda165ec | dd2283f260 | 5929a1f0ff | next-20181114 |
> > +-----------------------------------------------------+------------+------------+------------+---------------+
> > | boot_successes                                      | 314        | 178        | 190        | 168           |
> > | boot_failures                                       | 393        | 27         | 21         | 40            |
> > | WARNING:held_lock_freed                             | 383        | 23         | 17         | 39            |
> > | is_freeing_memory#-#,with_a_lock_still_held_there   | 383        | 23         | 17         | 39            |
> > | BUG:unable_to_handle_kernel                         | 5          | 2          | 4          | 1             |
> > | Oops:#[##]                                          | 9          | 3          | 4          | 1             |
> > | EIP:debug_check_no_locks_freed                      | 9          | 3          | 4          | 1             |
> > | Kernel_panic-not_syncing:Fatal_exception            | 9          | 3          | 4          | 1             |
> > | Mem-Info                                            | 4          | 1          |            |               |
> > | invoked_oom-killer:gfp_mask=0x                      | 1          | 1          |            |               |
> > | WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 6          | 4          | 7             |
> > | EIP:lock_downgrade                                  | 0          | 6          | 4          | 7             |
> > +-----------------------------------------------------+------------+------------+------------+---------------+
> > 
> > [   96.288009] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
> > [   96.359626] input_id (331) used greatest stack depth: 6360 bytes left
> > [   96.749228] grep (358) used greatest stack depth: 6336 bytes left
> > [   96.921470] network.sh (341) used greatest stack depth: 6212 bytes left
> > [   97.262340]
> > [   97.262587] =========================
> > [   97.263072] WARNING: held lock freed!
> > [   97.263536] 4.19.0-06969-gdd2283f #1 Not tainted
> > [   97.264110] -------------------------
> > [   97.264575] udevd/198 is freeing memory 9c16c930-9c16c99b, with a lock still held there!
> > [   97.265542] (ptrval) (&anon_vma->rwsem){....}, at: unlink_anon_vmas+0x14e/0x420
> > [   97.266450] 1 lock held by udevd/198:
> > [   97.266924]  #0: (ptrval) (&mm->mmap_sem){....}, at: __do_munmap+0x531/0x730
> 
> I have not figured out what this is caused by. But, the below warning looks
> more confusing. This might be caused by the below one.

I *think* we need to understand more about what detached VMAs mean for
rmap. The anon_vma for these VMAs still reachable for the rmap and
therefore VMA too. I don't quite grasp what is implications of this, but
it doesn't look good.

I'll look into this more when I get some free cycles.

It's better to disable the optimization for now (by ignoring 'downgrade'
in __do_munmap()). Before it hits release.

-- 
 Kirill A. Shutemov
