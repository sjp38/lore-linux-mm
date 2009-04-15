Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6565F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:47:16 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3F8lsFN010142
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:47:54 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3F8lqHS528540
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:47:54 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3F8lpcb000926
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 18:47:51 +1000
Date: Wed, 15 Apr 2009 14:17:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: meminfo Committed_AS underflows
Message-ID: <20090415084713.GU7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090415105033.AC29.A69D9226@jp.fujitsu.com> <20090415033455.GS7082@balbir.in.ibm.com> <20090415130042.AC3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090415130042.AC3D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 13:10:06]:

> > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:
> > 
> > >  	committed = atomic_long_read(&vm_committed_space);
> > > +	if (committed < 0)
> > > +		committed = 0;
> > 
> > Isn't this like pushing the problem under the rug?
> 
> global_page_state() already has same logic.
> IOW almost meminfo filed has this one (except Commited_AS).
>

OK
 
> 
> > >  	allowed = ((totalram_pages - hugetlb_total_pages())
> > >  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> > > 
> > > Index: b/mm/swap.c
> > > ===================================================================
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -519,7 +519,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
> > >   * We tolerate a little inaccuracy to avoid ping-ponging the counter between
> > >   * CPUs
> > >   */
> > > -#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
> > > +#define ACCT_THRESHOLD	max_t(long, 16, num_online_cpus() * 2)
> > >
> > 
> > Hmm.. this is a one time expansion, free of CPU hotplug.
> > 
> > Should we use nr_cpu_ids or num_possible_cpus()?
> 
> #define num_online_cpus()       cpumask_weight(cpu_online_mask)
> #define num_possible_cpus()     cpumask_weight(cpu_possible_mask)
> 
> num_possible_cpus() have the same calculation cost.
> nr_cpu_ids isn't proper value.
> it point to valid cpu-id range, no related number of online nor possible cpus.
>

Since the value is just a basis for thresholds, num_online_cpus()
might work. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
