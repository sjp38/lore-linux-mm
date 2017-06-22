Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2BCE6B036A
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:34:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a9so2190203oih.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:34:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d7si58929ote.187.2017.06.21.19.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 19:34:30 -0700 (PDT)
Received: from mail-ua0-f173.google.com (mail-ua0-f173.google.com [209.85.217.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8E48821D3C
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:34:29 +0000 (UTC)
Received: by mail-ua0-f173.google.com with SMTP id g40so3231845uaa.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:34:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170621174320.gouuexwzoau6pjnj@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <e2903f555bd23f8cf62f34b91895c42f7d4e40e3.1498022414.git.luto@kernel.org>
 <20170621174320.gouuexwzoau6pjnj@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 19:34:08 -0700
Message-ID: <CALCETrXXrCaO9SZjWGXz73ZN9iED0CRJ9QT7zukHxaAMw3VCkw@mail.gmail.com>
Subject: Re: [PATCH v3 04/11] x86/mm: Give each mm TLB flush generation a
 unique ID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 10:43 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:10PM -0700, Andy Lutomirski wrote:
>> - * The x86 doesn't have a mmu context, but
>> - * we put the segment information here.
>> + * x86 has arch-specific MMU state beyond what lives in mm_struct.
>>   */
>>  typedef struct {
>> +     /*
>> +      * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
>> +      * be reused, and zero is not a valid ctx_id.
>> +      */
>> +     u64 ctx_id;
>> +
>> +     /*
>> +      * Any code that needs to do any sort of TLB flushing for this
>> +      * mm will first make its changes to the page tables, then
>> +      * increment tlb_gen, then flush.  This lets the low-level
>> +      * flushing code keep track of what needs flushing.
>> +      *
>> +      * This is not used on Xen PV.
>> +      */
>> +     atomic64_t tlb_gen;
>
> Btw, can this just be a 4-byte int instead? I.e., simply atomic_t. I
> mean, it should be enough for all the TLB generations in flight, no?

There can only be NR_CPUS generations that actually mean anything at
any given time, but I think they can be arbitrarily discontinuous.
Imagine a malicious program that does:

set affiinitiy to CPU 1
mmap()
set affinity to CPU 0
for (i = 0; i < (1ULL<<32); i++) {
  munmap();
  mmap();
}
set affinity to CPU 1

With just atomic_t, this could blow up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
