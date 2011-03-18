Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4029F8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 01:20:45 -0400 (EDT)
Date: Thu, 17 Mar 2011 22:17:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] memcg: give current access to memory reserves if it's
 trying to die
Message-Id: <20110317221758.5e8e78d0.akpm@linux-foundation.org>
In-Reply-To: <20110318133534.818707d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
	<20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
	<20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
	<20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
	<20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
	<20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com>
	<20110317165319.07be118e.akpm@linux-foundation.org>
	<20110318133534.818707d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Fri, 18 Mar 2011 13:35:34 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 17 Mar 2011 16:53:19 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > Was it deliberate that mem_cgroup_out_of_memory() ignores the oom
> > notifier callbacks?
> > 
> 
> I'm not sure for what purpose notifier chain for oom exists.
> At a loock, it's for s390/powerpc Collaborative Memory Manager.. ?

commit 8bc719d3cab8414938f9ea6e33b58d8810d18068
Author:     Martin Schwidefsky <schwidefsky@de.ibm.com>
AuthorDate: Mon Sep 25 23:31:20 2006 -0700
Commit:     Linus Torvalds <torvalds@g5.osdl.org>
CommitDate: Tue Sep 26 08:48:47 2006 -0700

    [PATCH] out of memory notifier
    
    Add a notifer chain to the out of memory killer.  If one of the registered
    callbacks could release some memory, do not kill the process but return and
    retry the allocation that forced the oom killer to run.
    
    The purpose of the notifier is to add a safety net in the presence of
    memory ballooners.  If the resource manager inflated the balloon to a size
    where memory allocations can not be satisfied anymore, it is better to
    deflate the balloon a bit instead of killing processes.
    
    The implementation for the s390 ballooner is included.

> About memcg, notifier to userland already exists and I though I don't
> need to call CMM callbacks (for now, there is no user with memcg, I guess.)

Seems to me that the callback should be performed.

Or, perhaps, migrate it over to use the shrinker stuff, along with
suitable handling of the scanning priority.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
