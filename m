Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFFE6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 07:59:40 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 129so68512215pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 04:59:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d62si5958693pfj.173.2016.03.10.04.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 04:59:39 -0800 (PST)
Date: Thu, 10 Mar 2016 15:59:23 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: keep page cache radix tree nodes in check
Message-ID: <20160310125922.GA15269@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: linux-mm@kvack.org

Hello Johannes Weiner,

The patch 449dd6984d0e: "mm: keep page cache radix tree nodes in
check" from Apr 3, 2014, leads to the following static checker
warning:

	mm/filemap.c:138 page_cache_tree_delete()
	error: potentially using uninitialized 'node'.

mm/filemap.c
   113  static void page_cache_tree_delete(struct address_space *mapping,
   114                                     struct page *page, void *shadow)
   115  {
   116          struct radix_tree_node *node;
                                        ^^^^
   117          unsigned long index;
   118          unsigned int offset;
   119          unsigned int tag;
   120          void **slot;
   121  
   122          VM_BUG_ON(!PageLocked(page));
   123  
   124          __radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
                                                                       ^^^^
   125  
   126          if (shadow) {
   127                  mapping->nrexceptional++;
   128                  /*
   129                   * Make sure the nrexceptional update is committed before
   130                   * the nrpages update so that final truncate racing
   131                   * with reclaim does not see both counters 0 at the
   132                   * same time and miss a shadow entry.
   133                   */
   134                  smp_wmb();
   135          }
   136          mapping->nrpages--;
   137  
   138          if (!node) {
                     ^^^^

   139                  /* Clear direct pointer tags in root node */
   140                  mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
   141                  radix_tree_replace_slot(slot, shadow);
   142                  return;
   143          }

It's obviously simple enough for me to initialize "node" to NULL but I
suspect there is a reason that it can't be uninitialized...  I'm trying
to get some feedback for some new Smatch stuff I'm working on.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
