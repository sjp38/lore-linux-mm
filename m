Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 4206B6B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 07:46:29 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: fix NULL ptr deref when walking hugepages
Date: Wed, 23 May 2012 07:46:21 -0400
Message-Id: <1337773581-14372-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1337757643-18302-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2012 at 09:20:43AM +0200, Sasha Levin wrote:
> A missing vlidation of the value returned by find_vma() could cause a NULL ptr
> dereference when walking the pagetable.
> 
> This is triggerable from usermode by a simple user by trying to read a
> page info out of /proc/pid/pagemap which doesn't exist.
> 
> Introduced by commit 025c5b24 ("thp: optimize away unnecessary page table
> locking").
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  fs/proc/task_mmu.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 3e564f0..885830b 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -820,7 +820,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  
>  	/* find the first VMA at or above 'addr' */
>  	vma = find_vma(walk->mm, addr);
> -	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> +	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
>  		for (; addr != end; addr += PAGE_SIZE) {
>  			unsigned long offset;
>  
> -- 

Thank you. I have no objection.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
