From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907161820.LAA53051@google.engr.sgi.com>
Subject: Re: [RFC] [PATCH]kanoj-mm15-2.3.10 Fix ia32 SMP/clone pte races
Date: Fri, 16 Jul 1999 11:20:50 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9907151804120.1146-100000@penguin.transmeta.com> from "Linus Torvalds" at Jul 15, 99 06:09:56 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, alan@lxorguk.ukuu.org.uk
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 15 Jul 1999, Kanoj Sarcar wrote:
> > 
> > Note that an alternate solution to the ia32 SMP pte race is to change 
> > PAGE_SHARED in include/asm-i386/pgtable.h to not drop in _PAGE_RW.
> 
> That is imho preferable to the "freeze_range" thing.

While changing the PAGE_SHARED value is a little more cleaner (and
probably what a lot of other os's do), it does penalize all programs
when their first write to a page comes later than their first access.
I was trying to not incur this, but let me know if you would like
to see a patch on this line.

The freeze_range solution does not penalize most programs, assuming
most are non shared address spaces. Its a judgement call whether
clone programs are slowed too much while doing the freeze_range, 
compared to the slowdown seen by all programs with the PAGE_SHARED
scheme.

The freeze_range solution has the added advantage that in some cases,
it prevents updates to the page. See my comments down below too.

> 
> However, the _most_ preferable solution is probably just to update the
> page tables with locked read-modify-write operations. Not fun, but not
> horrible either. We'll have to change some of the interfaces, but it's
> probably not too bad.
> 

I thought about this a bit, and was concerned at the amount of changes
involved. A lot of code reads *pte, then uses it to make decisions. 
You would have to change all those places to 

1. atomically turn off the RW bit.
2. flush tlb
3. read the pte, which is then unchangeable.

The problem of course is that when you are working on a set of
contiguous ptes, you are incurring the tlb flush for every pte ...
specially bad in a shared address space environment. The freeze_range
solution freezes all the pte's first, then incurs one tlbflush. Also 
note that with the freeze_range fix, you are not doing any more 
flushes than what happens today.

For an example of how freeze_range can cut down number of tlb 
flushes, look at how many calls can be saved in filemap_sync_pte,
while looping over the ptes, if all platforms implemented freeze_range.
(It can be done just as an ia32 specific optimization too, if the
ia32 has a freeze_range).

> Note that for "unmap()" and for a lot of the special cases, I don't care
> about the race at all. If some thread writes to the mapping at the same
> time as it is being unmapped, tough luck. If we lose the dirty bit it's
> not our problem: a program that races on unmap gets what it deserves, I
> don't think there is any valid use of that race.

I differ ... loosing the dirty bit seems to always make the os the
culprit. Its one thing to say that while unmapping, racy writes from a 
clone are not synced to disk (some apps will argue with that too,
seeing this is not POSIX behavior, but their writes are not lost), its 
quite another to loose the dirty bit and hence the writes to the page 
completely.

Specially if we have a non performance impact solution which seems to 
take care of this issue, why not just be safe and do it ...

Let me know if you want me to create the PAGE_SHARED patch. Or if I
should try to come up with a different scheme ... Seems to me that 
data corruption bugs like this do need to be fixed in 2.2 (and 2.3)
soonest. 

Thanks.

Kanoj

> 
> It's not a security issue, it's more an issue of what to do in situations
> that can not happen with well-behaved applications anyway. My opinion is
> that if we screw badly behaved programs, that is not a problem (the same
> way that anything that passes in a bad pointer to a system call is
> immediately undefined behaviour: we return EFAULT just to be polite, that
> does NOT imply that we actually do anything sane).
> 
> So we do need to handle some of the cases, but others might as well just
> be left racy.
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
