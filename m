Date: Thu, 15 Jul 1999 18:09:56 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] [PATCH]kanoj-mm15-2.3.10 Fix ia32 SMP/clone pte races
In-Reply-To: <199907160024.RAA11667@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9907151804120.1146-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 15 Jul 1999, Kanoj Sarcar wrote:
> 
> Note that an alternate solution to the ia32 SMP pte race is to change 
> PAGE_SHARED in include/asm-i386/pgtable.h to not drop in _PAGE_RW.

That is imho preferable to the "freeze_range" thing.

However, the _most_ preferable solution is probably just to update the
page tables with locked read-modify-write operations. Not fun, but not
horrible either. We'll have to change some of the interfaces, but it's
probably not too bad.

Note that for "unmap()" and for a lot of the special cases, I don't care
about the race at all. If some thread writes to the mapping at the same
time as it is being unmapped, tough luck. If we lose the dirty bit it's
not our problem: a program that races on unmap gets what it deserves, I
don't think there is any valid use of that race.

It's not a security issue, it's more an issue of what to do in situations
that can not happen with well-behaved applications anyway. My opinion is
that if we screw badly behaved programs, that is not a problem (the same
way that anything that passes in a bad pointer to a system call is
immediately undefined behaviour: we return EFAULT just to be polite, that
does NOT imply that we actually do anything sane).

So we do need to handle some of the cases, but others might as well just
be left racy.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
