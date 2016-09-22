Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 395B4280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:58:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i193so187349515oib.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 00:58:34 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 3si484677ioz.100.2016.09.22.00.58.32
        for <linux-mm@kvack.org>;
        Thu, 22 Sep 2016 00:58:33 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com> <20160921143534.0dd95fe7@thinkpad>
In-Reply-To: <20160921143534.0dd95fe7@thinkpad>
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage size > memory block size
Date: Thu, 22 Sep 2016 15:58:15 +0800
Message-ID: <003e01d214a7$13a72220$3af56660$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Gerald Schaefer' <gerald.schaefer@de.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Michal Hocko' <mhocko@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Aneesh Kumar K . V'" <aneesh.kumar@linux.vnet.ibm.com>, 'Martin Schwidefsky' <schwidefsky@de.ibm.com>, 'Heiko Carstens' <heiko.carstens@de.ibm.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Rui Teng' <rui.teng@linux.vnet.ibm.com>

> 
> dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> list corruption and addressing exception when trying to set a memory
> block offline that is part (but not the first part) of a hugetlb page
> with a size > memory block size.
> 
> When no other smaller hugetlb page sizes are present, the VM_BUG_ON()
> will trigger directly. In the other case we will run into an addressing
> exception later, because dissolve_free_huge_page() will not work on the
> head page of the compound hugetlb page which will result in a NULL
> hstate from page_hstate().
> 
> To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> use the compound head page in dissolve_free_huge_page().
> 
> Also change locking in dissolve_free_huge_page(), so that it only takes
> the lock when actually removing a hugepage.
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
