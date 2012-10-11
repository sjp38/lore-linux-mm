Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3BA6C6B0068
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:44:57 -0400 (EDT)
Date: Thu, 11 Oct 2012 19:44:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 23/33] autonuma: retain page last_nid information in
 khugepaged
Message-ID: <20121011184453.GG3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-24-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-24-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:51:05AM +0200, Andrea Arcangeli wrote:
> When pages are collapsed try to keep the last_nid information from one
> of the original pages.
> 

If two pages within a THP disagree on the node, should the collapsing be
aborted? I would expect that the code of a remote access exceeds the
gain from reduced TLB overhead.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1023e67..78b2851 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1846,6 +1846,9 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  {
>  	pte_t *_pte;
>  	bool mknuma = false;
> +#ifdef CONFIG_AUTONUMA
> +	int autonuma_last_nid = -1;
> +#endif
>  	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
>  		pte_t pteval = *_pte;
>  		struct page *src_page;
> @@ -1855,6 +1858,17 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
>  		} else {
>  			src_page = pte_page(pteval);
> +#ifdef CONFIG_AUTONUMA
> +			/* pick the first one, better than nothing */
> +			if (autonuma_last_nid < 0) {
> +				autonuma_last_nid =
> +					ACCESS_ONCE(src_page->
> +						    autonuma_last_nid);
> +				if (autonuma_last_nid >= 0)
> +					ACCESS_ONCE(page->autonuma_last_nid) =
> +						autonuma_last_nid;
> +			}
> +#endif
>  			copy_user_highpage(page, src_page, address, vma);
>  			VM_BUG_ON(page_mapcount(src_page) != 1);
>  			release_pte_page(src_page);
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
