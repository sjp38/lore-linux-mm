Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EA6986B008A
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 08:13:59 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so2489861pde.7
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 05:13:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131212180057.GD134240@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com>
 <20131212180057.GD134240@sgi.com>
Subject: RE: [RFC PATCH 3/3] Change THP behavior
Content-Transfer-Encoding: 7bit
Message-Id: <20131213131349.D8DE9E0090@blue.fi.intel.com>
Date: Fri, 13 Dec 2013 15:13:49 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.orglinux-mm@kvack.org

Alex Thorlton wrote:
> +	/*
> +	 * now that we've done the accounting work, we check to see if
> +	 * we've exceeded our threshold
> +	 */
> +	if (temp_thp->ref_count >= mm->thp_threshold) {
> +		pmd_t pmd_entry;
> +		pgtable_t pgtable;
> +
> +		/*
> +		 * we'll do all of the following beneath the big ptl for now
> +		 * this will need to be modified to work with the split ptl
> +		 */
> +		spin_lock(&mm->page_table_lock);
> +
> +		/*
> +		 * once we get past the lock we have to make sure that somebody
> +		 * else hasn't already turned this guy into a THP, if they have,
> +		 * then the page we need is already faulted in as part of the THP
> +		 * they created
> +		 */
> +		if (PageTransHuge(temp_thp->page)) {
> +			spin_unlock(&mm->page_table_lock);
> +			return 0;
> +		}
> +
> +		pgtable = pte_alloc_one(mm, haddr);
> +		if (unlikely(!pgtable)) {
> +			spin_unlock(&mm->page_table_lock);
> +			return VM_FAULT_OOM;
> +		}
> +
> +		/* might wanna move this? */
> +		__SetPageUptodate(temp_thp->page);
> +
> +		/* turn the pages into one compound page */
> +		make_compound_page(temp_thp->page, HPAGE_PMD_ORDER);
> +
> +		/* set up the pmd */
> +		pmd_entry = mk_huge_pmd(temp_thp->page, vma->vm_page_prot);
> +		pmd_entry = maybe_pmd_mkwrite(pmd_mkdirty(pmd_entry), vma);
> +
> +		/* remap the new page since we cleared the mappings */
> +		page_add_anon_rmap(temp_thp->page, vma, address);
> +
> +		/* deposit the thp */
> +		pgtable_trans_huge_deposit(mm, pmd, pgtable);
> +
> +		set_pmd_at(mm, haddr, pmd, pmd_entry);
> +		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR - mm->thp_threshold + 1);
> +		/* mm->nr_ptes++; */
> +
> +		/* delete the reference to this compound page from our list */
> +		spin_lock(&mm->thp_list_lock);
> +		list_del(&temp_thp->list);
> +		spin_unlock(&mm->thp_list_lock);
> +
> +		spin_unlock(&mm->page_table_lock);
> +		return 0;

Hm. I think this part is not correct: you collapse temp thp page
into real one only for current procees. What will happen if a process with
temp thp pages was forked?

And I don't think this problem is an easy one. khugepaged can't collapse
pages with page->_count != 1 for the same reason: to make it properly you
need to take mmap_sem for all processes and collapse all pages at once.
And if a page is pinned, we also can't collapse.

Sorry, I don't think the whole idea has much potential. :(

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
