Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5E56B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 21:37:41 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o1H2bf4c000839
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:37:41 -0800
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by spaceape14.eur.corp.google.com with ESMTP id o1H2bbBS014424
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:37:40 -0800
Received: by pxi36 with SMTP id 36so1814982pxi.20
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:37:37 -0800 (PST)
Date: Tue, 16 Feb 2010 18:37:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217112353.b90f732a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161833360.20350@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
 <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com> <20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com> <20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com> <20100217112353.b90f732a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> And basically. memcg's oom means "the usage over the limits!!" and does
> never means "resouce is exhausted!!".
> 
> Then, marking OOM to zones sounds strange. You can cause oom in 64MB memcg
> in 64GB system.
> 

ZONE_OOM_LOCKED is taken system-wide because the result of a memcg oom is 
that a task will get killed and free memory, so VM_FAULT_OOM doesn't 
require any additional killing if we're oom, it should just retry after 
the task has exited.  If we remove the zone locking for memcg, it is 
possible that pagefaults will race with setting TIF_MEMDIE and two tasks 
get killed instead.  I guess that's acceptable considering its just as 
likely that the memcg will reallocate to the same limit again and cause 
VM_FAULT_OOM to rekill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
