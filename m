Date: Fri, 31 Mar 2006 10:41:56 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [patch] don't allow free hugetlb count fall below reserved count
Message-ID: <20060331004156.GK19421@localhost.localdomain>
References: <200603310013.k2V0Dng26534@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603310013.k2V0Dng26534@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 30, 2006 at 04:14:34PM -0800, Chen, Kenneth W wrote:
> With strict page reservation, I think kernel should enforce number of
> free hugetlb page don't fall below reserved count. Currently it is
> possible in the sysctl path.  Add proper check in sysctl to disallow
> that.

Hmm.. maybe.  I have no strong view either way.  With this patch
you're safer against accidentally taking hugepages away from a process
which needs them.  On the other hand, leaving it out gives a sysadmin
more flexibility to free up normal memory at the expense of risking
crashes for hugepage processes.

Ken - did you keep working on your alternative strict reservation
patches?  Last I recall they seemed to be converging on mine in all
the points I thought really mattered, except that I hadn't updated
mine to remove some of the problems you pointed out in it while
developing your patches (e.g. unnecessarily taking a lock on reserve).

I'm actually on a very long leave at the moment, so I'm not really
doing anything active.  Those problems should be fixed at some point,
though, either with patches to my approach, or by replacing it with
yours.

> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> --- ./mm/hugetlb.c.orig	2006-03-30 15:32:20.000000000 -0800
> +++ ./mm/hugetlb.c	2006-03-30 15:48:22.000000000 -0800
> @@ -334,6 +334,7 @@
>  		return nr_huge_pages;
>  
>  	spin_lock(&hugetlb_lock);
> +	count = max(count, reserved_huge_pages);
>  	try_to_free_low(count);
>  	while (count < nr_huge_pages) {
>  		struct page *page = dequeue_huge_page(NULL, 0);
> 

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
