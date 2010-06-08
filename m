Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 294226B01C6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:44:15 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:43:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy ooms
Message-Id: <20100608164325.a5fcdb39.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:31 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom killer presently kills current whenever there is no more memory
> free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> current is a memory-hogging task or that killing it will free any
> substantial amount of memory, however.

Well OK.  But we don't necesarily *want* to "free a substantial amount
of memory".  We want to resolve the oom within `current'.  That's the
sole responsibility of the oom-killer.  It doesn't have to free up
large amounts of additional memory in the expectation that sometime in
the future some other task will get an oom as well.  if the oom-killer
is working well, we can defer those actions until the problem actually
occurs.

Plus: if `current' isn't using much memory then it's probably a
short-lived or not-very-important process anyway.

> In such situations, it is better to scan the tasklist for nodes that are
> allowed to allocate on current's set of nodes and kill the task with the
> highest badness() score.  This ensures that the most memory-hogging task,
> or the one configured by the user with /proc/pid/oom_adj, is always
> selected in such scenarios.

Well... *why* is it better?  Needs more justification/explanation IMO.

A long time ago Andrea changed the oom-killer so that it basically
always killed `current', iirc.  I think that shipped in the Suse
kernel.  Maybe it was only in the case where `current' got an oom when
satisfying a pagefault, I forget the details.  But according to Andrea,
this design provided a simple and practical solution to ooms.

So I think this policy change would benefit from a more convincing
justification.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
