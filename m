Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 75C0C6B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 14:21:24 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id z2so3428842wey.32
        for <linux-mm@kvack.org>; Mon, 24 Dec 2012 11:21:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
References: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 24 Dec 2012 11:21:02 -0800
Message-ID: <CA+55aFxb63WMysJ-HQbam_JH05Bqp=XhrzokrSM-yvoaAzPASg@mail.gmail.com>
Subject: Re: PageHead macro broken?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <cdall@cs.columbia.edu>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>

On Mon, Dec 24, 2012 at 10:53 AM, Christoffer Dall
<cdall@cs.columbia.edu> wrote:
>
> I think I may have found an issue with the PageHead macro, which
> returns true for tail compound pages when CONFIG_PAGEFLAGS_EXTENDED is
> not defined.

Hmm. Your patch *looks* obviously correct, in that it actually makes
the code match the comment just above it. And making PageHead() test
just the "compound" flag (and thus a tail-page would trigger it too)
sounds wrong. But I join you in the "let's check the expected
semantics with the people who use it" chorus.

The fact that it fixes a problem on KVM/ARM is obviously another good sign.

At the same time, I wonder why it hasn't shown up as a problem on
x86-32. On x86-64 PAGEFLAGS_EXTENDED is always true, but afaik, it
should be possible to trigger this on 32-bit architectures if you just
have SPARSEMEM && !SPARSEMEM_VMEMMAP.

And SPARSEMEM on x86-32 is enabled with NUMA or EXPERIMENTAL set. And
afaik, x86-32 never has SPARSEMEM_VMEMMAP. So this should not be a
very uncommon setup.

Added Andrea and Kirill to the Cc, since most of the *uses* of
PageHead() in the generic VM code are attributed to either of them
according to "git blame". Left the rest of the email quoted for the
new participants.. Also, you seem to have used Christoph's old SGI
email address that I don't think is in use any more.

Andrea? Kirill? Christoph?

                   Linus

---
> I'm not sure however, if this indeed is the intended behavior and I'm
> missing something overall. In any case, the below patch is a proposed
> fix, which does fix a bug showing up on KVM/ARM with huge pages.
>
> Your input would be greatly appreciated.
>
> From: Christoffer Dall <cdall@cs.columbia.edu>
> Date: Fri, 21 Dec 2012 13:03:50 -0500
> Subject: [PATCH] mm: Fix PageHead when !CONFIG_PAGEFLAGS_EXTENDED
>
> Unfortunately with !CONFIG_PAGEFLAGS_EXTENDED, (!PageHead) is false, and
> (PageHead) is true, for tail pages.  If this is indeed the intended
> behavior, which I doubt because it breaks cache cleaning on some ARM
> systems, then the nomenclature is highly problematic.
>
> This patch makes sure PageHead is only true for head pages and PageTail
> is only true for tail pages, and neither is true for non-compound pages.
>
> Signed-off-by: Christoffer Dall <cdall@cs.columbia.edu>
> ---
>  include/linux/page-flags.h |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index b5d1384..70473da 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -362,7 +362,7 @@ static inline void ClearPageCompound(struct page *page)
>   * pages on the LRU and/or pagecache.
>   */
>  TESTPAGEFLAG(Compound, compound)
> -__PAGEFLAG(Head, compound)
> +__SETPAGEFLAG(Head, compound)  __CLEARPAGEFLAG(Head, compound)
>
>  /*
>   * PG_reclaim is used in combination with PG_compound to mark the
> @@ -374,8 +374,14 @@ __PAGEFLAG(Head, compound)
>   * PG_compound & PG_reclaim => Tail page
>   * PG_compound & ~PG_reclaim => Head page
>   */
> +#define PG_head_mask ((1L << PG_compound))
>  #define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))
>
> +static inline int PageHead(struct page *page)
> +{
> + return ((page->flags & PG_head_tail_mask) == PG_head_mask);
> +}
> +
>  static inline int PageTail(struct page *page)
>  {
>   return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
> --
> 1.7.9.5
>
>
> Thanks!
> -Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
