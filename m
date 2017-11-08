Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 415A66B02B4
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 23:56:13 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f6so703611pln.9
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 20:56:13 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id u69si876459pgb.489.2017.11.07.20.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Nov 2017 20:56:11 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
In-Reply-To: <2ce0a91c-985c-aad8-abfa-e91bc088bb3e@linux.vnet.ibm.com>
References: <20171105231850.5e313e46@roar.ozlabs.ibm.com> <871slcszfl.fsf@linux.vnet.ibm.com> <20171106174707.19f6c495@roar.ozlabs.ibm.com> <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com> <20171106192524.12ea3187@roar.ozlabs.ibm.com> <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com> <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com> <20171107160705.059e0c2b@roar.ozlabs.ibm.com> <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name> <20171107222228.0c8a50ff@roar.ozlabs.ibm.com> <20171107122825.posamr2dmzlzvs2p@node.shutemov.name> <20171108002448.6799462e@roar.ozlabs.ibm.com> <2ce0a91c-985c-aad8-abfa-e91bc088bb3e@linux.vnet.ibm.com>
Date: Wed, 08 Nov 2017 15:56:06 +1100
Message-ID: <87y3nh2wt5.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Florian Weimer <fweimer@redhat.com>, linux-arch@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

>> 
>> If it is decided to keep these kind of heuristics, can we get just a
>> small but reasonably precise description of each change to the
>> interface and ways for using the new functionality, such that would be
>> suitable for the man page? I couldn't fix powerpc because nothing
>> matches and even Aneesh and you differ on some details (MAP_FIXED
>> behaviour).
>
>
> I would consider MAP_FIXED as my mistake. We never discussed this 
> explicitly and I kind of assumed it to behave the same way. ie, we 
> search in lower address space (128TB) if the hint addr is below 128TB.
>
> IIUC we agree on the below.
>
> 1) MAP_FIXED allow the addr to be used, even if hint addr is below 128TB 
> but hint_addr + len is > 128TB.

So:
  mmap(0x7ffffffff000, 0x2000, ..., MAP_FIXED ...) = 0x7ffffffff000

> 2) For everything else we search in < 128TB space if hint addr is below 
> 128TB

  mmap((x < 128T), 0x1000, ...) = (y < 128T)
  ...
  mmap(0x7ffffffff000, 0x1000, ...) = 0x7ffffffff000
  mmap(0x800000000000, 0x1000, ...) = 0x800000000000
  ...
  mmap((x >= 128T), 0x1000, ...) = (y >= 128T)

> 3) We don't switch to large address space if hint_addr + len > 128TB. 
> The decision to switch to large address space is primarily based on hint 
> addr

But does the mmap succeed in that case or not?

ie:  mmap(0x7ffffffff000, 0x2000, ...) = ?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
