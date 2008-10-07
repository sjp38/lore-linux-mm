Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>  <1223391655.13453.344.camel@calx>
	 <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 11:37:35 -0500
Message-Id: <1223397455.13453.385.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-07 at 18:10 +0200, Peter Zijlstra wrote:
> On Tue, 2008-10-07 at 10:00 -0500, Matt Mackall wrote:
> > Give this a try, please:
...
> That seems to make it work again! (4 reboots, 0 crashes)

Thanks, Peter. I know we're way late in the 2.6.27 cycle, so I'll leave
it to Linus and Andrew to decide how to queue this up. I'm obligated to
mention it's theoretically possible that there's a path where this is
exploitable, but of course only on systems where SLOB is in use.


SLOB: fix bogus ksize calculation

SLOB's ksize calculation was braindamaged and generally harmlessly
underreported the allocation size. But for very small buffers, it could
in fact overreport them, leading code depending on krealloc to overrun
the allocation and trample other data.

Signed-off-by: Matt Mackall <mpm@selenic.com>
Tested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

diff -r 5e32b09a1b2b mm/slob.c
--- a/mm/slob.c	Fri Oct 03 14:04:43 2008 -0500
+++ b/mm/slob.c	Tue Oct 07 11:27:47 2008 -0500
@@ -515,7 +515,7 @@
 
 	sp = (struct slob_page *)virt_to_page(block);
 	if (slob_page(sp))
-		return ((slob_t *)block - 1)->units + SLOB_UNIT;
+		return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
 	else
 		return sp->page.private;
 }





-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
