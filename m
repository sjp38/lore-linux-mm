Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 69BD96B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:41:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H2f22K022194
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Jul 2009 11:41:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A24BA45DE51
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:41:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39E4B45DE57
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:41:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FFC1E78003
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:41:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F211DB8040
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:41:00 +0900 (JST)
Date: Fri, 17 Jul 2009 11:39:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090717113911.c49395ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090717104512.A914.A69D9226@jp.fujitsu.com>
References: <20090717090003.A903.A69D9226@jp.fujitsu.com>
	<20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090717104512.A914.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009 11:07:09 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Fri, 17 Jul 2009 09:04:46 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > On Wed, 15 Jul 2009, Lee Schermerhorn wrote:
> > > > 
> > > > > Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> > > > > possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> > > > > with memory].  Maybe this is a to support hot-plug?
> > > > > 
> > > > 
> > > > numactl --interleave=all simply passes a nodemask with all bits set, so if 
> > > > cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
> > > > then mpol_set_nodemask() doesn't mask them off.
> > > > 
> > > > Seems like we could handle this strictly in mempolicies without worrying 
> > > > about top_cpuset like in the following?
> > > 
> > > This patch seems band-aid patch. it will change memory-hotplug behavior.
> > > Please imazine following scenario:
> > > 
> > > 1. numactl interleave=all process-A
> > > 2. memory hot-add
> > > 
> > > before 2.6.30:
> > > 		-> process-A can use hot-added memory
> > > 
> > > your proposal patch:
> > > 		-> process-A can't use hot-added memory
> > > 
> > 
> > IMHO, the application itseld should be notifed to change its mempolicy by
> > hot-plug script on the host. While an application uses interleave, a new node
> > hot-added is just a noise. I think "How pages are interleaved" should not be
> > changed implicitly. Then, checking at set_mempolicy() seems sane. If notified,
> > application can do page migration and rebuild his mapping in ideal way.
> 
> Do you really want ABI change?
> 
No ;_

Hmm, IIUC, current handling of nodemask of mempolicy is below.
There should be 3 masks.
  - systems's N_HIGH_MEMORY
  - the mask user specified via mempolicy() (remembered only when MPOL_F_RELATIVE
  - cpusets's one

And pol->v.nodes is just a _cache_ of logical-and of aboves.
Synchronization with cpusets is guaranteed by cpuset's generation.
Synchronization with N_HIGH_MEMORY should be guaranteed by memory hotplug
notifier, but this is not implemented yet.

Then, what I can tell here is...
 - remember what's user requested. (only when MPOL_F_RELATIVE_NODES ?)
 - add notifiers for memory hot-add. (only when MPOL_F_RELATIVE_NODES ?)
 - add notifiers for memory hot-remove (both MPOL_F_STATIC/RELATIVE_NODES ?)

IMHO, for cpusets, don't calculate v.nodes again if MPOL_F_STATIC is good.
But for N_HIGH_MEMORY, v.nodes should be caluculated even if MPOL_F_STATIC is set.

Then, I think the mask user passed should be remembered even if MPOL_F_STATIC is
set and v.nodes should work as cache and should be updated in appropriate way.

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
