Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 015F9900144
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 18:06:14 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p8DM6807029071
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 15:06:10 -0700
Received: from yih10 (yih10.prod.google.com [10.243.66.202])
	by hpaq2.eem.corp.google.com with ESMTP id p8DM5QlG021000
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 15:06:06 -0700
Received: by yih10 with SMTP id 10so1192803yih.35
        for <linux-mm@kvack.org>; Tue, 13 Sep 2011 15:06:06 -0700 (PDT)
Date: Tue, 13 Sep 2011 15:06:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] cpusets: avoid looping when storing to mems_allowed if
 one node remains set
In-Reply-To: <4E6EDA2B.9090507@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1109131503520.11120@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1109090313130.23841@chino.kir.corp.google.com> <4E6EDA2B.9090507@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Sep 2011, Miao Xie wrote:

> This patch is dangerous if the task has a bind memory policy that was set
> to be neither MPOL_F_STATIC_NODES nor MPOL_F_RELATIVE_NODES, because the
> memory policy use node_remap() to rebind the allowed nodes, but node_remap()
> may make the old mask and the new mask nonoverlapping. So at this condition,
> the task may also see an empty node mask.
> 

The vast majority of cpuset users are not going to have mempolicies at 
all, the cpuset itself is the only policy they need to take advantage of 
the NUMA locality of their machine.  I'd be find with checking for 
!tsk->mempolicy in this exception as well since we already hold 
task_lock(tsk), but I think the real fix would be to make sure that an 
empty nodemask is never returned by mempolicies.  Something like ensuring 
that if the preferred node is MAX_NUMNODES (since it is determined by 
using first_node() over a possibly racing empty nodemask) that the first 
online node is returned during the race and that 
node_states[N_HIGH_MEMORY] is returned if an MPOL_BIND or MPOL_INTERLEAVE 
mask is empty.  Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
