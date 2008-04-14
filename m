Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3EEqbPR010266
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 10:52:37 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3EEqaRn237692
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 10:52:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3EEqa2b022323
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 10:52:36 -0400
Subject: Re: [RFC][PATCH 2/5] hugetlb: numafy several functions
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080411234712.GF19078@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com>
	 <20080411234712.GF19078@us.ibm.com>
Content-Type: text/plain
Date: Mon, 14 Apr 2008 09:52:50 -0500
Message-Id: <1208184770.17385.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, clameter@sgi.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2008-04-11 at 16:47 -0700, Nishanth Aravamudan wrote:
> +#define persistent_huge_pages_node(nid)	\
> +		(nr_huge_pages_node[nid] - surplus_huge_pages_node[nid])
> +static ssize_t hugetlb_write_nr_hugepages_node(struct sys_device *dev,
> +					const char *buf, size_t count)
> +{
> +	int nid = dev->id;
> +	unsigned long target;
> +	unsigned long free_on_other_nodes;
> +	unsigned long nr_huge_pages_req = simple_strtoul(buf, NULL, 10);
> +
> +	/*
> +	 * Increase the pool size on the node
> +	 * First take pages out of surplus state.  Then make up the
> +	 * remaining difference by allocating fresh huge pages.
> +	 *
> +	 * We might race with alloc_buddy_huge_page() here and be unable
> +	 * to convert a surplus huge page to a normal huge page. That is
> +	 * not critical, though, it just means the overall size of the
> +	 * pool might be one hugepage larger than it needs to be, but
> +	 * within all the constraints specified by the sysctls.
> +	 */
> +	spin_lock(&hugetlb_lock);
> +	while (surplus_huge_pages_node[nid] &&
> +		nr_huge_pages_req > persistent_huge_pages_node(nid)) {
> +		if (!adjust_pool_surplus_node(-1, nid))
> +			break;
> +	}
> +
> +	while (nr_huge_pages_req > persistent_huge_pages_node(nid)) {
> +		struct page *ret;
> +		/*
> +		 * If this allocation races such that we no longer need the
> +		 * page, free_huge_page will handle it by freeing the page
> +		 * and reducing the surplus.
> +		 */
> +		spin_unlock(&hugetlb_lock);
> +		ret = alloc_fresh_huge_page_node(nid);
> +		spin_lock(&hugetlb_lock);
> +		if (!ret)
> +			goto out;
> +
> +	}
> +
> +	if (nr_huge_pages_req >= nr_huge_pages_node[nid])
> +		goto out;
> +
> +	/*
> +	 * Decrease the pool size
> +	 * First return free pages to the buddy allocator (being careful
> +	 * to keep enough around to satisfy reservations).  Then place
> +	 * pages into surplus state as needed so the pool will shrink
> +	 * to the desired size as pages become free.
> +	 *
> +	 * By placing pages into the surplus state independent of the
> +	 * overcommit value, we are allowing the surplus pool size to
> +	 * exceed overcommit. There are few sane options here. Since
> +	 * alloc_buddy_huge_page() is checking the global counter,
> +	 * though, we'll note that we're not allowed to exceed surplus
> +	 * and won't grow the pool anywhere else. Not until one of the
> +	 * sysctls are changed, or the surplus pages go out of use.
> +	 */
> +	free_on_other_nodes = free_huge_pages - free_huge_pages_node[nid];
> +	if (free_on_other_nodes >= resv_huge_pages) {
> +		/* other nodes can satisfy reserve */
> +		target = nr_huge_pages_req;
> +	} else {
> +		/* this node needs some free to satisfy reserve */
> +		target = max((resv_huge_pages - free_on_other_nodes),
> +						nr_huge_pages_req);
> +	}
> +	try_to_free_low_node(nid, target);
> +	while (target < persistent_huge_pages_node(nid)) {
> +		struct page *page = dequeue_huge_page_node(NULL, nid);
> +		if (!page)
> +			break;
> +		update_and_free_page(nid, page);
> +	}
> +
> +	while (target < persistent_huge_pages_node(nid)) {
> +		if (!adjust_pool_surplus_node(1, nid))
> +			break;
> +	}
> +out:
> +	spin_unlock(&hugetlb_lock);
> +	return count;
> +}

Hmm, this function looks very familiar ;)  Is there any way we can
consolidate it with set_max_huge_pages()?  Perhaps the new node helpers
from the beginning of this series will help?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
