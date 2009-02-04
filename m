Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 50C516B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 09:07:00 -0500 (EST)
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090204171639.ECCE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090204115047.ECB5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090204045745.GC6212@barrios-desktop>
	 <20090204171639.ECCE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 04 Feb 2009 09:07:16 -0500
Message-Id: <1233756436.14819.13.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-04 at 19:28 +0900, KOSAKI Motohiro wrote:
> > With '29-rc3-git5', I found,
> > 
> > static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
> > {
> >   int mlocked = 0; 
> > 
> >   if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> >     if (vma->vm_flags & VM_LOCKED) {
> >       mlock_vma_page(page);
> >       mlocked++;  /* really mlocked the page */
> >     }    
> >     up_read(&vma->vm_mm->mmap_sem);
> >   }
> >   return mlocked;
> > }
> > 
> > It still try to downgrade mmap_sem.
> > Do I miss something ?
> 
> sorry, I misunderstood your "downgrade". I said linus removed downgrade_write(&mma_sem).
> 
> Now, I understand this issue perfectly. I agree you and lee-san's fix is correct.
> 	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> and, I think current try_to_mlock_page() is correct. no need change.
> Why?
> 
> 1. Generally, mmap_sem holding is necessary when vma->vm_flags accessed.
>    that's vma's basic rule.
> 2. However, try_to_unmap_one() doesn't held mamp_sem. but that's ok.
>    it often get incorrect result. but caller consider incorrect value safe.
> 3. try_to_mlock_page() need mmap_sem because it obey rule (1).
> 4. in try_to_mlock_page(), if down_read_trylock() is failure, 
>    we can't move the page to unevictable list. but that's ok.
>    the page in evictable list is periodically try to reclaim. and
>    be called try_to_unmap().
>    try_to_unmap() (and its caller) also move the unevictable page to unevictable list.
>    Therefore, in long term view, the page leak is not happend.
> 

Also worth noting that down_read_trylock() does not "downgrade" the
semaphore.  It only tries to acquire it in read mode.  

As Kosaki-san says, try_to_unmap() doesn't normally hold the mmap_sem.
It needs to acquire it here to stabilize the vma [vm_flags] while
mlocking the pages.  This is the place where a page mapped in a
VM_LOCKED vma that vmscan found on the normal lru list--e.g., because we
couldn't isolate them in mlock_vma_page()--get marked mlocked, if not
already marked. mlock_vma_page() is a no-op if page is already mlocked.

If we successsfully acquire the mmap_sem and the vma is still VM_LOCKED,
we know that the page is mlocked and try_to_unmap() will return
SWAP_MLOCK.  This allows vmscan [shrink_page_list()] to move the page to
the unevictable list and not need to bother with it in subsequent scans
until it becomes munlocked.

Lee 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
