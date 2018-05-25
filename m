Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CED56B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 17:09:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g92-v6so3733087plg.6
        for <linux-mm@kvack.org>; Fri, 25 May 2018 14:09:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 32-v6si303606ple.447.2018.05.25.14.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 14:09:42 -0700 (PDT)
Date: Fri, 25 May 2018 14:09:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, hugetlb_cgroup: suppress SIGBUS when hugetlb_cgroup
 charge fails
Message-Id: <20180525140940.976ca667f3c6ff83238c3620@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1805251356570.7798@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805251316090.167008@chino.kir.corp.google.com>
	<20180525134459.5c6f8e06f55307f72b95a901@linux-foundation.org>
	<alpine.DEB.2.21.1805251356570.7798@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 May 2018 13:59:40 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -2006,8 +2006,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
> > >  	 * code of zero indicates a reservation exists (no change).
> > >  	 */
> > >  	map_chg = gbl_chg = vma_needs_reservation(h, vma, addr);
> > > -	if (map_chg < 0)
> > > -		return ERR_PTR(-ENOMEM);
> > > +	if (map_chg < 0) {
> > > +		ret = -ENOMEM;
> > > +		goto out;
> > > +	}
> > 
> > This doesn't change the return value.
> > 
> 
> This, and the subsequent comments, are referring to the third paragraph of 
> the changelog.
> 
> The functional part of the change is for the 
> hugetlb_cgroup_charge_cgroup() return value that is now actually used.


Ah.  Missed that bit.

Altered changelog:

: When charging to a hugetlb_cgroup fails, alloc_huge_page() returns
: ERR_PTR(-ENOSPC) which will cause VM_FAULT_SIGBUS to be returned to the
: page fault handler.
: 
: This is because the return value from hugetlb_cgroup_charge_cgroup() is
: overwritten with ERR_PTR(-ENOSPC).
: 
: Instead, propagate the error code from hugetlb_cgroup_charge_cgroup()
: (ERR_PTR(-ENOMEM)), so VM_FAULT_OOM is handled correctly.  This is
: consistent with failing mem cgroup charges in the non-hugetlb fault path.
: 
: At the same time, restructure the return paths of alloc_huge_page() so it
: is consistent.

>
> > It would be nice if you could add a comment over alloc_huge_page()
> > explaining the return values (at least).  Why sometimes ENOMEM, other
> > times ENOSPC?
> > 
> 
> The ENOSPC is used to specifically induce a VM_FAULT_SIGBUS, which 
> Documentation/vm/hugetlbfs_reserv.txt specifies is how faults are handled 
> if no hugetlb pages are available.

That wasn't a code comment ;) Nobody will know to go looking in
hugetlbfs_reserv.txt - it isn't even referred to from mm/*.c.
