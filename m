Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4DDQv2g001798
	for <linux-mm@kvack.org>; Tue, 13 May 2008 09:26:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DDQvSx213258
	for <linux-mm@kvack.org>; Tue, 13 May 2008 07:26:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DDQvaS031534
	for <linux-mm@kvack.org>; Tue, 13 May 2008 07:26:57 -0600
Date: Tue, 13 May 2008 06:26:56 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080513132656.GB8738@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <20080505143547.GD14809@linux.vnet.ibm.com> <20080506093823.GD10141@wotan.suse.de> <20080506133224.GD9443@linux.vnet.ibm.com> <20080513075532.GA19870@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080513075532.GA19870@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 09:55:32AM +0200, Nick Piggin wrote:
> Sorry for the delay, was busy or away from keyboard for various reasons...
> 
> On Tue, May 06, 2008 at 06:32:24AM -0700, Paul E. McKenney wrote:
> > On Tue, May 06, 2008 at 11:38:24AM +0200, Nick Piggin wrote:
> > > 
> > > I'm wondering about this... and the problem does not only exist in
> > > memory ordering situations, but also just when using a single loaded
> > > value in a lot of times.
> > > 
> > > I'd be slightly worried about requiring this of threaded code. Even
> > > the regular memory ordering bugs we even have in core mm code is kind of
> > > annoying (and it is by no means just this current bug).
> > > 
> > > Is it such an improvement to refetch a pointer versus spilling to stack?
> > > Can we just ask gcc for a -multithreading-for-dummies mode?
> > 
> > I have thus far not been successful on this one in the general case.
> > It would be nice to be able to tell gcc that you really mean it when
> > you assign to a local variable...
> 
> Yes, exactly...
> 
> > > In that case it isn't really an ordering issue between two variables,
> > > but an issue within a single variable. And I'm not exactly sure we want
> > > to go down the path of trying to handle this. At least it probably belongs
> > > in a different patch.
> > 
> > Well, I have seen this sort of thing in real life with gcc, so I can't say
> > that I agree...  I was quite surprised the first time around!
> 
> I didn't intend to suggest that you are incorrect, or that ACCESS_ONCE
> is not technically required for correctness. But I question whether it
> is better to try fixing this throughout our source code, or in gcc's.

And it turns out that there are some features being proposed for the
upcoming c++0x standard that would have this effect.  "Relaxed access to
atomic variables" covers the "ACCESS_ONCE" piece, and is in the current
working draft.  We are also proposing something that captures the ordering
constraints of rcu_dereference(), which prohibits the compiler from doing
things like value speculation based on future dereferences of the variable
in question ("dependency ordering").  This has been through several
stages of review, and hopefully will get into the working draft soon.

Those sufficiently masochistic to dig through standardese might be
interested in:

	http://open-std.org/jtc1/sc22/wg21/docs/papers/2008/n2556.html

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
