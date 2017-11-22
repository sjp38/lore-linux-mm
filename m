Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1958A6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:17:26 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d15so13015800pfl.0
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:17:26 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e190si12867671pfe.409.2017.11.21.16.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 16:17:24 -0800 (PST)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 05A1621921
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 00:17:24 +0000 (UTC)
Received: by mail-io0-f173.google.com with SMTP id g73so21348885ioj.8
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:17:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <62d71c5c-515e-c3be-e8f0-4f640251d20c@linux.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos> <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
 <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com> <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
 <02e48e97-5842-6a19-1ea2-cee4ed5910f4@linux.intel.com> <CALCETrXk=qk=aeaXT+bZWoA2teEtavNnFNTE+o9kh7_As9bmpQ@mail.gmail.com>
 <62d71c5c-515e-c3be-e8f0-4f640251d20c@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 21 Nov 2017 16:17:02 -0800
Message-ID: <CALCETrWqWBMzC_a2bRiTd+dxZQaK+ubhDof-nL06_RG3O1W4gQ@mail.gmail.com>
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Tue, Nov 21, 2017 at 3:42 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/21/2017 03:32 PM, Andy Lutomirski wrote:
>>> To do this, we need to special-case the kernel page table walker to deal
>>> with PTEs only since we can't just grab PMD or PUD flags and stick them
>>> in a PTE.  We would only be able to use this path when populating things
>>> that we know are 4k-mapped in the kernel.
>> I'm not sure I'm understanding the issue.  We'd promise to map the
>> cpu_entry_area without using large pages, but I'm not sure I know what
>> you're referring to.  The only issue I see is that we'd have to be
>> quite careful when tearing down the user tables to avoid freeing the
>> shared part.
>
> It's just that it currently handles large and small pages in the kernel
> mapping that it's copying.  If we want to have it just copy the PTE,
> we've got to refactor things a bit to separate out the PTE flags from
> the paddr being targeted, and also make sure we don't munge the flags
> conversion from the large-page entries to 4k PTEs.  The PAT and PSE bits
> cause a bit of trouble here.

I'm confused.  I mean something like:

unsigned long start = (unsigned long)get_cpu_entry_area(cpu);
for (unsigned long addr = start; addr < start + sizeof(struct
cpu_entry_area); addr += PAGE_SIZE) {
  pte_t pte = *pte_offset_k(addr);  /* or however you do this */
  kaiser_add_mapping(pte_pfn(pte), pte_prot(pte));
}

modulo the huge pile of typos in there that surely exist.

But I still prefer my approach of just sharing the cpu_entry_area pmd
entries between the user and kernel tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
