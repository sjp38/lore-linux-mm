Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13D986B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:55:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w189-v6so12263050oiw.1
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:55:29 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 201-v6si5827159oic.338.2018.05.04.08.55.27
        for <linux-mm@kvack.org>;
        Fri, 04 May 2018 08:55:28 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v10 24/25] x86/mm: add speculative pagefault handling
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1523975611-15978-25-git-send-email-ldufour@linux.vnet.ibm.com>
	<CAD4BONd5DZiKkGPGaYqEcVb+YubVDy43MNNQ8_yztDHWpf0Y7w@mail.gmail.com>
	<fb143123-d54e-b08d-1bd8-07767c86c7d0@linux.vnet.ibm.com>
Date: Fri, 04 May 2018 16:55:25 +0100
In-Reply-To: <fb143123-d54e-b08d-1bd8-07767c86c7d0@linux.vnet.ibm.com>
	(Laurent Dufour's message of "Thu, 3 May 2018 16:59:14 +0200")
Message-ID: <87efirl8k2.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Punit Agrawal <punitagrawal@gmail.com>, akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.ch en@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> On 30/04/2018 20:43, Punit Agrawal wrote:
>> Hi Laurent,
>> 
>> I am looking to add support for speculative page fault handling to
>> arm64 (effectively porting this patch) and had a few questions.
>> Apologies if I've missed an obvious explanation for my queries. I'm
>> jumping in bit late to the discussion.
>
> Hi Punit,
>
> Thanks for giving this series a review.
> I don't have arm64 hardware to play with, but I'll be happy to add arm64
> patches to my series and to try to maintain them.

I'll be happy to try them on arm64 platforms I have access to and
provide feedback.

>
>> 
>> On Tue, Apr 17, 2018 at 3:33 PM, Laurent Dufour
>> <ldufour@linux.vnet.ibm.com> wrote:
>>> From: Peter Zijlstra <peterz@infradead.org>
>>>

[...]

>>>
>>> -       vma = find_vma(mm, address);
>>> +       if (!vma || !can_reuse_spf_vma(vma, address))
>>> +               vma = find_vma(mm, address);
>> 
>> Is there a measurable benefit from reusing the vma?
>> 
>> Dropping the vma reference unconditionally after speculative page
>> fault handling gets rid of the implicit state when "vma != NULL"
>> (increased ref-count). I found it a bit confusing to follow.
>
> I do agree, this is quite confusing. My initial goal was to be able to reuse
> the VMA in the case a protection key error was detected, but it's not really
> necessary on x86 since we know at the beginning of the fault operation that
> protection key are in the loop. This is not the case on ppc64 but I couldn't
> find a way to easily rely on the speculatively fetched VMA neither, so for
> protection keys, this didn't help.
>
> Regarding the measurable benefit of reusing the fetched vma, I did further
> tests using will-it-scale/page_fault2_threads test, and I'm no more really
> convince that this worth the added complexity. I think I'll drop the patch "mm:
> speculative page fault handler return VMA" of the series, and thus remove the
> call to can_reuse_spf_vma().

Makes sense. Thanks for giving this a go.

Punit

[...]
