Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 77A236B0055
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 20:59:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H0xhSa012159
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Jul 2009 09:59:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C73A45DE50
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:59:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2346345DE5A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:59:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CDD401DB8038
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:59:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 50B64E38004
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:59:42 +0900 (JST)
Date: Fri, 17 Jul 2009 09:57:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090717090003.A903.A69D9226@jp.fujitsu.com>
References: <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
	<alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
	<20090717090003.A903.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009 09:04:46 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, 15 Jul 2009, Lee Schermerhorn wrote:
> > 
> > > Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> > > possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> > > with memory].  Maybe this is a to support hot-plug?
> > > 
> > 
> > numactl --interleave=all simply passes a nodemask with all bits set, so if 
> > cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
> > then mpol_set_nodemask() doesn't mask them off.
> > 
> > Seems like we could handle this strictly in mempolicies without worrying 
> > about top_cpuset like in the following?
> 
> This patch seems band-aid patch. it will change memory-hotplug behavior.
> Please imazine following scenario:
> 
> 1. numactl interleave=all process-A
> 2. memory hot-add
> 
> before 2.6.30:
> 		-> process-A can use hot-added memory
> 
> your proposal patch:
> 		-> process-A can't use hot-added memory
> 

IMHO, the application itseld should be notifed to change its mempolicy by
hot-plug script on the host. While an application uses interleave, a new node
hot-added is just a noise. I think "How pages are interleaved" should not be
changed implicitly. Then, checking at set_mempolicy() seems sane. If notified,
application can do page migration and rebuild his mapping in ideal way.

BUT I don't linke init->mem_allowed contains N_POSSIBLE...it should be initialized
to N_HIGH_MEMORY, IMHO.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
