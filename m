Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BCC8A6B0211
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 22:00:07 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E205UU002708
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 11:00:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D526845DE4F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B111F45DE51
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5501DB805A
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 46F271DB803F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:04 +0900 (JST)
Date: Wed, 14 Apr 2010 10:56:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414105608.d40c70ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
	<20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 10:40:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 14 Apr 2010 10:03:08 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > > @@ -2563,6 +2565,15 @@ void mem_cgroup_end_migration(struct mem
> > > >  	 */
> > > >  	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > > >  		mem_cgroup_uncharge_page(target);
> > > > +	else {
> > > > +		/*
> > > > +		 * When a migrated file cache is remapped, it's not charged.
> > > > +		 * Verify it. Because we're under lock_page(), there are
> > > > +		 * no race with uncharge.
> > > > +		 */
> > > > +		if (page_mapped(target))
> > > > +			mem_cgroup_update_file_mapped(mem, target, 1);
> > > > +	}
> > > We cannot rely on page lock, because when we succeeded in page migration,
> > > "target" = "newpage" has already unlocked in move_to_new_page(). So the "target"
> > > can be removed from the radix-tree theoretically(it's not related to this
> > > underflow problem, though).
> > > Shouldn't we call lock_page(target) and check "if (!target->mapping)" to handle
> > > this case(maybe in another patch) ?
> > > 
> > Sounds reasonable. I think about that.
> > 
> 

Thinking again....new page is unlocked here. It means the new page may be
removed from radix-tree before commit_charge().

Haha, it seems totally wrong. please wait..

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
