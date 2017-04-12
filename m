Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80BC56B03A1
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 06:41:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s22so13153492pfs.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 03:41:40 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r138si13394440pfr.150.2017.04.12.03.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Apr 2017 03:41:39 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above 47-bits
In-Reply-To: <20170407155945.7lyapjbwacg3ikw6@node.shutemov.name>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com> <20170406140106.78087-9-kirill.shutemov@linux.intel.com> <8d68093b-670a-7d7e-2216-bf64b19c7a48@linux.vnet.ibm.com> <20170407155945.7lyapjbwacg3ikw6@node.shutemov.name>
Date: Wed, 12 Apr 2017 20:41:29 +1000
Message-ID: <87wpap6h7q.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <dsafonov@virtuozzo.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hi Kirill,

I'm interested in this because we're doing pretty much the same thing on
powerpc at the moment, and I want to make sure x86 & powerpc end up with
compatible behaviour.

"Kirill A. Shutemov" <kirill@shutemov.name> writes:
> On Fri, Apr 07, 2017 at 07:05:26PM +0530, Anshuman Khandual wrote:
>> On 04/06/2017 07:31 PM, Kirill A. Shutemov wrote:
>> > On x86, 5-level paging enables 56-bit userspace virtual address space.
>> > Not all user space is ready to handle wide addresses. It's known that
>> > at least some JIT compilers use higher bits in pointers to encode their
>> > information. It collides with valid pointers with 5-level paging and
>> > leads to crashes.
>> > 
>> > To mitigate this, we are not going to allocate virtual address space
>> > above 47-bit by default.
>> 
>> I am wondering if the commitment of virtual space range to the
>> user space is kind of an API which needs to be maintained there
>> after. If that is the case then we need to have some plans when
>> increasing it from the current level.
>
> I don't think we should ever enable full address space for all
> applications. There's no point.
>
> /bin/true doesn't need more than 64TB of virtual memory.
> And I hope never will.
>
> By increasing virtual address space for everybody we will pay (assuming
> current page table format) at least one extra page per process for moving
> stack at very end of address space.

That assumes the current layout though, it could be different.

> Yes, you can gain something in security by having more bits for ASLR, but
> I don't think it worth the cost.

It may not be worth the cost now, for you, but that trade off will be
different for other people and at other times.

So I think it's quite likely some folks will be interested in the full
address range for ASLR.

>> expanding the address range next time around. I think we need
>> to have a plan for this and particularly around 'hint' mechanism
>> and whether it should be decided per mmap() request or at the
>> task level.
>
> I think the reasonable way for an application to claim it's 63-bit clean
> is to make allocations with (void *)-1 as hint address.

I do like the simplicity of that.

But I wouldn't be surprised if some (crappy) code out there already
passes an address of -1. Probably it won't break if it starts getting
high addresses, but who knows.

An alternative would be to only interpret the hint as requesting a large
address if it's >= 64TB && < TASK_SIZE_MAX.

If we're really worried about breaking userspace then a new MMAP flag
seems like the safest option?

I don't feel particularly strongly about any option, but like I said my
main concern is that x86 & powerpc end up with the same behaviour.

And whatever we end up with someone will need to do an update to the man
page for mmap.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
