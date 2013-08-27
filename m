Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6FEEB6B0044
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 04:37:21 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id es20so3185437lab.24
        for <linux-mm@kvack.org>; Tue, 27 Aug 2013 01:37:19 -0700 (PDT)
Date: Tue, 27 Aug 2013 12:37:18 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130827083718.GC7416@moon>
References: <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
 <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
 <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
 <20130826222833.GA24320@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826222833.GA24320@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Aug 26, 2013 at 06:28:33PM -0400, Dave Jones wrote:
>  > 
>  > I've not tried matching up bits with Dave's reports, and just going
>  > into a meeting now, but this patch looks worth a try: probably Cyrill
>  > can improve it meanwhile to what he actually wants there (I'm
>  > surprised anything special is needed for just moving a pte).
>  > 
>  > Hugh
>  > 
>  > --- 3.11-rc7/mm/mremap.c	2013-07-14 17:10:16.640003652 -0700
>  > +++ linux/mm/mremap.c	2013-08-26 14:46:14.460027627 -0700
>  > @@ -126,7 +126,7 @@ static void move_ptes(struct vm_area_str
>  >  			continue;
>  >  		pte = ptep_get_and_clear(mm, old_addr, old_pte);
>  >  		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
>  > -		set_pte_at(mm, new_addr, new_pte, pte_mksoft_dirty(pte));
>  > +		set_pte_at(mm, new_addr, new_pte, pte);
>  >  	}
> 
> I'll give this a shot once I'm done with the bisect.

I managed to trigger the issue as well. The patch below fixes it.
Dave, could you please give it a shot once time permit?

Pavel, I kept 'make it dirty on move' logic, but i'm somehow doubt
in it, won't plain pte copying (as in Hugh's patch) work of us?
---
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] mm: move_ptes -- Set soft dirty bit depending on pte type

Dave reported corrupted swap entries

 | [ 4588.541886] swap_free: Unused swap offset entry 00002d15
 | [ 4588.541952] BUG: Bad page map in process trinity-kid12  pte:005a2a80 pmd:22c01f067

and Hugh pointed that in move_ptes _PAGE_SOFT_DIRTY bit
set regardless the type of entry pte consists of. The
trick here is that -- when we carry soft dirty status
in swap entries we are to use _PAGE_SWP_SOFT_DIRTY instead,
because this is the only place in pte which can be used
for own needs without intersecting with bits owned by
swap entry type/offset.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mremap.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

Index: linux-2.6.git/mm/mremap.c
===================================================================
--- linux-2.6.git.orig/mm/mremap.c
+++ linux-2.6.git/mm/mremap.c
@@ -15,6 +15,7 @@
 #include <linux/swap.h>
 #include <linux/capability.h>
 #include <linux/fs.h>
+#include <linux/swapops.h>
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
@@ -69,6 +70,23 @@ static pmd_t *alloc_new_pmd(struct mm_st
 	return pmd;
 }
 
+static pte_t move_soft_dirty_pte(pte_t pte)
+{
+	/*
+	 * Set soft dirty bit so we can notice
+	 * in userspace the ptes were moved.
+	 */
+#ifdef CONFIG_MEM_SOFT_DIRTY
+	if (pte_present(pte))
+		pte = pte_mksoft_dirty(pte);
+	else if (is_swap_pte(pte))
+		pte = pte_swp_mksoft_dirty(pte);
+	else if (pte_file(pte))
+		pte = pte_file_mksoft_dirty(pte);
+#endif
+	return pte;
+}
+
 static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		unsigned long old_addr, unsigned long old_end,
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
@@ -126,7 +144,8 @@ static void move_ptes(struct vm_area_str
 			continue;
 		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
-		set_pte_at(mm, new_addr, new_pte, pte_mksoft_dirty(pte));
+		pte = move_soft_dirty_pte(pte);
+		set_pte_at(mm, new_addr, new_pte, pte);
 	}
 
 	arch_leave_lazy_mmu_mode();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
