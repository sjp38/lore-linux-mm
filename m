Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C207C6B03B0
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 13:02:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v62so265323221pfd.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 10:02:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d20si19047528plj.429.2017.07.05.10.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 10:02:22 -0700 (PDT)
Date: Wed, 5 Jul 2017 19:02:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
Message-ID: <20170705170219.ogjnswef3ufgeklz@hirez.programming.kicks-ass.net>
References: <cover.1498751203.git.luto@kernel.org>
 <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
 <20170705121807.GF4941@worktop>
 <CALCETrWivSq=qSN6DMBLXVRCo-EBOx_xvnQYXHojYHuG7SaWnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWivSq=qSN6DMBLXVRCo-EBOx_xvnQYXHojYHuG7SaWnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, Jul 05, 2017 at 09:04:39AM -0700, Andy Lutomirski wrote:
> On Wed, Jul 5, 2017 at 5:18 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
> >> @@ -104,18 +140,20 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
> >>
> >>               /* Resume remote flushes and then read tlb_gen. */
> >>               cpumask_set_cpu(cpu, mm_cpumask(next));
> >
> > Barriers should have a comment... what is being ordered here against
> > what?
> 
> How's this comment?
> 
>         /*
>          * Resume remote flushes and then read tlb_gen.  We need to do
>          * it in this order: any inc_mm_tlb_gen() caller that writes a
>          * larger tlb_gen than we read here must see our cpu set in
>          * mm_cpumask() so that it will know to flush us.  The barrier
>          * here synchronizes with inc_mm_tlb_gen().
>          */

Slightly confusing, you mean this, right?


	cpumask_set_cpu(cpu, mm_cpumask());			inc_mm_tlb_gen();

	MB							MB

	next_tlb_gen = atomic64_read(&next->context.tlb_gen);	flush_tlb_others(mm_cpumask());


which seems to make sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
