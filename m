Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6BB286B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:41:02 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:41:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/9] migrate: add hugepage migration code to
 migrate_pages()
Message-Id: <20130814164100.e4ba87e694e3c6563c91bf0e@linux-foundation.org>
In-Reply-To: <1376025702-14818-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1376025702-14818-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri,  9 Aug 2013 01:21:36 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> +static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> +		const nodemask_t *nodes, unsigned long flags,
> +				    void *private)
> +{
> +#ifdef CONFIG_HUGETLB_PAGE
> +	int nid;
> +	struct page *page;
> +
> +	spin_lock(&vma->vm_mm->page_table_lock);
> +	page = pte_page(huge_ptep_get((pte_t *)pmd));
> +	nid = page_to_nid(page);
> +	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> +		goto unlock;
> +	/* With MPOL_MF_MOVE, we migrate only unshared hugepage. */
> +	if (flags & (MPOL_MF_MOVE_ALL) ||
> +	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
> +		isolate_huge_page(page, private);
> +unlock:
> +	spin_unlock(&vma->vm_mm->page_table_lock);
> +#else
> +	BUG();
> +#endif
> +}

The function is poorly named.  What does it "check"?  And it does more
than checking things - at actually makes alterations!

Can we have a better name here please, and some docmentation explaining
what it does and why it does it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
