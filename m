Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84CD86B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 18:43:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 27so12854402pft.8
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:43:03 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l80si13280136pfa.19.2017.11.21.15.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 15:43:02 -0800 (PST)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
 <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
 <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
 <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
 <02e48e97-5842-6a19-1ea2-cee4ed5910f4@linux.intel.com>
 <CALCETrXk=qk=aeaXT+bZWoA2teEtavNnFNTE+o9kh7_As9bmpQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <62d71c5c-515e-c3be-e8f0-4f640251d20c@linux.intel.com>
Date: Tue, 21 Nov 2017 15:42:59 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXk=qk=aeaXT+bZWoA2teEtavNnFNTE+o9kh7_As9bmpQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/21/2017 03:32 PM, Andy Lutomirski wrote:
>> To do this, we need to special-case the kernel page table walker to deal
>> with PTEs only since we can't just grab PMD or PUD flags and stick them
>> in a PTE.  We would only be able to use this path when populating things
>> that we know are 4k-mapped in the kernel.
> I'm not sure I'm understanding the issue.  We'd promise to map the
> cpu_entry_area without using large pages, but I'm not sure I know what
> you're referring to.  The only issue I see is that we'd have to be
> quite careful when tearing down the user tables to avoid freeing the
> shared part.

It's just that it currently handles large and small pages in the kernel
mapping that it's copying.  If we want to have it just copy the PTE,
we've got to refactor things a bit to separate out the PTE flags from
the paddr being targeted, and also make sure we don't munge the flags
conversion from the large-page entries to 4k PTEs.  The PAT and PSE bits
cause a bit of trouble here.

IOW, it would make the call-sites look cleaner, but it largely just
shifts the complexity elsewhere.  But, either way, it's all contained to
kaiser.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
