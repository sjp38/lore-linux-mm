Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F02ED6B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:20:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t76so6291071pfk.7
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 13:20:01 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c41si11932778plj.293.2017.11.21.13.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 13:20:00 -0800 (PST)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
 <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
Date: Tue, 21 Nov 2017 13:19:57 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/20/2017 12:46 PM, Andy Lutomirski wrote:
>>> +     /*
>>> +      * We could theoretically do this in setup_fixmap_gdt().
>>> +      * But, we would need to rewrite the above page table
>>> +      * allocation code to use the bootmem allocator.  The
>>> +      * buddy allocator is not available at the time that we
>>> +      * call setup_fixmap_gdt() for CPU 0.
>>> +      */
>>> +     kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
>>> +                               __PAGE_KERNEL_RO | _PAGE_GLOBAL);
>> This one is needs to stay.
> When you rebase on to my latest version, this should change to mapping
> the entire cpu_entry_area.

I did this, but unfortunately it ends up having to individually map all
four pieces of cpu_entry_area.  They all need different permissions and
while theoretically we could do TSS+exception-stacks in the same call,
they're not next to each other:

 GDT: R/O
 TSS: R/W at least because of trampoline stack
 entry code: EXEC+R/O
 exception stacks: R/W

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
