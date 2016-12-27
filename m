Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDAF6B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 06:20:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so803446995pgi.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 03:20:02 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id t4si26858621pgb.161.2016.12.27.03.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 03:20:01 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id g1so12176260pgn.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 03:20:00 -0800 (PST)
Date: Tue, 27 Dec 2016 21:19:46 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting
 for a page bit
Message-ID: <20161227211946.3770b6ce@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com>
	<20161225030030.23219-3-npiggin@gmail.com>
	<CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
	<20161226111654.76ab0957@roar.ozlabs.ibm.com>
	<CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 26 Dec 2016 11:07:52 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Dec 25, 2016 at 5:16 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > I did actually play around with that. I could not get my skylake
> > to forward the result from a lock op to a subsequent load (the
> > latency was the same whether you use lock ; andb or lock ; andl
> > (32 cycles for my test loop) whereas with non-atomic versions I
> > was getting about 15 cycles for andb vs 2 for andl.  
> 
> Yes, interesting. It does look like the locked ops don't end up having
> the partial write issue and the size of the op doesn't matter.
> 
> But it's definitely the case that the write buffer hit immediately
> after the atomic read-modify-write ends up slowing things down, so the
> profile oddity isn't just a profile artifact. I wrote a stupid test
> program that did an atomic increment, and then read either the same
> value, or an adjacent value in memory (so same instruvtion sequence,
> the difference just being what memory location the read accessed).
> 
> Reading the same value after the atomic update was *much* more
> expensive than reading the adjacent value, so it causes some kind of
> pipeline hickup (by about 50% of the cost of the atomic op itself:
> iow, the "atomic-op followed by read same location" was over 1.5x
> slower than "atomic op followed by read of another location").
> 
> So the atomic ops don't serialize things entirely, but they *hate*
> having the value read (regardless of size) right after being updated,
> because it causes some kind of nasty pipeline issue.

Sure, I would expect independent operations to be able to run ahead
of the atomic op, and this might point to speculation of consistency
for loads -- an independent younger load can be executed speculatively
before the atomic op and flushed if the cacheline was lost before the
load is completed in order.

I bet forwarding from the store queue in case of a locked op is more
difficult. I guess it could be done in the same way, but the load hits
the store queue ahead of the cache then it's more work to then have
the load go to the cache so it can find the line to speculate on while
the flush is in progress. Common case of load hit non-atomic store
would not require this case so it may just not be worthwhile.

Anyway that's speculation (ha). What matters is we know the load is
nasty.

> 
> A cmpxchg does seem to avoid the issue.

Yes, I wonder what to do. POWER CPUs have very similar issues and we
have noticed unlock_page and several other cases where atomic ops cause
load stalls. With its ll/sc, POWER would prefer not to do a cmpxchg.

Attached is part of a patch I've been mulling over for a while. I
expect you to hate it, and it does not solve this problem for x86,
but I like being able to propagate values from atomic ops back
to the compiler. Of course, volatile then can't be used either which
is another spanner...

Short term option is to just have a specific primitive for
clear-unlock-and-test, which we kind of need anyway here to avoid the
memory barrier in an arch-independent way.

Thanks,
Nick

---

After removing the smp_mb__after_atomic and volatile from test_bit,
applying this directive to atomic primitives results in test_bit able
to recognise if the value is in a register. unlock_page improves:

     lwsync
     ldarx   r10,0,r3
     andc    r10,r10,r9
     stdcx.  r10,0,r3
     bne-    99c <unlock_page+0x5c>
-    ld      r9,0(r3)
-    andi.   r10,r9,2
+    andi.   r10,r10,2
     beqlr
     b       97c <unlock_page+0x3c>
---
 arch/powerpc/include/asm/bitops.h       |  2 ++
 arch/powerpc/include/asm/local.h        | 12 ++++++++++++
 include/asm-generic/bitops/non-atomic.h |  2 +-
 include/linux/compiler.h                | 19 +++++++++++++++++++
 mm/filemap.c                            |  2 +-
 5 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/bitops.h b/arch/powerpc/include/asm/bitops.h
index 59abc620f8e8..0c3e0c384b7d 100644
--- a/arch/powerpc/include/asm/bitops.h
+++ b/arch/powerpc/include/asm/bitops.h
@@ -70,6 +70,7 @@ static __inline__ void fn(unsigned long mask,	\
 	: "=&r" (old), "+m" (*p)		\
 	: "r" (mask), "r" (p)			\
 	: "cc", "memory");			\
+	compiler_assign_ptr_val(p, old);	\
 }
 
 DEFINE_BITOP(set_bits, or, "")
@@ -117,6 +118,7 @@ static __inline__ unsigned long fn(			\
 	: "=&r" (old), "=&r" (t)			\
 	: "r" (mask), "r" (p)				\
 	: "cc", "memory");				\
+	compiler_assign_ptr_val(p, old);		\
 	return (old & mask);				\
 }
 
diff --git a/arch/powerpc/include/asm/local.h b/arch/powerpc/include/asm/local.h
index b8da91363864..be965e6c428a 100644
--- a/arch/powerpc/include/asm/local.h
+++ b/arch/powerpc/include/asm/local.h
@@ -33,6 +33,8 @@ static __inline__ long local_add_return(long a, local_t *l)
 	: "r" (a), "r" (&(l->a.counter))
 	: "cc", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t;
 }
 
@@ -52,6 +54,8 @@ static __inline__ long local_sub_return(long a, local_t *l)
 	: "r" (a), "r" (&(l->a.counter))
 	: "cc", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t;
 }
 
@@ -69,6 +73,8 @@ static __inline__ long local_inc_return(local_t *l)
 	: "r" (&(l->a.counter))
 	: "cc", "xer", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t;
 }
 
@@ -96,6 +102,8 @@ static __inline__ long local_dec_return(local_t *l)
 	: "r" (&(l->a.counter))
 	: "cc", "xer", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t;
 }
 
@@ -130,6 +138,8 @@ static __inline__ int local_add_unless(local_t *l, long a, long u)
 	: "r" (&(l->a.counter)), "r" (a), "r" (u)
 	: "cc", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t != u;
 }
 
@@ -159,6 +169,8 @@ static __inline__ long local_dec_if_positive(local_t *l)
 	: "r" (&(l->a.counter))
 	: "cc", "memory");
 
+	compiler_assign_ptr_val(&(l->a.counter), t);
+
 	return t;
 }
 
diff --git a/include/asm-generic/bitops/non-atomic.h b/include/asm-generic/bitops/non-atomic.h
index 697cc2b7e0f0..e8b388b98309 100644
--- a/include/asm-generic/bitops/non-atomic.h
+++ b/include/asm-generic/bitops/non-atomic.h
@@ -100,7 +100,7 @@ static inline int __test_and_change_bit(int nr,
  * @nr: bit number to test
  * @addr: Address to start counting from
  */
-static inline int test_bit(int nr, const volatile unsigned long *addr)
+static inline int test_bit(int nr, const unsigned long *addr)
 {
 	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
 }
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index cf0fa5d86059..b31353934c6a 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -205,6 +205,25 @@ void ftrace_likely_update(struct ftrace_branch_data *f, int val, int expect);
 	= (unsigned long)&sym;
 #endif
 
+/*
+ * Inform the compiler when the value of a pointer is known.
+ * This can be useful when the caller knows the value but the compiler does
+ * not. Typically, when assembly is used.
+ *
+ * val should be a variable that's likely to be in a register or an immediate,
+ * or a constant.
+ *
+ * This should be used carefully, verifying improvements in generated code.
+ * This is not a hint. It will cause bugs if it is used incorrectly.
+ */
+#ifndef compiler_assign_ptr_val
+# define compiler_assign_ptr_val(ptr, val)			\
+do {								\
+	if (*(ptr) != (val))					\
+		unreachable();					\
+} while (0)
+#endif
+
 #ifndef RELOC_HIDE
 # define RELOC_HIDE(ptr, off)					\
   ({ unsigned long __ptr;					\
diff --git a/mm/filemap.c b/mm/filemap.c
index 82f26cde830c..0e7d9008e95f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -929,7 +929,7 @@ void unlock_page(struct page *page)
 	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
-	smp_mb__after_atomic();
+	// smp_mb__after_atomic();
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
