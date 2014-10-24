Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id AA85082BE1
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 04:33:19 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id a41so3614720yho.9
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:33:19 -0700 (PDT)
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com. [209.85.213.48])
        by mx.google.com with ESMTPS id 11si2640778ykj.62.2014.10.24.01.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 01:33:17 -0700 (PDT)
Received: by mail-yh0-f48.google.com with SMTP id v1so460379yhn.7
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:33:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414107635.364.91.camel@pasglop>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
	<20141023.184035.388557314666522484.davem@davemloft.net>
	<1414107635.364.91.camel@pasglop>
Date: Fri, 24 Oct 2014 09:33:17 +0100
Message-ID: <CAPvkgC0myFkGjv=L7XMhjfOSyB=3VAMHzkY9JGwwo_x7i=k0Kw@mail.gmail.com>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On 24 October 2014 00:40, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Thu, 2014-10-23 at 18:40 -0400, David Miller wrote:
>> Hey guys, was looking over the generic GUP while working on a sparc64
>> issue and I noticed that you guys do speculative page gets, and after
>> talking with Johannes Weiner (CC:'d) about this we don't see how it
>> could be necessary.
>>
>> If interrupts are disabled during the page table scan (which they
>> are), no IPI tlb flushes can arrive.  Therefore any removal from the
>> page tables is guarded by interrupts being re-enabled.  And as a
>> result, page counts of pages we see in the page tables must always
>> have a count > 0.
>>
>> x86 does direct atomic_add() on &page->_count because of this
>> invariant and I would rather see the generic version do this too.
>
> This is of course only true of archs who use IPIs for TLB flushes, so if
> we are going down the path of not being speculative, powerpc would have
> to go back to doing its own since our broadcast TLB flush means we
> aren't protected (we are only protected vs. the page tables themselves
> being freed since we do that via sched RCU).
>
> AFAIK, ARM also broadcasts TLB flushes...

Indeed, for most ARM cores we have hardware TLB broadcasts, thus we
need the speculative path.

>
> Another option would be to make the generic code use something defined
> by the arch to decide whether to use speculative get or
> not. I like the idea of keeping the bulk of that code generic...

It would be nice to have the code generalised further.
In addition to the speculative/atomic helpers the implementation would
need to be renamed from GENERIC_RCU_GUP to GENERIC_GUP.
The other noteworthy assumption made in the RCU GUP is that pte's can
be read atomically. For x86 this isn't true when running with 64-bit
pte's, thus a helper would be needed.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
