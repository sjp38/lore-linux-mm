Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 19E536B004A
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 03:25:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A440A3EE081
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:25:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C20845DEA6
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:25:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7627D45DE9E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:25:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 649A01DB803B
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:25:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CB0C1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:25:32 +0900 (JST)
Date: Thu, 16 Feb 2012 17:24:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock
 splitting
Message-Id: <20120216172409.5fa18608.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F3C9798.7050800@openvz.org>
References: <20120215224221.22050.80605.stgit@zurg>
	<20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>
	<4F3C9798.7050800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 16 Feb 2012 09:43:52 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Thu, 16 Feb 2012 02:57:04 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:

> >> * optimize page to book translations, move it upper in the call stack,
> >>    replace some struct zone arguments with struct book pointer.
> >>
> >
> > a page->book transrater from patch 2/15
> >
> > +struct book *page_book(struct page *page)
> > +{
> > +	struct mem_cgroup_per_zone *mz;
> > +	struct page_cgroup *pc;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return&page_zone(page)->book;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	if (!PageCgroupUsed(pc))
> > +		return&page_zone(page)->book;
> > +	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> > +	smp_rmb();
> > +	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
> > +			page_to_nid(page), page_zonenum(page));
> > +	return&mz->book;
> > +}
> >
> > What happens when pc->mem_cgroup is rewritten by move_account() ?
> > Where is the guard for lockless access of this ?
> 
> Initially this suppose to be protected with lru_lock, in final patch they are protected with rcu.

Hmm, VM_BUG_ON(!PageLRU(page)) ?

move_account() overwrites pc->mem_cgroup with isolating page from LRU.
but it doesn't take lru_lock.

BTW, what amount of perfomance benefit ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
