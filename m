Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 442DB6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:34:12 -0400 (EDT)
Message-ID: <4FF124A8.60509@redhat.com>
Date: Mon, 02 Jul 2012 00:33:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 29/40] autonuma: retain page last_nid information in khugepaged
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-30-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-30-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> When pages are collapsed try to keep the last_nid information from one
> of the original pages.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   mm/huge_memory.c |   11 +++++++++++
>   1 files changed, 11 insertions(+), 0 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 094f82b..ae20409 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1814,7 +1814,18 @@ static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
>   			clear_user_highpage(page, address);
>   			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
>   		} else {
> +#ifdef CONFIG_AUTONUMA
> +			int autonuma_last_nid;
> +#endif
>   			src_page = pte_page(pteval);
> +#ifdef CONFIG_AUTONUMA
> +			/* pick the last one, better than nothing */
> +			autonuma_last_nid =
> +				ACCESS_ONCE(src_page->autonuma_last_nid);
> +			if (autonuma_last_nid>= 0)
> +				ACCESS_ONCE(page->autonuma_last_nid) =
> +					autonuma_last_nid;
> +#endif
>   			copy_user_highpage(page, src_page, address, vma);
>   			VM_BUG_ON(page_mapcount(src_page) != 1);
>   			VM_BUG_ON(page_count(src_page) != 2);

Can you remember the node ID inside the loop, but do the
assignment just once after the loop has exited?

It seems excessive to make the assignment up to 512 times.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
