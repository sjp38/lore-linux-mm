Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 07B1F6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:44:59 -0500 (EST)
Received: by oihr132 with SMTP id r132so11216434oih.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:44:58 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id k17si19125891oib.66.2015.12.11.14.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:44:58 -0800 (PST)
Received: by oihr132 with SMTP id r132so11216324oih.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:44:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151211143300.0ac516fbd219a67954698f9a@linux-foundation.org>
References: <cover.1449803537.git.luto@kernel.org> <c35a9ff9b8ef452964adbf3d828edceff45b70a8.1449803537.git.luto@kernel.org>
 <20151211143300.0ac516fbd219a67954698f9a@linux-foundation.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 14:44:38 -0800
Message-ID: <CALCETrUgS3Ex9-wMquYrFi823JChsDT1+3nVdv_ezGa3T55vyQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm: Add vm_insert_pfn_prot
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Dec 11, 2015 at 2:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 10 Dec 2015 19:21:43 -0800 Andy Lutomirski <luto@kernel.org> wrote:
>
>> The x86 vvar mapping contains pages with differing cacheability
>> flags.  This is currently only supported using (io_)remap_pfn_range,
>> but those functions can't be used inside page faults.
>
> Foggy.  What does "support" mean here?

We currently have a hack in which every x86 mm has a "vvar" vma that
has a .fault handler that always fails (it's the vm_special_mapping
fault handler backed by an empty pages array).  To make everything
work, at mm startup, the vdso code uses remap_pfn_range and
io_remap_pfn_range to poke the pfns into the page tables.

I'd much rather implement this using the new .fault mechanism, and the
canonical way to implement .fault seems to be vm_insert_pfn, and
vm_insert_pfn doesn't allow setting per-page cacheability.
Unfortunately, one of the three x86 vvar pages needs to be uncacheable
because it's a genuine IO page, so I can't use vm_insert_pfn.

I suppose I could just call io_remap_pfn_range from .fault, but I
think that's frowned upon.  Admittedly, I wasn't really sure *why*
that's frowned upon.  This goes way back to 2007
(e0dc0d8f4a327d033bfb63d43f113d5f31d11b3c) when .fault got fancier.

>
>> Add vm_insert_pfn_prot to support varying cacheability within the
>> same non-COW VMA in a more sane manner.
>
> Here, "support" presumably means "insertion of pfns".  Can we spell all
> this out more completely please?

Yes, will fix.

>
>> x86 needs this to avoid a CRIU-breaking and memory-wasting explosion
>> of VMAs when supporting userspace access to the HPET.
>>
>
> OtherwiseAck.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
