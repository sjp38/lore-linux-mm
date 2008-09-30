Subject: Re: [PATCH] slub: reduce total stack usage of slab_err & object_err
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1222796245.23159.38.camel@calx>
References: <1222787736.2995.24.camel@castor.localdomain>
	 <48E2480A.9090003@linux-foundation.org>
	 <1222791638.2995.41.camel@castor.localdomain>
	 <1222796245.23159.38.camel@calx>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 13:33:06 -0500
Message-Id: <1222799586.23159.57.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-30 at 12:37 -0500, Matt Mackall wrote:
> On Tue, 2008-09-30 at 17:20 +0100, Richard Kennedy wrote:
> > Yes, using vprintk is better but you still have this path :
> > ( with your patch applied)
> > 
> > 	object_err -> slab_bug(208) -> printk(216)
> > instead of 
> > 	object_err -> slab_bug_message(8) -> printk(216)
> > 
> > unfortunately the overhead for having var_args is pretty big, at least
> > on x86_64. I haven't measured it on 32 bit yet.
> 
> That's fascinating. I tried a simple test case in userspace:
> 
> #include <stdarg.h>
> #include <stdio.h>
> 
> void p(char *fmt, ...)
> {
> 	va_list args;
> 
> 	va_start(args, fmt);
> 	vprintf(fmt, args);
> 	va_end(args);
> }
> 
> On 32-bit, I'm seeing 32 bytes of stack vs 216 on 64-bit. Disassembly
> suggests it's connected to va_list fiddling with XMM registers, which
> seems quite odd.

Ok, on closer inspection, this is part of the x86_64 calling convention.
When calling a varargs function, the caller passes the number of
floating point SSE regs used in rax. The callee then has to save these
away for va_list use. The GCC prologue apparently sets aside space for
xmm0-xmm7 (16 bytes each) all the time (plus rdi, rsi, rdx, rcx, r8, and
r9).

Obviously, we're never passing floating point args in the kernel, so
we're taking about a 40+ byte hit in code size and 128 byte hit in stack
size for every varargs call.

Looks like the gcc people have a patch in progress:

http://gcc.gnu.org/ml/gcc-patches/2008-08/msg02165.html

So I think we should assume that x86_64 will sort this out eventually.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
