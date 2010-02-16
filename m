Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 779A26B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 23:52:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G4q4Sh005380
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 13:52:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB0D45DE55
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B6A145DE51
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FAF21DB8046
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1DC91DB803F
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:52:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com>
Message-Id: <20100216110859.72C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 13:52:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Feb 2010, KOSAKI Motohiro wrote:
> 
> > > Tasks that do not share the same set of allowed nodes with the task that
> > > triggered the oom should not be considered as candidates for oom kill.
> > > 
> > > Tasks in other cpusets with a disjoint set of mems would be unfairly
> > > penalized otherwise because of oom conditions elsewhere; an extreme
> > > example could unfairly kill all other applications on the system if a
> > > single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> > > more memory than allowed.
> > > 
> > > Killing tasks outside of current's cpuset rarely would free memory for
> > > current anyway.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > This patch does right thing and looks promissing. but unfortunately
> > I have to NAK this patch temporary.
> > 
> > This patch is nearly just revert of the commit 7887a3da75. We have to
> > dig archaeology mail log and find why this reverting don't cause
> > the old pain again.
> > 
> 
> Nick is probably wondering why I cc'd him on this patchset, and this is it 
> :)

Good decision :)

> 
> We now determine whether an allocation is constrained by a cpuset by 
> iterating through the zonelist and checking 
> cpuset_zone_allowed_softwall().  This checks for the necessary cpuset 
> restrictions that we need to validate (the GFP_ATOMIC exception is 
> irrelevant, we don't call into the oom killer for those).  We don't need 
> to kill outside of its cpuset because we're not guaranteed to find any 
> memory on those nodes, in fact it allows for needless oom killing if a 
> task sets all of its threads to have OOM_DISABLE in its own cpuset and 
> then runs out of memory.  The oom killer would have killed every other 
> user task on the system even though the offending application can't 
> allocate there.  That's certainly an undesired result and needs to be 
> fixed in this manner.

But this explanation is irrelevant and meaningless. CPUSET can change
restricted node dynamically. So, the tsk->mempolicy at oom time doesn't
represent the place of task's usage memory. plus, OOM_DISABLE can 
always makes undesirable result. it's not special in this case.

The fact is, both current and your heuristics have a corner case. it's
obvious. (I haven't seen corner caseless heuristics). then talking your
patch's merit doesn't help to merge the patch. The most important thing
is, we keep no regression. personally, I incline your one. but It doesn't
mean we can ignore its demerit.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
