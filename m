Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A073F6B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 15:07:22 -0400 (EDT)
Date: Wed, 11 Mar 2009 20:06:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311190655.GM27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 11:46:17AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 11 Mar 2009, Andrea Arcangeli wrote:
> 
> > On Wed, Mar 11, 2009 at 10:58:17AM -0700, Linus Torvalds wrote:
> > > As far as I can tell, it's the same old problem that we've always had: if 
> > > you fork(), it's unclear who is going to do the first write - parent or 
> > > child (and "parent" in this case can include any number of threads that 
> > > share the VM, of course).
> > 
> > The child doesn't touch any page. Calling fork just generates O_DIRECT
> > corruption in the parent regardless of what the child does.
> 
> You aren't listening.
> 
> It depends on who does the write. If the _parent_ does the write (with 
> another thread or not), then the _parent_ gets the COW.
> 
> That's all I said.

I only wanted to clarify this doesn't require the child to touch the
page at all.

> If the idiots who use O_DIRECT don't understand that, then hey, it's their 
> problem. I have long been of the opinion that we should not support 
> O_DIRECT at all, and that it's a totally broken premise to start with. 

Well if you don't like it used by databases, O_DIRECT is still ideal for
KVM. Guest caches runs at cpu core speed unlike host cache. Not that
KVM can reproduce this bug (all ram where KVM would be doing O_DIRECT
is mapped MADV_DONTFORK, and besides guest physical ram has to be
allocated with memalign(4096) ;).

Said that I agree it'd be better off to nuke O_DIRECT than to leave
this bug as O_DIRECT should not break the usual memory-protection
semantics provided by read() and fork() syscalls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
