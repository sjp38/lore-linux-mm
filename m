Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4AA606B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:36:46 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB2aif5005133
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 11:36:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 376B045DE55
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:36:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F86145DE52
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:36:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EE24EE1800B
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:36:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F5F1DB803F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:36:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v3
In-Reply-To: <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091111113559.FD4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 11:36:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
> 
> Fixing node-oriented allocation handling in oom-kill.c
> I myself think this as bugfix not as ehnancement.
> 
> In these days, things are changed as
>   - alloc_pages() eats nodemask as its arguments, __alloc_pages_nodemask().
>   - mempolicy don't maintain its own private zonelists.
>   (And cpuset doesn't use nodemask for __alloc_pages_nodemask())
> 
> But, current oom-killer's doesn't handle nodemask and it's wrong.
> 
> This patch does
>   - check nodemask, if nodemask && nodemask doesn't cover all
>     node_states[N_HIGH_MEMORY], this is CONSTRAINT_MEMORY_POLICY.
>   - Scan all zonelist under nodemask, if it hits cpuset's wall
>     this faiulre is from cpuset.
> And
>   - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
>     This doesn't change "current" behavior.
>     If callers use __GFP_THISNODE, it should handle "page allocation failure"
>     by itself.
> 
> Changelog: 2009/11/11
>  - fixed nodes_equal() calculation.
>  - return CONSTRAINT_MEMPOLICY always if given nodemask is not enough big.
> 
> Changelog: 2009/11/06
>  - fixed lack of oom.h
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
> ---
>  drivers/char/sysrq.c |    2 +-
>  include/linux/oom.h  |    4 +++-
>  mm/oom_kill.c        |   44 ++++++++++++++++++++++++++++++++------------
>  mm/page_alloc.c      |   10 ++++++++--
>  4 files changed, 44 insertions(+), 16 deletions(-)
> 

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
