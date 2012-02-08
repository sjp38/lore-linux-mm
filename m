Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 333D36B13F7
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 19:12:20 -0500 (EST)
Date: Tue, 7 Feb 2012 16:12:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix UP THP spin_is_locked BUGs
Message-Id: <20120207161209.52d065e1.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1202071556460.7549@eggly.anvils>
References: <alpine.LSU.2.00.1202071556460.7549@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 7 Feb 2012 16:00:46 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Fix CONFIG_TRANSPARENT_HUGEPAGE=y CONFIG_SMP=n CONFIG_DEBUG_VM=y
> CONFIG_DEBUG_SPINLOCK=n kernel: spin_is_locked() is then always false,
> and so triggers some BUGs in Transparent HugePage codepaths.
> 
> asm-generic/bug.h mentions this problem, and provides a WARN_ON_SMP(x);
> but being too lazy to add VM_BUG_ON_SMP, BUG_ON_SMP, WARN_ON_SMP_ONCE,
> VM_WARN_ON_SMP_ONCE, just test NR_CPUS != 1 in the existing VM_BUG_ONs.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/huge_memory.c |    4 ++--
>  mm/swap.c        |    2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> --- 3.3-rc2/mm/huge_memory.c	2012-01-20 08:42:35.304020840 -0800
> +++ linux/mm/huge_memory.c	2012-02-07 15:37:18.581666053 -0800
> @@ -2083,7 +2083,7 @@ static void collect_mm_slot(struct mm_sl
>  {
>  	struct mm_struct *mm = mm_slot->mm;
>  
> -	VM_BUG_ON(!spin_is_locked(&khugepaged_mm_lock));
> +	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));

We do have assert_spin_locked(), but I couldn't see any way of using it
while observing these laziness constraints ;)

Should we patch -stable too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
