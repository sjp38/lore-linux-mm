Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 75AD66B0085
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 03:04:43 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3R6fI6i027262
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 02:41:18 -0400
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3R74fdX377258
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:04:41 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3R74eFu001877
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:04:41 +1000
Date: Mon, 27 Apr 2009 12:33:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix try_get_mem_cgroup_from_swapcache()
Message-ID: <20090427070342.GD4454@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp> <20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp> <20090427065358.GB4454@balbir.in.ibm.com> <20090427155953.32990d5a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090427155953.32990d5a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-27 15:59:53]:

> On Mon, 27 Apr 2009 12:23:58 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-04-27 09:51:00]:
> > 
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > memcg: fix try_get_mem_cgroup_from_swapcache()
> > > 
> > > This is a bugfix for commit 3c776e64660028236313f0e54f3a9945764422df(included 2.6.30-rc1).
> > > Used bit of swapcache is solid under page lock, but considering move_account,
> > > pc->mem_cgroup is not.
> > > 
> > > We need lock_page_cgroup() anyway.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > I think we need to start documenting the locks the
> > page_cgroup lock nests under.
> > 
> Addin some comments on source code may be necessary.
> 
> > If memcg_tasklist were a spinlock instead of mutex, could we use that
> > instead of page_cgroup lock, since we care only about task migration?
> > 
> 
> Hmm ? Another problem ? I can't catch what you ask.
> move_account() is a function called by force_empty()->"move account to parent"

IIUC, pc->mem_cgroup might change due to task migration and that is
why we've added the page cgroup lock. If the race is between task
migration and force_empty(), we can use the memcg_tasklist by making
it a spinlock.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
