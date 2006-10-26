Date: Fri, 27 Oct 2006 09:47:45 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
Message-ID: <20061026234745.GB11733@localhost.localdomain>
References: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Andrew Morton <akpm@osdl.org>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 26, 2006 at 03:17:20PM -0700, Chen, Kenneth W wrote:
> First rev of patch to allow hugetlb page fault to scale.
> 
> hugetlb_instantiation_mutex was introduced to prevent spurious allocation
> failure in a corner case: two threads race to instantiate same page with
> only one free page left in the global pool.  However, this global
> serialization hurts fault performance badly as noted by Christoph Lameter.
> This patch attempt to cut back the use of mutex only when free page resource
> is limited, thus allow fault to scale in most common cases.

>From my experience of spending most of the last two weeks going "We
can just do <this>...hack, hack.., no, that has a race too" this is
much harder to get right than you'd think.

For example with your patch, suppose CPU0 and CPU1 are both attempting
to instantiate the same page in a shared mapping, CPU2 is attempting
to instantiate a page in an unrelated mapping.

CPU0		CPU1		CPU2		token	free_hpages
						0	2
atomic_inc					1	2
(use_mutex=0)
		atomic_inc			2	2
		(use_mutex=1)
				atomic_inc	3	2
				(use_mutex=1)
				mutex_lock
				<complete fault>
				mutex_unlock
				atomic_dec	2	1
		mutex_lock			2	1
alloc_huge_page					2	0
		alloc_huge_page
		-> OOM
add_to_page_cache

So we still have the spurious OOM.  There may be other race
scenarios, that's just the first I came up with.

Oh, also your patch accesses free_huge_pages bare, whereas its usually
protected by hugetlb_lock.  As a read-only access that's *probably*
ok, but any lock-free access of variables which are generally supposed
to be lock protected makes me nervious.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
