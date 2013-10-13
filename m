Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0983F6B0031
	for <linux-mm@kvack.org>; Sun, 13 Oct 2013 17:12:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so6730740pad.37
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 14:12:49 -0700 (PDT)
Received: by mail-oa0-f46.google.com with SMTP id o1so501161oag.19
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 14:12:47 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Oct 2013 01:12:47 +0400
Message-ID: <CAMo8BfKqWPbDCMwCoH6BO6uXyYwr0Z1=AaMJDRLQt66FLb7LAg@mail.gmail.com>
Subject: CONFIG_SLUB/USE_SPLIT_PTLOCKS compatibility
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hello,

I'm reliably getting kernel crash on xtensa when CONFIG_SLUB
is selected and USE_SPLIT_PTLOCKS appears to be true (SMP=y,
NR_CPUS=4, DEBUG_SPINLOCK=n, DEBUG_LOCK_ALLOC=n).
This happens because spinlock_t ptl and struct page *first_page overlap
in the struct page. The following call chain makes allocation of order
3 and initializes first_page pointer in its 7 tail pages:

 do_page_fault
  handle_mm_fault
   __pte_alloc
    kmem_cache_alloc
     __slab_alloc
      new_slab
       __alloc_pages_nodemask
        get_page_from_freelist
         prep_compound_page

Later pte_offset_map_lock is called with one of these tail pages
overwriting its first_page pointer:

 do_fork
  copy_process
   dup_mm
    copy_page_range
     copy_pte_range
      pte_alloc_map_lock
       pte_offset_map_lock

Finally kmem_cache_free is called for that tail page, which calls
slab_free(s, virt_to_head_page(x),... but virt_to_head_page here
returns NULL, because the page's first_page pointer was overwritten
earlier:

exit_mmap
 free_pgtables
  free_pgd_range
   free_pud_range
    free_pmd_range
     free_pte_range
      pte_free
       kmem_cache_free
        slab_free
         __slab_free

__slab_free touches NULL struct page, that's it.

Changing allocator to SLAB or enabling DEBUG_SPINLOCK
fixes that crash.

My question is, is CONFIG_SLUB supposed to work with
USE_SPLIT_PTLOCKS (and if yes what's wrong in my case)?

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
