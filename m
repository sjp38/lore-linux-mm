Date: Wed, 13 Aug 2008 18:37:11 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH for -mm 3/5] kill unnecessary locked_vm adjustment
In-Reply-To: <1218570910.6360.120.camel@lts-notebook>
References: <20080811160542.945F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1218570910.6360.120.camel@lts-notebook>
Message-Id: <20080813174122.E779.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> > Now, __mlock_vma_pages_range never return positive value.
> > So, locked_vm adjustment code is unnecessary.
> 
> True, __mlock_vma_pages_range() does not return a positive value.  [It
> didn't before this patch series, right?]  

True.


> However, you are now counting
> mlocked hugetlb pages and user mapped kernel pages against locked_vm--at
> least in the mmap(MAP_LOCKED) path--even tho' we don't actually mlock().
> Note that mlock[all]() will still avoid counting these pages in
> mlock_fixup(), as I think it should.
> 
> Huge shm pages are already counted against user->locked_shm.  This patch
> counts them against mm->locked_vm, as well, if one mlock()s them.  But,
> since locked_vm and locked_shm are compared to the memlock rlimit
> independently, so we won't be double counting the huge pages against
> either limit.  However,  mlock()ed [not SHMLOCKed] hugetlb pages will
> now be counted against locked_vm limit and will reduce the amount of
> non-shm memory that the task can lock [maybe not such a bad thing?].
> Also, mlock()ed hugetlb pages will be included in the /proc/<pid>/status
> "VmLck" element, even tho' they're not really mlocked and they don't
> show up in the /proc/meminfo "Mlocked" count.
> 
> Similarly, mlock()ing a vm range backed by kernel pages--e.g.,
> VM_RESERVED|VM_DONTEXPAND vmas--will show up in the VmLck status
> element, but won't actually be mlocked nor counted in Mlocked meminfo
> field.  They will be counted against the task's locked vm limit.
> 
> So, I don't know whether to Ack or Nack this.  I guess it's no further
> from reality than the current code.  But, I don't think you need this
> one.  The code already differentiates between negative values as error
> codes and non-negative values as an adjustment to locked_vm, so you
> should be able to meet the standards mandated error returns without this
> patch.  
> 
> Still thinking about this...

I think...

In general, nobody want regression.
and locked_vm exist from long time ago.

So, We shouldn't change locked_vm behavior although this have
very strange behavior.

in linus-tree locked_vm indicate count of amount of VM_LOCKED vma range,
not populated pages nor number of physical pages of locked vma.

Yes, current linus-tree locked_vm code have some strange behavior.
but if we want to change it, we should split out from split-lru patch, IMHO.

Then, I hope to remove locked_vm adjustment code.
Am I missing point?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
