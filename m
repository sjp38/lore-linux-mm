Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C20866B0343
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 08:25:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c12so258124656pfj.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 05:25:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w8si17341765pfj.27.2017.07.05.05.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 05:25:16 -0700 (PDT)
Date: Wed, 5 Jul 2017 14:25:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
Message-ID: <20170705122506.GG4941@worktop>
References: <cover.1498751203.git.luto@kernel.org>
 <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
> +			    u16 *new_asid, bool *need_flush)
> +{
> +	u16 asid;
> +
> +	if (!static_cpu_has(X86_FEATURE_PCID)) {
> +		*new_asid = 0;
> +		*need_flush = true;
> +		return;
> +	}
> +
> +	for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
> +		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
> +		    next->context.ctx_id)
> +			continue;
> +
> +		*new_asid = asid;
> +		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
> +			       next_tlb_gen);
> +		return;
> +	}
> +
> +	/*
> +	 * We don't currently own an ASID slot on this CPU.
> +	 * Allocate a slot.
> +	 */
> +	*new_asid = this_cpu_add_return(cpu_tlbstate.next_asid, 1) - 1;

So this basically RR the ASID slots. Have you tried slightly more
complex replacement policies like CLOCK ?

> +	if (*new_asid >= TLB_NR_DYN_ASIDS) {
> +		*new_asid = 0;
> +		this_cpu_write(cpu_tlbstate.next_asid, 1);
> +	}
> +	*need_flush = true;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
