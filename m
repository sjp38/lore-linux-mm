Date: Thu, 12 Oct 2000 00:03:31 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <Pine.LNX.4.10.10010111702001.2444-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.1001011232450.23223A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Linus,

On Wed, 11 Oct 2000, Linus Torvalds wrote:

> I much prefered the dirty fault version.

> What does "quite noticeable" mean? Does it mean that you can see page
> faults (no big deal), or does it mean that you can actually measure the
> performance degradation objectively?

It's a factor of 4 difference in execution time on the filemap rewrite
test on a 1GB file (including all those cache misses that should have
dwarfed the page fault handler). Moving the writable test and mkdirty
early on in the page fault handler made no measurable difference in
execution time; the bulk of the overhead appears to be in handling the
page fault itself.

> Also, this version doesn't seem to fix the bug.
...
> Both of the above paths can cause the dirty bit to be dropped again, as
> far as I can see.

Note the fragment above those portions of the patch where the
pte_xchg_clear is done on the page table: this results in a page fault
for any other cpu that looks at the pte while it is unavailable.

> In fact, you seem to have _added_ those drops in this patch. What's up?

It's safe because of how x86s hardware works when it encounters the
cleared pte.  According to one of the manuals I've got here (the old 386
book is the only one that states it outright, sigh), the access and dirty
bits are updated with a locked memory cycle only if the entry is marked
present.  If you want test code demonstrating that x86 does a reread of
the pte on a dirty fault, I'll gladly share it.

> I'm not going to apply a patch that I don't see will even fix the problem
> at this point.
> 
> I _will_ apply the "exception on dirty" version, if you remove the SMP
> special case (ie you do it unconditionally). At least that one I believe
> really fixes the problem.

I'd rather not lose the use of a hardware feature that makes a difference
during the most important time: when the system is under heavy load and
the page table scanner is active.  If there's a way the atomic updates can
be cleaned up acceptably, then I want to do so.  Cheers,

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
