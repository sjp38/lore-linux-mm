Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B6286B0082
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 04:54:36 -0500 (EST)
Date: Thu, 17 Dec 2009 09:54:10 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Question about pte_offset_map_lock
In-Reply-To: <20091217114630.d353907a.minchan.kim@barrios-desktop>
Message-ID: <Pine.LNX.4.64.0912170937450.3176@sister.anvils>
References: <20091217114630.d353907a.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009, Minchan Kim wrote:
> It may be a dumb question.
> 
> As I read the code of pte_lock, I have a question. 
> Now, there is pte_offset_map_lock following as. 
> 
> #define pte_offset_map_lock(mm, pmd, address, ptlp)     \
> ({                                                      \
>         spinlock_t *__ptl = pte_lockptr(mm, pmd);       \
>         pte_t *__pte = pte_offset_map(pmd, address);    \
>         *(ptlp) = __ptl;                                \
>         spin_lock(__ptl);                               \
>         __pte;                                          \
> })
> 
> Why do we grab the lock after getting __pte?
> Is it possible that __pte might be changed before we grab the spin_lock?
> 
> Some codes in mm checks original pte by pte_same. 
> There are not-checked cases in proc. As looking over the cases,
> It seems no problem. But in future, new user of pte_offset_map_lock 
> could mistake with that?

I think you wouldn't be asking the question if we'd called it __ptep.

It's a (perhaps kmap_atomic) pointer into the page table: the virtual
address of a page table entry, not the page table entry itself.

You're right that the entry itself could change before we get the lock,
and pte_same() is what we use to check that an entry is still what we
were expecting; but the containing page table will remain the same,
until munmap() or exit_mmap() at least.

(For completeness, I ought to add that the entry might even change
while we have the lock: accessed and dirty bits could get set by a
racing thread in userspace.  There are places where we have to be
very careful about not missing a dirty bit, but missing an accessed
bit on rare occasions doesn't matter.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
