Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l99Adcc9008801
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:39:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99Afu4Z118416
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:41:56 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99AcL8W012407
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:38:21 +1000
Message-ID: <470B5A13.9020601@linux.vnet.ibm.com>
Date: Tue, 09 Oct 2007 16:08:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [1/6]
 fix refcnt race in charge/uncharge
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com> <20071009184925.ad8248d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009184925.ad8248d4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> The logic of uncharging is 
>  - decrement refcnt -> lock page cgroup -> remove page cgroup.
> But the logic of charging is
>  - lock page cgroup -> increment refcnt -> return.
> 
> Then, one charge will be added to a page_cgroup under being removed.
> This makes no big trouble (like panic) but one charge is lost.
> 
> This patch add a test at charging to verify page_cgroup's refcnt is
> greater than 0. If not, unlock and retry.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
>  mm/memcontrol.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.23-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> +++ linux-2.6.23-rc8-mm2/mm/memcontrol.c
> @@ -271,14 +271,19 @@ int mem_cgroup_charge(struct page *page,
>  	 * to see if the cgroup page already has a page_cgroup associated
>  	 * with it
>  	 */
> +retry:
>  	lock_page_cgroup(page);
>  	pc = page_get_page_cgroup(page);
>  	/*
>  	 * The page_cgroup exists and the page has already been accounted
>  	 */
>  	if (pc) {
> -		atomic_inc(&pc->ref_cnt);
> -		goto done;
> +		if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
> +			/* this page is under being uncharge ? */
> +			unlock_page_cgroup(page);
> +			goto retry;
> +		} else
> +			goto done;
>  	}
> 
>  	unlock_page_cgroup(page);
> 
> 

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
