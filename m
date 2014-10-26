Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id B21176B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 16:52:05 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id l6so2938164qcy.1
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 13:52:05 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id w5si17897726qat.116.2014.10.26.13.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Oct 2014 13:52:02 -0700 (PDT)
Message-ID: <1414356641.364.142.camel@pasglop>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 27 Oct 2014 07:50:41 +1100
In-Reply-To: <1414167761.19984.17.camel@jarvis.lan>
References: 
	<1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
	 <20141023.184035.388557314666522484.davem@davemloft.net>
	 <1414107635.364.91.camel@pasglop> <1414167761.19984.17.camel@jarvis.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, steve.capper@linaro.org, aarcange@redhat.com, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org

On Fri, 2014-10-24 at 09:22 -0700, James Bottomley wrote:

> Parisc does this.  As soon as one CPU issues a TLB purge, it's broadcast
> to all the CPUs on the inter-CPU bus.  The next instruction isn't
> executed until they respond.
> 
> But this is only for our CPU TLB.  There's no other external
> consequence, so removal from the page tables isn't effected by this TLB
> flush, therefore the theory on which Dave bases the change to
> atomic_add() should work for us (of course, atomic_add is lock add
> unlock on our CPU, so it's not going to be of much benefit).

I'm not sure I follow you here.

Do you or do you now perform an IPI to do TLB flushes ? If you don't
(for example because you have HW broadcast), then you need the
speculative get_page(). If you do (and can read a PTE atomically), you
can get away with atomic_add().

The reason is that if you remember how zap_pte_range works, we perform
the flush before we get rid of the page.

So if your using IPIs for the flush, the fact that gup_fast has
interrupts disabled will delay the IPI response and thus effectively
prevent the pages from being actually freed, allowing us to simply do
the atomic_add() on x86.

But if we don't use IPIs because we have HW broadcast of TLB
invalidations, then we don't have that synchronization. atomic_add won't
work, we need get_page_speculative() because the page could be
concurrently being freed.

Cheers,
Ben.

> James
> 
> > Another option would be to make the generic code use something defined
> > by the arch to decide whether to use speculative get or
> > not. I like the idea of keeping the bulk of that code generic...
> > 
> > Cheers,
> > Ben.
> > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
