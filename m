Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EBBA96B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:25:40 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G5PcTn019975
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 14:25:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 206B745DE53
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:25:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E3DC545DE52
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:25:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA3EDE38002
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:25:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 69BCF1DB803C
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:25:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 5/7 -mm] oom: replace sysctls with quick mode
In-Reply-To: <alpine.DEB.2.00.1002151411530.26927@chino.kir.corp.google.com>
References: <20100215170634.729E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151411530.26927@chino.kir.corp.google.com>
Message-Id: <20100216141539.72EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 14:25:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Feb 2010, KOSAKI Motohiro wrote:
> 
> > > Two VM sysctls, oom dump_tasks and oom_kill_allocating_task, were
> > > implemented for very large systems to avoid excessively long tasklist
> > > scans.  The former suppresses helpful diagnostic messages that are
> > > emitted for each thread group leader that are candidates for oom kill
> > > including their pid, uid, vm size, rss, oom_adj value, and name; this
> > > information is very helpful to users in understanding why a particular
> > > task was chosen for kill over others.  The latter simply kills current,
> > > the task triggering the oom condition, instead of iterating through the
> > > tasklist looking for the worst offender.
> > > 
> > > Both of these sysctls are combined into one for use on the aforementioned
> > > large systems: oom_kill_quick.  This disables the now-default
> > > oom_dump_tasks and kills current whenever the oom killer is called.
> > > 
> > > The oom killer rewrite is the perfect opportunity to combine both sysctls
> > > into one instead of carrying around the others for years to come for
> > > nothing else than legacy purposes.
> > 
> > "_quick" is always bad sysctl name.
> 
> Why?  It does exactly what it says: it kills current without doing an 
> expensive tasklist scan and suppresses the possibly long tasklist dump.  
> That's the oom killer's "quick mode."

Because, an administrator think "_quick" implies "please use it always".
plus, "quick" doesn't describe clealy meanings. oom_dump_tasks does.



> > instead, turnning oom_dump_tasks on
> > by default is better.
> > 
> 
> It's now on by default and can be disabled by enabling oom_kill_quick.
> 
> > plus, this patch makes unnecessary compatibility issue.
> > 
> 
> It's the perfect opportunity when totally rewriting the oom killer to 
> combine two sysctls with the exact same users into one.  Users will notice 
> that the tasklist is always dumped now (we're defaulting oom_dump_tasks 
> to be enabled), so there is no reason why we can't remove oom_dump_tasks, 
> we're just giving them a new way to disable it.  oom_kill_allocating_task 
> no longer always means what it once did: with the mempolicy-constrained 
> oom rewrite, we now iterate the tasklist for such cases to kill a task.  
> So users need to reassess whether this should be set if all tasks on the 
> system are constrained by mempolicies, a typical configuration for 
> extremely large systems.  

No.
Your explanation doesn't answer why this change don't cause any comatibility
issue to _all_ user. Merely "opportunity" doesn't allow we ignore real world user.
I had made some incompatibility patch too, but all one have unavoidable reason. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
