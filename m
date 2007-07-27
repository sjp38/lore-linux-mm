Message-ID: <46A9D26E.9010703@gmail.com>
Date: Fri, 27 Jul 2007 13:09:34 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com>	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>	 <46A98A14.3040300@gmail.com> <1185522844.6295.64.camel@Homer.simpson.net>	 <46A9ACB2.9030302@gmail.com> <1185528368.7851.44.camel@Homer.simpson.net>
In-Reply-To: <1185528368.7851.44.camel@Homer.simpson.net>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, B.Steinbrink@gmx.de, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On 07/27/2007 11:26 AM, Mike Galbraith wrote:

> On Fri, 2007-07-27 at 10:28 +0200, Rene Herman wrote:

>> I still wonder what the "the swap thing" is though. People just kept
>> saying that swap-prefetch helped which would seem to indicate their
>> problem didnt have anything to do with updatedb.
> 
> I haven't rummaged around in the VM in quite a long while, so don't know 
> exactly where the balance lies any more, and have never looked at 
> swap-prefetch, but the mechanism of how swap-prefetch can help the 
> "morning after syndrome" seems simple enough:

As far as I've googled things together, the below scenario won't happen:

> Reclaim (swapout) a slew of application pages because there are 
> truckloads of utterly bored pages laying about when updatedb comes along 
> and introduces memory pressure in the middle of the night.

Ack (*)

> Updatedb finishes, freeing some ram (doesn't matter how much)

Will be very little and swap-prefetch at least in its current form needs 
more than very little to start doing anything:

http://ck.kolivas.org/patches/swap-prefetch/2.6.21-swap_prefetch-38.patch

| /*
|  * Set max number of entries to 2/3 the size of physical ram  as we
|  * only ever prefetch to consume 2/3 of the ram.
|  */

However, okay, let's just ignore that and pretend it kicks in even with the 
little free memory updatedb itself left behind when it finished:

> swap-prefetch detects idle CPU, and begins faulting swapped out pages 
> back in. In the process of doing so, memory pressure is generated, and
> now these freshly accessed pages are a less lovely target than the now
> aging VFS caches that updatedb bloated up, so they shrink back down
> enough that the balance you had before updatedb ran is restored...

The story now again breaks down here. Over at:

http://lkml.org/lkml/2007/2/9/112

we have swap-prefetch's author saying:

| swap prefetch stores the data at the tail end of the lru list which
| means that even if you do want to use that ram for something else,
| the prefetched pages will be immediately dropped.

So those aging VFS caches will never be replaced by anything prefetched it 
seems and any prefetching stops after the couple of pages that updatedb 
itself freed have been taken again.

A subsequent bit in that same message reads:

| It can't help the updatedb scenario. Updatedb leaves the ram full and
| swap prefetch wants to cost as little as possible so it will never
| move anything out of ram in preference for the pages it wants to swap
| back in.

which I'll take as confirmation.

> with the notable exception that cached data is now toast, so what you
> gained by faulting god knows how frequently used pages back in isn't
> _necessarily_ going to help you.

Also file-backed pages (such as the program binaries itself). However, _if_ 
prefetching were to take place, I'd be okay assuming it helps.

> Heck, it could even step on what was left of your cached working set
> after updatedb finished.

Given swap-prefetch's focus on being as free as possible I don't believe it 
should hurt any. And yes, it's always going to help _some_ workload shifts 
and as far as I'm concerned is a "makes sense" kind of tweak even if it's 
not the be all end all so again, not against swap-prefetch or its merger or 
anything...

>> Also, I know shit about the VFS so this may well be not very educated but to 
>> me something like FADV_NOREUSE on a dirfd sounds like a much more promising 
>> approach than the convoluted userspace schemes being discussed, if only 
>> because it'll actually be implemented/used.
> 
> I like Andrew's mention of a future option... put that sucker and
> everybody who looks like him in a resource limited container.

As to the (*) above -- now that I actually know about the "swappiness" 
thing, shouldn't setting that to 0 around updatedb runs really be quite 
effective and if it's not, is there anything to be fixed there? Bjoern 
Steinbrink (added to CC) earlier in this thread tried that and said stuff 
went weird.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
