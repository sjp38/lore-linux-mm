Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D86536B020A
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 04:32:25 -0400 (EDT)
Received: by pwi10 with SMTP id 10so4902258pwi.14
        for <linux-mm@kvack.org>; Thu, 29 Apr 2010 01:32:24 -0700 (PDT)
Subject: Re: [RFC PATCH -v3] take all anon_vma locks in anon_vma_lock
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100429081521.GM15815@csn.ul.ie>
References: <1272403852-10479-3-git-send-email-mel@csn.ul.ie>
	 <20100427231007.GA510@random.random> <20100428091555.GB15815@csn.ul.ie>
	 <20100428153525.GR510@random.random> <20100428155558.GI15815@csn.ul.ie>
	 <20100428162305.GX510@random.random>
	 <20100428134719.32e8011b@annuminas.surriel.com>
	 <20100428142510.09984e15@annuminas.surriel.com>
	 <20100428161711.5a815fa8@annuminas.surriel.com>
	 <20100428165734.6541bab3@annuminas.surriel.com>
	 <20100429081521.GM15815@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 29 Apr 2010 17:32:17 +0900
Message-ID: <1272529937.2100.219.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-04-29 at 09:15 +0100, Mel Gorman wrote:
> On Wed, Apr 28, 2010 at 04:57:34PM -0400, Rik van Riel wrote:
> > Take all the locks for all the anon_vmas in anon_vma_lock, this properly
> > excludes migration and the transparent hugepage code from VMA changes done
> > by mmap/munmap/mprotect/expand_stack/etc...
> > 
> 
> In vma_adjust(), what prevents something like rmap_map seeing partial
> updates while the following lines execute?
> 
>         vma->vm_start = start;
>         vma->vm_end = end;
>         vma->vm_pgoff = pgoff;
>         if (adjust_next) {
>                 next->vm_start += adjust_next << PAGE_SHIFT;
>                 next->vm_pgoff += adjust_next;
>         }
> They would appear to happen outside the lock, even with this patch. The
> update happened within the lock in 2.6.33.
> 
> 
> 
This part does it. :)

----
@@ -578,6 +578,7 @@ again:                      remove_next = 1 + (end >
next->vm_end);
                }   
        }   
 
+       anon_vma_lock(vma, &mm->mmap_sem);
        if (root) {
                flush_dcache_mmap_lock(mapping);
                vma_prio_tree_remove(vma, root);
@@ -599,6 +600,7 @@ again:                      remove_next = 1 + (end >
next->vm_end);
                vma_prio_tree_insert(vma, root);
                flush_dcache_mmap_unlock(mapping);
        }   
+       anon_vma_unlock(vma);
---


But we still need patch about shift_arg_pages.



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
