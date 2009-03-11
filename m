Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7DA326B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:38:05 -0400 (EDT)
Date: Wed, 11 Mar 2009 19:37:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311183748.GK27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 10:58:17AM -0700, Linus Torvalds wrote:
> As far as I can tell, it's the same old problem that we've always had: if 
> you fork(), it's unclear who is going to do the first write - parent or 
> child (and "parent" in this case can include any number of threads that 
> share the VM, of course).

The child doesn't touch any page. Calling fork just generates O_DIRECT
corruption in the parent regardless of what the child does.

> This isn't anything new. Anything that does anything by physical address 

This is nothing new also in the sense that all linux kernels out there
had this bug thus far.

> will simply not do the right thing over a fork. The physical page may have 
> started out as the parents physical page, but it may end up in the end 
> being the _childs_ physical page if the parent wrote to it and triggered 
> the cow.

Actually the child will get corrupted too. Not just the parent by
losing the O_DIRECT reads. The child always assumes its anon page
contents will not get lost or overwritten after changing them in the
child.

> The rule has always been: don't mix fork() with page pinning. It doesn't 
> work. It never worked. It likely never will.

I never heard this rule here, but surely I agree there will not be
many apps out there capable of triggering this. Mostly because most
apps uses O_DIRECT on top of shm (surely not because they're not
usually calling fork). The ones affected are the ones using anonymous
memory with threads and not allocating memory with memalign(4096)
despite they use 512byte blocksize for their I/O. If they use threads
and they allocate with memalign(512) they can be affected if they call
fork anywhere.

I don't think it's urgent fix, but if you now are pretending that this
doesn't ever need fixing and we can live with the bug forever, I think
you're wrong. If something I'd rather see O_DIRECT not supporting
hardblocksize anymore but only PAGE_SIZE multiples, that would at
least limiting the breakage to an undefined behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
