Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 68C4C6B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 03:47:02 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S7kxiT022288
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 16:46:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6D745DE50
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:46:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 036FE45DE4D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:46:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BD42E38002
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:46:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4890E1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:46:58 +0900 (JST)
Date: Wed, 28 Oct 2009 16:44:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: make memcg's file mapped consistent with global
 VM
Message-Id: <20091028164430.bc660f25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091028073212.GO16378@balbir.in.ibm.com>
References: <20091028121619.c094e9c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20091028071854.GL16378@balbir.in.ibm.com>
	<20091028162458.45865281.kamezawa.hiroyu@jp.fujitsu.com>
	<20091028073212.GO16378@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009 13:02:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-10-28 16:24:58]:
> 
> > On Wed, 28 Oct 2009 12:48:54 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-10-28 12:16:19]:
> > > 
> > > > Based on mmotm-Oct13 + some patches in -mm queue.
> > > > 
> > > > ==
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > 
> > > > memcg-cleanup-file-mapped-consistent-with-globarl-vm-stat.patch
> > > > 
> > > > In global VM, FILE_MAPPED is used but memcg uses MAPPED_FILE.
> > > > This makes grep difficult. Replace memcg's MAPPED_FILE with FILE_MAPPED
> > > > 
> > > > And in global VM, mapped shared memory is accounted into FILE_MAPPED.
> > > > But memcg doesn't. fix it.
> > > 
> > > I wanted to explicitly avoid this since I wanted to do an iterative
> > > correct accounting of shared memory. The renaming is fine with me
> > > since we don't break ABI in user space.
> > > 
> > To do that, FILE_MAPPED is not correct.
> > Because MAPPED includes shmem in global VM, no valid reason to do different
> > style of counting.
> 
> OK, fair enough! Lets count shmem in FILE_MAPPED
> 
> > 
> > For shmem, we have a charge type as MEM_CGROUP_CHARGE_TYPE_SHMEM and 
> > we can set "PCG_SHMEM" flag onto page_cgroup or some.
> > Then, we can count it in explicit way. 
> >
> 
> Apart from shmem, I want to count all memory that is shared (mapcount > 1),
> I'll send out an RFC once I have the implementation.

I recommend you to start from adding new statistics to global VM to show that.
(Then, we don't need to say "this is a special counter for memcg.....)

> For now, I
> want to focus on testing memcg a bit more and start looking at some
> aspects of dirty accounting.
> 
I'm now cleaning up and test array counter (I posted before.) which works as
vm_stat[] for memcg. Maybe it will be useful.

A bit off-topic, let me show my current TO-DO-LIST.

  - implementing a counter like vm_stat[]
  - wait for Nishimura's task move patches.
  - implementing dirty_page accounting in very simple style.
  - implementing dirty_page limiting or kicking flusher thread for memcg.
  - fix oom-killer related things.
  - some necessary clean-ups.
  - implementing memory usage notifier or oom-notifier to userland.
  - helping I/O controller for buffered I/O tracking.

Because I don't fix priority of each jobs, someone unknown may finish
before I start ;)

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
