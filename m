Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E081128028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:25:10 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g128so1026110itb.5
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:25:10 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 206si742037itj.150.2017.11.10.04.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 04:25:09 -0800 (PST)
Date: Fri, 10 Nov 2017 13:25:02 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 22/30] x86, pcid, kaiser: allow flushing for future ASID
 switches
Message-ID: <20171110122502.s2i6od7lx4uooyyu@hirez.programming.kicks-ass.net>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194728.4D8F87B6@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108194728.4D8F87B6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, Nov 08, 2017 at 11:47:28AM -0800, Dave Hansen wrote:
> +/*
> + * We get here when we do something requiring a TLB invalidation
> + * but could not go invalidate all of the contexts.  We do the
> + * necessary invalidation by clearing out the 'ctx_id' which
> + * forces a TLB flush when the context is loaded.
> + */
> +void clear_non_loaded_ctxs(void)
> +{
> +	u16 asid;
> +
> +	/*
> +	 * This is only expected to be set if we have disabled
> +	 * kernel _PAGE_GLOBAL pages.
> +	 */
> +        if (IS_ENABLED(CONFIG_X86_GLOBAL_PAGES)) {
> +		WARN_ON_ONCE(1);
> +                return;
> +	}

Whitespace damage..

> +
> +	for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
> +		/* Do not need to flush the current asid */
> +		if (asid == this_cpu_read(cpu_tlbstate.loaded_mm_asid))
> +			continue;
> +		/*
> +		 * Make sure the next time we go to switch to
> +		 * this asid, we do a flush:
> +		 */
> +		this_cpu_write(cpu_tlbstate.ctxs[asid].ctx_id, 0);
> +	}
> +	this_cpu_write(cpu_tlbstate.all_other_ctxs_invalid, false);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
