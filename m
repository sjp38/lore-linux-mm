Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12CC46B0159
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 06:16:32 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o9UAGOPq027834
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 03:16:29 -0700
Received: from vws4 (vws4.prod.google.com [10.241.21.132])
	by wpaz21.hot.corp.google.com with ESMTP id o9UAFh6s005335
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 03:16:23 -0700
Received: by vws4 with SMTP id 4so1389735vws.37
        for <linux-mm@kvack.org>; Sat, 30 Oct 2010 03:16:23 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 30 Oct 2010 03:16:23 -0700
Message-ID: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
Subject: RFC: reviving mlock isolation dead code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

The following code at the bottom of try_to_unmap_one appears to be dead:

 out_mlock:
        pte_unmap_unlock(pte, ptl);

        /*
         * We need mmap_sem locking, Otherwise VM_LOCKED check makes
         * unstable result and race. Plus, We can't wait here because
         * we now hold anon_vma->lock or mapping->i_mmap_lock.
         * if trylock failed, the page remain in evictable lru and later
         * vmscan could retry to move the page to unevictable lru if the
         * page is actually mlocked.
         */
        if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
                if (vma->vm_flags & VM_LOCKED) {
                        mlock_vma_page(page);
                        ret = SWAP_MLOCK;
                }
                up_read(&vma->vm_mm->mmap_sem);
        }
        return ret;

The mmap_sem read acquire always fais here, because the mmap_sem is
held exclusively by __mlock_vma_pages_range(). By the time
__mlock_vma_pages_range() terminates (so that its caller can release
mmap_sem), all mlocked pages have been isolated already so that LRU
eviction algorithms should not encounter them (and if they do, the
pages should at least be already marked as mlocked).


I would like to resurect this, as I am seeing problems during a large
mlock (many GB). The mlock takes a long time to complete
(__mlock_vma_pages_range() is loading pages from disk), there is
memory pressure as some pages have to be evicted to make room for the
large mlock, and the LRU algorithm performs badly with the high amount
of pages still on LRU list - PageMlocked has not been set yet - while
their VMA is already VM_LOCKED.

One approach I am considering would be to modify
__mlock_vma_pages_range() and it call sites so the mmap sem is only
read-owned while __mlock_vma_pages_range() runs. The mlock handling
code in try_to_unmap_one() would then be able to acquire the
mmap_sem() and help, as it is designed to do.

Please comment if you have any concerns about this.

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
