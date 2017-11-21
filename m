Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD436B025E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 18:17:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m4so1581320pgc.23
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:17:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e14si12034403pga.447.2017.11.21.15.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 15:17:17 -0800 (PST)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
 <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
 <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
 <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <02e48e97-5842-6a19-1ea2-cee4ed5910f4@linux.intel.com>
Date: Tue, 21 Nov 2017 15:17:15 -0800
MIME-Version: 1.0
In-Reply-To: <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/21/2017 02:46 PM, Andy Lutomirski wrote:
>> GDT: R/O TSS: R/W at least because of trampoline stack entry code:
>> EXEC+R/O exception stacks: R/W
> Can you avoid code duplication by adding some logic right after the
> kernel cpu_entry_area is set up to iterate page by page over the PTEs
> in the cpu_entry_area for that CPU and just install exactly the same
> PTEs into the kaiser table?  E.g. just call kaiser_add_mapping once
> per page but with the parameters read out from the fixmap PTEs
> instead of hard coded?

Yes, we could do that.  But, what's the gain?  We end up removing
effectively three (long) lines of code from three kaiser_add_mapping()
calls.

To do this, we need to special-case the kernel page table walker to deal
with PTEs only since we can't just grab PMD or PUD flags and stick them
in a PTE.  We would only be able to use this path when populating things
that we know are 4k-mapped in the kernel.

I guess the upside is that we don't open-code the permissions in the
KAISER code that *have* to match the permissions that the kernel itself
established.

It also means that theoretically you could not touch the KAISER code the
next time we expand the cpu entry area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
