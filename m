Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB7636B00C9
	for <linux-mm@kvack.org>; Sat, 30 May 2009 09:54:01 -0400 (EDT)
From: pageexec@freemail.hu
Date: Sat, 30 May 2009 15:54:48 +0200
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
Reply-to: pageexec@freemail.hu
Message-ID: <4A213AA8.18076.182E39C1@pageexec.freemail.hu>
In-reply-to: <1243689707.6645.134.camel@laptop>
References: <20090522073436.GA3612@elte.hu>, <4A211BA8.8585.17B52182@pageexec.freemail.hu>, <1243689707.6645.134.camel@laptop>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 30 May 2009 at 15:21, Peter Zijlstra wrote:

> On Sat, 2009-05-30 at 13:42 +0200, pageexec@freemail.hu wrote:
> > > Why waste time on this?
> > 
> > e.g., when userland executes a syscall, it 'can run kernel code'. if that kernel
> > code (note: already exists, isn't provided by the attacker) gives unintended
> > kernel memory back to userland, there is a problem. that problem is addressed
> > in part by early sanitizing of freed data.
> 
> Right, so the whole point is to minimize the impact of actual bugs,
> right?

correct. this approach is the manifestation of a particular philosophy
in computer security where instead of finding all bugs, we minimize or,
at times, eliminate their bad sideeffects. non-executable pages, ASLR,
etc are all about this. see below why.

> So why not focus on fixing those actual bugs? Can we create tools
> to help us find such bugs faster? We use sparse for a lot of static
> checking, we create things like lockdep and kmemcheck to dynamically
> find trouble.
> 
> Can we instead of working around a problem, fix the actual problem?

finding all use-after-free bugs is not possible, as far as i know. the
fundamental problem is that you'd have to find bugs with arbitrary read
sideeffects (which is just as hard a problem as finding bugs with arbitrary
write sideeffects which you'd also have to solve). if you solve these
problems, you'll have solved the most important bug class in computer
security that many decades of academic/industrial/etc research failed at.

since there's no (practical and theoretical) solution in sight for finding
and eliminating such memory handling bugs, we're left with tackling a less
ambitious goal of at least reducing their sideeffects to acceptable levels.

of course there'll be always instances and subclasses of bugs that we can
find by manual or automated inspection, but that only shows that the rest
can only by handled by 'working around the problem'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
