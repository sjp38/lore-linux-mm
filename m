Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DCF6F8D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:45:22 -0500 (EST)
Date: Mon, 28 Feb 2011 11:40:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: clean up migration
Message-Id: <20110228114006.89177ce7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <AANLkTik44K60MLTw_m431xd3ZFatAo=9O+42jUHscdFR@mail.gmail.com>
References: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
	<20110228111822.41484020.nishimura@mxp.nes.nec.co.jp>
	<AANLkTik44K60MLTw_m431xd3ZFatAo=9O+42jUHscdFR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> >> @@ -678,13 +675,11 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >> A  A  A  }
> >>
> >> A  A  A  /* charge against new page */
> >> - A  A  charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
> >> - A  A  if (charge == -ENOMEM) {
> >> - A  A  A  A  A  A  rc = -ENOMEM;
> >> + A  A  rc = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
> >> + A  A  if (rc)
> >> A  A  A  A  A  A  A  goto unlock;
> >> - A  A  }
> >> - A  A  BUG_ON(charge);
> >>
> >> + A  A  rc = -EAGAIN;
> >> A  A  A  if (PageWriteback(page)) {
> >> A  A  A  A  A  A  A  if (!force || !sync)
> >> A  A  A  A  A  A  A  A  A  A  A  goto uncharge;
> > How about
> >
> > A  A  A  A if (mem_cgroup_prepare_migration(..)) {
> > A  A  A  A  A  A  A  A rc = -ENOMEM;
> > A  A  A  A  A  A  A  A goto unlock;
> > A  A  A  A }
> >
> > ?
> >
> > Re-setting "rc" to -EAGAIN is not necessary in this case.
> > "if (mem_cgroup_...)" is commonly used in many places.
> >
> It works now but Johannes doesn't like it and me, either.
> It makes unnecessary dependency which mem_cgroup_preparre_migration
> can't propagate error to migrate_pages.
> Although we don't need it, I want to remove such unnecessary dependency.
> 
I see.
Thank you for your explanation.

Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
