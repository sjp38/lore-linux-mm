Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 844AE82F67
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:54:43 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so67483018pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:54:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xx10si15808759pac.132.2015.10.21.13.54.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:54:42 -0700 (PDT)
Date: Wed, 21 Oct 2015 23:54:17 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: simplify reclaim path for MADV_FREE
Message-ID: <20151021205417.GC9839@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: linux-mm@kvack.org

Hello Minchan Kim,

The patch e4f28388eb72: "mm: simplify reclaim path for MADV_FREE"
from Oct 21, 2015, leads to the following static checker warning:

	mm/rmap.c:1469 try_to_unmap_one()
	warn: inconsistent indenting

mm/rmap.c
  1459                  /*
  1460                   * Store the swap location in the pte.
  1461                   * See handle_pte_fault() ...
  1462                   */
  1463                  VM_BUG_ON_PAGE(!PageSwapCache(page), page);
  1464                  if (swap_duplicate(entry) < 0) {
  1465                          set_pte_at(mm, address, pte, pteval);
  1466                          ret = SWAP_FAIL;
  1467                          goto out_unmap;
  1468                  }
  1469                          if (!PageDirty(page))
  1470                                  SetPageDirty(page);

My guess is that we can just remove the extra tabs.  It wasn't supposed
to be before the "goto out_unmap;" was it?

  1471                  if (list_empty(&mm->mmlist)) {
  1472                          spin_lock(&mmlist_lock);
  1473                          if (list_empty(&mm->mmlist))
  1474                                  list_add(&mm->mmlist, &init_mm.mmlist);
  1475                          spin_unlock(&mmlist_lock);
  1476                  }


regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
