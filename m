Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 079956B03C3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:40:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so28828145wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:40:27 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id z65si17167211wrb.382.2017.06.21.02.40.26
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 02:40:26 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:40:15 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 02/11] x86/ldt: Simplify LDT switching logic
Message-ID: <20170621094015.nknwc5iec7zn56xl@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <2a859ac01245f9594c58f9d0a8b2ed8a7cd2507e.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <2a859ac01245f9594c58f9d0a8b2ed8a7cd2507e.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:08PM -0700, Andy Lutomirski wrote:
> Originally, Linux reloaded the LDT whenever the prev mm or the next
> mm had an LDT.  It was changed in 0bbed3beb4f2 ("[PATCH]
> Thread-Local Storage (TLS) support") (from the historical tree) like
> this:
> 
> -		/* load_LDT, if either the previous or next thread
> -		 * has a non-default LDT.
> +		/*
> +		 * load the LDT, if the LDT is different:
> 		 */
> -		if (next->context.size+prev->context.size)
> +		if (unlikely(prev->context.ldt != next->context.ldt))
> 			load_LDT(&next->context);
> 
> The current code is unlikely to avoid any LDT reloads, since different
> mms won't share an LDT.
> 
> When we redo lazy mode to stop flush IPIs without switching to
> init_mm, though, the current logic would become incorrect: it will
> be possible to have real_prev == next but nonetheless have a stale
> LDT descriptor.
> 
> Simplify the code to update LDTR if either the previous or the next
> mm has an LDT, i.e. effectively restore the historical logic..
> While we're at it, clean up the code by moving all the ifdeffery to
> a header where it belongs.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/mmu_context.h | 26 ++++++++++++++++++++++++++
>  arch/x86/mm/tlb.c                  | 20 ++------------------
>  2 files changed, 28 insertions(+), 18 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
