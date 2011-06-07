Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4EA6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 19:52:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0523B3EE0C1
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 08:52:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE00345DE53
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 08:52:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB78745DE50
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 08:52:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5131DB8040
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 08:52:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 668CD1DB803E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 08:52:29 +0900 (JST)
Date: Wed, 8 Jun 2011 08:45:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110608084538.99e395fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110607102611.GA26954@cmpxchg.org>
References: <20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
	<20110606125421.GB30184@cmpxchg.org>
	<20110606144519.1e2e7d86.akpm@linux-foundation.org>
	<20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607075131.GB22234@cmpxchg.org>
	<20110607165537.dc9e8888.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607102611.GA26954@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>

On Tue, 7 Jun 2011 12:26:11 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Jun 07, 2011 at 04:55:37PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 7 Jun 2011 09:51:31 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > @@ -283,23 +285,30 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
> > >  
> > >  void __init page_cgroup_init(void)
> > >  {
> > > -	unsigned long pfn;
> > > -	int fail = 0;
> > > +	pg_data_t *pgdat;
> > >  
> > >  	if (mem_cgroup_disabled())
> > >  		return;
> > >  
> > > -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> > > -		if (!pfn_present(pfn))
> > > -			continue;
> > > -		fail = init_section_page_cgroup(pfn);
> > > -	}
> > > -	if (fail) {
> > > -		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> > > -		panic("Out of memory");
> > > -	} else {
> > > -		hotplug_memory_notifier(page_cgroup_callback, 0);
> > > +	for_each_online_pgdat(pgdat) {
> > > +		unsigned long start;
> > > +		unsigned long end;
> > > +		unsigned long pfn;
> > > +
> > > +		start = pgdat->node_start_pfn & ~(PAGES_PER_SECTION - 1);
> > > +		end = ALIGN(pgdat->node_start_pfn + pgdat->node_spanned_pages,
> > > +			    PAGES_PER_SECTION);
> > > +		for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
> > > +			if (!pfn_present(pfn))
> > > +				continue;
> > > +			if (!init_section_page_cgroup(pgdat->node_id, pfn))
> > > +				continue;
> > 
> > AFAIK, nodes can overlap. So, this [start, end) scan doesn't work. sections
> > may be initizalised mulitple times ...in wrong way. At here, what we can trust
> > is nid in page->flags or early_node_map[]?.
> 
> Sections are not be initialized multiple times.  Once their
> page_cgroup array is allocated they are skipped if considered again
> later.
> 
> Second, even if there are two nodes backing the memory of a single
> section, there is still just a single page_cgroup array per section,
> we have to take the memory from one node or the other.
> 
> So if both node N1 and N2 fall into section SN, SN->page_cgroup will
> be an array of page_cgroup structures, allocated on N1, to represent
> the pages of SN.
> 
> The first section considered when walking the PFNs of N2 will be SN,
> which will be skipped because of !!SN->page_cgroup.
> 
> I do not see the problem.
> 

Assume a host with node layout

N0 | N1 | N2 | N3 | N4 | N0


pages for all node will be allocated onto node-0.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
