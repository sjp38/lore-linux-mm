Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B1526B01FE
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:58:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F6wXsS007207
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Apr 2010 15:58:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7566D45DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:58:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D9CF45DE4D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:58:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F58EE08007
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:58:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE9D9E0800A
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:58:32 +0900 (JST)
Date: Thu, 15 Apr 2010 15:54:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	<g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	<20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Greg Thelen <gthelen@google.com>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 15:21:04 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > The only reason to use trylock in this case is to prevent deadlock
> > when running in a context that may have preempted or interrupted a
> > routine that already holds the bit locked.  In the
> > __remove_from_page_cache() irqs are disabled, but that does not imply
> > that a routine holding the spinlock has been preempted.  When the bit
> > is locked, preemption is disabled.  The only way to interrupt a holder
> > of the bit for an interrupt to occur (I/O, timer, etc).  So I think
> > that in_interrupt() is sufficient.  Am I missing something?
> > 
> IIUC, it's would be enough to prevent deadlock where one CPU tries to acquire
> the same page cgroup lock. But there is still some possibility where 2 CPUs
> can cause dead lock each other(please see the commit e767e056).
> IOW, my point is "don't call lock_page_cgroup() under mapping->tree_lock". 
> 
Hmm, maybe worth to try. We may be able to set/clear all DIRTY/WRITBACK bit
on page_cgroup without mapping->tree_lock.
In such case, of course, the page itself should be locked by lock_page().

But.Hmm..for example.

account_page_dirtied() is the best place to mark page_cgroup dirty. But
it's called under mapping->tree_lock.

Another thinking:
I wonder we may have to change our approach for dirty page acccounting.

Please see task_dirty_inc(). It's for per task dirty limiting.
And you'll notice soon that there is no task_dirty_dec().

Making use of lib/proportions.c's proportion calculation as task_dirty limit or
per-bdi dirty limit does is worth to be considered.
This is very simple and can be implemented without problems we have now.
(Need to think about algorithm itself, but it's used and works well.)
We'll never see complicated race condtions.

I know some guys wants "accurate" accounting, but I myself don't want too much.
Using propotions.c can offer us unified approach with per-task dirty accounting.
or per-bid dirty accouting.

If we do so, memcg will have interface like per-bdi dirty ratio (see below)
[kamezawa@bluextal kvm2]$ ls /sys/block/dm-0/bdi/
max_ratio  min_ratio  power  read_ahead_kb  subsystem  uevent

Maybe
  memory.min_ratio
  memory.max_ratio

And use this instead of  task_dirty_limit(current, pbdi_dirty); As

	if (mem_cgroup_dirty_ratio_support(current)) // return 0 if root cgroup
		memcg_dirty_limit(current, pbdi_dirty, xxxx?);
	else
		task_dirty_limit(current, pbdi_diryt)

To be honest, I don't want to increase caller of lock_page_cgroup() and don't
want to see complicated race conditions.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
