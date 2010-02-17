Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BD2E76B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 21:58:24 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id o1H2wNtN006586
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:58:23 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by spaceape7.eur.corp.google.com with ESMTP id o1H2w3B7000973
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:58:21 -0800
Received: by pzk26 with SMTP id 26so2773845pzk.25
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:58:21 -0800 (PST)
Date: Tue, 16 Feb 2010 18:58:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161850540.3106@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com> <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com> <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com> <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
 <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com> <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> > We want to lock all populated zones with ZONE_OOM_LOCKED to avoid 
> > needlessly killing more than one task regardless of how many memcgs are 
> > oom.
> > 
> Current implentation archive what memcg want. Why remove and destroy memcg ?
> 

I've updated my patch to not take ZONE_OOM_LOCKED for any zones on memcg 
oom.  I'm hoping that you will add sysctl_panic_on_oom == 2 for this case 
later, however.

> What I mean is
>  - What VM_FAULT_OOM means is not "memory is exhausted" but "something is exhausted".
> 
> For example, when hugepages are all used, it may return VM_FAULT_OOM.
> Especially when nr_overcommit_hugepage == usage_of_hugepage, it returns VM_FAULT_OOM.
> 

The hugetlb case seems to be the only misuse of VM_FAULT_OOM where it 
doesn't mean we simply don't have the memory to handle the page fault, 
i.e. your earlier "memory is exhausted" definition.  That was handled well 
before calling out_of_memory() by simply killing current since we know it 
is faulting hugetlb pages and its resource is limited.

We could pass the vma to pagefault_out_of_memory() and simply kill current 
if its killable and is_vm_hugetlb_page(vma).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
