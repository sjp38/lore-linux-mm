Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DEE26B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 19:58:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 40FD53EE0BC
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 09:58:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8545845DE69
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 09:58:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C7145DE61
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 09:58:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5238B1DB8040
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 09:58:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EEFD61DB803C
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 09:58:08 +0900 (JST)
Date: Thu, 6 Jan 2011 09:52:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-Id: <20110106095211.b35f012b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
	<20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jan 2011 15:47:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 5 Jan 2011 13:48:50 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Hi,
> > 
> > On Wed, Jan 5, 2011 at 1:00 PM, Daisuke Nishimura
> > <nishimura@mxp.nes.nec.co.jp> wrote:
> > > Hi.
> > >
> > > This is a fix for a problem which has bothered me for a month.
> > >
> > > ===
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > >
> > > In current implimentation, mem_cgroup_end_migration() decides whether the page
> > > migration has succeeded or not by checking "oldpage->mapping".
> > >
> > > But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> > > NULL from the begining, so the check would be invalid.
> > > As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> > > even if it's not, so "newpage" would be freed while it's not uncharged.
> > >
> > > This patch fixes it by passing mem_cgroup_end_migration() the result of the
> > > page migration.
> > >
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > Nice catch. I don't oppose the patch.
> Thank you for your review.
> 

Nice catch.


> > But as looking the code in unmap_and_move, I feel part of mem cgroup
> > migrate is rather awkward.
> > 
> > int unmap_and_move()
> > {
> >    charge = mem_cgroup_prepare_migration(xxx);
> >    ..
> >    BUG_ON(charge); <-- BUG if it is charged?
> >    ..
> > uncharge:
> >    if (!charge)    <-- why do we have to uncharge !charge?
> >       mem_group_end_migration(xxx);
> >    ..
> > }
> > 
> > 'charge' local variable isn't good. How about changing "uncharge" or whatever?
> hmm, I agree that current code seems a bit confusing, but I can't think of
> better name to imply the result of 'charge'.
> 
> And considering more, I can't understand why we need to check "if (!charge)"
> before mem_cgroup_end_migration() becase it must be always true and, IMHO,
> mem_cgroup_end_migration() should do all necesarry checks to avoid double uncharge.

ok, please remove it.
Before this commit, http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=01b1ae63c2270cbacfd43fea94578c17950eb548;hp=bced0520fe462bb94021dcabd32e99630c171be2

"mem" is not passed as argument and this was the reason for the vairable "charge".

We can check "charge is in moving" by checking "mem == NULL".


> So, I think this local variable can be removed completely.
> 
> 	rc = mem_cgroup_prepare_migration(..);
> 	if (rc == -ENOMEM)
> 		goto unlock;
> 	BUG_ON(rc);
> 	..
> uncharge:
> 	mem_cgroup_end_migration(..);
> 
> KAMEZAWA-san, what do you think ?
> 

seems ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
