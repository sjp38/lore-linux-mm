Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D7A9A6B003B
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:35:56 -0400 (EDT)
Date: Mon, 16 Sep 2013 18:35:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 17/50] mm: Do not flush TLB during protection change if
 !pte_present && !migration_entry
Message-ID: <20130916163547.GF9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378805550-29949-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 10, 2013 at 10:31:57AM +0100, Mel Gorman wrote:
> NUMA PTE scanning is expensive both in terms of the scanning itself and
> the TLB flush if there are any updates. Currently non-present PTEs are
> accounted for as an update and incurring a TLB flush where it is only
> necessary for anonymous migration entries. This patch addresses the
> problem and should reduce TLB flushes.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/mprotect.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 1f9b54b..1e9cef0 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -109,8 +109,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				make_migration_entry_read(&entry);
>  				set_pte_at(mm, addr, pte,
>  					swp_entry_to_pte(entry));
> +
> +				pages++;
>  			}
> -			pages++;
>  		}
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();

Should we fold this into patch 7 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
