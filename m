Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB3816B0047
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 01:06:49 -0400 (EDT)
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu>
	 <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
	 <20090311174103.GA11979@elte.hu>
	 <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain>
	 <20090311183748.GK27823@random.random>
	 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
	 <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
	 <20090311195935.GO27823@random.random>
	 <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
Content-Type: text/plain
Date: Sat, 14 Mar 2009 16:06:29 +1100
Message-Id: <1237007189.25062.91.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-11 at 13:19 -0700, Linus Torvalds wrote:
> 
> That said, I don't know who the crazy O_DIRECT users are. It may be true 
> that some O_DIRECT users end up using the same pages over and over again, 
> and that this is a good optimization for them.

Just my 2 cents here...

While I agree mostly with what you say about O_DIRECT crazyness,
unfortunately, gup is also a fashionable interface in a few other areas,
such as IB or RDMA'ish things, and I'm pretty sure we'll see others
popping here or there.

Right, it's a bit stinky, but it -is- somewhat nice for a driver to be
able to take a chunk of existing user addresses and not care whether
they are anonymous, shmem, file mappings, large pages, ... and just gup
and get some DMA pounding on them. There are various usage scenarios
where it's in fact less ugly than anything else you can come up with ...
pretty much.

IB folks so far have been avoiding the fork() trap thanks to
madvise(MADV_DONTFORK) afaik. And it all goes generally well when the
whole application knows what it's doing and just plain avoids fork.

-But- things get nasty if for some reason, the user of gup is somewhere
deep in some kind of library that an application uses without knowing,
while forking here or there to run shell scripts or other helpers.

I've seen it :-)

So if a solution can be found that doesn't uglify the whole thing beyond
recognition, it's probably worth it.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
