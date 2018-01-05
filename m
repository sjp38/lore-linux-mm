Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 766DB28026E
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 02:29:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f64so2398936pfd.6
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 23:29:25 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e16si3198404pgr.639.2018.01.04.23.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 23:29:23 -0800 (PST)
Date: Fri, 5 Jan 2018 15:29:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 152/256] mm/migrate.c:1934:53: sparse: incorrect type
 in argument 2 (different argument counts)
Message-ID: <201801051507.45CKDK0l%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Michal,

First bad commit (maybe != root cause):

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   1ceb98996d2504dd4e0bcb5f4cb9009a18cd8aaa
commit: 37870392dd6966328ed2fe49a247ab37d6fa7344 [152/256] mm, hugetlb: unify core page allocation accounting and initialization
reproduce:
        # apt-get install sparse
        git checkout 37870392dd6966328ed2fe49a247ab37d6fa7344
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +1934 mm/migrate.c

de466bd6 Mel Gorman     2013-12-18  1899  
b32967ff Mel Gorman     2012-11-19  1900  /*
b32967ff Mel Gorman     2012-11-19  1901   * Attempt to migrate a misplaced page to the specified destination
b32967ff Mel Gorman     2012-11-19  1902   * node. Caller is expected to have an elevated reference count on
b32967ff Mel Gorman     2012-11-19  1903   * the page that will be dropped by this function before returning.
b32967ff Mel Gorman     2012-11-19  1904   */
1bc115d8 Mel Gorman     2013-10-07  1905  int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
1bc115d8 Mel Gorman     2013-10-07  1906  			   int node)
b32967ff Mel Gorman     2012-11-19  1907  {
b32967ff Mel Gorman     2012-11-19  1908  	pg_data_t *pgdat = NODE_DATA(node);
340ef390 Hugh Dickins   2013-02-22  1909  	int isolated;
7039e1db Peter Zijlstra 2012-10-25  1910  	int nr_remaining;
b32967ff Mel Gorman     2012-11-19  1911  	LIST_HEAD(migratepages);
b32967ff Mel Gorman     2012-11-19  1912  
b32967ff Mel Gorman     2012-11-19  1913  	/*
1bc115d8 Mel Gorman     2013-10-07  1914  	 * Don't migrate file pages that are mapped in multiple processes
1bc115d8 Mel Gorman     2013-10-07  1915  	 * with execute permissions as they are probably shared libraries.
b32967ff Mel Gorman     2012-11-19  1916  	 */
1bc115d8 Mel Gorman     2013-10-07  1917  	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
1bc115d8 Mel Gorman     2013-10-07  1918  	    (vma->vm_flags & VM_EXEC))
b32967ff Mel Gorman     2012-11-19  1919  		goto out;
7039e1db Peter Zijlstra 2012-10-25  1920  
b32967ff Mel Gorman     2012-11-19  1921  	/*
b32967ff Mel Gorman     2012-11-19  1922  	 * Rate-limit the amount of data that is being migrated to a node.
b32967ff Mel Gorman     2012-11-19  1923  	 * Optimal placement is no good if the memory bus is saturated and
b32967ff Mel Gorman     2012-11-19  1924  	 * all the time is being spent migrating!
b32967ff Mel Gorman     2012-11-19  1925  	 */
340ef390 Hugh Dickins   2013-02-22  1926  	if (numamigrate_update_ratelimit(pgdat, 1))
b32967ff Mel Gorman     2012-11-19  1927  		goto out;
b32967ff Mel Gorman     2012-11-19  1928  
b32967ff Mel Gorman     2012-11-19  1929  	isolated = numamigrate_isolate_page(pgdat, page);
b32967ff Mel Gorman     2012-11-19  1930  	if (!isolated)
b32967ff Mel Gorman     2012-11-19  1931  		goto out;
b32967ff Mel Gorman     2012-11-19  1932  
b32967ff Mel Gorman     2012-11-19  1933  	list_add(&page->lru, &migratepages);
9c620e2b Hugh Dickins   2013-02-22 @1934  	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
68711a74 David Rientjes 2014-06-04  1935  				     NULL, node, MIGRATE_ASYNC,
68711a74 David Rientjes 2014-06-04  1936  				     MR_NUMA_MISPLACED);
7039e1db Peter Zijlstra 2012-10-25  1937  	if (nr_remaining) {
59c82b70 Joonsoo Kim    2014-01-21  1938  		if (!list_empty(&migratepages)) {
59c82b70 Joonsoo Kim    2014-01-21  1939  			list_del(&page->lru);
599d0c95 Mel Gorman     2016-07-28  1940  			dec_node_page_state(page, NR_ISOLATED_ANON +
59c82b70 Joonsoo Kim    2014-01-21  1941  					page_is_file_cache(page));
59c82b70 Joonsoo Kim    2014-01-21  1942  			putback_lru_page(page);
59c82b70 Joonsoo Kim    2014-01-21  1943  		}
7039e1db Peter Zijlstra 2012-10-25  1944  		isolated = 0;
03c5a6e1 Mel Gorman     2012-11-02  1945  	} else
03c5a6e1 Mel Gorman     2012-11-02  1946  		count_vm_numa_event(NUMA_PAGE_MIGRATE);
7039e1db Peter Zijlstra 2012-10-25  1947  	BUG_ON(!list_empty(&migratepages));
7039e1db Peter Zijlstra 2012-10-25  1948  	return isolated;
340ef390 Hugh Dickins   2013-02-22  1949  
340ef390 Hugh Dickins   2013-02-22  1950  out:
340ef390 Hugh Dickins   2013-02-22  1951  	put_page(page);
340ef390 Hugh Dickins   2013-02-22  1952  	return 0;
7039e1db Peter Zijlstra 2012-10-25  1953  }
220018d3 Mel Gorman     2012-12-05  1954  #endif /* CONFIG_NUMA_BALANCING */
b32967ff Mel Gorman     2012-11-19  1955  

:::::: The code at line 1934 was first introduced by commit
:::::: 9c620e2bc5aa4256c102ada34e6c76204ed5898b mm: remove offlining arg to migrate_pages

:::::: TO: Hugh Dickins <hughd@google.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
