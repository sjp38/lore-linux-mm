Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9334A6B005C
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:55:52 -0400 (EDT)
Date: Thu, 21 May 2009 12:56:03 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090521195603.GK10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <4A15A69F.3040604@redhat.com> <20090521202628.39625a5d@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090521202628.39625a5d@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On 20:26 Thu 21 May     , Alan Cox wrote:
> > You don't always know this at page free time.
> 
> You do at buffer free time.

Alan, I think you will agree with me that forcing people to know what
they have to do exactly with their buffers when they will contain
confidential/sensitive data is suboptimal. Like it's been said before,
the clearing isn't the only issue here. We have pagination to disk,
re-allocation leaks, etc.

Rik conveniently recommended me to write a threat model for this and
that's exactly what will be done so the issues are clarified further
more. The text had been omitted form the patches to keep them reasonably
small.

> Still doesn't need a page flag - that is a vma flag which is far cheaper.
> Also means you can get rid of the stupid mlock() misuse by things like
> GPG to work around OS weaknesses by crypting the page if it hits
> disk/swap/whatever.

I had the intention to cover cases like gnupg's approach to
pseudo-secure memory (their mlock pool, the three pass memset wipe, etc)
with this implementation.

We would need to look into a sane approach for encrypting the data. That
was out of scope for my patches, so far. It adds further complexity and
might require more invasive changes (if we want to let the user select
the algorithm on runtime, etc).

Do you suggest a vma flag should be created for this as well?

> > I could also imagine the suspend-to-disk code skipping
> > PG_sensitive pages when storing data to disk, and
> > replacing it with some magic signature so programs
> > that use special PG_sensitive buffers can know that
> > their crypto key disappeared after a restore.
> 
> Its irrelevant in the simple S2D case. I just patch other bits of the
> suspend image to mail me the new key later. The right answer is crypted
> swap combined with a hard disk password and thus a crypted and locked
> suspend image. Playing the "I must not miss any page which might be
> sensitive even compiler stack copies and library buffers I don't know
> about" game is not going to build you a secure system - its simply
> *lousy* engineering and design.

The point is that the keys or sensitive marked pages should never, ever
be swapped to disk, by any means. Right now the patch only affects
kernel code, the task related flag and functionality patches haven't been
submitted yet.

Regarding retrieving the encryption keys, IVs, and so forth, why bother
reading the data remaining on disk? You can just retrieve them off
memory (ex. via rogue driver or some re-allocation bug scenario,
information leak or similar issue) and that's it.

> 
> Basically though - loss of physical control means you have to assue the
> recovered system is compromised. I doubt even TC is going to manage to
> spot firmware compromises on your CD-ROM drive, which thanks to the film
> industry creating a demand for altered firmware is a well understood
> field..

I don't see what physical compromise of the machine has to do with
anything about this patch and the issues it addresses. Although, the
real benefits from TC will be more about memory containment, untrusted
code injection prevention and so forth.

Basically things like preventing SELinux from being disabled via some
kernel vulnerability which let's an attacker abuse a write-4 primitive
(on x86_64 as well). Or patching the pagetables to make the kernel text
writable. Or injecting code in the .rodata section. Or redirecting an
IDT gate to some RWX mapping. The list goes on.

While other vendors might use this technology for locking down their
users, mutilating their rights and constrain their legitimate use of
their systems, we can use this technology for a beneficial purpose.
After all, that was the beauty of Linux since the start. We don't need
to follow a political or corporate agenda in these regards. Right?

> The cost of doing crypto on suspend to disk relative to media speed is
> basically irrelevant on a PC today. In the S2R case you might want to
> crypt those pages against an electronic pure read of RAM type attack but
> this is getting into serious spook territory.

If someone has access to an oscilloscope and the required equipment to
read data directly in that manner, well, the problem isn't that they
have access to your hardware. The problem is that you pissed off the
wrong people. And the list of things to attract such attention is
still, fortunately, short. Or so we believe.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
