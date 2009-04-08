Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 819285F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 22:30:03 -0400 (EDT)
Date: Wed, 8 Apr 2009 10:29:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/14] mm: remove FAULT_FLAG_RETRY dead code
Message-ID: <20090408022955.GA15993@localhost>
References: <20090407071729.233579162@intel.com> <20090407072133.053995305@intel.com> <604427e00904071303g1d092eabp59fca0713ddacf82@mail.gmail.com> <20090407232700.GB5607@localhost> <604427e00904071817n767122byb439043e8a228011@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00904071817n767122byb439043e8a228011@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ying Han,

On Wed, Apr 08, 2009 at 09:17:26AM +0800, Ying Han wrote:
> On Tue, Apr 7, 2009 at 4:27 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Wed, Apr 08, 2009 at 04:03:36AM +0800, Ying Han wrote:
> >> On Tue, Apr 7, 2009 at 12:17 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> > Cc: Ying Han <yinghan@google.com>
> >> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >> > ---
> >> >  mm/memory.c |    4 +---
> >> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >> >
> >> > --- mm.orig/mm/memory.c
> >> > +++ mm/mm/memory.c
> >> > @@ -2766,10 +2766,8 @@ static int do_linear_fault(struct mm_str
> >> >  {
> >> >        pgoff_t pgoff = (((address & PAGE_MASK)
> >> >                        - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> >> > -       int write = write_access & ~FAULT_FLAG_RETRY;
> >> > -       unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
> >> > +       unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
> >> >
> >> > -       flags |= (write_access & FAULT_FLAG_RETRY);
> >> >        pte_unmap(page_table);
> >> >        return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
> >> >  }
> >> So, we got rid of FAULT_FLAG_RETRY flag?
> >
> > Seems yes for the current mm tree, see the following two commits.
> >
> > I did this patch on seeing 761fe7bc8193b7. But a closer look
> > indicates that the following two patches disable the filemap
> > VM_FAULT_RETRY part totally...
> >
> > Anyway, if these two patches are to be reverted somehow(I guess yes),
> > this patch shall be _ignored_.
> >
> > btw, do you have any test case and performance numbers for
> > FAULT_FLAG_RETRY? And possible overheads for (the worst case)
> > sparse random mmap reads on a sparse file?  I cannot find any
> > in your changelogs..
> 
> here is the benchmark i posted on [V1] but somehow missed in [V2] describtion
> 
> Benchmarks:
> case 1. one application has a high count of threads each faulting in
> different pages of a hugefile. Benchmark indicate that this double data
> structure walking in case of major fault results in << 1% performance hit.
> 
> case 2. add another thread in the above application which in a tight loop of
> mmap()/munmap(). Here we measure loop count in the new thread while other
> threads doing the same amount of work as case one. we got << 3% performance
> hit on the Complete Time(benchmark value for case one) and 10% performance
> improvement on the mmap()/munmap() counter.
> 
> This patch helps a lot in cases we have writer which is waitting behind all
> readers, so it could execute much faster.
> 

Just tested the sparse-random-read-on-sparse-file case, and found the
performance impact to be 0.4% (8.706s vs 8.744s). Kind of acceptable.

without FAULT_FLAG_RETRY:
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.28s user 5.39s system 99% cpu 8.692 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.17s user 5.54s system 99% cpu 8.742 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user 5.48s system 99% cpu 8.684 total

FAULT_FLAG_RETRY:
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user 5.63s system 99% cpu 8.825 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.22s user 5.47s system 99% cpu 8.718 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.13s user 5.55s system 99% cpu 8.690 total

In the above faked workload, the mmap read page offsets are loaded from
stride-100 and performed on /mnt/btrfs-ram/sparse, which are created by:

                seq 0 100 1000000 > stride-100
                dd if=/dev/zero of=/mnt/btrfs-ram/sparse bs=1M count=1 seek=1024000

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
