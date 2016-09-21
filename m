Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81BC728024E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:14:07 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so97087964pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:14:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s3si41160833pag.147.2016.09.21.08.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 08:14:06 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8LFDjYu028821
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:14:06 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25k7bkjw5n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:14:05 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 21 Sep 2016 16:14:03 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0624A2190056
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:13:20 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8LFE0wP18350422
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 15:14:00 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8LEE1Dj020459
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:14:02 -0600
Date: Wed, 21 Sep 2016 17:13:57 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v2 1/1] mm/hugetlb: fix memory offline with hugepage
 size > memory block size
In-Reply-To: <f3b4221f-8f23-23ce-6bf5-052df7274470@linux.vnet.ibm.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>
	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
	<20160921143534.0dd95fe7@thinkpad>
	<f3b4221f-8f23-23ce-6bf5-052df7274470@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160921171357.1c01d481@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Wed, 21 Sep 2016 21:17:29 +0800
Rui Teng <rui.teng@linux.vnet.ibm.com> wrote:

> >  /*
> >   * Dissolve free hugepages in a given pfn range. Used by memory hotplug to
> >   * make specified memory blocks removable from the system.
> > - * Note that start_pfn should aligned with (minimum) hugepage size.
> > + * Note that this will dissolve a free gigantic hugepage completely, if any
> > + * part of it lies within the given range.
> >   */
> >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  {
> > @@ -1466,9 +1473,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> >  	if (!hugepages_supported())
> >  		return;
> >
> > -	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
> >  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> > -		dissolve_free_huge_page(pfn_to_page(pfn));
> > +		if (pfn_to_page(pfn)))
> > +			pfn_to_page(pfn));
> How many times will dissolve_free_huge_page() be invoked in this loop?
> For each pfn, it will be converted to the head page, and then the list
> will be deleted repeatedly.

In the case where the memory block [start_pfn, end_pfn] is part of a
gigantic hugepage, dissolve_free_huge_page() will only be invoked once.

If there is only one gigantic hugepage pool, 1 << minimum_order will be
larger than the memory block size, and the loop will stop after the first
invocation of dissolve_free_huge_page().

If there are additional hugepage pools, with hugepage sizes < memory
block size, then it will loop as many times as 1 << minimum_order fits
inside a memory block, e.g. 256 times with 1 MB minimum hugepage size
and 256 MB memory block size.

However, the PageHuge() check should always return false after the first
invocation of dissolve_free_huge_page(), since update_and_free_page()
will take care of resetting compound_dtor, and so there will also be
just one invocation.

The only case where there will be more than one invocation is the case
where we do not have any part of a gigantic hugepage inside the memory
block, but rather multiple "normal sized" hugepages. Then there will be
one invocation per hugepage, as opposed to one invocation per
"1 << minimum_order" range as it was before the patch. So it also
improves the behaviour in the case where there is no gigantic page
involved.

> >  }
> >
> >  /*
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
