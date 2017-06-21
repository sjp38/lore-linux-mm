Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55EDE6B03F7
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:41:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so19523715wrb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:41:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 195si16908729wmk.73.2017.06.21.06.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:41:02 -0700 (PDT)
Date: Wed, 21 Jun 2017 15:40:58 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using
 PCID
In-Reply-To: <alpine.DEB.2.20.1706211159430.2328@nanos>
Message-ID: <alpine.DEB.2.20.1706211540320.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org> <alpine.DEB.2.20.1706211159430.2328@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 21 Jun 2017, Thomas Gleixner wrote:
> > +	for (asid = 0; asid < NR_DYNAMIC_ASIDS; asid++) {
> > +		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
> > +		    next->context.ctx_id)
> > +			continue;
> > +
> > +		*new_asid = asid;
> > +		*need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
> > +			       next_tlb_gen);
> > +		return;
> > +	}
> 
> Hmm. So this loop needs to be taken unconditionally even if the task stays
> on the same CPU. And of course the number of dynamic IDs has to be short in
> order to makes this loop suck performance wise.

 ...  not suck ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
