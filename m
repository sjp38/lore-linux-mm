Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 690C86B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:02:27 -0400 (EDT)
Date: Wed, 11 Mar 2009 10:58:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311174103.GA11979@elte.hu>
Message-ID: <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Ingo Molnar wrote:
> 
> Hm, is there any security impact? Andrea is talking about data 
> corruption. I'm wondering whether that's just corruption 
> relative to whatever twisted semantics O_DIRECT has in this case 
> [which would be harmless], or some true pagecache corruption 
> going across COW (or other) protection domains that could be 
> exploited [which would not be harmless].

As far as I can tell, it's the same old problem that we've always had: if 
you fork(), it's unclear who is going to do the first write - parent or 
child (and "parent" in this case can include any number of threads that 
share the VM, of course).

And that means that anything that relies on pinned pages will never know 
whether it is pinning a page in the parent or the child - because whoever 
does the first COW of that page is the one that just gets a _copy_, not 
the original pinned page.

This isn't anything new. Anything that does anything by physical address 
will simply not do the right thing over a fork. The physical page may have 
started out as the parents physical page, but it may end up in the end 
being the _childs_ physical page if the parent wrote to it and triggered 
the cow.

The rule has always been: don't mix fork() with page pinning. It doesn't 
work. It never worked. It likely never will.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
