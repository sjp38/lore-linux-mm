Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E3D78D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 09:14:19 -0500 (EST)
Received: by wwb29 with SMTP id 29so5286211wwb.26
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 06:14:13 -0800 (PST)
Message-ID: <4D344EAF.1080401@petalogix.com>
Date: Mon, 17 Jan 2011 15:14:07 +0100
From: Michal Simek <michal.simek@petalogix.com>
Reply-To: michal.simek@petalogix.com
MIME-Version: 1.0
Subject: Re: [PATCH 13 of 66] export maybe_mkwrite
References: <patchbomb.1288798055@v2.random> <15324c9c30081da3a740.1288798068@v2.random>
In-Reply-To: <15324c9c30081da3a740.1288798068@v2.random>
Content-Type: multipart/mixed;
 boundary="------------050903090406060709040502"
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050903090406060709040502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> huge_memory.c needs it too when it fallbacks in copying hugepages into regular
> fragmented pages if hugepage allocation fails during COW.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

It wasn't good idea to do it. mm/memory.c is used only for system with 
MMU. System without MMU are broken.

Not sure what the right fix is but anyway I think use one ifdef make 
sense (git patch in attachment).

Regards,
Michal


diff --git a/include/linux/mm.h b/include/linux/mm.h
index 956a355..f6385fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -470,6 +470,7 @@ static inline void set_compound_order(struct page 
*page, unsigned long order)
  	page[1].lru.prev = (void *)order;
  }

+#ifdef CONFIG_MMU
  /*
   * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
   * servicing faults for write access.  In the normal case, do always want
@@ -482,6 +483,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct 
vm_area_struct *vma)
  		pte = pte_mkwrite(pte);
  	return pte;
  }
+#endif

  /*
   * Multiple processes may "see" the same page. E.g. for untouched


> ---
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -416,6 +416,19 @@ static inline void set_compound_order(st
>  }
>  
>  /*
> + * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
> + * servicing faults for write access.  In the normal case, do always want
> + * pte_mkwrite.  But get_user_pages can cause write faults for mappings
> + * that do not have writing enabled, when used by access_process_vm.
> + */
> +static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> +{
> +	if (likely(vma->vm_flags & VM_WRITE))
> +		pte = pte_mkwrite(pte);
> +	return pte;
> +}
> +
> +/*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
>   * zeroes, and text pages of executables and shared libraries have
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2048,19 +2048,6 @@ static inline int pte_unmap_same(struct 
>  	return same;
>  }
>  
> -/*
> - * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
> - * servicing faults for write access.  In the normal case, do always want
> - * pte_mkwrite.  But get_user_pages can cause write faults for mappings
> - * that do not have writing enabled, when used by access_process_vm.
> - */
> -static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> -{
> -	if (likely(vma->vm_flags & VM_WRITE))
> -		pte = pte_mkwrite(pte);
> -	return pte;
> -}
> -
>  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
>  {
>  	/*
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663

--------------050903090406060709040502
Content-Type: text/x-patch;
 name="0001-mm-System-without-MMU-do-not-need-pte_mkwrite.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-mm-System-without-MMU-do-not-need-pte_mkwrite.patch"


--------------050903090406060709040502--
