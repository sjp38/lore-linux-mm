Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C384F6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:07:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H27CG7004840
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 11:07:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D46245DE57
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:07:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 118D145DE55
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:07:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D879D1DB8041
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:07:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DC671DB8045
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:07:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090717090003.A903.A69D9226@jp.fujitsu.com> <20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090717104512.A914.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 11:07:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 17 Jul 2009 09:04:46 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Wed, 15 Jul 2009, Lee Schermerhorn wrote:
> > > 
> > > > Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> > > > possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> > > > with memory].  Maybe this is a to support hot-plug?
> > > > 
> > > 
> > > numactl --interleave=all simply passes a nodemask with all bits set, so if 
> > > cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
> > > then mpol_set_nodemask() doesn't mask them off.
> > > 
> > > Seems like we could handle this strictly in mempolicies without worrying 
> > > about top_cpuset like in the following?
> > 
> > This patch seems band-aid patch. it will change memory-hotplug behavior.
> > Please imazine following scenario:
> > 
> > 1. numactl interleave=all process-A
> > 2. memory hot-add
> > 
> > before 2.6.30:
> > 		-> process-A can use hot-added memory
> > 
> > your proposal patch:
> > 		-> process-A can't use hot-added memory
> > 
> 
> IMHO, the application itseld should be notifed to change its mempolicy by
> hot-plug script on the host. While an application uses interleave, a new node
> hot-added is just a noise. I think "How pages are interleaved" should not be
> changed implicitly. Then, checking at set_mempolicy() seems sane. If notified,
> application can do page migration and rebuild his mapping in ideal way.

Do you really want ABI change?



> BUT I don't linke init->mem_allowed contains N_POSSIBLE...it should be initialized
> to N_HIGH_MEMORY, IMHO.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
