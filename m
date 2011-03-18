Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADCDE8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 16:36:26 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2IKaOEk013268
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:36:24 -0700
Received: from pva4 (pva4.prod.google.com [10.241.209.4])
	by kpbe17.cbf.corp.google.com with ESMTP id p2IKaM3Q000893
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:36:23 -0700
Received: by pva4 with SMTP id 4so591691pva.16
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 13:36:22 -0700 (PDT)
Date: Fri, 18 Mar 2011 13:36:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: give current access to memory reserves if it's
 trying to die
In-Reply-To: <20110317221758.5e8e78d0.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103181333210.27112@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
 <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
 <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com> <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com> <20110317165319.07be118e.akpm@linux-foundation.org> <20110318133534.818707d2.kamezawa.hiroyu@jp.fujitsu.com> <20110317221758.5e8e78d0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 17 Mar 2011, Andrew Morton wrote:

> commit 8bc719d3cab8414938f9ea6e33b58d8810d18068
> Author:     Martin Schwidefsky <schwidefsky@de.ibm.com>
> AuthorDate: Mon Sep 25 23:31:20 2006 -0700
> Commit:     Linus Torvalds <torvalds@g5.osdl.org>
> CommitDate: Tue Sep 26 08:48:47 2006 -0700
> 
>     [PATCH] out of memory notifier
>     
>     Add a notifer chain to the out of memory killer.  If one of the registered
>     callbacks could release some memory, do not kill the process but return and
>     retry the allocation that forced the oom killer to run.
>     
>     The purpose of the notifier is to add a safety net in the presence of
>     memory ballooners.  If the resource manager inflated the balloon to a size
>     where memory allocations can not be satisfied anymore, it is better to
>     deflate the balloon a bit instead of killing processes.
>     
>     The implementation for the s390 ballooner is included.
> 

I think it would be safe to do this only for CONSTRAINT_NONE in 
out_of_memory() since it's definitely not the right thing to do when a 
cpuset or mempolicy is oom; there's no guarantee that the freed memory is 
allocatable by the oom task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
