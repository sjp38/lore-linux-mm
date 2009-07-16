Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 249BD6B0085
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:05:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G10JNN016570
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 10:00:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6883345DE53
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:00:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4687045DE52
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:00:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26D601DB8041
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:00:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9AC91DB803C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:00:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
Message-Id: <20090716093508.9D05.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 10:00:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2009-07-15 at 18:48 +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > On 2.6.31-rc3, following test makes kernel panic immediately.
> > 
> >   numactl --interleave=all echo
> > 
> > Panic message is below. I don't think commit 58568d2a8 is correct patch.
> > 
> > old behavior:
> >   do_set_mempolicy
> >     mpol_new
> >       cpuset_update_task_memory_state
> >         guarantee_online_mems
> >           nodes_and(cs->mems_allowed, node_states[N_HIGH_MEMORY]);
> > 
> > but new code doesn't consider N_HIGH_MEMORY. Then, the userland program
> > passing non-online node bit makes crash, I guess.
> > 
> > Miao, What do you think?
> 
> This looks similar to the problem I tried to fix in:
> 
> 	http://marc.info/?l=linux-mm&m=124140637722309&w=4
> 
> Miao pointed out that the patch needs more work to track hot plug of
> nodes.  I've not had time to get back to this.
> 
> Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> with memory].  Maybe this is a to support hot-plug?

Maybe.

task->mems_allowed of the init process is initialized by node_possible_map.
if the system doesn't have memory hot-plug capability, node_possible_map
is equal to node_online_map.


-------------------------------------------------
@@ -867,6 +866,11 @@ static noinline int init_post(void)
 static int __init kernel_init(void * unused)
 {
        lock_kernel();
+
+       /*
+        * init can allocate pages on any node
+        */
+       set_mems_allowed(node_possible_map);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
