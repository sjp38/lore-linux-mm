Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEED6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:30:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n21-v6so15803918iob.19
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 04:30:15 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q68-v6si7412915itq.120.2018.06.19.04.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 04:30:13 -0700 (PDT)
Date: Tue, 19 Jun 2018 14:29:44 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] mm: Convert collapse_shmem to XArray
Message-ID: <20180619112944.f2fokthjunzavgcw@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: linux-mm@kvack.org

Hello Matthew Wilcox,

The patch d31429cb560d: "mm: Convert collapse_shmem to XArray" from
Dec 4, 2017, leads to the following static checker warning:

	mm/khugepaged.c:1435 collapse_shmem()
	error: double unlock 'irq:'

mm/khugepaged.c
  1398                  xas_unlock_irq(&xas);
  1399  
  1400                  if (isolate_lru_page(page)) {
  1401                          result = SCAN_DEL_PAGE_LRU;
  1402                          goto out_isolate_failed;
  1403                  }
  1404  
  1405                  if (page_mapped(page))
  1406                          unmap_mapping_pages(mapping, index, 1, false);
  1407  
  1408                  xas_lock(&xas);
                        ^^^^^^^^^^^^^^
This used to disable IRQs.

  1409                  xas_set(&xas, index);
  1410  
  1411                  VM_BUG_ON_PAGE(page != xas_load(&xas), page);
  1412                  VM_BUG_ON_PAGE(page_mapped(page), page);
  1413  
  1414                  /*
  1415                   * The page is expected to have page_count() == 3:
  1416                   *  - we hold a pin on it;
  1417                   *  - one reference from page cache;
  1418                   *  - one from isolate_lru_page;
  1419                   */
  1420                  if (!page_ref_freeze(page, 3)) {
  1421                          result = SCAN_PAGE_COUNT;
  1422                          goto out_lru;
  1423                  }
  1424  
  1425                  /*
  1426                   * Add the page to the list to be able to undo the collapse if
  1427                   * something go wrong.
  1428                   */
  1429                  list_add_tail(&page->lru, &pagelist);
  1430  
  1431                  /* Finally, replace with the new page. */
  1432                  xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
  1433                  continue;
  1434  out_lru:
  1435                  xas_unlock_irq(&xas);
                        ^^^^^^^^^^^^^^^^^^^
So I guess we should change this to xas_unlock(&xas);?

  1436                  putback_lru_page(page);
  1437  out_isolate_failed:
  1438                  unlock_page(page);
  1439                  put_page(page);
  1440                  goto xa_unlocked;
  1441  out_unlock:

regards,
dan carpenter
