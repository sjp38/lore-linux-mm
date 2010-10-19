Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 362C06B0085
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:10:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J1Ab88005563
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:10:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6522145DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:10:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1550445DE55
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:10:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC21A1DB8041
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:10:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B1ABE38008
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:10:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <alpine.DEB.2.00.1010181034530.1294@router.home>
References: <20101018182035.3AFB.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010181034530.1294@router.home>
Message-Id: <20101019101012.A1B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 10:10:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > @@ -245,6 +261,11 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
> >  	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
> >  	s8 *p = pcp->vm_stat_diff + item;
> >
> > +	if (unlikely(!vm_stat_drift_take(zone, item))) {
> > +		zone_page_state_add(-1, zone, item);
> > +		return;
> > +	}
> > +
> >  	(*p)--;
> >
> >  	if (unlikely(*p < - pcp->stat_threshold)) {
> 
> Increased overhead for basic VM counter management.
> 
> Instead of all of this why not simply set the stat_threshold to 0 for
> select cpus?

hmm... difficult. but I will think this way a while ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
