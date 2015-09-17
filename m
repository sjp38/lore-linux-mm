Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id C65AF6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 15:31:56 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so14749989lbb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 12:31:56 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id ck10si3238606lbc.145.2015.09.17.12.31.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 12:31:55 -0700 (PDT)
Received: by lanb10 with SMTP id b10so17592856lan.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 12:31:55 -0700 (PDT)
Date: Thu, 17 Sep 2015 22:31:52 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150917193152.GJ2000@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
 <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Thu, Sep 17, 2015 at 10:58:59AM +0200, Martin Schwidefsky wrote:
> Fixes a regression introduced with commit 179ef71cbc085252
> "mm: save soft-dirty bits on swapped pages"
> 
> The maybe_same_pte() function is used to match a swap pte independent
> of the swap software dirty bit set with pte_swp_mksoft_dirty().
> 
> For CONFIG_HAVE_ARCH_SOFT_DIRTY=y but CONFIG_MEM_SOFT_DIRTY=n the
> software dirty bit may be set but maybe_same_pte() will not recognize
> a software dirty swap pte. Due to this a 'swapoff -a' will hang.
> 
> The straightforward solution is to replace CONFIG_MEM_SOFT_DIRTY
> with HAVE_ARCH_SOFT_DIRTY in maybe_same_pte().
> 
> Cc: linux-mm@kvack.org
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  mm/swapfile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 5887731..bf7da58 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1113,7 +1113,7 @@ unsigned int count_swap_pages(int type, int free)
>  
>  static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
>  {
> -#ifdef CONFIG_MEM_SOFT_DIRTY
> +#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  	/*
>  	 * When pte keeps soft dirty bit the pte generated
>  	 * from swap entry does not has it, still it's same

You know, I seem to miss how this might help. If CONFIG_MEM_SOFT_DIRTY=n
then all related helpers are nop'ed.

In particular in the commit you mentioned

+static inline int maybe_same_pte(pte_t pte, pte_t swp_pte)
+{
+#ifdef CONFIG_MEM_SOFT_DIRTY
+       /*
+        * When pte keeps soft dirty bit the pte generated
+        * from swap entry does not has it, still it's same
+        * pte from logical point of view.
+        */
+       pte_t swp_pte_dirty = pte_swp_mksoft_dirty(swp_pte);
+       return pte_same(pte, swp_pte) || pte_same(pte, swp_pte_dirty);
+#else
+       return pte_same(pte, swp_pte);
+#endif
+}
+
...
@@ -892,7 +907,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
        }
 
        pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-       if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
+       if (unlikely(!maybe_same_pte(*pte, swp_entry_to_pte(entry)))) {
                mem_cgroup_cancel_charge_swapin(memcg);
                ret = 0;
                goto out;
@@ -947,7 +962,7 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
                 * swapoff spends a _lot_ of time in this loop!
                 * Test inline before going to call unuse_pte.
                 */
-               if (unlikely(pte_same(*pte, swp_pte))) {
+               if (unlikely(maybe_same_pte(*pte, swp_pte))) {
                        pte_unmap(pte);
                        ret = unuse_pte(vma, pmd, addr, entry, page);
                        if (ret)

Thus when CONFIG_MEM_SOFT_DIRTY = n, the unuse_pte will be the same
as it were without the patch, calling pte_same.

Now to the bit itself

#ifdef CONFIG_MEM_SOFT_DIRTY
#define _PAGE_SWP_SOFT_DIRTY_PAGE_PSE
#else
#define _PAGE_SWP_SOFT_DIRTY_PAGE_PSE(_AT(pteval_t, 0))
#endif

it's 0 if CONFIG_MEM_SOFT_DIRTY=n, so any setup of this
bit will simply become nop

#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
{
	return pte_set_flags(pte, _PAGE_SWP_SOFT_DIRTY);
}

static inline int pte_swp_soft_dirty(pte_t pte)
{
	return pte_flags(pte) & _PAGE_SWP_SOFT_DIRTY;
}

static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
{
	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
}
#endif

So I fear I'm lost where this "set" of the bit comes from
when CONFIG_MEM_SOFT_DIRTY=n.

Martin, could you please elaborate? Seems I'm missing
something obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
