Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C8366B018F
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 00:39:19 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2I4dGIC020975
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Mar 2010 13:39:16 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EF1545DE5A
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:39:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A8D845DE4F
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:39:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 45CFCE08001
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:39:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CA93E38008
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:39:09 +0900 (JST)
Date: Thu, 18 Mar 2010 13:35:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100318041944.GA18054@balbir.in.ibm.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010 09:49:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 08:54:11]:
> 
> > On Wed, 17 Mar 2010 17:28:55 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * Andrea Righi <arighi@develer.com> [2010-03-15 00:26:38]:
> > > 
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > > Now, file-mapped is maintaiend. But more generic update function
> > > > will be needed for dirty page accounting.
> > > > 
> > > > For accountig page status, we have to guarantee lock_page_cgroup()
> > > > will be never called under tree_lock held.
> > > > To guarantee that, we use trylock at updating status.
> > > > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > > >
> > > 
> > > I don't like this at all, but in almost all cases is not acceptable
> > > for statistics, since decisions will be made on them and having them
> > > incorrect is really bad. Could we do a form of deferred statistics and
> > > fix this.
> > > 
> > 
> > plz show your implementation which has no performance regresssion.
> > For me, I don't neee file_mapped accounting, at all. If we can remove that,
> > we can add simple migration lock.
> 
> That doesn't matter, if you need it, I think the larger user base
> matters. Unmapped and mapped page cache is critical and I use it
> almost daily.
> 
> > file_mapped is a feattue you added. please improve it.
> >
> 
> I will, but please don't break it silently
> 
Andrea, could you go in following way ?

	- don't touch FILE_MAPPED stuff.
	- add new functions for other dirty accounting stuff as in this series.
	  (using trylock is ok.)
	
Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
mem_cgroup_update_file_mapped(). The look may be messy but it's not your
fault. But please write "why add new function" to patch description.

I'm sorry for wasting your time.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
