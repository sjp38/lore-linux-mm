From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
Date: Fri, 19 Oct 2007 09:49:00 +1000
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_tD/FHL3nvu84Zrs"
Message-Id: <200710190949.01019.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_tD/FHL3nvu84Zrs
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

[sorry, I read and replied to my inbox before mailing lists...
please ignore the last mail on this patch, and reply to this
one which is properly threaded]

On Friday 19 October 2007 08:15, Christoph Lameter wrote:
> Currently page flags are only modified in SLUB under page lock. This means
> that we do not need an atomic operation to release the lock since there
> is nothing we can race against that is modifying page flags. We can simply
> clear the bit without the use of an atomic operation and make sure that
> this change becomes visible after the other changes to slab metadata
> through a memory barrier.
>
> The performance of slab_free() increases 10-15% (SMP configuration doing
> a long series of remote frees).

Ah, thanks, but can we just use my earlier patch that does the
proper __bit_spin_unlock which is provided by
bit_spin_lock-use-lock-bitops.patch

This primitive should have a better chance at being correct, and
also potentially be more optimised for each architecture (it
only has to provide release consistency).

I have attached the patch here just for reference, but actually
I am submitting it properly as part of a patch series today, now
that the base bit lock patches have been sent upstream.


>  mm/slub.c |   15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
>
> diff -puN mm/slub.c~slub-avoid-atomic-operation-for-slab_unlock mm/slub.c
> --- a/mm/slub.c~slub-avoid-atomic-operation-for-slab_unlock
> +++ a/mm/slub.c
> @@ -1181,9 +1181,22 @@ static __always_inline void slab_lock(st
>       bit_spin_lock(PG_locked, &page->flags);
>  }
>
> +/*
> + * Slab unlock version that avoids having to use atomic operations
> + * (echos some of the code of bit_spin_unlock!)
> + */
>  static __always_inline void slab_unlock(struct page *page)
>  {
> -     bit_spin_unlock(PG_locked, &page->flags);
> +#ifdef CONFIG_SMP
> +     unsigned long flags;
> +
> +     flags = page->flags & ~(1 << PG_locked);
> +
> +     smp_wmb();
> +     page->flags = flags;
> +#endif
> +     preempt_enable();
> +     __release(bitlock);
>  }

This looks wrong, because it would allow the store unlocking
flags to pass a load within the critical section.

stores aren't allowed to pass loads in x86 (only vice versa),
so you might have been confused by looking at x86's spinlocks
into thinking this will work. However on powerpc and sparc, I
don't think it gives you the right types of barriers.


--Boundary-00=_tD/FHL3nvu84Zrs
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="slub-use-nonatomic-unlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="slub-use-nonatomic-unlock.patch"

Slub can use the non-atomic version to unlock because other flags will not
get modified with the lock held.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1185,7 +1185,7 @@ static __always_inline void slab_lock(st
 
 static __always_inline void slab_unlock(struct page *page)
 {
-	bit_spin_unlock(PG_locked, &page->flags);
+	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
 static __always_inline int slab_trylock(struct page *page)

--Boundary-00=_tD/FHL3nvu84Zrs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
