Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2B026B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:49:14 -0400 (EDT)
Date: Wed, 11 Mar 2009 11:46:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311183748.GK27823@random.random>
Message-ID: <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Andrea Arcangeli wrote:

> On Wed, Mar 11, 2009 at 10:58:17AM -0700, Linus Torvalds wrote:
> > As far as I can tell, it's the same old problem that we've always had: if 
> > you fork(), it's unclear who is going to do the first write - parent or 
> > child (and "parent" in this case can include any number of threads that 
> > share the VM, of course).
> 
> The child doesn't touch any page. Calling fork just generates O_DIRECT
> corruption in the parent regardless of what the child does.

You aren't listening.

It depends on who does the write. If the _parent_ does the write (with 
another thread or not), then the _parent_ gets the COW.

That's all I said.

> > The rule has always been: don't mix fork() with page pinning. It doesn't 
> > work. It never worked. It likely never will.
> 
> I never heard this rule here

It's never been written down, but it's obvious to anybody who looks at how 
COW works for even five seconds. The fact is, the person doing the COW 
after a fork() is the person who no longer has the same physical page 
(because he got a new page).

So _anything- that depends on physical addresses simply _cannot_ work 
concurrently with a fork. That has always been true.

If the idiots who use O_DIRECT don't understand that, then hey, it's their 
problem. I have long been of the opinion that we should not support 
O_DIRECT at all, and that it's a totally broken premise to start with. 

This is just one of millions of reasons.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
