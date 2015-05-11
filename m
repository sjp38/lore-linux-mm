Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD8536B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 07:18:00 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so97197738obb.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 04:18:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xt18si6973488oeb.90.2015.05.11.04.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 04:18:00 -0700 (PDT)
Date: Mon, 11 May 2015 14:17:48 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Message-ID: <20150511111748.GA20660@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org

Hello Naoya Horiguchi,

The patch c8721bbbdd36: "mm: memory-hotplug: enable memory hotplug to
handle hugepage" from Sep 11, 2013, leads to the following static
checker warning:

	mm/hugetlb.c:1203 dissolve_free_huge_pages()
	warn: potential right shift more than type allows '9,18,64'

mm/hugetlb.c
  1189  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
  1190  {
  1191          unsigned int order = 8 * sizeof(void *);
                                     ^^^^^^^^^^^^^^^^^^
Let's say order is 64.

  1192          unsigned long pfn;
  1193          struct hstate *h;
  1194  
  1195          if (!hugepages_supported())
  1196                  return;
  1197  
  1198          /* Set scan step to minimum hugepage size */
  1199          for_each_hstate(h)
  1200                  if (order > huge_page_order(h))
  1201                          order = huge_page_order(h);
  1202          VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
  1203          for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
                                                            ^^^^^^^^^^
1 << 64 is undefined but let's say it's zero because that's normal for
GCC.  This is an endless loop.

  1204                  dissolve_free_huge_page(pfn_to_page(pfn));
  1205  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
