Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 482506B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 14:57:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so46368980pgq.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:57:17 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 91si1284045ply.118.2016.11.22.11.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 11:57:16 -0800 (PST)
Date: Wed, 23 Nov 2016 03:56:29 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support
 additional page copy routines.
Message-ID: <201611230331.FuGRxmmN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161122162530.2370-2-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

Hi Zi,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.9-rc6 next-20161122]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Zi-Yan/Parallel-hugepage-migration-optimization/20161123-022913
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> fs/f2fs/data.c:1938:26: sparse: not enough arguments for function migrate_page_copy
   fs/f2fs/data.c: In function 'f2fs_migrate_page':
   fs/f2fs/data.c:1938:2: error: too few arguments to function 'migrate_page_copy'
     migrate_page_copy(newpage, page);
     ^~~~~~~~~~~~~~~~~
   In file included from fs/f2fs/data.c:1893:0:
   include/linux/migrate.h:45:13: note: declared here
    extern void migrate_page_copy(struct page *newpage, struct page *page,
                ^~~~~~~~~~~~~~~~~

vim +1938 fs/f2fs/data.c

5b7a487c Weichao Guo 2016-09-20  1922  	if (atomic_written) {
5b7a487c Weichao Guo 2016-09-20  1923  		struct inmem_pages *cur;
5b7a487c Weichao Guo 2016-09-20  1924  		list_for_each_entry(cur, &fi->inmem_pages, list)
5b7a487c Weichao Guo 2016-09-20  1925  			if (cur->page == page) {
5b7a487c Weichao Guo 2016-09-20  1926  				cur->page = newpage;
5b7a487c Weichao Guo 2016-09-20  1927  				break;
5b7a487c Weichao Guo 2016-09-20  1928  			}
5b7a487c Weichao Guo 2016-09-20  1929  		mutex_unlock(&fi->inmem_lock);
5b7a487c Weichao Guo 2016-09-20  1930  		put_page(page);
5b7a487c Weichao Guo 2016-09-20  1931  		get_page(newpage);
5b7a487c Weichao Guo 2016-09-20  1932  	}
5b7a487c Weichao Guo 2016-09-20  1933  
5b7a487c Weichao Guo 2016-09-20  1934  	if (PagePrivate(page))
5b7a487c Weichao Guo 2016-09-20  1935  		SetPagePrivate(newpage);
5b7a487c Weichao Guo 2016-09-20  1936  	set_page_private(newpage, page_private(page));
5b7a487c Weichao Guo 2016-09-20  1937  
5b7a487c Weichao Guo 2016-09-20 @1938  	migrate_page_copy(newpage, page);
5b7a487c Weichao Guo 2016-09-20  1939  
5b7a487c Weichao Guo 2016-09-20  1940  	return MIGRATEPAGE_SUCCESS;
5b7a487c Weichao Guo 2016-09-20  1941  }
5b7a487c Weichao Guo 2016-09-20  1942  #endif
5b7a487c Weichao Guo 2016-09-20  1943  
eb47b800 Jaegeuk Kim 2012-11-02  1944  const struct address_space_operations f2fs_dblock_aops = {
eb47b800 Jaegeuk Kim 2012-11-02  1945  	.readpage	= f2fs_read_data_page,
eb47b800 Jaegeuk Kim 2012-11-02  1946  	.readpages	= f2fs_read_data_pages,

:::::: The code at line 1938 was first introduced by commit
:::::: 5b7a487cf32d3a266fea83d590d3226b5ad817a7 f2fs: add customized migrate_page callback

:::::: TO: Weichao Guo <guoweichao@huawei.com>
:::::: CC: Jaegeuk Kim <jaegeuk@kernel.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
