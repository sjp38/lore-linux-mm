Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m25I2XIZ010643
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 13:02:33 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I3F8u194288
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 11:03:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I3EEJ001914
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 11:03:15 -0700
Date: Wed, 5 Mar 2008 10:03:22 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] 2.6.25-rc3-mm1 - Mempolicy:  make
	dequeue_huge_page_vma() obey MPOL_BIND nodemask
Message-ID: <20080305180322.GA9795@us.ibm.com>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214734.6858.9968.sendpatchset@localhost> <20080228133247.6a7b626f.akpm@linux-foundation.org> <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost> <20080304180145.GB9051@csn.ul.ie> <1204733195.5026.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204733195.5026.20.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On 05.03.2008 [11:06:34 -0500], Lee Schermerhorn wrote:
> PATCH Mempolicy - make dequeue_huge_page_vma() obey MPOL_BIND nodemask
> 
> dequeue_huge_page_vma() is not obeying the MPOL_BIND nodemask
> with the zonelist rework.  It needs to search only zones in 
> the mempolicy nodemask for hugepages.
> 
> Use for_each_zone_zonelist_nodemask() instead of
> for_each_zone_zonelist().
> 
> Note:  this will bloat mm/hugetlb.o a bit until Mel reworks the
> inlining of the for_each_zone... macros and helpers.
> 
> Added mempolicy helper function mpol_bind_nodemask() to hide
> the details of mempolicy from hugetlb and to avoid
> #ifdef CONFIG_NUMA in dequeue_huge_page_vma().
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/mempolicy.h |   13 +++++++++++++
>  mm/hugetlb.c              |    4 +++-
>  2 files changed, 16 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.25-rc3-mm1/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/mm/hugetlb.c	2008-03-05 10:35:12.000000000 -0500
> +++ linux-2.6.25-rc3-mm1/mm/hugetlb.c	2008-03-05 10:37:09.000000000 -0500
> @@ -99,8 +99,10 @@ static struct page *dequeue_huge_page_vm
>  					htlb_alloc_mask, &mpol);
>  	struct zone *zone;
>  	struct zoneref *z;
> +	nodemask_t *nodemask = mpol_bind_nodemask(mpol);

We get this mpol from huge_zonelist(). Would it perhaps make sense to
pass the nodemask as a parameter, too, to huge_zonelist(), rather than
adding mpol_bind_nodemask()? This is the only user of it in-tree.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
