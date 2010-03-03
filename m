Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D6A96B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:48:12 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o230mA8J011295
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 09:48:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DBC245DE50
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:48:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ECBA45DE4E
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:48:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BBFC1DB8015
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:48:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B257F1DB8014
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:48:09 +0900 (JST)
Date: Wed, 3 Mar 2010 09:44:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301052306.GG19665@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
	<20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
	<20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 16:38:16 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > This patch causes a regression???  You never said that in any of your 
> > > reviews and I have no idea what you're talking about, this patch simply 
> > > cleans up the code and closes a race where VM_FAULT_OOM could needlessly 
> > > kill tasks in parallel oom conditions.
> > > 
> > try_set_system_oom() is not called in memory_cgroup_out_of_memory() path.
> > Then, oom kill twice.
> > 
> 
> So how does this cause a regression AT ALL?  Calling try_set_system_oom() 
> in pagefault_out_of_memory() protects against concurrent out_of_memory() 
> from the page allocator before a task is actually killed.  So this patch 
> closes that race entirely.  So it most certainly does not introduce a 
> regression.
> 
> You said earlier that mem_cgroup_out_of_memory() need not serialize 
> against parallel oom killings because in that scenario we must kill 
> something anyway, memory freeing from other ooms won't help if a memcg is 
> over its limit.  So, yeah, we may kill two tasks if both the system and a 
> memcg are oom in parallel and neither have actually killed a task yet, but 
> that's much more jusitiable since we shouldn't rely on a memcg oom to free 
> memory for the entire system.
> 
> So, again, there's absolutely no regression introduced by this patch.
> 
I'm sorry if I miss somthing.

memory_cgroup_out_of_memory() kills a task. and return VM_FAULT_OOM then,
page_fault_out_of_memory() kills another task.
and cause panic if panic_on_oom=1.

Then, if we remove mem_cgroup_oom_called(), we have to take care that
memcg doesn't cause VM_FAULT_OOM.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
