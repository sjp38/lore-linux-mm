Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 570156B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 02:32:31 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id nAB7WOpd015071
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 07:32:25 GMT
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz17.hot.corp.google.com with ESMTP id nAB7WLSb002742
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 23:32:22 -0800
Received: by pzk12 with SMTP id 12so616972pzk.13
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 23:32:21 -0800 (PST)
Date: Tue, 10 Nov 2009 23:32:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911102331550.15125@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
 <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com> <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com> <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:

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
> So, current oom-killer's check function is wrong.
> 
> This patch does
>   - check nodemask, if nodemask && nodemask doesn't cover all
>     node_states[N_HIGH_MEMORY], this is CONSTRAINT_MEMORY_POLICY.
>   - Scan all zonelist under nodemask, if it hits cpuset's wall
>     this faiulre is from cpuset.
> And
>   - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
>     This doesn't change "current" behavior. If callers use __GFP_THISNODE
>     it should handle "page allocation failure" by itself.
> 
>   - handle __GFP_NOFAIL+__GFP_THISNODE path.
>     This is something like a FIXME but this gfpmask is not used now.
> 
> Changelog: 2009/11/11(2)
>  - uses nodes_subset().
>  - clean up.
>  - added __GFP_NOFAIL case. And added waring.
>  - removed inline
>  - removed 'ret'
> 
> Changelog: 2009/11/11
>  - fixed nodes_equal() calculation.
>  - return CONSTRAINT_MEMPOLICY always if given nodemask is not enough big.
> 
> Changelog: 2009/11/06
>  - fixed lack of oom.h
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
