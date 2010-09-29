Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 56F3C6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 20:42:17 -0400 (EDT)
Date: Tue, 28 Sep 2010 17:41:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] arch: remove __GFP_REPEAT for order-0 allocations
Message-Id: <20100928174147.41e48aef.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1009281644110.21757@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com>
	<20100928143655.4282a001.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009281536390.24817@chino.kir.corp.google.com>
	<20100928155326.9ded5a92.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009281605180.24817@chino.kir.corp.google.com>
	<20100928164006.55c442b1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1009281644110.21757@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010 16:52:01 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Tue, 28 Sep 2010, Andrew Morton wrote:
> 
> > > > > So we can definitely remove __GFP_REPEAT for any order-0 allocation and 
> > > > > it's based on its implementation -- poorly defined as it may be -- and the 
> > > > > inherit design of any sane page allocator that retries such an allocation 
> > > > > if it's going to use reclaim in the first place.
> > > > 
> > > > Why was __GFP_REPEAT used in those callsites?  What were people trying
> > > > to achieve?
> > > > 
> > > 
> > > I can't predict what they were trying to achieve
> > 
> > Using my super powers it took me all of three minutes.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git
> > 
> > Do `git log > foo', and search foo for GFP_REPEAT.
> > 
> > A couple of interesting ones are:
> > 
> 
> Ok, so __GFP_REPEAT was used to replace the open-coding of retry loops by 
> putting that logic into the page allocator, and that logic was 
> subsequently changed to tie the bit to how many pages were reclaimed and 
> retry iff we haven't reclaimed the number of pages needed (in my patch, 
> that would be a single page).

It also shows that there was at least one version of the page allocator
(written by a very skilled and experienced Linux MM developer) which
would simply return NULL when there was no memory.  And here you are
assuring us that there will never ever be such a version again.

> It also shows that the page allocator has infinitely looped for 
> allocations under PAGE_ALLOC_COSTLY_ORDER since your patch from over seven 
> years ago.

Really don't give a shit what the allocator-of-the-moment happens to be
doing.

What I care about is that very smart, experienced and hard-working
Linux developers decided, a long time ago, that page-table allocations
are special, and need special treatment.  This is information!

What I also care about is lazy MM developers who just rip stuff out
without understanding it and without even bothering to make an
*attempt* to understand it.

> So, given the fact that the PAGE_ALLOC_COSTLY_ORDER logic has existed 
> since the same time, the semantics of __GFP_REPEAT have changed and are 
> often misrepresented, and we don't even invoke the __GFP_REPEAT logic for 
> any of the allocations in my patch since they are oom killable,

Probably this is because lazy ignorant MM developers broke earlier
intentions without even knowing that they were doing so.

> I think my patch should be merged.

Well before destroying the information, you tell me: why did MM
developers decide that page-table allocations needed special treatment?
 What experience led them to decide to implement that?  Has the problem
which they solved been fixed by other means?  Are those means
sufficiently permanently embedded (see "-aa" above) that we can afford
to destroy this piece of information?

If we break stuff and destroy this sort of historical knowledge then we
get to make the same mistakes every decade or so and the damn thing
*never* converges.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
