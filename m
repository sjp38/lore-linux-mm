Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 00AAB6B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 07:12:27 -0500 (EST)
Date: Mon, 22 Feb 2010 23:12:22 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
Message-ID: <20100222121222.GV9738@laptop>
References: <20100218134921.GF9738@laptop>
 <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com>
 <20100219033126.GI9738@laptop>
 <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 02:06:45AM -0800, David Rientjes wrote:
> On Fri, 19 Feb 2010, Nick Piggin wrote:
> > But it doesn't matter if stores are done under lock, if the loads are
> > not. masks can be multiple words, so there isn't any ordering between
> > reading half and old mask and half a new one that results in an invalid
> > state. AFAIKS.
> > 
> 
> It doesn't matter for MAX_NUMNODES > BITS_PER_LONG because 
> task->mems_alllowed only gets updated via cpuset_change_task_nodemask() 
> where the added nodes are set and then the removed nodes are cleared.  The 
> side effect of this lockless access to task->mems_allowed means we may 
> have a small race between
> 
> 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
> 
> 		and
> 
> 	tsk->mems_allowed = *newmems;
> 
> but the penalty is that we get an allocation on a removed node, which 
> isn't a big deal, especially since it was previously allowed.

If you have a concurrent reader without any synchronisation, then what
stops it from loading a word of the mask before stores to add the new
nodes and then loading another word of the mask after the stores to
remove the old nodes? (which can give an empty mask).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
