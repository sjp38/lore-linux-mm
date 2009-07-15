Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A89A6B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 12:50:36 -0400 (EDT)
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 15 Jul 2009 13:31:04 -0400
Message-Id: <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-15 at 18:48 +0900, KOSAKI Motohiro wrote:
> Hi
> 
> On 2.6.31-rc3, following test makes kernel panic immediately.
> 
>   numactl --interleave=all echo
> 
> Panic message is below. I don't think commit 58568d2a8 is correct patch.
> 
> old behavior:
>   do_set_mempolicy
>     mpol_new
>       cpuset_update_task_memory_state
>         guarantee_online_mems
>           nodes_and(cs->mems_allowed, node_states[N_HIGH_MEMORY]);
> 
> but new code doesn't consider N_HIGH_MEMORY. Then, the userland program
> passing non-online node bit makes crash, I guess.
> 
> Miao, What do you think?

This looks similar to the problem I tried to fix in:

	http://marc.info/?l=linux-mm&m=124140637722309&w=4

Miao pointed out that the patch needs more work to track hot plug of
nodes.  I've not had time to get back to this.

Interestingly, on ia64, the top cpuset mems_allowed gets set to all
possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
with memory].  Maybe this is a to support hot-plug?

Lee

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
