Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC276B25F7
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:17:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 4so7780830plc.5
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:17:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y64sor42941272pgd.38.2018.11.21.03.17.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 03:17:51 -0800 (PST)
Date: Wed, 21 Nov 2018 14:17:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LKP] dd2283f260 [ 97.263072]
 WARNING:at_kernel/locking/lockdep.c:#lock_downgrade
Message-ID: <20181121111745.v56gygpfn5gvdoc4@kshutemo-mobl1>
References: <20181115055443.GF18977@shao2-debian>
 <d9371abc-60f6-ce37-529f-d097464a1412@linux.alibaba.com>
 <20181120085749.lj7dzk52633oq42s@kshutemo-mobl1>
 <9dec33d0-f408-8428-b004-fa63fc2e9091@linux.alibaba.com>
 <20181120134216.s5derazwpay5gkfk@kshutemo-mobl1>
 <d552af11-7b73-da6a-ed12-6cb7bd1bb5a4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d552af11-7b73-da6a-ed12-6cb7bd1bb5a4@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kernel test robot <rong.a.chen@intel.com>, Waiman Long <longman@redhat.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Nov 21, 2018 at 08:35:28AM +0800, Yang Shi wrote:
> 
> 
> On 11/20/18 9:42 PM, Kirill A. Shutemov wrote:
> > On Tue, Nov 20, 2018 at 08:10:51PM +0800, Yang Shi wrote:
> > > 
> > > On 11/20/18 4:57 PM, Kirill A. Shutemov wrote:
> > > > On Fri, Nov 16, 2018 at 08:56:04AM -0800, Yang Shi wrote:
> > > > > > a8dda165ec  vfree: add debug might_sleep()
> > > > > > dd2283f260  mm: mmap: zap pages with read mmap_sem in munmap
> > > > > > 5929a1f0ff  Merge tag 'riscv-for-linus-4.20-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
> > > > > > 0bc80e3cb0  Add linux-next specific files for 20181114
> > > > > > +-----------------------------------------------------+------------+------------+------------+---------------+
> > > > > > |                                                     | a8dda165ec | dd2283f260 | 5929a1f0ff | next-20181114 |
> > > > > > +-----------------------------------------------------+------------+------------+------------+---------------+
> > > > > > | boot_successes                                      | 314        | 178        | 190        | 168           |
> > > > > > | boot_failures                                       | 393        | 27         | 21         | 40            |
> > > > > > | WARNING:held_lock_freed                             | 383        | 23         | 17         | 39            |
> > > > > > | is_freeing_memory#-#,with_a_lock_still_held_there   | 383        | 23         | 17         | 39            |
> > > > > > | BUG:unable_to_handle_kernel                         | 5          | 2          | 4          | 1             |
> > > > > > | Oops:#[##]                                          | 9          | 3          | 4          | 1             |
> > > > > > | EIP:debug_check_no_locks_freed                      | 9          | 3          | 4          | 1             |
> > > > > > | Kernel_panic-not_syncing:Fatal_exception            | 9          | 3          | 4          | 1             |
> > > > > > | Mem-Info                                            | 4          | 1          |            |               |
> > > > > > | invoked_oom-killer:gfp_mask=0x                      | 1          | 1          |            |               |
> > > > > > | WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 6          | 4          | 7             |
> > > > > > | EIP:lock_downgrade                                  | 0          | 6          | 4          | 7             |
> > > > > > +-----------------------------------------------------+------------+------------+------------+---------------+
> > > > > > 
> > > > > > [   96.288009] random: get_random_u32 called from arch_rnd+0x3c/0x70 with crng_init=0
> > > > > > [   96.359626] input_id (331) used greatest stack depth: 6360 bytes left
> > > > > > [   96.749228] grep (358) used greatest stack depth: 6336 bytes left
> > > > > > [   96.921470] network.sh (341) used greatest stack depth: 6212 bytes left
> > > > > > [   97.262340]
> > > > > > [   97.262587] =========================
> > > > > > [   97.263072] WARNING: held lock freed!
> > > > > > [   97.263536] 4.19.0-06969-gdd2283f #1 Not tainted
> > > > > > [   97.264110] -------------------------
> > > > > > [   97.264575] udevd/198 is freeing memory 9c16c930-9c16c99b, with a lock still held there!
> > > > > > [   97.265542] (ptrval) (&anon_vma->rwsem){....}, at: unlink_anon_vmas+0x14e/0x420
> > > > > > [   97.266450] 1 lock held by udevd/198:
> > > > > > [   97.266924]  #0: (ptrval) (&mm->mmap_sem){....}, at: __do_munmap+0x531/0x730
> > > > > I have not figured out what this is caused by. But, the below warning looks
> > > > > more confusing. This might be caused by the below one.
> > > > I *think* we need to understand more about what detached VMAs mean for
> > > > rmap. The anon_vma for these VMAs still reachable for the rmap and
> > > > therefore VMA too. I don't quite grasp what is implications of this, but
> > > > it doesn't look good.
> > > I'm supposed before accessing anon_vma, VMA need to be found by find_vma()
> > > first, right? But, finding VMA need hold mmap_sem, once detach VMAs is
> > > called, others should not be able to find the VMAs anymore. So, the anon_vma
> > > should not be reachable except the munmap caller.
> > No. anon_vma can be reached from page->mapping. The page can be reached
> > during physcal memory scan or if the page is shared (across fork()). None
> > of these accesses require mmap_sem.
> 
> If they don't require mmap_sem at all, this problem should be valid
> regardless of the optimization. We just downgraded write mmap_sem to read,
> but still hold it.

I tend to agree with you.

But having the crash in the picture makes me wounder if there's scenario
when VMA reachable via anon_vma, but not via find_vma() causes a problem.
I cannot think of any, but who knows.

-- 
 Kirill A. Shutemov
