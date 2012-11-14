Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 068966B0078
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:39:26 -0500 (EST)
Message-ID: <50A3E553.2040501@redhat.com>
Date: Wed, 14 Nov 2012 13:39:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Optimize the TLB flush of sys_mprotect() and
 change_protection() users
References: <1352883029-7885-1-git-send-email-mingo@kernel.org> <1352883029-7885-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1352883029-7885-3-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On 11/14/2012 03:50 AM, Ingo Molnar wrote:
> Reuse the NUMA code's 'modified page protections' count that
> change_protection() computes and skip the TLB flush if there's
> no changes to a range that sys_mprotect() modifies.
>
> Given that mprotect() already optimizes the same-flags case
> I expected this optimization to dominantly trigger on
> CONFIG_NUMA_BALANCING=y kernels - but even with that feature
> disabled it triggers rather often.
>
> There's two reasons for that:
>
> 1)
>
> While sys_mprotect() already optimizes the same-flag case:
>
>          if (newflags == oldflags) {
>                  *pprev = vma;
>                  return 0;
>          }
>
> and this test works in many cases, but it is too sharp in some
> others, where it differentiates between protection values that the
> underlying PTE format makes no distinction about, such as
> PROT_EXEC == PROT_READ on x86.
>
> 2)
>
> Even where the pte format over vma flag changes necessiates a
> modification of the pagetables, there might be no pagetables
> yet to modify: they might not be instantiated yet.
>
> During a regular desktop bootup this optimization hits a couple
> of hundred times. During a Java test I measured thousands of
> hits.
>
> So this optimization improves sys_mprotect() in general, not just
> CONFIG_NUMA_BALANCING=y kernels.
>
> [ We could further increase the efficiency of this optimization if
>    change_pte_range() and change_huge_pmd() was a bit smarter about
>    recognizing exact-same-value protection masks - when the hardware
>    can do that safely. This would probably further speed up mprotect(). ]
>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>   mm/mprotect.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ce0377b..6ff2d5e 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -145,7 +145,10 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
>   		pages += change_pud_range(vma, pgd, addr, next, newprot,
>   				 dirty_accountable);
>   	} while (pgd++, addr = next, addr != end);
> -	flush_tlb_range(vma, start, end);
> +
> +	/* Only flush the TLB if we actually modified any entries: */
> +	if (pages)
> +		flush_tlb_range(vma, start, end);
>
>   	return pages;
>   }

Ahh, this explains why the previous patch does what it does.

Would be nice to have that explained in the changelog for that patch,
too :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
