Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0EB8D6B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 19:04:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H04uqx029888
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 09:04:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D388E45DE50
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:04:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B214845DE4D
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:04:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BFC1E38001
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:04:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 507D51DB803E
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 09:04:52 +0900 (JST)
Date: Wed, 17 Feb 2010 09:01:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
	<20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
	<20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
	<20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 15:54:50 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> > Then, please leave panic_on_oom=always.
> > Even with mempolicy or cpuset 's OOM, we need panic_on_oom=always option.
> > And yes, I'll add something similar to memcg. freeze_at_oom or something.
> > 
> 
> Memcg isn't a special case here, it should also panic the machine if 
> panic_on_oom == 2, so if we aren't going to remove this option then I 
> agree with Nick that we need to panic from mem_cgroup_out_of_memory() as 
> well.  Some users use cpusets, for example, for the same effect of memory 
> isolation as you use memcg, so panicking in one scenario and not the other 
> is inconsistent.
> 
Hmm, I have a few reason to add special behavior to memcg rather than panic.

 - freeze_at_oom is enough.
   If OOM can be notified, the management daemon can do useful jobs. Shutdown
   all other cgroups or migrate them to other host and do kdump.

 - memcg's oom is not very complicated.
   Because we just counts RSS+FileCache

But, Hmm...I'd like to go this way.

 1. At first, support panic_on_oom=2 in memcg.

 2. Second, I'll add OOM-notifier and freeze_at_oom to memcg.
    and don't call memcg_out_of_memory in oom_kill.c in this case. Because
    we don't kill anything. Taking coredumps of all procs in memcg is not
    very difficult.

I need to discuss with memcg guys. But this will be a way to go, I think

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
