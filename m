Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D0426B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 22:24:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H3OeSF005763
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 12:24:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6707E45DE59
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 12:24:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A17F45DE4F
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 12:24:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7830A1DB803E
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 12:24:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F2E8E38004
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 12:24:38 +0900 (JST)
Date: Wed, 17 Feb 2010 12:21:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100217122106.31e12398.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
	<20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
	<20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
	<20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
	<20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
	<20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
	<20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 18:58:17 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > We want to lock all populated zones with ZONE_OOM_LOCKED to avoid 
> > > needlessly killing more than one task regardless of how many memcgs are 
> > > oom.
> > > 
> > Current implentation archive what memcg want. Why remove and destroy memcg ?
> > 
> 
> I've updated my patch to not take ZONE_OOM_LOCKED for any zones on memcg 
> oom.  I'm hoping that you will add sysctl_panic_on_oom == 2 for this case 
> later, however.
> 
I'll write panic_on_oom for memcg, later. 

> > What I mean is
> >  - What VM_FAULT_OOM means is not "memory is exhausted" but "something is exhausted".
> > 
> > For example, when hugepages are all used, it may return VM_FAULT_OOM.
> > Especially when nr_overcommit_hugepage == usage_of_hugepage, it returns VM_FAULT_OOM.
> > 
> 
> The hugetlb case seems to be the only misuse of VM_FAULT_OOM where it 
> doesn't mean we simply don't have the memory to handle the page fault, 
> i.e. your earlier "memory is exhausted" definition.  That was handled well 
> before calling out_of_memory() by simply killing current since we know it 
> is faulting hugetlb pages and its resource is limited.
> 
> We could pass the vma to pagefault_out_of_memory() and simply kill current 
> if its killable and is_vm_hugetlb_page(vma).
> 

No. hugepage is not only case.
You may not read but we annoyed i915's driver bug recently and it was clearly
misuse of VM_FAULT_OOM. Then, we got many reports of OOM killer in these months.
(thanks to Kosaki about this.)

quick glance around core codes...
 - HUGEPAGE at el. should return some VM_FAULT_NO_RESOUECE rather than VM_FAULT_OOM.
 - filemap.c's VM_FAULT_OOM shoudn't call page_fault_oom_kill because it has already
   called oom_killer if it can. 
 - about relayfs, is VM_FAULT_OOM should be BUG_ON()...
 - filemap_xip.c return VM_FAULT_OOM....but it doesn't seem to be OOM..
   just like VM_FAULT_NO_VALID_PAGE_FOUND. (But I'm not familiar with this area.)
 - fs/buffer.c 's VM_FAULT_OOM is returned oom-killer is called.
 - shmem.c's VM_FAULT_OOM is retuned oom-killer is called.

i915's VM_FAULT_OOM is miterious but I can't find whether its real OOM or just shortage
of is own resource. I think VM_FAULT_NO_RESOUCE should be added.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
