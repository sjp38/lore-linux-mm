Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB1146B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 20:01:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2311n1l011507
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 10:01:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2698745DE50
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:01:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 088CC45DE4F
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:01:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E50D7E38003
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:01:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B2321DB804A
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:01:48 +0900 (JST)
Date: Wed, 3 Mar 2010 09:58:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301052306.GG19665@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
	<20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
	<20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
	<20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 16:53:00 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > memory_cgroup_out_of_memory() kills a task. and return VM_FAULT_OOM then,
> > page_fault_out_of_memory() kills another task.
> > and cause panic if panic_on_oom=1.
> > 
> 
> If mem_cgroup_out_of_memory() has returned, then it has already killed a 
> task that will have TIF_MEMDIE set and therefore make the VM_FAULT_OOM oom 
> a no-op.  If the oom killed task subsequently returns VM_FAULT_OOM, we 
> better panic because we've fully depleted memory reserves and no future 
> memory freeing is guaranteed.
> 
In patch 01-03, you don't modified panic_on_oom implementation.
And this patch, you don't modified the return code of memcg's charge code.
It still returns -ENOMEM.

Then, VM_FAULT_OOM is returned and page_fault_out_of_memory() calles this
and hit this.

       case CONSTRAINT_NONE:
                if (sysctl_panic_on_oom) {
                        dump_header(NULL, gfp_mask, order, NULL);
                        panic("out of memory. panic_on_oom is selected\n");
                }

The system will panic. A hook, mem_cgroup_oom_called() is for avoiding this.
memcg's oom doesn't mean memory shortage, just means it his limit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
