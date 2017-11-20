Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C70F86B0069
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:47:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j16so10528568pgn.14
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:47:17 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d124si5061854pgc.520.2017.11.20.12.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 12:47:16 -0800 (PST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7D84E21986
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:47:16 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id n134so13587675itg.1
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:47:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711202115190.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 20 Nov 2017 12:46:55 -0800
Message-ID: <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com>
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Mon, Nov 20, 2017 at 12:22 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Fri, 10 Nov 2017, Dave Hansen wrote:
>>       __set_fixmap(get_cpu_gdt_ro_index(cpu), get_cpu_gdt_paddr(cpu), prot);
>> +
>> +     /* CPU 0's mapping is done in kaiser_init() */
>> +     if (cpu) {
>> +             int ret;
>> +
>> +             ret = kaiser_add_mapping((unsigned long) get_cpu_gdt_ro(cpu),
>> +                                      PAGE_SIZE, __PAGE_KERNEL_RO);
>> +             /*
>> +              * We do not have a good way to fail CPU bringup.
>> +              * Just WARN about it and hope we boot far enough
>> +              * to get a good log out.
>> +              */
>
> The GDT fixmap can be set up before the CPU is started. There is no reason
> to do that in cpu_init().
>
>> +
>> +     /*
>> +      * We could theoretically do this in setup_fixmap_gdt().
>> +      * But, we would need to rewrite the above page table
>> +      * allocation code to use the bootmem allocator.  The
>> +      * buddy allocator is not available at the time that we
>> +      * call setup_fixmap_gdt() for CPU 0.
>> +      */
>> +     kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
>> +                               __PAGE_KERNEL_RO | _PAGE_GLOBAL);
>
> This one is needs to stay.

When you rebase on to my latest version, this should change to mapping
the entire cpu_entry_area.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
