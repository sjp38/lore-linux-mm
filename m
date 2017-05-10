Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF27831F8
	for <linux-mm@kvack.org>; Wed, 10 May 2017 02:06:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17so16744304pfd.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 23:06:01 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id i61si2015173plb.191.2017.05.09.23.05.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 23:06:00 -0700 (PDT)
Message-ID: <5912AB58.7020103@huawei.com>
Date: Wed, 10 May 2017 13:55:36 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge
 page fails (fwd)
References: <alpine.DEB.2.20.1705092341330.3502@hadrien>
In-Reply-To: <alpine.DEB.2.20.1705092341330.3502@hadrien>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, kbuild-all@01.org

On 2017/5/9 23:43, Julia Lawall wrote:
> Hello,
>
> I don't know if there is a bug here, but it could e worth checking on.  If
> the loop on line 1481 is executed, page will not be NULL at the out label
> on line 1560.  Instead it will have a dummy value.  Perhaps the value of
> result keeps the if at the out label from being taken.
>
> julia
  Hi, Julia
 
   it has no memory leak.  so my initial thought is not correct. but I do not know you mean.
   The page is local variable.  it aybe a  dummy value. but it should not cause any issue.
   is it right? or I miss something.

  Thanks
  zhongjiang
> ---------- Forwarded message ----------
> Date: Tue, 9 May 2017 23:27:43 +0800
> From: kbuild test robot <fengguang.wu@intel.com>
> To: kbuild@01.org
> Cc: Julia Lawall <julia.lawall@lip6.fr>
> Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge page
>     fails
>
> Hi zhong,
>
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.11 next-20170509]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/zhongjiang/mm-fix-the-memory-leak-after-collapsing-the-huge-page-fails/20170509-193011
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> :::::: branch date: 4 hours ago
> :::::: commit date: 4 hours ago
>
>>> mm/khugepaged.c:1560:5-9: ERROR: invalid reference to the index variable of the iterator on line 1481
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout a5318ea654d5b764d6e06c6cfbfc21e44ce56e2b
> vim +1560 mm/khugepaged.c
>
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1475  		struct zone *zone = page_zone(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1476
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1477  		/*
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1478  		 * Replacing old pages with new one has succeed, now we need to
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1479  		 * copy the content and free old pages.
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1480  		 */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26 @1481  		list_for_each_entry_safe(page, tmp, &pagelist, lru) {
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1482  			copy_highpage(new_page + (page->index % HPAGE_PMD_NR),
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1483  					page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1484  			list_del(&page->lru);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1485  			unlock_page(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1486  			page_ref_unfreeze(page, 1);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1487  			page->mapping = NULL;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1488  			ClearPageActive(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1489  			ClearPageUnevictable(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1490  			put_page(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1491  		}
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1492
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1493  		local_irq_save(flags);
> 11fb9989 Mel Gorman         2016-07-28  1494  		__inc_node_page_state(new_page, NR_SHMEM_THPS);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1495  		if (nr_none) {
> 11fb9989 Mel Gorman         2016-07-28  1496  			__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
> 11fb9989 Mel Gorman         2016-07-28  1497  			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1498  		}
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1499  		local_irq_restore(flags);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1500
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1501  		/*
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1502  		 * Remove pte page tables, so we can re-faulti
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1503  		 * the page as huge.
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1504  		 */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1505  		retract_page_tables(mapping, start);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1506
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1507  		/* Everything is ready, let's unfreeze the new_page */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1508  		set_page_dirty(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1509  		SetPageUptodate(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1510  		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1511  		mem_cgroup_commit_charge(new_page, memcg, false, true);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1512  		lru_cache_add_anon(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1513  		unlock_page(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1514
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1515  		*hpage = NULL;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1516  	} else {
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1517  		/* Something went wrong: rollback changes to the radix-tree */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1518  		shmem_uncharge(mapping->host, nr_none);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1519  		spin_lock_irq(&mapping->tree_lock);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1520  		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1521  				start) {
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1522  			if (iter.index >= end)
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1523  				break;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1524  			page = list_first_entry_or_null(&pagelist,
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1525  					struct page, lru);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1526  			if (!page || iter.index < page->index) {
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1527  				if (!nr_none)
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1528  					break;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1529  				nr_none--;
> 59749e6c Johannes Weiner    2016-12-12  1530  				/* Put holes back where they were */
> 59749e6c Johannes Weiner    2016-12-12  1531  				radix_tree_delete(&mapping->page_tree,
> 59749e6c Johannes Weiner    2016-12-12  1532  						  iter.index);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1533  				continue;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1534  			}
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1535
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1536  			VM_BUG_ON_PAGE(page->index != iter.index, page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1537
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1538  			/* Unfreeze the page. */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1539  			list_del(&page->lru);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1540  			page_ref_unfreeze(page, 2);
> 6d75f366 Johannes Weiner    2016-12-12  1541  			radix_tree_replace_slot(&mapping->page_tree,
> 6d75f366 Johannes Weiner    2016-12-12  1542  						slot, page);
> 148deab2 Matthew Wilcox     2016-12-14  1543  			slot = radix_tree_iter_resume(slot, &iter);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1544  			spin_unlock_irq(&mapping->tree_lock);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1545  			putback_lru_page(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1546  			unlock_page(page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1547  			spin_lock_irq(&mapping->tree_lock);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1548  		}
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1549  		VM_BUG_ON(nr_none);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1550  		spin_unlock_irq(&mapping->tree_lock);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1551
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1552  		/* Unfreeze new_page, caller would take care about freeing it */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1553  		page_ref_unfreeze(new_page, 1);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1554  		mem_cgroup_cancel_charge(new_page, memcg, true);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1555  		unlock_page(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1556  		new_page->mapping = NULL;
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1557  	}
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1558  out:
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1559  	VM_BUG_ON(!list_empty(&pagelist));
> a5318ea6 zhong jiang        2017-05-09 @1560  	if (page != NULL && result != SCAN_SUCCEED)
> a5318ea6 zhong jiang        2017-05-09  1561  		put_page(new_page);
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1562  	/* TODO: tracepoints */
> f3f0e1d2 Kirill A. Shutemov 2016-07-26  1563  }
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
