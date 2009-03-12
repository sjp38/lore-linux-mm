Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 618326B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 01:36:28 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Thu, 12 Mar 2009 16:36:18 +1100
References: <20090311170611.GA2079@elte.hu> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903121636.18867.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 12 March 2009 05:46:17 Linus Torvalds wrote:
> On Wed, 11 Mar 2009, Andrea Arcangeli wrote:

> > > The rule has always been: don't mix fork() with page pinning. It
> > > doesn't work. It never worked. It likely never will.
> >
> > I never heard this rule here
>
> It's never been written down, but it's obvious to anybody who looks at how
> COW works for even five seconds. The fact is, the person doing the COW
> after a fork() is the person who no longer has the same physical page
> (because he got a new page).
>
> So _anything- that depends on physical addresses simply _cannot_ work
> concurrently with a fork. That has always been true.
>
> If the idiots who use O_DIRECT don't understand that, then hey, it's their
> problem. I have long been of the opinion that we should not support
> O_DIRECT at all, and that it's a totally broken premise to start with.
>
> This is just one of millions of reasons.

Well it is a quite well known issue at this stage I think. We've had
MADV_DONTFORK since 2.6.16 which is basically to solve this issue I
think with infiniband library. I guess if it would be really helpful
we *could* add MADV_DONTCOW.

Assuming we want to try fixing it transparently... what about another
approach, mark a vma as VM_DONTCOW and uncow all existing pages in it
if it ever has get_user_pages run on it. Big hammer approach.

fast gup would be a little bit harder because looking up the vma
defeats the purpose. However if we use another page bit to say the
page belongs to a VM_DONTCOW vma, then we only need to check that
once and fall back to slow gup if it is clear. So there would be no
extra atomics in the repeat case. Yes it would be slower, but apps
that really care should know what they are doing and set
MADV_DONTFORK or MADV_DONTCOW on the vma by hand before doing the
zero copy IO.

Would this work? Anyone see any holes? (I imagine someone might argue
against big hammer, but I would prefer it if it is lighter impact on
the VM and still allows good applications to avoid the hammer)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
