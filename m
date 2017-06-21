Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B96D6B0429
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:43:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so7574735wrc.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:43:39 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id w145si16435943wmw.126.2017.06.21.10.43.37
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 10:43:37 -0700 (PDT)
Date: Wed, 21 Jun 2017 19:43:20 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
Message-ID: <20170621174320.gouuexwzoau6pjnj@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:10PM -0700, Andy Lutomirski wrote:
> - * The x86 doesn't have a mmu context, but
> - * we put the segment information here.
> + * x86 has arch-specific MMU state beyond what lives in mm_struct.
>   */
>  typedef struct {
> +	/*
> +	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
> +	 * be reused, and zero is not a valid ctx_id.
> +	 */
> +	u64 ctx_id;
> +
> +	/*
> +	 * Any code that needs to do any sort of TLB flushing for this
> +	 * mm will first make its changes to the page tables, then
> +	 * increment tlb_gen, then flush.  This lets the low-level
> +	 * flushing code keep track of what needs flushing.
> +	 *
> +	 * This is not used on Xen PV.
> +	 */
> +	atomic64_t tlb_gen;

Btw, can this just be a 4-byte int instead? I.e., simply atomic_t. I
mean, it should be enough for all the TLB generations in flight, no?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
