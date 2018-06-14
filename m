Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF8B6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 22:49:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u21-v6so2287327pfn.0
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 19:49:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y18-v6sor1349736pfj.44.2018.06.13.19.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 19:49:39 -0700 (PDT)
Date: Thu, 14 Jun 2018 12:49:31 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 3/3] powerpc/64s/radix: optimise TLB flush with
 precise TLB ranges in mmu_gather
Message-ID: <20180614124931.703e5b54@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFzJRknbQD6Mv3OSOvUVozQ4H8ni8jPP7UEEi9wKXmVhQA@mail.gmail.com>
References: <20180612071621.26775-1-npiggin@gmail.com>
	<20180612071621.26775-4-npiggin@gmail.com>
	<CA+55aFzKBieD0Y3sgFQzt+x5esqb9vT6SEQ28xyCz5UWegfFVg@mail.gmail.com>
	<20180613083131.139a3c34@roar.ozlabs.ibm.com>
	<CA+55aFyk9VBLUk8VYhfEUR55x0TXY9_QX1dE4wE0A_ias9tMNQ@mail.gmail.com>
	<20180613090950.50566245@roar.ozlabs.ibm.com>
	<CA+55aFxd97-29qi-JMxyPPoZMxw=eObQHB5XXGiLj7SNV8B-oQ@mail.gmail.com>
	<CA+55aFzbYBXUDcAGaP_HoCxjTvOgkixc0+7nJqMea0yKjLSnhw@mail.gmail.com>
	<20180613101241.004fd64e@roar.ozlabs.ibm.com>
	<CA+55aFzJRknbQD6Mv3OSOvUVozQ4H8ni8jPP7UEEi9wKXmVhQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 12 Jun 2018 18:10:26 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Jun 12, 2018 at 5:12 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> > >
> > > And in _theory_, maybe you could have just used "invalpg" with a
> > > targeted address instead. In fact, I think a single invlpg invalidates
> > > _all_ caches for the associated MM, but don't quote me on that.  
> 
> Confirmed. The SDK says
> 
>  "INVLPG also invalidates all entries in all paging-structure caches
>   associated with the current PCID, regardless of the linear addresses
>   to which they correspond"

Interesting, so that's very much like powerpc.

> so if x86 wants to do this "separate invalidation for page directory
> entryes", then it would want to
> 
>  (a) remove the __tlb_adjust_range() operation entirely from
> pud_free_tlb() and friends

Revised patch below (only the generic part this time, but powerpc
implementation gives the same result as the last patch).

> 
>  (b) instead just have a single field for "invalidate_tlb_caches",
> which could be a boolean, or could just be one of the addresses

Yeah well powerpc hijacks one of the existing bools in the mmu_gather
for exactly that, and sets it when a page table page is to be freed.

> and then the logic would be that IFF no other tlb invalidate is done
> due to an actual page range, then we look at that
> invalidate_tlb_caches field, and do a single INVLPG instead.
> 
> I still am not sure if this would actually make a difference in
> practice, but I guess it does mean that x86 could at least participate
> in some kind of scheme where we have architecture-specific actions for
> those page directory entries.

I think it could. But yes I don't know how much it would help, I think
x86 tlb invalidation is very fast, and I noticed this mostly at exec
time when you probably lose all your TLBs anyway.

> 
> And we could make the default behavior - if no architecture-specific
> tlb page directory invalidation function exists - be the current
> "__tlb_adjust_range()" case. So the default would be to not change
> behavior, and architectures could opt in to something like this.
> 
>             Linus

Yep, is this a bit more to your liking?

---
 include/asm-generic/tlb.h | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index faddde44de8c..fa44321bc8dd 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -262,36 +262,49 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
  * architecture to do its own odd thing, not cause pain for others
  * http://lkml.kernel.org/r/CA+55aFzBggoXtNXQeng5d_mRoDnaMBE5Y+URs+PHR67nUpMtaw@mail.gmail.com
  *
+ * Powerpc (Book3S 64-bit) with the radix MMU has an architected "page
+ * walk cache" that is invalidated with a specific instruction. It uses
+ * need_flush_all to issue this instruction, which is set by its own
+ * __p??_free_tlb functions.
+ *
  * For now w.r.t page table cache, mark the range_size as PAGE_SIZE
  */
 
+#ifndef pte_free_tlb
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
+#endif
 
+#ifndef pmd_free_tlb
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
+#endif
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
+#ifndef pud_free_tlb
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
+#endif
 
 #ifndef __ARCH_HAS_5LEVEL_HACK
+#ifndef p4d_free_tlb
 #define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
+#endif
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
-- 
2.17.0
