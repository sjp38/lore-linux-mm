Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 32E1E6B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 07:12:28 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so5003222eaj.35
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 04:12:27 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id s8si51985601eeh.248.2013.12.30.04.12.27
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 04:12:27 -0800 (PST)
Date: Mon, 30 Dec 2013 14:12:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 2/2] mm: additional checks to page flag set/clear
Message-ID: <20131230121224.GB8117@node.dhcp.inet.fi>
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com>
 <1388281504-11453-2-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388281504-11453-2-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 28, 2013 at 08:45:04PM -0500, Sasha Levin wrote:
> Check if the flag is already set before setting it, and vice versa
> for clearing.
> 
> Obviously setting or clearing a flag twice isn't a problem on it's
> own, but it implies that there's an issue where some piece of code
> assumed an opposite state of the flag.

BUG() is overkill. WARN_ONCE is more then enough.

And I don't think this kind of checks make sense for all flags.

Have you seen any obviously broken case which these checks could catch?

> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/page-flags.h | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index d1fe1a7..36b0bef 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -130,6 +130,12 @@ enum pageflags {
>  
>  #ifndef __GENERATING_BOUNDS_H
>  
> +#ifdef CONFIG_DEBUG_VM_PAGE_FLAGS
> +#define VM_ASSERT_FLAG(assert, page) VM_BUG_ON_PAGE(assert, page)
> +#else
> +#define VM_ASSERT_FLAG(assert, page) do { } while (0)
> +#endif
> +
>  /*
>   * Macros to create function definitions for page flags
>   */
> @@ -139,11 +145,13 @@ static inline int Page##uname(const struct page *page)			\
>  
>  #define SETPAGEFLAG(uname, lname)					\
>  static inline void SetPage##uname(struct page *page)			\
> -			{ set_bit(PG_##lname, &page->flags); }
> +			{ VM_ASSERT_FLAG(Page##uname(page), page);	\
> +			set_bit(PG_##lname, &page->flags); }
>  
>  #define CLEARPAGEFLAG(uname, lname)					\
>  static inline void ClearPage##uname(struct page *page)			\
> -			{ clear_bit(PG_##lname, &page->flags); }
> +			{ VM_ASSERT_FLAG(!Page##uname(page), page);	\
> +			clear_bit(PG_##lname, &page->flags); }
>  
>  #define __SETPAGEFLAG(uname, lname)					\
>  static inline void __SetPage##uname(struct page *page)			\
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
