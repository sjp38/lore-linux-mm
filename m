Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2E78E6B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 23:13:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kp14so538640pab.0
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 20:13:07 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id se7si6018812pbb.354.2014.04.25.20.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 20:13:06 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3711620pdj.8
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 20:13:06 -0700 (PDT)
Date: Fri, 25 Apr 2014 20:11:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <535ADAFD.9040308@intel.com>
Message-ID: <alpine.LSU.2.11.1404251956570.990@eggly.anvils>
References: <53558507.9050703@zytor.com> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com> <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz> <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
 <20140424065133.GX26782@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404241110160.2443@eggly.anvils> <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com> <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
 <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com> <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop> <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com> <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com> <alpine.LSU.2.11.1404250414590.5198@eggly.anvils> <535A9356.8060608@intel.com> <alpine.LSU.2.11.1404251138050.5909@eggly.anvils> <535ADAFD.9040308@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Fri, 25 Apr 2014, Dave Hansen wrote:
> On 04/25/2014 11:41 AM, Hugh Dickins wrote:
> > On Fri, 25 Apr 2014, Dave Hansen wrote:
> >> On 04/25/2014 05:01 AM, Hugh Dickins wrote:
> >>> Er, i_mmap_mutex.
> >>>
> >>> That's what unmap_mapping_range(), and page_mkclean()'s rmap_walk,
> >>> take to iterate over the file vmas.  So perhaps there's no race at all
> >>> in the unmap_mapping_range() case.  And easy (I imagine) to fix the
> >>> race in Dave's racewrite.c use of MADV_DONTNEED: untested patch below.
> >>
> >> Do you want some testing on this?
> > 
> > Yes, please do: I just haven't gotten around to cloning the git
> > tree and trying it.  It's quite likely that we shall go Linus's
> > way rather than this, but still useful to have the information
> > as to whether this way really is viable.
> 
> Your patch works fine for the madvise() case.  The effect appears the
> same as Linus's to my test case at least.  I didn't test any unmaps or
> other creative uses of unmap_mapping_range().

Thanks a lot for checking that, Dave, I'm glad to hear it worked.

Right, that patch only addressed the MADV_DONTNEED case: I've now
extended it, reverting the change in madvise.c, and doing it in
unmap_single_vma() instead, to cover all the cases.

So here is my alternative to Linus's "split 'tlb_flush_mmu()'" patch.
I don't really have a preference between the two approaches, and it
looks like Linus is now happy with his, so I don't expect this one to
go anywhere; unless someone else can see a significant advantage to it.
Not very thoroughly tested, I should add.

[PATCH] mm: unmap_single_vma take i_mmap_mutex

unmap_single_vma() take i_mmap_mutex on VM_SHARED mapping, and do the
tlb_flush_mmu() before releasing it, so that other cpus cannot modify
pages while they might be written as clean; but unmap_mapping_range()
already has i_mmap_mutex, so exclude that by a note in zap_details.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/mm.h |    1 +
 mm/memory.c        |   38 ++++++++++++++++++++++++++++++++------
 2 files changed, 33 insertions(+), 6 deletions(-)

--- 3.15-rc2/include/linux/mm.h	2014-04-13 17:24:36.120507176 -0700
+++ linux/include/linux/mm.h	2014-04-25 17:17:01.740484354 -0700
@@ -1073,6 +1073,7 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
+	bool mutex_is_held;	/* unmap_mapping_range() holds i_mmap_mutex */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
--- 3.15-rc2/mm/memory.c	2014-04-13 17:24:36.656507188 -0700
+++ linux/mm/memory.c	2014-04-25 19:01:42.564633627 -0700
@@ -1294,12 +1294,12 @@ static void unmap_page_range(struct mmu_
 	mem_cgroup_uncharge_end();
 }
 
-
 static void unmap_single_vma(struct mmu_gather *tlb,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr,
 		struct zap_details *details)
 {
+	struct mutex *mutex;
 	unsigned long start = max(vma->vm_start, start_addr);
 	unsigned long end;
 
@@ -1329,12 +1329,38 @@ static void unmap_single_vma(struct mmu_
 			 * safe to do nothing in this case.
 			 */
 			if (vma->vm_file) {
-				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
-				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
-				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+				mutex = &vma->vm_file->f_mapping->i_mmap_mutex;
+				mutex_lock(mutex);
+				__unmap_hugepage_range_final(tlb, vma, start,
+								end, NULL);
+				mutex_unlock(mutex);
+			}
+		} else {
+			/*
+			 * When unmapping a shared writable mapping, we must
+			 * take care that TLB is flushed on other cpus running
+			 * this mm, before page_mkclean() or page reclaim loses
+			 * this vma from its rmap walk: otherwise another cpu
+			 * could modify page while it's being written as clean.
+			 * unmap_mapping_range() already holds i_mmap_mutex
+			 * preventing that, we must take it for other cases.
+			 */
+			mutex = NULL;
+			if (vma->vm_file && (vma->vm_flags & VM_SHARED) &&
+			    (!details || !details->mutex_is_held)) {
+				mutex = &vma->vm_file->f_mapping->i_mmap_mutex;
+				mutex_lock(mutex);
 			}
-		} else
 			unmap_page_range(tlb, vma, start, end, details);
+			if (mutex) {
+				unsigned long old_end = tlb->end;
+				tlb->end = end;
+				tlb_flush_mmu(tlb);
+				tlb->start = end;
+				tlb->end = old_end;
+				mutex_unlock(mutex);
+			}
+		}
 	}
 }
 
@@ -3009,7 +3035,7 @@ void unmap_mapping_range(struct address_
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
-
+	details.mutex_is_held = true;
 
 	mutex_lock(&mapping->i_mmap_mutex);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
