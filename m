Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A6626B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 05:28:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n14ASLXl001496
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 4 Feb 2009 19:28:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DAAE45DE63
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 19:28:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC33A45DE5D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 19:28:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6EDF1DB8042
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 19:28:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C8E1DB8040
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 19:28:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
In-Reply-To: <20090204045745.GC6212@barrios-desktop>
References: <20090204115047.ECB5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090204045745.GC6212@barrios-desktop>
Message-Id: <20090204171639.ECCE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  4 Feb 2009 19:28:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> With '29-rc3-git5', I found,
> 
> static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
> {
>   int mlocked = 0; 
> 
>   if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
>     if (vma->vm_flags & VM_LOCKED) {
>       mlock_vma_page(page);
>       mlocked++;  /* really mlocked the page */
>     }    
>     up_read(&vma->vm_mm->mmap_sem);
>   }
>   return mlocked;
> }
> 
> It still try to downgrade mmap_sem.
> Do I miss something ?

sorry, I misunderstood your "downgrade". I said linus removed downgrade_write(&mma_sem).

Now, I understand this issue perfectly. I agree you and lee-san's fix is correct.
	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


and, I think current try_to_mlock_page() is correct. no need change.
Why?

1. Generally, mmap_sem holding is necessary when vma->vm_flags accessed.
   that's vma's basic rule.
2. However, try_to_unmap_one() doesn't held mamp_sem. but that's ok.
   it often get incorrect result. but caller consider incorrect value safe.
3. try_to_mlock_page() need mmap_sem because it obey rule (1).
4. in try_to_mlock_page(), if down_read_trylock() is failure, 
   we can't move the page to unevictable list. but that's ok.
   the page in evictable list is periodically try to reclaim. and
   be called try_to_unmap().
   try_to_unmap() (and its caller) also move the unevictable page to unevictable list.
   Therefore, in long term view, the page leak is not happend.

this explanation is enough?

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
