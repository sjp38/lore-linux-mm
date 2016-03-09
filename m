Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 552106B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 09:51:28 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id td3so14778598pab.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 06:51:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t13si1503757pas.225.2016.03.09.06.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 06:51:27 -0800 (PST)
Date: Wed, 9 Mar 2016 15:51:19 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
Message-ID: <20160309145119.GN6356@twins.programming.kicks-ass.net>
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
 <56DFC604.6070407@synopsys.com>
 <20160309101349.GJ6344@twins.programming.kicks-ass.net>
 <56E023A5.2000105@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E023A5.2000105@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-parisc@vger.kernel, Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Noam Camus <noamc@ezchip.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-snps-arc@lists.infradead.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Mar 09, 2016 at 06:52:45PM +0530, Vineet Gupta wrote:
> On Wednesday 09 March 2016 03:43 PM, Peter Zijlstra wrote:
> >> There is clearly a problem in slub code that it is pairing a test_and_set_bit()
> >> with a __clear_bit(). Latter can obviously clobber former if they are not a single
> >> instruction each unlike x86 or they use llock/scond kind of instructions where the
> >> interim store from other core is detected and causes a retry of whole llock/scond
> >> sequence.
> > 
> > Yes, test_and_set_bit() + __clear_bit() is broken.
> 
> But in SLUB: bit_spin_lock() + __bit_spin_unlock() is acceptable ? How so
> (ignoring the performance thing for discussion sake, which is a side effect of
> this implementation).

The sort answer is: Per definition. They are defined to work together,
which is what makes __clear_bit_unlock() such a special function.

> So despite the comment below in bit_spinlock.h I don't quite comprehend how this
> is allowable. And if say, by deduction, this is fine for LLSC or lock prefixed
> cases, then isn't this true in general for lot more cases in kernel, i.e. pairing
> atomic lock with non-atomic unlock ? I'm missing something !

x86 (and others) do in fact use non-atomic instructions for
spin_unlock(). But as this is all arch specific, we can make these
assumptions. Its just that generic code cannot rely on it.

So let me try and explain.


The problem as identified is:

CPU0						CPU1

bit_spin_lock()					__bit_spin_unlock()
1:
	/* fetch_or, r1 holds the old value */
	spin_lock
	load	r1, addr
						load	r1, addr
						bclr	r2, r1, 1
						store	r2, addr
	or	r2, r1, 1
	store	r2, addr	/* lost the store from CPU1 */
	spin_unlock

	and	r1, 1
	bnz	2	/* it was set, go wait */
	ret

2:
	load	r1, addr
	and	r1, 1
	bnz	2	/* wait until its not set */

	b	1	/* try again */



For LL/SC we replace:

	spin_lock
	load	r1, addr

	...

	store	r2, addr
	spin_unlock

With the (obvious):

1:
	load-locked	r1, addr

	...

	store-cond	r2, addr
	bnz		1 /* or whatever branch instruction is required to retry */


In this case the failure cannot happen, because the store from CPU1
would have invalidated the lock from CPU0 and caused the
store-cond to fail and retry the loop, observing the new value.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
