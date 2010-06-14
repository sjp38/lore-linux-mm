Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 686436B01C1
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:08:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5EB8N5g010067
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Jun 2010 20:08:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 55EDD45DE52
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3123445DE51
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DD751DB8038
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 162C21DB803F
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:08:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness score for parent
In-Reply-To: <alpine.DEB.2.00.1006140154370.17771@chino.kir.corp.google.com>
References: <20100613184150.617E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006140154370.17771@chino.kir.corp.google.com>
Message-Id: <20100614194045.9DAB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Jun 2010 20:08:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > It mean we shouldn't assume parent and child have the same mems_allowed,
> > > > perhaps.
> > > > 
> > > 
> > > I'd be happy to have that in oom_kill_process() if you pass the
> > > enum oom_constraint and only do it for CONSTRAINT_CPUSET.  Please add a 
> > > followup patch to my latest patch series.
> > 
> > Please clarify.
> > Why do we need CONSTRAINT_CPUSET filter?
> > 
> 
> Because we don't care about intersecting mems_allowed unless it's a cpuset 
> constrained oom.

OK, I caught your mention. My version have following hunk. 
I think simple nodemask!=NULL check is  is more cleaner.



====================================================
void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
                int order, nodemask_t *nodemask)
{
(snip)
        if (constraint != CONSTRAINT_MEMORY_POLICY)
                nodemask = NULL;
(snip)
        read_lock(&tasklist_lock);
        __out_of_memory(gfp_mask, order, nodemask);
        read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
