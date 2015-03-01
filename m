Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0F87A6B0032
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 22:57:19 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id hq11so8827928vcb.9
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 19:57:18 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id ke4si3930085vdb.79.2015.02.28.19.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 19:57:17 -0800 (PST)
Message-ID: <1425182227.4645.173.camel@kernel.crashing.org>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 01 Mar 2015 14:57:07 +1100
In-Reply-To: <CA+55aFw+K6aev6JPTiYxWjtJS0O8+MUwC-5=O4Gb+0mCd+tOfQ@mail.gmail.com>
References: <1422361485.6648.71.camel@opensuse.org>
	 <54C78756.9090605@suse.cz>
	 <alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	 <1422364084.6648.82.camel@opensuse.org> <s5h7fw8hvdp.wl-tiwai@suse.de>
	 <CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	 <CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	 <CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	 <CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	 <1422836637.17302.9.camel@au1.ibm.com>
	 <CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	 <1425107567.4645.108.camel@kernel.crashing.org>
	 <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
	 <1425158083.4645.139.camel@kernel.crashing.org>
	 <1425161796.4645.149.camel@kernel.crashing.org>
	 <1425164559.4645.157.camel@kernel.crashing.org>
	 <CA+55aFw+K6aev6JPTiYxWjtJS0O8+MUwC-5=O4Gb+0mCd+tOfQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, 2015-02-28 at 16:41 -0800, Linus Torvalds wrote:
> On Sat, Feb 28, 2015 at 3:02 PM, Benjamin Herrenschmidt
> <benh@kernel.crashing.org> wrote:
> >
> > Anyway, here's the current patch:
> 
> Ok, I think I like this approach better.
> 
> Your FAULT_FLAG_EXEC handling is wrong, though. It shouldn't check
> VM_WRITE, it should check VM_EXEC. A bit too much copy-paste ;)

Ah yes indeed :) I would have caught that pretty quickly once I tried
powerpc.

> Btw, it's quite possible that we could just do all the PF_PROT
> handling at the x86 level, before even calling the generic fault
> handler. It's not like we even need the vma or the mm semaphore: if
> it's a non-write protection fault, we always SIGSEGV. So why even
> bother getting the locks and looking up the page tables etc?

For non-write possibly, though that means we always end up going
through handle_mm_fault for a non-present PTE before we decide
that it wasn't actually accessible.

Not a huge deal I suppose unless something (ab)uses mprotect + emulation
for things like spying on MMIO accesses (been there) or god knows what
other userspace based paging or GC might be out there. It's asking for
trouble but the check in access_error() doesn't hurt much either.

On the other hand, we are all about simplifying code here, aren't
we ? :-) It's not like the early bail-out on x86 will buy us much and
it's going to be more arch specific code since they'll all have a
different variant of PF_PROT.

One thing that worries me a bit, however, with the PF_PROT handling in
the generic case is the case of archs who support
present-but-not-accessible PTEs in "HW" (for us that basically means no
_PAGE_USER), as these might use such fault for NUMA balancing, or
software maintained "young" bit, and in those case, bailing out on
PF_PROT is wrong. I'll have to figure out if that ever happens when I
dig through more archs.

> Now, that PF_PROT handling isn't exactly performance-critical, but it
> might help to remove the odd x86 special case from the generic code.

I don't think it's that odd on x86. If you look at what other archs do,
there's a bit of everything out there. Just powerpc may or may not
support exec permission for example depending on the CPU generation and
when it doesn't it's basically similar to x86. I yet have to fully
understand what ARM does (looks simple, just need to make sure it's what
I think it is and check various ARM generations), sparc has its
oddities, etc...

None of that is terribly urgent and I'm pretty busy so give me a bit
more time now that we have some kind of direction, to go through a few
more archs and see where it takes us. I'll start gathering cross
compilers and qemu debian images in the next few days.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
