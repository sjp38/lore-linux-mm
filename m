Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E83D96B0037
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 10:12:27 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so8680550pbc.4
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 07:12:27 -0700 (PDT)
Date: Tue, 08 Oct 2013 10:11:40 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1381241500-bfdgpu61-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131008090236.951114091@gmail.com>
References: <20131008090019.527108154@gmail.com>
 <20131008090236.951114091@gmail.com>
Subject: Re: [patch 1/3] [PATCH] mm: migration -- Do not loose soft dirty bit
 if page is in migration state
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Andy Lutomirski <luto@amacapital.net>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Oct 08, 2013 at 01:00:20PM +0400, Cyrill Gorcunov wrote:
> If page migration is turne on in the config and the page is migrating,
> we may loose soft dirty bit. If fork and mprotect if called on migrating
> pages (once migration is complete) pages do not obtain soft dirty bit
> in correspond pte entries. Fix it adding appropriate test on swap
> entries.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> Cc: Marcelo Tosatti <mtosatti@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/memory.c   |    2 ++
>  mm/migrate.c  |    2 ++
>  mm/mprotect.c |    7 +++++--
>  3 files changed, 9 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.git/mm/memory.c
> ===================================================================
> --- linux-2.6.git.orig/mm/memory.c
> +++ linux-2.6.git/mm/memory.c
> @@ -837,6 +837,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  					 */
>  					make_migration_entry_read(&entry);
>  					pte = swp_entry_to_pte(entry);
> +					if (pte_swp_soft_dirty(*src_pte))
> +						pte = pte_swp_mksoft_dirty(pte);
>  					set_pte_at(src_mm, addr, src_pte, pte);
>  				}
>  			}

When we convert pte to swap_entry, we convert soft-dirty bit in
pte_to_swp_entry(). So I think that it's better to convert it back
in swp_entry_to_pte() when we do swap_entry-to-pte conversion.

Thanks,
Naoya Horiguchi

> Index: linux-2.6.git/mm/migrate.c
> ===================================================================
> --- linux-2.6.git.orig/mm/migrate.c
> +++ linux-2.6.git/mm/migrate.c
> @@ -161,6 +161,8 @@ static int remove_migration_pte(struct p
>  
>  	get_page(new);
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
> +	if (pte_swp_soft_dirty(*ptep))
> +		pte = pte_mksoft_dirty(pte);
>  	if (is_write_migration_entry(entry))
>  		pte = pte_mkwrite(pte);
>  #ifdef CONFIG_HUGETLB_PAGE
> Index: linux-2.6.git/mm/mprotect.c
> ===================================================================
> --- linux-2.6.git.orig/mm/mprotect.c
> +++ linux-2.6.git/mm/mprotect.c
> @@ -94,13 +94,16 @@ static unsigned long change_pte_range(st
>  			swp_entry_t entry = pte_to_swp_entry(oldpte);
>  
>  			if (is_write_migration_entry(entry)) {
> +				pte_t newpte;
>  				/*
>  				 * A protection check is difficult so
>  				 * just be safe and disable write
>  				 */
>  				make_migration_entry_read(&entry);
> -				set_pte_at(mm, addr, pte,
> -					swp_entry_to_pte(entry));
> +				newpte = swp_entry_to_pte(entry);
> +				if (pte_swp_soft_dirty(oldpte))
> +					newpte = pte_swp_mksoft_dirty(newpte);
> +				set_pte_at(mm, addr, pte, newpte);
>  			}
>  			pages++;
>  		}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
