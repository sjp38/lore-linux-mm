Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 386596B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 21:57:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so912956pbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 18:57:49 -0700 (PDT)
Date: Wed, 30 May 2012 18:57:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V7 05/14] hugetlb: avoid taking i_mmap_mutex in
 unmap_single_vma() for hugetlb
In-Reply-To: <1338388739-22919-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1205301857170.25774@chino.kir.corp.google.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 30 May 2012, Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
> fix linked list corruption in unmap_hugepage_range()") but we don't use
> page->lru in unmap_hugepage_range any more.  Also the lock was taken
> higher up in the stack in some code path.  That would result in deadlock.
> 
> unmap_mapping_range (i_mmap_mutex)
>  -> unmap_mapping_range_tree
>     -> unmap_mapping_range_vma
>        -> zap_page_range_single
>          -> unmap_single_vma
> 	      -> unmap_hugepage_range (i_mmap_mutex)
> 

You should be able to show this with lockdep?

> For shared pagetable support for huge pages, since pagetable pages are ref
> counted we don't need any lock during huge_pmd_unshare.  We do take
> i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
> (39dde65c9940c97f ("shared page table for hugetlb page")).
> 

I think this should be folded into patch 4, the code you're removing here 
is just added in that function unnecessarily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
