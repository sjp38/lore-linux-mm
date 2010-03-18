Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0DC6B0095
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 12:29:25 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2IGT0IY021429
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 21:59:00 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2IGT0883248226
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 21:59:00 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2IGSxTL019329
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 21:58:59 +0530
Date: Thu, 18 Mar 2010 21:58:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100318162855.GG18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-2-git-send-email-arighi@develer.com>
 <20100317115855.GS18054@balbir.in.ibm.com>
 <20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
 <20100318041944.GA18054@balbir.in.ibm.com>
 <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:

> On Thu, 18 Mar 2010 09:49:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 08:54:11]:
> > 
> > > On Wed, 17 Mar 2010 17:28:55 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * Andrea Righi <arighi@develer.com> [2010-03-15 00:26:38]:
> > > > 
> > > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > 
> > > > > Now, file-mapped is maintaiend. But more generic update function
> > > > > will be needed for dirty page accounting.
> > > > > 
> > > > > For accountig page status, we have to guarantee lock_page_cgroup()
> > > > > will be never called under tree_lock held.
> > > > > To guarantee that, we use trylock at updating status.
> > > > > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > > > >
> > > > 
> > > > I don't like this at all, but in almost all cases is not acceptable
> > > > for statistics, since decisions will be made on them and having them
> > > > incorrect is really bad. Could we do a form of deferred statistics and
> > > > fix this.
> > > > 
> > > 
> > > plz show your implementation which has no performance regresssion.
> > > For me, I don't neee file_mapped accounting, at all. If we can remove that,
> > > we can add simple migration lock.
> > 
> > That doesn't matter, if you need it, I think the larger user base
> > matters. Unmapped and mapped page cache is critical and I use it
> > almost daily.
> > 
> > > file_mapped is a feattue you added. please improve it.
> > >
> > 
> > I will, but please don't break it silently
> > 
> Andrea, could you go in following way ?
> 
> 	- don't touch FILE_MAPPED stuff.
> 	- add new functions for other dirty accounting stuff as in this series.
> 	  (using trylock is ok.)
> 
> Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> fault. But please write "why add new function" to patch description.
> 
> I'm sorry for wasting your time.

Do we need to go down this route? We could check the stat and do the
correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
and for others potentially look at trylock. It is OK for different
stats to be protected via different locks.

/me takes a look at the code again.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
