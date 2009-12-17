Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E12466B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 03:01:59 -0500 (EST)
Subject: Re: Question about pte_offset_map_lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091217114630.d353907a.minchan.kim@barrios-desktop>
References: <20091217114630.d353907a.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 09:01:19 +0100
Message-ID: <1261036879.27920.11.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 11:46 +0900, Minchan Kim wrote:
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

I think currently mmap_sem serializes all that. Cases like faults that
take the mmap_sem for reading sometimes need the pte validation to check
if they didn't race with another fault etc.

But since mmap_sem is held for reading the vma can't dissapear and the
memory map is stable in the sense that the page tables will be present
(or can be instantiated when needed), since munmap removes the
pagetables for vmas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
