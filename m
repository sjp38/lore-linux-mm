Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DB4DA5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 00:10:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F4AAaV006574
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 13:10:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC70A45DE61
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8588D45DE51
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC991DB803F
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:10:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D26681DB8041
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 13:10:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: meminfo Committed_AS underflows
In-Reply-To: <20090415033455.GS7082@balbir.in.ibm.com>
References: <20090415105033.AC29.A69D9226@jp.fujitsu.com> <20090415033455.GS7082@balbir.in.ibm.com>
Message-Id: <20090415130042.AC3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 13:10:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:
> 
> >  	committed = atomic_long_read(&vm_committed_space);
> > +	if (committed < 0)
> > +		committed = 0;
> 
> Isn't this like pushing the problem under the rug?

global_page_state() already has same logic.
IOW almost meminfo filed has this one (except Commited_AS).


> >  	allowed = ((totalram_pages - hugetlb_total_pages())
> >  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> > 
> > Index: b/mm/swap.c
> > ===================================================================
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -519,7 +519,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
> >   * We tolerate a little inaccuracy to avoid ping-ponging the counter between
> >   * CPUs
> >   */
> > -#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
> > +#define ACCT_THRESHOLD	max_t(long, 16, num_online_cpus() * 2)
> >
> 
> Hmm.. this is a one time expansion, free of CPU hotplug.
> 
> Should we use nr_cpu_ids or num_possible_cpus()?

#define num_online_cpus()       cpumask_weight(cpu_online_mask)
#define num_possible_cpus()     cpumask_weight(cpu_possible_mask)

num_possible_cpus() have the same calculation cost.
nr_cpu_ids isn't proper value.
it point to valid cpu-id range, no related number of online nor possible cpus.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
