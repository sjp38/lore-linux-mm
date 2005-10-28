Date: Fri, 28 Oct 2005 02:15:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028001500.GB5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <20051027200434.GT5091@opteron.random> <17249.25225.582755.489919@wombat.chubb.wattle.id.au> <20051027164959.61d04327.akpm@osdl.org> <20051028095600.Y6002974@wobbly.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051028095600.Y6002974@wobbly.melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Peter Chubb <peterc@gelato.unsw.edu.au>, pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 28, 2005 at 09:56:00AM +1000, Nathan Scott wrote:
> There is, at least on IRIX (F_FREESP64).  Agreed on the API klunkiness
> though ... its really not pretty. :|  Personally, I'd recommend going
> with a sane API, and perhaps emulating the other on top of it if need
> be.

That's fine with me as replacement of truncate_rage, this is such a
corner case usage that this api is probably ok. however this is a
separate thing from the madvise one. The madvise one is the only one
where I'm aware of a real life need (of course madvise can be also
replaced by the F_FREESP64 but see below).

I had a specific requirement of using virtual addresses of mapped tmpfs
files, and not physical offsets and filedescriptors. At first I
suggested adding a sys_truncate_range but they apparently they don't
know where the file maps to (or they would need to translate it and
that's not cheap), but the kernel can find it faster than userland (or
at least not slower than userland) by using the vmas.

About madvise not being used to do fs actions I agree about that,
however madvise is already destructive in terms of anonymous memory, so
it doesn't make an huge difference to me. I just didn't imagine a better
way to do that using the virtual range. There's nothing fundamentally
wrong in using MADV_TRUNCATE to do that. This involves a fs callback but
it certainly is a mm operation too given it changes the view of the
address space the same way MADV_DONTNEET (aka MADV_FREE) does for
anonymous memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
