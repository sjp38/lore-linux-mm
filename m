Subject: Re: updatedb
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <46A9ACB2.9030302@gmail.com>
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
	 <46A81C39.4050009@gmail.com>
	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>
	 <46A98A14.3040300@gmail.com> <1185522844.6295.64.camel@Homer.simpson.net>
	 <46A9ACB2.9030302@gmail.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 11:26:08 +0200
Message-Id: <1185528368.7851.44.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 10:28 +0200, Rene Herman wrote:
> On 07/27/2007 09:54 AM, Mike Galbraith wrote:
> 
> > On Fri, 2007-07-27 at 08:00 +0200, Rene Herman wrote:
> > 
> >> The remaining issue of updatedb unnecessarily blowing away VFS caches is 
> >> being discussed (*) in a few thread-branches still running.
> > 
> > If you solve that, the swap thing dies too, they're one and the same
> > problem.
> 
> I still wonder what the "the swap thing" is though. People just kept saying 
> that swap-prefetch helped which would seem to indicate their problem didnt 
> have anything to do with updatedb.

I haven't rummaged around in the VM in quite a long while, so don't know
exactly where the balance lies any more, and have never looked at
swap-prefetch, but the mechanism of how swap-prefetch can help the
"morning after syndrome" seems simple enough:

Reclaim (swapout) a slew of application pages because there are
truckloads of utterly bored pages laying about when updatedb comes along
and introduces memory pressure in the middle of the night.  Updatedb
finishes, freeing some ram (doesn't matter how much) swap-prefetch
detects idle CPU, and begins faulting swapped out pages back in.  In the
process of doing so, memory pressure is generated, and now these freshly
accessed pages are a less lovely target than the now aging VFS caches
that updatedb bloated up, so they shrink back down enough that the
balance you had before updatedb ran is restored... with the notable
exception that cached data is now toast, so what you gained by faulting
god knows how frequently used pages back in isn't _necessarily_ going to
help you.  Heck, it could even step on what was left of your cached
working set after updatedb finished.

> Also, I know shit about the VFS so this may well be not very educated but to 
> me something like FADV_NOREUSE on a dirfd sounds like a much more promising 
> approach than the convoluted userspace schemes being discussed, if only 
> because it'll actually be implemented/used.

I like Andrew's mention of a future option... put that sucker and
everybody who looks like him in a resource limited container.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
