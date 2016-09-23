Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D245A28024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:36:34 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so197149245pab.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 03:36:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id yi8si7382989pac.65.2016.09.23.03.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 03:36:33 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8NAX5Qi004918
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:36:33 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25mqb6tx8v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 06:36:32 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 23 Sep 2016 11:36:30 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id B10AC219005E
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:35:48 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8NAaS6H4391382
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:36:28 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8NAaS2u015943
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:36:28 -0600
Date: Fri, 23 Sep 2016 12:36:22 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v3] mm/hugetlb: fix memory offline with hugepage size >
 memory block size
In-Reply-To: <57E41EF6.1010903@linux.intel.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<20160920155354.54403-2-gerald.schaefer@de.ibm.com>
	<05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
	<20160921143534.0dd95fe7@thinkpad>
	<20160922095137.GC11875@dhcp22.suse.cz>
	<20160922154549.483ee313@thinkpad>
	<20160922182937.38af9d0e@thinkpad>
	<57E41EF6.1010903@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160923123622.00289d21@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On Thu, 22 Sep 2016 11:12:06 -0700
Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 09/22/2016 09:29 AM, Gerald Schaefer wrote:
> >  static void dissolve_free_huge_page(struct page *page)
> >  {
> > +	struct page *head = compound_head(page);
> > +	struct hstate *h = page_hstate(head);
> > +	int nid = page_to_nid(head);
> > +
> >  	spin_lock(&hugetlb_lock);
> > -	if (PageHuge(page) && !page_count(page)) {
> > -		struct hstate *h = page_hstate(page);
> > -		int nid = page_to_nid(page);
> > -		list_del(&page->lru);
> > -		h->free_huge_pages--;
> > -		h->free_huge_pages_node[nid]--;
> > -		h->max_huge_pages--;
> > -		update_and_free_page(h, page);
> > -	}
> > +	list_del(&head->lru);
> > +	h->free_huge_pages--;
> > +	h->free_huge_pages_node[nid]--;
> > +	h->max_huge_pages--;
> > +	update_and_free_page(h, head);
> >  	spin_unlock(&hugetlb_lock);
> >  }
> 
> Do you need to revalidate anything once you acquire the lock?  Can this,
> for instance, race with another thread doing vm.nr_hugepages=0?  Or a
> thread faulting in and allocating the large page that's being dissolved?
> 

Yes, good point. I was relying on the range being isolated, but that only
seems to be checked in dequeue_huge_page_node(), as introduced with the
original commit. So this would only protect against anyone allocating the
hugepage at this point. This is also somehow expected, since we already
are beyond the "point of no return" in offline_pages().

vm.nr_hugepages=0 seems to be an issue though, as set_max_hugepages()
will not care about isolation, and so I guess we could have a race here
and double-free the hugepage. Revalidation of at least PageHuge() after
taking the lock should protect from that, not sure about page_count(),
but I think I'll just check both which will give the same behaviour as
before.

Will send v4, after thinking a bit more on the page reservation point
brought up by Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
