From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14282.37533.98879.414300@dukat.scot.redhat.com>
Date: Mon, 30 Aug 1999 15:18:05 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <37CA73D8.E41F4F5@switchboard.ericsson.se>
References: <Pine.LNX.4.10.9908291037120.28136-100000@imperial.edgeglobal.com>
	<14281.23624.70350.745345@dukat.scot.redhat.com>
	<37CA73D8.E41F4F5@switchboard.ericsson.se>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, James Simmons <jsimmons@edgeglobal.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 30 Aug 1999 14:06:48 +0200, Marcus Sundberg
<erammsu@kieraypc01.p.y.ki.era.ericsson.se> said:

> What I believe James is talking about here is allowing non-priviledged
> processes to access graphics hardware where the graphics card, or even
> the whole system, may enter an unrecoverable state if you try to access
> the frame buffer while the accel engine is active. (Yes there really
> exist such hardware...)

I know that.  I know _why_ it is desirable to have hardware protection
of these memory regions.  I also know why it is expensive to provide
that protection in the VM, and why in the SMP threaded case that cost
becomes a prohibitive overhead.  That sucks, but that's life in the
crap-hardware PC world.

> To achieve this you really must physicly prevent the process to access
> the framebuffer while the accel engine is active. The question is what
> the best way to do this is (and if that way is good enough to bother
> doing it...) ?

The only way to do it is to flip page tables while the accel engine is
running.  You may want to restore it on demand by trapping the page
fault on the framebuffer and stalling until the accel lock is released.
This can be done, but it is really expensive: you are doing a whole pile
of messy VM operations every time you want to trigger the accel engine
(any idea how often you want to flip the protection, btw?)

So you are talking several system calls, SMP inter-processor interrupts
and piles of VM page twiddling every time you want to claim and release
the core engine.  Sorry, folks, but there's no way of avoiding the
conclusion that this is going to be expensive.  In the single-CPU or
single-thread case the cost can be kept under control, but it is not
going to be cheap.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
