Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0E26B00D1
	for <linux-mm@kvack.org>; Sat, 30 May 2009 10:29:24 -0400 (EDT)
Date: Sat, 30 May 2009 15:30:23 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090530153023.45600fd2@lxorguk.ukuu.org.uk>
In-Reply-To: <1243689707.6645.134.camel@laptop>
References: <20090522073436.GA3612@elte.hu>
	<20090530054856.GG29711@oblivion.subreption.com>
	<1243679973.6645.131.camel@laptop>
	<4A211BA8.8585.17B52182@pageexec.freemail.hu>
	<1243689707.6645.134.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: pageexec@freemail.hu, "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

> Right, so the whole point is to minimize the impact of actual bugs,
> right? So why not focus on fixing those actual bugs? Can we create tools
> to help us find such bugs faster? We use sparse for a lot of static
> checking, we create things like lockdep and kmemcheck to dynamically
> find trouble.
> 
> Can we instead of working around a problem, fix the actual problem?

Why do cars have crashworthiness and seatbelts ? Why not fix the actual
problem (driving errors) ? I mean lets face it they make the vehicle
heavier, less fuel efficient, less fun and more annoying to use.

> Wiping everything because we're too 'lazy' to figure out what really
> matters otoh seems silly.

It isn't about being lazy. A program cannot deduce what is or is not
sensitive. Consider the simple case of writing a highly confidential
document, encrypting it with GPG and deleting (secure deleting even) the
document. 

The chances are you write it in openoffice, which has no idea
it is secure, copies of bits of it end up mashed around by the glibc
allocator and on the stack in pages that then get recycled into kernel
space on page frees. We then clear them later as they go back to user
space - assuming they don't leak or get copied.

For most of us that probabilities of that data not leaking are fine, but
not for all.

The kernel has no idea what data it touches may be confidential and the
user space often doesn't either. Even if it did in a highly secure
environment you want to enumerate what is safe not try and label what is
not.

Think about it this way - is it better to have a root password you guard
carefully, or to give everyone the root password except the list of bad
guys you maintain ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
