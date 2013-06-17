Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CF1546B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 04:20:42 -0400 (EDT)
Date: Mon, 17 Jun 2013 10:20:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 7/7] mm/pgtable: Don't accumulate addr during pgd
 prepopulate pmd
Message-ID: <20130617082040.GC19194@dhcp22.suse.cz>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371345290-19588-7-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371345290-19588-7-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 16-06-13 09:14:50, Wanpeng Li wrote:
> The old codes accumulate addr to get right pmd, however,
> currently pmds are preallocated and transfered as a parameter,
> there is unnecessary to accumulate addr variable any more, this
> patch remove it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  arch/x86/mm/pgtable.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 17fda6a..cb787da 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -240,7 +240,6 @@ static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
>  static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
>  {
>  	pud_t *pud;
> -	unsigned long addr;
>  	int i;
>  
>  	if (PREALLOCATED_PMDS == 0) /* Work around gcc-3.4.x bug */
> @@ -248,8 +247,7 @@ static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
>  
>  	pud = pud_offset(pgd, 0);
>  
> - 	for (addr = i = 0; i < PREALLOCATED_PMDS;
> -	     i++, pud++, addr += PUD_SIZE) {
> +	for (i = 0; i < PREALLOCATED_PMDS; i++, pud++) {
>  		pmd_t *pmd = pmds[i];
>  
>  		if (i >= KERNEL_PGD_BOUNDARY)
> -- 
> 1.8.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
