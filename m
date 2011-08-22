Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 51F156B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:14:28 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so5470364bkb.14
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 13:14:25 -0700 (PDT)
Date: Tue, 23 Aug 2011 00:14:20 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low
 addresses
Message-ID: <20110822201418.GA3176@albatros>
References: <20110812102954.GA3496@albatros>
 <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
 <20110816090540.GA7857@albatros>
 <20110822101730.GA3346@albatros>
 <4E5290D6.5050406@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E5290D6.5050406@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 22, 2011 at 10:24 -0700, H. Peter Anvin wrote:
> Conceptually:
> 
> I also have to admit to being somewhat skeptical to the concept on a
> littleendian architecture like x86.

Sorry, I was too short at my statement.  This is a quote from Solar
Designer:

"Requiring NUL as the most significant byte of a 32-bit address achieves
two things:

1. The overflow length has to be inferred/guessed exactly, because only
one NUL may be written.  Simply using a repeated pattern (with function
address and arguments) no longer works.

2. Passing function arguments in the straightforward manner no longer
works, because copying stops after the NUL.  The attacker's best bet may
be to find an entry point not at function boundary that sets registers
and then proceeds with or branches to the desired library code.  The
easiest way to set registers and branch would be a function epilogue -
pop/pop/.../ret - but then there's the difficulty in passing the address
to ret to (we have just one NUL and we've already used it to get to this
code).  Similarly, even via such pop's we can't pass an argument that
contains a NUL in it - e.g., the address of "/bin/sh" in libc (it
contains a NUL most significant byte too) or a zero value for root's
uid.  A possible bypass is via multiple overflows - if the overflow may
be triggered more than once before the vulnerable function returns, then
multiple NULs may be written, exactly one per overflow.  But this is
hopefully relatively rare."

I'll extend the patch description to explain the motivation more
clearly.


> Code-wise:
> 
> The code is horrific; it is full of open-coded magic numbers;

Agreed, the magic needs macro definition and comments.

> it also
> puts a function called arch_get_unmapped_exec_area() in a generic file,
> which could best be described as "WTF" -- the arch_ prefix we use
> specifically to denote a per-architecture hook function.

Agreed.  But I'd want to leave it in mm/mmap.c as it's likely be used by
other archs - the changes are bitness specific, not arch specific.  Is
it OK if I do this?

#ifndef HAVE_ARCH_UNMAPPED_EXEC_AREA
void *arch_get_unmapped_exec_area(...)
{
    ...
}
#endif


Thank you for the review!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
