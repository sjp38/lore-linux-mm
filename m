Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EB7BE6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:14:00 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x188so36724268pfb.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:14:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y64si11540505pfi.87.2016.03.09.02.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 02:14:00 -0800 (PST)
Date: Wed, 9 Mar 2016 11:13:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
Message-ID: <20160309101349.GJ6344@twins.programming.kicks-ass.net>
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
 <56DFC604.6070407@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DFC604.6070407@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-parisc@vger.kernel, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wed, Mar 09, 2016 at 12:13:16PM +0530, Vineet Gupta wrote:
> +CC linux-arch, parisc folks, PeterZ
> 
> On Wednesday 09 March 2016 02:10 AM, Christoph Lameter wrote:
> > On Tue, 8 Mar 2016, Vineet Gupta wrote:
> > 
> >> # set the bit
> >> 80543b8e:	ld_s       r2,[r13,0] <--- (A) Finds PG_locked is set
> >> 80543b90:	or         r3,r2,1    <--- (B) other core unlocks right here
> >> 80543b94:	st_s       r3,[r13,0] <--- (C) sets PG_locked (overwrites unlock)
> > 
> > Duh. Guess you  need to take the spinlock also in the arch specific
> > implementation of __bit_spin_unlock(). This is certainly not the only case
> > in which we use the __ op to unlock.
> 
> __bit_spin_lock() by definition is *not* required to be atomic, bit_spin_lock() is
> - so I don't think we need a spinlock there.

Agreed. The double underscore prefixed instructions are not required to
be atomic in any way shape or form.

> There is clearly a problem in slub code that it is pairing a test_and_set_bit()
> with a __clear_bit(). Latter can obviously clobber former if they are not a single
> instruction each unlike x86 or they use llock/scond kind of instructions where the
> interim store from other core is detected and causes a retry of whole llock/scond
> sequence.

Yes, test_and_set_bit() + __clear_bit() is broken.

> > If you take the lock in __bit_spin_unlock
> > then the race cannot happen.
> 
> Of course it won't but that means we penalize all non atomic callers of the API
> with a superfluous spinlock which is not require din first place given the
> definition of API.

Quite. _However_, your arch is still broken, but not by your fault. Its
the generic-asm code that is wrong.

The thing is that __bit_spin_unlock() uses __clear_bit_unlock(), which
defaults to __clear_bit(). Which is wrong.

---
Subject: bitops: Do not default to __clear_bit() for __clear_bit_unlock()

__clear_bit_unlock() is a special little snowflake. While it carries the
non-atomic '__' prefix, it is specifically documented to pair with
test_and_set_bit() and therefore should be 'somewhat' atomic.

Therefore the generic implementation of __clear_bit_unlock() cannot use
the fully non-atomic __clear_bit() as a default.

If an arch is able to do better; is must provide an implementation of
__clear_bit_unlock() itself.

Reported-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/bitops/lock.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/asm-generic/bitops/lock.h b/include/asm-generic/bitops/lock.h
index c30266e94806..8ef0ccbf8167 100644
--- a/include/asm-generic/bitops/lock.h
+++ b/include/asm-generic/bitops/lock.h
@@ -29,16 +29,16 @@ do {					\
  * @nr: the bit to set
  * @addr: the address to start counting from
  *
- * This operation is like clear_bit_unlock, however it is not atomic.
- * It does provide release barrier semantics so it can be used to unlock
- * a bit lock, however it would only be used if no other CPU can modify
- * any bits in the memory until the lock is released (a good example is
- * if the bit lock itself protects access to the other bits in the word).
+ * A weaker form of clear_bit_unlock() as used by __bit_lock_unlock(). If all
+ * the bits in the word are protected by this lock some archs can use weaker
+ * ops to safely unlock.
+ *
+ * See for example x86's implementation.
  */
 #define __clear_bit_unlock(nr, addr)	\
 do {					\
-	smp_mb();			\
-	__clear_bit(nr, addr);		\
+	smp_mb__before_atomic();	\
+	clear_bit(nr, addr);		\
 } while (0)
 
 #endif /* _ASM_GENERIC_BITOPS_LOCK_H_ */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
