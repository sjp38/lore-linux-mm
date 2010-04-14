Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C8D1B6B020F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 21:44:04 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E1i1aO010670
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 10:44:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B97E45DE70
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:44:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4883945DE60
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:44:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C9A81DB8040
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:44:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D33E61DB803B
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:44:00 +0900 (JST)
Date: Wed, 14 Apr 2010 10:40:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
	<20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 10:03:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > > @@ -2563,6 +2565,15 @@ void mem_cgroup_end_migration(struct mem
> > >  	 */
> > >  	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > >  		mem_cgroup_uncharge_page(target);
> > > +	else {
> > > +		/*
> > > +		 * When a migrated file cache is remapped, it's not charged.
> > > +		 * Verify it. Because we're under lock_page(), there are
> > > +		 * no race with uncharge.
> > > +		 */
> > > +		if (page_mapped(target))
> > > +			mem_cgroup_update_file_mapped(mem, target, 1);
> > > +	}
> > We cannot rely on page lock, because when we succeeded in page migration,
> > "target" = "newpage" has already unlocked in move_to_new_page(). So the "target"
> > can be removed from the radix-tree theoretically(it's not related to this
> > underflow problem, though).
> > Shouldn't we call lock_page(target) and check "if (!target->mapping)" to handle
> > this case(maybe in another patch) ?
> > 
> Sounds reasonable. I think about that.
> 

Ah, PageCgroupUsed() is already checked under lock_page_cgroup(). It's enough.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
