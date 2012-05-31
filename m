Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5256C6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 01:28:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 31 May 2012 06:13:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4V5PpMT22216732
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:25:51 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4V5Pojw023630
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:25:51 +1000
Date: Thu, 31 May 2012 10:55:40 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 05/14] hugetlb: avoid taking i_mmap_mutex in
 unmap_single_vma() for hugetlb
Message-ID: <20120531052540.GA24855@skywalker.linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1338388739-22919-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1205301857170.25774@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205301857170.25774@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Wed, May 30, 2012 at 06:57:47PM -0700, David Rientjes wrote:
> On Wed, 30 May 2012, Aneesh Kumar K.V wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
> > fix linked list corruption in unmap_hugepage_range()") but we don't use
> > page->lru in unmap_hugepage_range any more.  Also the lock was taken
> > higher up in the stack in some code path.  That would result in deadlock.
> > 
> > unmap_mapping_range (i_mmap_mutex)
> >  -> unmap_mapping_range_tree
> >     -> unmap_mapping_range_vma
> >        -> zap_page_range_single
> >          -> unmap_single_vma
> > 	      -> unmap_hugepage_range (i_mmap_mutex)
> > 
> 
> You should be able to show this with lockdep?

I was not able to get a lockdep report

> 
> > For shared pagetable support for huge pages, since pagetable pages are ref
> > counted we don't need any lock during huge_pmd_unshare.  We do take
> > i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
> > (39dde65c9940c97f ("shared page table for hugetlb page")).
> > 
> 
> I think this should be folded into patch 4, the code you're removing here 
> is just added in that function unnecessarily.
> 

I am removing i_mmap_mutex in this patch. That is not added in patch 4.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
