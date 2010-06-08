Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 860BE6B01E1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:24:15 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:23:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
Message-Id: <20100608132339.54db2317.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:25 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
> 
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.  To use a sane heuristic, we must ensure that killing a
> task would likely free memory for current and avoid needlessly killing
> others at all costs just because their potential memory freeing is
> unknown.  It is better to kill current than another task needlessly.

This is all a bit arbitrary, isn't it?  The key word here is "rarely". 
If indeed this task had allocated gobs of memory from `current's nodes
and then sneakily switched nodes, this will be a big regression!

So..  It's not completely clear to me how we justify this decision. 
Are we erring too far on the side of keep-tasks-running?  Is failing to
clear the oom a lot bigger problem than killing an innocent task?  I
think so.  In which case we should err towards slaughtering the
innocent?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
